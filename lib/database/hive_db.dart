import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:uuid/uuid.dart';

import '../models/data_model.dart';
import '../models/update_model.dart';
import '../models/sync_model.dart';
import './database_mgr.dart';

class HiveConnector {
  late Box<dynamic> _settingBox;
  late Box<dynamic> _serverBox;
  late Box<AppUser> _userBox;
  late Box<Book> _bookBox;
  late Box<Recipe> _recipeBox;
  late Box<OperationQueue> _queueBox;
  late Box<Operation> _queueOperationBox;
  late Box<String> _changeBox;

  HiveConnector();

  Future<void> initialize() async {
    if (!kIsWeb) {
      final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
      Hive
        ..init(appDocumentDir.path)
        ..registerAdapter(AppUserAdapter())
        ..registerAdapter(BookAdapter())
        ..registerAdapter(VariantAdapter())
        ..registerAdapter(IngredientAdapter())
        ..registerAdapter(TagAdapter())
        ..registerAdapter(RecipeStepAdapter())
        ..registerAdapter(RecipeAdapter())
        ..registerAdapter(UserUpdateAdapter())
        ..registerAdapter(BookUpdateAdapter())
        ..registerAdapter(RecipeUpdateAdapter())
        ..registerAdapter(OperationTypeAdapter())
        ..registerAdapter(OperationAdapter())
        ..registerAdapter(OperationQueueAdapter());
    }

    _settingBox = await Hive.openBox('settings');
    _serverBox = await Hive.openBox('server');
    _userBox = await Hive.openBox('user');
    _bookBox = await Hive.openBox('books');
    _recipeBox = await Hive.openBox('recipes');
    _queueBox = await Hive.openBox('queue');
    _queueOperationBox = await Hive.openBox('queueOperations');
    _changeBox = await Hive.openBox('changes');

    if (_queueBox.isEmpty) {
      _queueBox.add(OperationQueue());
    }
    if (kDebugMode) print('Hive initialized');
  }

  void clearAll() {
    _userBox.clear();
    _bookBox.clear();
    _recipeBox.clear();
  }


  // SETTINGS
  void saveTheme(int id) {
    _settingBox.put('theme', id);
  }

  int? loadTheme() {
    var themeId = _settingBox.get('theme');
    if (themeId is int) {
      return themeId;
    }

    return null;
  }

  void saveLocale(String locale) {
    _settingBox.put('locale', locale);
  }

  String? loadLocale() {
    var locale = _settingBox.get('locale');
    if (locale is String) {
      return locale;
    }

    return null;
  }

  void saveWakelock(bool activated) {
    _settingBox.put('wakelock', activated);
  }

  bool? loadWakelock() {
    var activated = _settingBox.get('wakelock');
    if (activated is bool) {
      return activated;
    }

    return null;
  }

  void saveCurrentBook(String id) {
    _settingBox.put('currentBook', id);
  }

  String? loadCurrentBook() {
    var currentBook = _settingBox.get('currentBook');
    if (currentBook is String) {
      return currentBook;
    }

    return null;
  }

  // SERVER
  void saveServerUri(String uri) {
    try {
      _serverBox.put('uri', uri);
    } on Exception catch(e) {
      throw Exception(e);
    }
  }

  String? getServerUri() {
    try {
      return _serverBox.get('uri');
    } on Exception {
      return null;
    }
  }

  void saveCredentials(String cred) {
    try {
      _serverBox.put('credentials', cred);
    } on Exception catch(e) {
      throw Exception(e);
    }
  }

  String? getCredentials() {
    try {
      return _serverBox.get('credentials');
    } on Exception {
      return null;
    }
  }
  
  // USER //
  Future<void> setUser(AppUser appUser) async {
    try {
      await _userBox.clear();
      await _userBox.add(appUser);
    } on Exception catch(e) {
      throw Exception(e);
    }
  }

  AppUser? getUser() {
    try {
      if (_userBox.length > 0) {
        var appUser = _userBox.getAt(0);
        if (appUser is AppUser) {
          return appUser;
        }
      }
    } on Exception catch(e) {
      throw Exception(e);
    }

    return null;
  }

  void updateUser({String? name, String? email, List<String>? favoriteRecipes, bool addToQueue=true}) async {
    AppUser? user = getUser();

    if (user != null) {
      if (name != null || email != null || favoriteRecipes != null) {
        UserUpdate userUpdate = UserUpdate(id: user.id);
        if (name != null) {
          userUpdate.name = name;
          user.name = name;
        }
        if (email != null) {
          userUpdate.email = email;
          user.email = email;
        }
        if (favoriteRecipes != null) {
          userUpdate.favoriteRecipes = favoriteRecipes;
          user.favoriteRecipes = favoriteRecipes;
        }

        await user.save();

        if (addToQueue) {
          addQueueOperation(type: OperationType.update, object: userUpdate);
        }
      }
    }
  }

  String getUserName() {
    AppUser? user = getUser();
    if (user != null) {
      return user.name;
    }
    return '';
  }

