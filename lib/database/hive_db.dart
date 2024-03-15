import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import '../../models/model.dart';

class HiveConnector {
  late Box<dynamic> _settingBox;
  late Box<dynamic> _serverBox;
  late Box<dynamic> _userBox;
  late Box<dynamic> _bookBox;
  late Box<dynamic> _recipeBox;

  HiveConnector();

  Future<void> initialize() async {
    if (!kIsWeb) {
      final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
      Hive
        ..init(appDocumentDir.path)
        ..registerAdapter(AppUserAdapter())
        ..registerAdapter(BookAdapter())
        ..registerAdapter(RecipeAdapter())
        ..registerAdapter(VariantAdapter())
        ..registerAdapter(RecipeStepAdapter())
        ..registerAdapter(IngredientAdapter())
        ..registerAdapter(TagAdapter());
    }

    _settingBox = await Hive.openBox('settings');
    _serverBox = await Hive.openBox('server');
    _userBox = await Hive.openBox('user');
    _bookBox = await Hive.openBox('books');
    _recipeBox = await Hive.openBox('recipes');
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
  void setUser(AppUser appUser) {
    try {
      _userBox.clear();
      _userBox.add(appUser);
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

  void addBook(Book book) {
    try {
      _bookBox.add(book);
    } on Exception catch(e) {
      throw Exception(e);
    }
  }

  void saveBook(Book book) {
    try {
      book.save();
    } on Exception catch(e) {
      throw Exception(e);
    }
  }

  void deleteBook(String id) {
    try {
      _bookBox.delete(id);
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

  // addUserToBook

  // RECIPE //
  Recipe? getRecipe(String recipeUid) {
    try {
      Recipe? recipe = _bookBox.get(recipeUid);
      if (recipe != null) {
        return recipe;
      }
    } on Exception catch(e) {
      throw Exception(e);
    }

    return null;
  }

  void addRecipe(Recipe recipe) {
    try {
      _recipeBox.add(recipe);
    } on Exception catch(e) {
      throw Exception(e);
    }
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
      _recipeBox.delete(id);
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
}