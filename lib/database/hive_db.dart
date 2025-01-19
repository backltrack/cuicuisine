import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:objectid/objectid.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import '../models/data_model.dart';
import '../models/update_model.dart';
import '../models/sync_model.dart';
import './database_mgr.dart';
import 'file_storage.dart';

class HiveConnector {
  late Box<dynamic> _settingBox;
  late Box<dynamic> _serverBox;
  late Box<AppUser> _userBox;
  late Box<Book> _bookBox;
  late Box<Recipe> _recipeBox;
  late Box<OperationQueue> _queueBox;
  late Box<Operation> _queueOperationBox;
  late Box<String> _changeBox;
  late Box<dynamic> _contextBox;
  late Box<dynamic> _bookIngredientsBox;
  FileStorage fileStorage = FileStorage();

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
        ..registerAdapter(OperationQueueAdapter())
        ..registerAdapter(RecipeImageAdapter())
        ..registerAdapter(AccessLevelAdapter());
    }

    _settingBox = await Hive.openBox('settings');
    _serverBox = await Hive.openBox('server');
    _userBox = await Hive.openBox('user');
    _bookBox = await Hive.openBox('books');
    _recipeBox = await Hive.openBox('recipes');
    _queueBox = await Hive.openBox('queue');
    _queueOperationBox = await Hive.openBox('queueOperations');
    _changeBox = await Hive.openBox('changes');
    _contextBox = await Hive.openBox('context');
    _bookIngredientsBox = await Hive.openBox('bookIngredients');

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

  void saveBookSharingAgreement(bool isValid) {
    _settingBox.put('bookSharing', isValid);
  }

  bool? loadBookSharingAgreement() {
    var isValid = _settingBox.get('bookSharing');
    if (isValid is bool) {
      return isValid;
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

  void deleteCredentials() {
    _serverBox.delete('credentials');
    _userBox.clear();
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

  String? getUserId() {
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

  void toggleFavorite(String recipeId) {
    AppUser? user = getUser();
    if (user != null) {
      if (user.favoriteRecipes.contains(recipeId)) {
        List<String> list = [...user.favoriteRecipes];
        list.remove(recipeId);
        updateUser(favoriteRecipes: list);
      }
      else {
        updateUser(favoriteRecipes: [...user.favoriteRecipes, recipeId]);
      }
    }
  }

  // BOOK //
  Book? getBook(String bookId) {
    try {
      Book? book = _bookBox.values.firstWhere((book) => book.id == bookId);
      return book;
    } on Exception {
      return null;
    }
  }

  List<Book> getUserBooks({bool getOwnedOnly = false}) {
    String? userId = getUserId();
    if (userId != null) {
      try {
        final List<Book> userBooks = [];
        _bookBox.values.forEach((book) {
            print(book.users);
            if (book.users.contains(userId)) {
              if (getOwnedOnly) {
                if (book.access[userId] != null && book.access[userId]!.index >= AccessLevel.write.index) {
                  userBooks.add(book);
                }
              }
              else {
                userBooks.add(book);
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

  String? addNewBook(String name) {
    AppUser? user = getUser();
    if (user == null) {
      return null;
    }
    Book book = Book(id: ObjectId().hexString, name: name, recipeIds: [], users: [user.id], access: {user.id: AccessLevel.own});
    addBook(book);

    return book.id;
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
    
    await book.save();

    if (addToQueue) {
      addQueueOperation(type: OperationType.update, object: bookUpdate);
    }
  }

  AccessLevel? getUserAccess(String bookId) {
    Book? book = getBook(bookId);
    if (book != null) {
      AccessLevel? access = book.access[getUserId()];
      if (access != null) {
        return access;
      }
    }
    return null;
  }

  Future<void> updateTagsAndIngredients() async {
    List<String> tags = [];
    List<String> ingredients = [];

    _bookIngredientsBox.clear();

    String? currentBookId = loadCurrentBook();
    if (currentBookId != null) {
      Book? book = getBook(currentBookId);
      if (book != null) {
        List<String> recipeIds = book.recipeIds;
        for (String recipeId in recipeIds) {
          Recipe? recipe = getRecipe(recipeId);
          if (recipe != null) {
            for (String tag in recipe.tags) {
              if (!tags.contains(tag)) {
                tags.add(tag);
              }
            }
            for (Ingredient ingredient in recipe.recipeIngredients) {
              if (!ingredients.contains(ingredient.name.trim().toLowerCase())) {
                ingredients.add(ingredient.name.trim().toLowerCase());
              }
              if (!_bookIngredientsBox.values.contains(ingredient.name.trim().toLowerCase())) {
                _bookIngredientsBox.add(ingredient.name.trim().toLowerCase());
              } 
            }
          }
        }
        await _contextBox.clear();
        await _contextBox.put('tags', tags);
        await _contextBox.put('ingredients', ingredients);
      }
    }
  }

  List<String> getBookTags() {
    var tags = _contextBox.get('tags');
    if (tags != null) {
      return List<String>.from(tags);
    }
    return [];
  }

  List<String> getBookIngredients() {
    var ingredients = _contextBox.get('ingredients');
    if (ingredients != null) {
      return List<String>.from(ingredients);
    }
    return [];
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

  void updateBookLastUpdate(String id, DateTime lastUpdate) {
    Book book = _bookBox.values.firstWhere((book) => book.id == id);
    book.lastUpdate = lastUpdate;
    book.save();
  }

  void updateBookFromDict(Map<String, dynamic> data) {
    Book book = _bookBox.values.firstWhere((book) => book.id == data['id']);

    if (data.keys.contains('name')) {
      book.name = data['name'];
    }
    if (data.keys.contains('recipeIds')) {
      book.recipeIds = List<String>.from(data['recipeIds']);
    }
    if (data.keys.contains('users')) {
      book.users = List<String>.from(data['users']);
    }
    if (data.keys.contains('access')) {
      Map<String, AccessLevel> _access = {};
      for (String userId in data['access'].keys.toList()) {
        _access[userId] = AccessLevel.values[data['access'][userId]];
      }
      book.access = _access;
    }
    if (data.keys.contains('lastUpdate')) {
      book.lastUpdate = DateTime.parse(data['lastUpdate']);
    }
    
    book.save();
  }

  void addUserToBook(Book book) {
    DatabaseMgr().localMgr.updateBook(book.id, 
      BookUpdate(
        id: book.id,
        users: List.from(book.users)..add(DatabaseMgr().localMgr.getUserId()!)
      )
    );
  }

  void removeUserFromBook(Book book) {
    DatabaseMgr().localMgr.updateBook(
      book.id,
      BookUpdate(
        id: book.id,
        users: List.from(book.users)..remove(DatabaseMgr().localMgr.getUserId()),
        access: Map.from(book.access)..removeWhere((key, value) => key == DatabaseMgr().localMgr.getUserId())
      )
    );
  }

  bool removeOtherUserFromBook(String userId, Book book) {
    if (book.access[DatabaseMgr().localMgr.getUserId()] == AccessLevel.own) {
      DatabaseMgr().localMgr.updateBook(
        book.id,
        BookUpdate(
          id: book.id,
          users: List.from(book.users)..remove(userId),
          access: Map.from(book.access)..removeWhere((key, value) => key == userId)
        )
      );
      return true;
    } 
    
    return false;
  }

  bool updateUserAccess(Book book, String userId, AccessLevel value) {
    if (book.access[DatabaseMgr().localMgr.getUserId()] == AccessLevel.own) {
      Map<String, AccessLevel> _newAccess = Map.from(book.access);
      _newAccess[userId] = value;

      DatabaseMgr().localMgr.updateBook(
        book.id,
        BookUpdate(
          id: book.id,
          access: _newAccess
        )
      );
      return true;
    } 
    
    return false;
  }

  void deleteBook(String id, {bool addToQueue=true}) {
    try {
      Book book = _bookBox.values.firstWhere((book) => book.id == id);
      Book bookCopy = Book.fromBookCopy(book);
      book.delete();

      if (addToQueue) {
        addQueueOperation(type: OperationType.delete, object: bookCopy);
      }

      for (String recipeId in bookCopy.recipeIds) {
        deleteRecipe(recipeId);
      }

    } on StateError {
      print("book not found");
      return;
    }
  }


  // RECIPE //
  Recipe? getRecipe(String recipeId) {
    try {
      Recipe? recipe = _recipeBox.values.firstWhere((recipe) => recipe.id == recipeId);
      return recipe;
    }
    on StateError {
      return null;
    }
  }

  List<Recipe> getRecipesFromBook(String bookId) {
    List<Recipe> recipes = [];

    Book? book = getBook(bookId);
    print("$bookId => $book");
    if (book != null) {
      for (String recipeId in book.recipeIds) {
        Recipe? recipe = getRecipe(recipeId);
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

  void addRecipe(Recipe recipe, {bool addToQueue=true}) {
    try {
      _recipeBox.add(recipe);

      if (addToQueue) {
        addQueueOperation(type: OperationType.create, object: recipe);
      }
      else {
        // if not, the recipe is fetched from more recent: not dirty
        recipe.isDirty = false;
        recipe.save();
      }
    } on Exception catch(e) {
      throw Exception(e);
    }
  }

  String addNewRecipe({String name="", required String bookId}) {
    Recipe recipe = Recipe(id: ObjectId().hexString, name: name, preparationTime: 0, cookingTime: 0, waitingTime: 0, tags: [], quantity: 2, recipeIngredients: [], steps: [], creationDate: DateTime.now());
    addRecipe(recipe);

    Book? book = getBook(bookId);
    if (book != null) {
      updateBook(bookId, BookUpdate(id: bookId, recipeIds: [...book.recipeIds, recipe.id]), addToQueue: false);
    }

    return recipe.id;
  }

  void updateRecipe(String id, RecipeUpdate recipeUpdate, {bool addToQueue=true}) async {
    try {
      Recipe recipe = _recipeBox.values.firstWhere((recipe) => recipe.id == id);
      recipe.copyFromUpdate(recipeUpdate);
      recipe.isDirty = true;
      print(recipe.toJson());
      await recipe.save();
    }
    catch (e) {
      print(e);
      return;
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
    recipe.isDirty = false;
    recipe.save();
  }

  void duplicateRecipe(Recipe recipe, String destinationBookId) async {
    String newRecipeId = addNewRecipe(name: recipe.name, bookId: destinationBookId);
    
    List<String> duplicatedImages = [];
    for (String imageId in recipe.pictures) {
      duplicatedImages.add(await duplicateImage(recipe.id, imageId, newRecipeId));
    }
    
    updateRecipe(newRecipeId, 
      RecipeUpdate(
        id: newRecipeId,
        name: recipe.name,
        preparationTime: recipe.preparationTime,
        waitingTime: recipe.waitingTime,
        cookingTime: recipe.cookingTime,
        pictures: duplicatedImages,
        quantity: recipe.quantity,
        quantityType: recipe.quantityType,
        recipeIngredients: recipe.recipeIngredients,
        steps: recipe.steps,
        tags: recipe.tags,
        variants: recipe.variants
      )
    );
  }

  void deleteRecipe(String id, {bool addToQueue=true}) {
    try {
      Recipe recipe = _recipeBox.values.firstWhere((recipe) => recipe.id == id);
      Recipe recipeCopy = Recipe.fromRecipeCopy(recipe);
      recipe.delete();

      if (addToQueue) {
        addQueueOperation(type: OperationType.delete, object: recipeCopy);
      }

    } on StateError {
      print("recipe not found");
      return;
    }
  }

  void clearRecipes() {
    _recipeBox.clear();
  }

  Future<List<String>> saveRecipeImages(List<XFile> images, String recipeId) async {
    List<String> newPictures = [];
    for (XFile image in images) {
      final String newImageId = ObjectId().hexString;
      String? newPath = await fileStorage.writeImage(image: image, recipeId: recipeId, imageId: newImageId);
      if (newPath != null) {
        newPictures.add(newImageId);

        addQueueOperation(type: OperationType.create, object: RecipeImage(path: newPath, recipeId: recipeId, imageId: newImageId));
      }
    }
    return newPictures;
  }

  Future<bool> removeRecipeImage(String recipeId, String imageId) async {
    Recipe? recipe = getRecipe(recipeId);
    if (recipe != null) {
      if (recipe.pictures.contains(imageId)) {
        bool result = await fileStorage.deleteImage(recipeId: recipeId, imageId: imageId);
        if (result) {
          addQueueOperation(type: OperationType.delete, object: RecipeImage(path: fileStorage.idToPath(recipeId: recipeId, imageId: imageId), recipeId: recipeId, imageId: imageId));
        }
        return true;
      }
    }
    return false;
  }

  Future<String> duplicateImage(String recipeId, String imageId, String newRecipeId) async {
    String path = fileStorage.idToPath(recipeId: recipeId, imageId: imageId);
    XFile file = XFile(path);

    String newImageId = ObjectId().hexString;
    await fileStorage.writeImage(image: file, recipeId: newRecipeId, imageId: newImageId);
    return newImageId;
  }

  Future<void> putPicturesToStorage(List<XFile> images, String recipeId) async {
    Recipe? recipe = getRecipe(recipeId);
    if (recipe != null) {
      List<String> newPictures = await saveRecipeImages(images, recipeId);
      
      if (newPictures.isNotEmpty) {
        updateRecipe(
          recipeId,
          RecipeUpdate(
            id: recipeId,
            pictures: [...recipe.pictures] + newPictures
          )
        );
      }
    }
  }

  Future<void> removePictureFromStorage(String recipeId, String imageId) async {
    bool result  = await removeRecipeImage(recipeId, imageId);
    if (result) {
      Recipe? recipe = getRecipe(recipeId);
      if (recipe != null) {
        recipe.pictures.remove(imageId);
        updateRecipe(
          recipeId,
          RecipeUpdate(
            id: recipeId,
            pictures: recipe.pictures
          )
        );
      }
    }
  }

  Future<Image> getRecipeImage(String recipeId, imageId) async {
    Image? image = await fileStorage.readImage(recipeId: recipeId, imageId: imageId);
    if (image != null) {
      return image;
    }
    return Image.asset("assets/images/default_image.png");
  }

  Future<List<Image>> getRecipeImages(String recipeId) async {
    Recipe? recipe = getRecipe(recipeId);
    if (recipe != null) {
      List<Image> images = [];
      for (String id in recipe.pictures) {
        images.add(await getRecipeImage(recipeId, id));
      }

      return images;
    }
    return [];
  }

  Future<Image> getFirstRecipeImage(String recipeId) async {
    Recipe? recipe = getRecipe(recipeId);
    if (recipe != null) {
      if (recipe.pictures.isNotEmpty) {
        return await getRecipeImage(recipeId, recipe.pictures[0]);
      }
    }
    return Image.asset("assets/images/default_image.png");
  }

  Future<void> cleanExtraImages(Recipe recipe) async {
    List<String> allRecipeImages = await fileStorage.getAllRecipeImages(recipe.id);
    for (String path in allRecipeImages) {
      Map<String, String>? ids = fileStorage.pathToId(path);
      if (ids != null && ids.containsKey('imageId')) {
        if (!recipe.pictures.contains(ids['imageId'])) {
          await fileStorage.deleteImage(recipeId: recipe.id, imageId: ids['imageId']!);
        }
      }
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

    Operation ope = Operation(id: ObjectId().hexString, type: type, object: object);
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
    String change = ObjectId().hexString;
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