  String? getUserUid() {
    AppUser? user = getUser();
    if (user != null) {
      return user.id;
    }
    return null;
  }

  void updateUserLastUpdate(String id, DateTime lastUpdate) {
    AppUser? user = getUser();

    if (user != null) {
      user.lastUpdate = lastUpdate; 
      user.save();
    }
  }

  // BOOK //
  Book? getBook(String bookUid) {
    try {
      Book? book = _bookBox.get(bookUid);
      if (book != null) {
        return book;
      }
    } on Exception catch(e) {
      throw Exception(e);
    }

    return null;
  }

  List<Book> getUserBooks({bool getOwnedOnly = false}) {
    String? userUid = getUserUid();
    if (userUid != null) {
      try {
        final List<Book> userBooks = [];
        _bookBox.values.forEach((book) {
          if (book is Book) {
            print(book.users);
            if (book.users.contains(userUid)) {
              if (getOwnedOnly) {
                if (book.access[userUid] != null && book.access[userUid]! > 1) {
                  userBooks.add(book);
                }
              }
              else {
                userBooks.add(book);
              }
            }
          }
        });

        return userBooks;
      } on Exception catch(e) {
        throw Exception(e);
      }
    }
    else {
      print('Disconnected');
      return [];
    }
  }

  void addNewBook(String name) {
    AppUser? user = getUser();
    if (user == null) {
      return;
    }
    Book book = Book(id: const Uuid().v4(), name: name, recipeUids: [], users: [user.id], access: {user.id: 2});
    addBook(book);
  }

  void addBook(Book book, {bool addToQueue=true}) {
    try {
      _bookBox.add(book);
      saveCurrentBook(book.id);

      if (addToQueue) {
        addQueueOperation(type: OperationType.create, object: book);
      }
    } on Exception catch(e) {
      throw Exception(e);
    }
  }

  void updateBook(String id, BookUpdate bookUpdate, {bool addToQueue=true}) async {
    Book book = _bookBox.values.firstWhere((book) => book.id == id);

    book.copyFromUpdate(bookUpdate);
    print(book.toJson());
    await book.save();

    if (addToQueue) {
      addQueueOperation(type: OperationType.update, object: bookUpdate);
    }
  }

  void deleteBook(String id) {
    try {
      _bookBox.values.firstWhere((book) => book.id == id)
        .delete();
    } on Exception catch(e) {
      throw Exception(e);
    }
  }

  Future<void> clearBooks() async {
    try {
      await _bookBox.clear();
    } on Exception catch(e) {
      throw Exception(e);
    }
  }

  void updateBookId(String id, String newId) {
    Book book = _bookBox.values.firstWhere((book) => book.id == id);
    book.id = newId;
    book.save();

    String? currentBookId = loadCurrentBook();
    if (currentBookId != null && currentBookId == id) {
      saveCurrentBook(newId);
    }
  }

  void updateBookFromDict(Map<String, dynamic> data) {
    Book book = _bookBox.values.firstWhere((book) => book.id == data['id']);

    if (data.keys.contains('name')) {
      book.name = data['name'];
    }
    if (data.keys.contains('recipeUids')) {
      book.recipeUids = List<String>.from(data['recipeUids']);
    }
    if (data.keys.contains('users')) {
      book.users = List<String>.from(data['users']);
    }
    if (data.keys.contains('access')) {
      book.access = Map<String, int>.from(data['access']);
    }
    if (data.keys.contains('lastUpdate')) {
      book.lastUpdate = DateTime.parse(data['lastUpdate']);
    }
    
    book.save();
  }

  void updateBookLastUpdate(String id, DateTime lastUpdate) {
    Book book = _bookBox.values.firstWhere((book) => book.id == id);
    book.lastUpdate = lastUpdate;
    book.save();
  }


  // RECIPE //
  Recipe? getRecipe(String recipeUid) {
    Recipe? recipe = _recipeBox.get(recipeUid);
    if (recipe != null) {
      return recipe;
    }

    return null;
  }

  List<Recipe> getRecipesFromBook(String bookUid) {
    List<Recipe> recipes = [];

    Book? book = getBook(bookUid);
    if (book != null) {
      for (String recipeUid in book.recipeUids) {
        Recipe? recipe = getRecipe(recipeUid);
        if (recipe != null) {
          recipes.add(recipe);
        }
      }
    }

    return recipes;
  }

  List<Recipe> getAllRecipes() {
    List<Recipe> recipes = [];

    for (Recipe recipe in _recipeBox.values) {
      recipes.add(recipe);
    }

    return recipes;
  }

  Recipe addRecipe({String name="", bool addToQueue=true}) {
    try {
      Recipe recipe = Recipe(id: const Uuid().v4(), name: name, preparationTime: 0, cookingTime: 0, waitingTime: 0, tags: [], quantity: 0, recipeIngredients: [], steps: [], creationDate: DateTime.now());
      _recipeBox.add(recipe);

      if (addToQueue) {
        addQueueOperation(type: OperationType.create, object: recipe);
      }

      return recipe;
    } on Exception catch(e) {
      throw Exception(e);
    }
  }

