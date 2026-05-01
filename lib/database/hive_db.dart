import 'dart:convert';
import 'dart:io';

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
  late Box<dynamic> _webImagesBox;
  FileStorage fileStorage = FileStorage();

  HiveConnector();

  Future<void> initialize() async {
    if (!kIsWeb) {
      if (Platform.isLinux) {
        Hive.init('${Platform.environment['HOME']}/.local/share/com.example.cuicuisine/hive');
      }
      else {
        final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
        Hive.init(appDocumentDir.path);
      }
    }
    Hive
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

    _settingBox = await Hive.openBox('settings');
    _serverBox = await Hive.openBox('server');
    _userBox = await Hive.openBox('user');
    _bookBox = await Hive.openBox('books');
    _recipeBox = await Hive.openBox('recipes');
    _queueBox = await Hive.openBox('queue');
    _queueOperationBox = await Hive.openBox('queueOperations');
    _changeBox = await Hive.openBox('changes');
    _contextBox = await Hive.openBox('context');
    _webImagesBox = await Hive.openBox('webImages');

    if (_queueBox.isEmpty) {
      await _queueBox.add(OperationQueue());
    }
    if (kDebugMode) print('Hive initialized');
  }

  Future<void> clearAllUserData() async {
    await _userBox.clear();
    await _bookBox.clear();
    await _recipeBox.clear();
    await _queueBox.clear();
    await _queueOperationBox.clear();
    await _changeBox.clear();
    await _contextBox.clear();
    await _webImagesBox.clear();

    if (_queueBox.isEmpty) {
      await _queueBox.add(OperationQueue());
    }
  }


  // SETTINGS
  Future<void> saveTheme(int id) async {
    await _settingBox.put('theme', id);
  }

  int? loadTheme() {
    var themeId = _settingBox.get('theme');
    if (themeId is int) {
      return themeId;
    }

    return null;
  }

  Future<void> saveLocale(String locale) async {
    await _settingBox.put('locale', locale);
  }

  String? loadLocale() {
    var locale = _settingBox.get('locale');
    if (locale is String) {
      return locale;
    }

    return null;
  }

  Future<void> saveWakelock(bool activated) async {
    await _settingBox.put('wakelock', activated);
  }

  bool? loadWakelock() {
    var activated = _settingBox.get('wakelock');
    if (activated is bool) {
      return activated;
    }

    return null;
  }

  Future<void> saveCurrentBookId(String id) async {
    await _settingBox.put('currentBook', id);
  }

  String? getCurrentBookId() {
    var currentBook = _settingBox.get('currentBook');
    if (currentBook is String) {
      return currentBook;
    }

    return null;
  }

  Future<void> saveBookSharingAgreement(bool isValid) async {
    await _settingBox.put('bookSharing', isValid);
  }

  bool? loadBookSharingAgreement() {
    var isValid = _settingBox.get('bookSharing');
    if (isValid is bool) {
      return isValid;
    }

    return null;
  }

  // SERVER
  Future<void> saveServerUri(String uri) async {
    try {
      await _serverBox.put('uri', uri);
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

  Future<void> saveCredentials(String cred) async {
    try {
      await _serverBox.put('credentials', cred);
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

  Future<void> deleteCredentials() async {
    await _serverBox.delete('credentials');
    await _userBox.clear();
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

  Future<void> updateUser({String? name, String? email, List<String>? favoriteRecipes, bool addToQueue=true}) async {
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

  Future<void> updateUserLastUpdate(String id, DateTime lastUpdate) async {
    AppUser? user = getUser();

    if (user != null) {
      user.lastUpdate = lastUpdate; 
      await user.save();
    }
  }

  Future<void> toggleFavorite(String recipeId) async {
    AppUser? user = getUser();
    if (user != null) {
      if (user.favoriteRecipes.contains(recipeId)) {
        List<String> list = [...user.favoriteRecipes];
        list.remove(recipeId);
        await updateUser(favoriteRecipes: list);
      }
      else {
        await updateUser(favoriteRecipes: [...user.favoriteRecipes, recipeId]);
      }
    }
  }

  // BOOK //
  Book? getBook(String bookId) {
    try {
      Book? book = _bookBox.values.firstWhere((book) => book.id == bookId);
      return book;
    } catch (e) {
      return null;
    }
  }

  List<Book> getUserBooks({bool getWritableOnly = false}) {
    String? userId = getUserId();
    if (userId != null) {
      try {
        final List<Book> userBooks = [];
        for (var book in _bookBox.values) {
            if (book.users.contains(userId)) {
              if (getWritableOnly) {
                if (book.access[userId] != null && book.access[userId]!.index >= AccessLevel.write.index) {
                  userBooks.add(book);
                }
              }
              else {
                userBooks.add(book);
              }
            }
        }

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

  Future<String?> addNewBook(String name) async {
    AppUser? user = getUser();
    if (user == null) {
      return null;
    }
    Book book = Book(id: ObjectId().hexString, name: name, recipeIds: [], users: [user.id], access: {user.id: AccessLevel.own});
    await addBook(book);

    return book.id;
  }

  Future<void> addBook(Book book, {bool addToQueue=true}) async {
    try {
      await _bookBox.add(book);
      await saveCurrentBookId(book.id);

      if (addToQueue) {
        addQueueOperation(type: OperationType.create, object: book);
      }
    } on Exception catch(e) {
      throw Exception(e);
    }
  }

  Future<void> updateBook(String id, BookUpdate bookUpdate, {bool addToQueue=true}) async {
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

  List<Tag> getBookTags() {
    List<Tag> tags = [];

    String? currentBookId = getCurrentBookId();
    if (currentBookId != null) {
      Book? book = getBook(currentBookId);
      if (book != null) {
        tags = book.tags;
      }
    }

    return tags;
  }

  List<BookIngredient> getBookIngredients() {
    List<BookIngredient> ingredients = [];

    String? currentBookId = getCurrentBookId();
    if (currentBookId != null) {
      Book? book = getBook(currentBookId);
      if (book != null) {
        ingredients = book.bookIngredients;
      }
    }

    return ingredients;
  }

  List<Tag> getRecipeTags(String recipeId) {
    List<Tag> tags = [];

    Recipe? recipe = getRecipe(recipeId);
    if (recipe != null) {
      Book? currentBook = DatabaseMgr().localMgr.getCurrentBookId() != null ? getBook(DatabaseMgr().localMgr.getCurrentBookId()!) : null;
      if (currentBook != null && currentBook.recipeIds.contains(recipeId)) {
        for (Tag tag in currentBook.tags) {
          if (recipe.tags.contains(tag.id)) {
             tags.add(tag);
          }
        }
      }
    }

    return tags;
  }

  Future<void> clearBooks() async {
    try {
      await _bookBox.clear();
    } on Exception catch(e) {
      throw Exception(e);
    }
  }

  Future<void> updateBookId(String id, String newId) async {
    Book book = _bookBox.values.firstWhere((book) => book.id == id);
    book.id = newId;
    await book.save();

    String? currentBookId = getCurrentBookId();
    if (currentBookId != null && currentBookId == id) {
      await saveCurrentBookId(newId);
    }
  }

  Future<void> updateBookLastUpdate(String id, DateTime lastUpdate) async {
    Book book = _bookBox.values.firstWhere((book) => book.id == id);
    book.lastUpdate = lastUpdate;
    await book.save();
  }

  Future<void> updateBookFromDict(Map<String, dynamic> data) async {
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
    
    await book.save();
  }

  Future<bool> removeOtherUserFromBook(String userId, Book book) async {
    if (book.access[DatabaseMgr().localMgr.getUserId()] == AccessLevel.own) {
      await DatabaseMgr().localMgr.updateBook(
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

  Future<bool> updateUserAccess(Book book, String userId, AccessLevel value) async {
    if (book.access[DatabaseMgr().localMgr.getUserId()] == AccessLevel.own) {
      Map<String, AccessLevel> _newAccess = Map.from(book.access);
      _newAccess[userId] = value;

      await DatabaseMgr().localMgr.updateBook(
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

  Future<void> deleteBook(String id, {bool addToQueue=true}) async {
    try {
      Book book = _bookBox.values.firstWhere((book) => book.id == id);
      Book bookCopy = Book.fromBookCopy(book);
      await book.delete();

      if (addToQueue) {
        addQueueOperation(type: OperationType.delete, object: bookCopy);
      }

      for (String recipeId in bookCopy.recipeIds) {
        await deleteRecipe(recipeId);
      }

    } on StateError {
      print("book not found");
      return;
    }
  }

  Future<BookIngredient> addBookIngredient(String bookId, String name, String unit, double density) async {
    try {
      BookIngredient bookIngredient = BookIngredient(id: ObjectId().hexString, name: name, unit: unit, density: density);
      await updateBook(bookId, BookUpdate(id: bookId, bookIngredients: [...getBook(bookId)!.bookIngredients, bookIngredient]));
      return bookIngredient;
    } on Exception catch(e) {
      throw Exception(e);
    }
  }

  BookIngredient? getBookIngredient(String bookIngredientId) {
    Book? book = getBook(getCurrentBookId()!);
    if (book != null) {
      try {
        BookIngredient? bookIngredient = book.bookIngredients.firstWhere((ingredient) => ingredient.id == bookIngredientId);
        return bookIngredient;
      } on StateError {
        print("book ingredient not found");
        return null;
      }
    }
    return null;
  }

  Future<bool> deleteBookIngredient(String bookId, String bookIngredientId) async {
    try {
      Book? book = getBook(bookId);
      BookIngredient? bookIngredient = getBookIngredient(bookIngredientId);
      if (book != null && bookIngredient != null) {
        if (getIngredientsRelatedToBookIngredient(bookIngredient).isNotEmpty) {
          print("You can't delete this ingredient because it's used in a recipe");
          return false;
        }
        List<BookIngredient> updatedIngredients = List.from(book.bookIngredients)..removeWhere((ingredient) => ingredient.id == bookIngredientId);
        await updateBook(bookId, BookUpdate(id: bookId, bookIngredients: updatedIngredients));
        return true;
      }
    } on Exception catch(e) {
      throw Exception(e);
    }
    return false;
  }

  Future<void> updateBookIngredient(String bookId, String bookIngredientId, {String? name, String? unit, double? density}) async {
    try {
      Book? book = getBook(bookId);
      BookIngredient? bookIngredient = getBookIngredient(bookIngredientId);
      if (book != null && bookIngredient != null) {
        BookIngredient updatedBookIngredient = BookIngredient(
          id: bookIngredient.id,
          name: name ?? bookIngredient.name,
          unit: unit ?? bookIngredient.unit,
          density: density ?? bookIngredient.density
        );
        List<BookIngredient> updatedIngredients = List.from(book.bookIngredients)..removeWhere((ingredient) => ingredient.id == bookIngredientId)..add(updatedBookIngredient);
        await updateBook(bookId, BookUpdate(id: bookId, bookIngredients: updatedIngredients));
      }
    } on Exception catch(e) {
      throw Exception(e);
    }
  }

  List<Ingredient> getIngredientsRelatedToBookIngredient(BookIngredient bookIngredient) {
    List<Ingredient> ingredients = [];
    for (Recipe recipe in getAllRecipes()) {
      for (Ingredient ingredient in recipe.recipeIngredients) {
        if (ingredient.bookIngredientId == bookIngredient.id) {
          ingredients.add(ingredient);
        }
      }
    }
    return ingredients;
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
    Set<String> seenIds = {};

    Book? book = getBook(bookId);
    print("$bookId => $book");
    if (book != null) {
      for (String recipeId in book.recipeIds) {
        if (!seenIds.add(recipeId)) continue;
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

  Future<void> addRecipe(Recipe recipe, {bool addToQueue=true}) async {
    try {
      await _recipeBox.add(recipe);

      if (addToQueue) {
        addQueueOperation(type: OperationType.create, object: recipe);
      }
      else {
        // if not, the recipe is fetched from more recent: not dirty
        recipe.isDirty = false;
        await recipe.save();
      }
    } on Exception catch(e) {
      throw Exception(e);
    }
  }

  Future<String> addNewRecipe({String name="", required String bookId}) async {
    Recipe recipe = Recipe(id: ObjectId().hexString, name: name, preparationTime: 0, cookingTime: 0, waitingTime: 0, tags: [], quantity: 2, recipeIngredients: [], steps: [], creationDate: DateTime.now().toUtc());
    await addRecipe(recipe);

    Book? book = getBook(bookId);
    if (book != null) {
      await updateBook(bookId, BookUpdate(id: bookId, recipeIds: [...book.recipeIds, recipe.id]), addToQueue: false);
    }

    return recipe.id;
  }

  Future<void> updateRecipe(String id, RecipeUpdate recipeUpdate, {bool addToQueue=true}) async {
    try {
      Recipe recipe = _recipeBox.values.firstWhere((recipe) => recipe.id == id);
      recipe.copyFromUpdate(recipeUpdate);
      recipe.isDirty = true;
      print(recipe.toJson());
      await recipe.save();
    } catch (e) {
      print(e);
      return;
    }

    if (addToQueue) {
      addQueueOperation(type: OperationType.update, object: recipeUpdate);
    }
  }

  Future<void> updateRecipeFromDict(Map<String, dynamic> data) async {
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
    
    await recipe.save();
  }

  Future<void> updateRecipeId(String id, String newId) async {
    Recipe recipe = _recipeBox.values.firstWhere((recipe) => recipe.id == id);
    recipe.id = newId;
    recipe.isDirty = false;
    await recipe.save();
  }

  Future<void> updateRecipeLastUpdate(String id, DateTime lastUpdate) async {
    Recipe recipe = _recipeBox.values.firstWhere((recipe) => recipe.id == id);
    recipe.lastUpdate = lastUpdate;
    recipe.isDirty = false;
    await recipe.save();
  }

  Future<void> duplicateRecipe(Recipe recipe, String destinationBookId) async {
    AccessLevel? accessLevel = getUserAccess(destinationBookId);
    if (accessLevel == null || accessLevel.index == AccessLevel.read.index) {
      print("You don't have access to this book");
      return;
    }
    String newRecipeId = await addNewRecipe(name: recipe.name, bookId: destinationBookId);
    
    List<String> duplicatedImages = [];
    for (String imageId in recipe.pictures) {
      String? newImageId = await duplicateImage(recipe.id, imageId, newRecipeId);
      if (newImageId != null) {
        duplicatedImages.add(newImageId);
      }
    }
    
    await updateRecipe(newRecipeId, 
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

  Future<void> deleteRecipe(String id, {bool addToQueue=true}) async {
    try {
      Recipe recipe = _recipeBox.values.firstWhere((recipe) => recipe.id == id);
      Recipe recipeCopy = Recipe.fromRecipeCopy(recipe);
      await recipe.delete();

      if (addToQueue) {
        addQueueOperation(type: OperationType.delete, object: recipeCopy);
      }

    } on StateError {
      print("recipe not found");
      return;
    }
  }

  Future<void> clearRecipes() async {
    await _recipeBox.clear();
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

  Future<String?> duplicateImage(String recipeId, String imageId, String newRecipeId) async {
    String path = fileStorage.idToPath(recipeId: recipeId, imageId: imageId);
    XFile file = XFile(path);

    List<String> newIds = await saveRecipeImages([file], newRecipeId);
    // await fileStorage.writeImage(image: file, recipeId: newRecipeId, imageId: newImageId);
    return newIds.isNotEmpty ? newIds[0] : null;
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
        print("recipe.pictures before removal: ${recipe.pictures}");
        recipe.pictures.remove(imageId);
        print("recipe.pictures after removal: ${recipe.pictures}");
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
    print("Is image null? ${image == null}");
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
      print("recipe.pictures: ${recipe.pictures}");
      if (recipe.pictures.isNotEmpty) {
        return await getRecipeImage(recipeId, recipe.pictures[0]);
      }
    }
    return Image.asset("assets/images/default_image.png");
  }

  Future<void> cleanExtraImages(Recipe recipe) async {
    print("Cleaning extra images for recipe ${recipe.id} ($recipe.name)");
    List<String> allRecipeImages = await fileStorage.getAllRecipeImages(recipe.id);
    print("All recipe images: $allRecipeImages");
    for (String path in allRecipeImages) {
      Map<String, String>? ids = fileStorage.pathToId(path);
      print("IDs from path: $ids");
      if (ids != null && ids.containsKey('imageId')) {
        if (!recipe.pictures.contains(ids['imageId'])) {
          print("Deleting image ${ids['imageId']} from recipe ${recipe.id}");
          await fileStorage.deleteImage(recipeId: recipe.id, imageId: ids['imageId']!);
        }
      }
    }
  }

  // WEB IMAGES //
  Future<String?> writeWebImage({required XFile image, required String recipeId, required String imageId}) async {
    String imageString = await image.readAsString();
    String path = fileStorage.idToPath(recipeId: recipeId, imageId: imageId);
    await _webImagesBox.put(path, imageString);
    return path;
  }

  Future<Image?> readWebImage({required String recipeId, required String imageId}) async {
    String path = fileStorage.idToPath(recipeId: recipeId, imageId: imageId);
    if (_webImagesBox.containsKey(path)) {
      Uint8List bytes = base64.decode(_webImagesBox.get(path));
      return Image.memory(bytes);
    }
    return null;
  }

  Future<String?> writeWebImagefromBytes({required List<int> bytes, required String recipeId, required String imageId}) async {
    String path = fileStorage.idToPath(recipeId: recipeId, imageId: imageId);
    String imageString = base64.encode(bytes);
    
    await _webImagesBox.put(path, imageString);
    return path;
  }

  bool webImageExists({required String recipeId, required String imageId}) {
    String path = fileStorage.idToPath(recipeId: recipeId, imageId: imageId);
    return _webImagesBox.containsKey(path);
  }

  Future<bool> deleteWebImage({required String recipeId, required String imageId}) async {
    String path = fileStorage.idToPath(recipeId: recipeId, imageId: imageId);
    if (_webImagesBox.containsKey(path)) {
      await _webImagesBox.delete(path);
      return true;
    }
    return false;
  }

  // QUEUE //

  Future<Operation?> popOperationFromId(String id) async {
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
      await _queueOperationBox.deleteAt(index);
      return ope;
    }

    return null;
  }

  Future<void> addQueueOperation({required OperationType type, required DatabaseObject object, bool pushAfter=true}) async {
    OperationQueue queue = _queueBox.getAt(0)!;

    Operation ope = Operation(id: ObjectId().hexString, type: type, object: object);
    await _queueOperationBox.add(ope);

    queue.addOperation(ope.id);

    if (DatabaseMgr().isOnline) {
      if (pushAfter) {
        await DatabaseMgr().synchronization.pushQueue();
      }
    }
  }

  Future<Operation?> getFirstOperation() async {
    OperationQueue queue = _queueBox.getAt(0)!;
    String? operationId = queue.getFirstOperationId();

    if (operationId != null) {
      print(operationId);
      Operation? ope = await popOperationFromId(operationId);
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
    //debug purpose: to check if there is a desync between queue and operations
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