  void updateRecipe(String id, RecipeUpdate recipeUpdate, {bool addToQueue=true}) async {
    try {
      Recipe recipe = _recipeBox.values.firstWhere((recipe) => recipe.id == id);
      recipe.copyFromUpdate(recipeUpdate);
      print(recipe.toJson());
      await recipe.save();
    }
    catch (e) {
      try {
        Recipe recipe = _recipeBox.values.firstWhere((recipe) => recipe.initId == id);
        recipe.copyFromUpdate(recipeUpdate);
        recipeUpdate.id = recipe.id;
        print(recipe.toJson());
        await recipe.save();
      }
      catch (e) {
        print(e);
        return;
      }
    }

    if (addToQueue) {
      addQueueOperation(type: OperationType.update, object: recipeUpdate);
    }
  }

  void updateRecpeFromDict(Map<String, dynamic> data) {
    Recipe recipe = _recipeBox.values.firstWhere((recipe) => recipe.id == data['id']);
    if (data.keys.contains('name')) {
      recipe.name = data['name'];
    }
    if (data.keys.contains('pictures')) {
      recipe.pictures = List<String>.from(data['pictures']);
    }
    if (data.keys.contains('preparationTime')) {
      recipe.preparationTime = data['preparationTime'];
    }
    if (data.keys.contains('cookingTime')) {
      recipe.cookingTime = data['cookingTime'];
    }
    if (data.keys.contains('waitingTime')) {
      recipe.waitingTime = data['waitingTime'];
    }
    if (data.keys.contains('tags')) {
      recipe.tags = List<String>.from(data['tags']);
    }
    if (data.keys.contains('quantity')) {
      recipe.quantity = data['quantity'];
    }
    if (data.keys.contains('quantityType')) {
      recipe.quantityType = data['quantityType'];
    }
    if (data.keys.contains('steps')) {
      recipe.steps = List<RecipeStep>.from(data['steps']);
    }
    if (data.keys.contains('variants')) {
      recipe.variants = List<Variant>.from(data['variants']);
    }
    if (data.keys.contains('lastUpdate')) {
      recipe.lastUpdate = DateTime.parse(data['lastUpdate']);
    }
    
    recipe.save();
  }

  void updateRecipeId(String id, String newId) {
    print(id);
    print(newId);
    Recipe recipe = _recipeBox.values.firstWhere((recipe) => recipe.id == id);
    recipe.id = newId;
    recipe.isDirty = false;
    recipe.save();
  }

  void updateRecipeLastUpdate(String id, DateTime lastUpdate) {
    Recipe recipe = _recipeBox.values.firstWhere((recipe) => recipe.id == id);
    recipe.lastUpdate = lastUpdate;
    recipe.save();
  }

  void saveRecipe(Recipe recipe) {
    try {
      recipe.save();
    } on Exception catch(e) {
      throw Exception(e);
    }
  }

  void deleteRecipe(String id) {
    try {
      _recipeBox.values.firstWhere((recipe) => recipe.id == id)
        .delete();
    } on Exception catch(e) {
      throw Exception(e);
    }
  }

  void clearRecipes() {
    try {
      _recipeBox.clear();
    } on Exception catch(e) {
      throw Exception(e);
    }
  }

  // QUEUE //

  Operation? getOperationFromId(String id) {
    Operation? ope;
    int index = 0;
    for (Operation item in _queueOperationBox.values) {
      if (item.id == id) {
        ope = item;
        break;
      }
      index += 1;
    }

    if (ope != null) {
      _queueOperationBox.deleteAt(index);
      return ope;
    }

    return null;
  }

  void addQueueOperation({required OperationType type, required DatabaseObject object, bool pushAfter=true}) {
    OperationQueue queue = _queueBox.getAt(0)!;

    Operation ope = Operation(id: const Uuid().v4(), type: type, object: object);
    _queueOperationBox.add(ope);

    queue.addOperation(ope.id);

    if (DatabaseMgr().isOnline) {
      if (pushAfter) {
        DatabaseMgr().synchronization.pushQueue();
      }
    }
  }

  Operation? getFirstOperation() {
    OperationQueue queue = _queueBox.getAt(0)!;
    String? operationId = queue.getFirstOperationId();

    if (operationId != null) {
      print(operationId);
      Operation? ope = getOperationFromId(operationId);
      if (ope != null) {
        return ope;
      }
    }

    return null;
  }

  int getQueueLength() {
    OperationQueue queue = _queueBox.getAt(0)!;
    return queue.length();
  }

  int getOperationLength() {
    return _queueOperationBox.length;
  }

  int getBooksNum() {
    return _bookBox.length;
  }

  // Changes
  String createChange() {
    String change = const Uuid().v4();
    return change;
  }

  void addChange(String change) {
    _changeBox.add(change);
  }

  String? getLastChange() {
    int lastIndex = _changeBox.length - 1;
    if (lastIndex >= 0) {
      String? lastChange = _changeBox.getAt(lastIndex);
      if (lastChange != null){
        return lastChange;
      }
    }
    return null;
  }
}