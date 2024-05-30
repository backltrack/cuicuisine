import 'dart:async';
import 'dart:io';

import 'package:cuicuisine/database/database_mgr.dart';
import 'package:cuicuisine/models/update_model.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:convert';
import 'package:oauth2/oauth2.dart' as oauth2;

import 'oauth2.dart';
import '../models/data_model.dart';

class MongoConnector {
  String server = '';
  late oauth2.Client client;
  
  MongoConnector({required this.server});

  // helper
  Future<dynamic> _secureGetRequest(String endpoint) async {
    Uri serverUri = Uri.parse(server);

    var headers = {
      'accept': 'application/json',
      'Authorization': client.credentials.accessToken
    };

    try {
      Response response = await client.get(Uri(scheme: serverUri.scheme, host: serverUri.host, port: serverUri.port, path: endpoint), 
        headers: headers);
      return response;
    } on TimeoutException catch(_) {
      DatabaseMgr().isOnline = false;
      // throw TimeoutException;
    } on SocketException catch(_) {
      DatabaseMgr().isOnline = false;
      // throw SocketException;
    }
  }

  // Future<dynamic> _secureDeleteRequest(String url) async {
  //   dynamic response;
  //   try {
  //     response = await http
  //         .delete(Uri.parse(url));
  //   } on TimeoutException catch(e) {
  //     // add pop up "check server connexion"
  //     DatabaseMgr().isOnline = false;
  //     throw Exception(e);
  //   } on SocketException catch(e) {
  //     DatabaseMgr().isOnline = false;
  //     throw Exception(e);
  //   }
  //   return response;
  // }

  Future<dynamic> _securePostJsonRequest(String endpoint, Map<String, dynamic> data) async {
    Uri serverUri = Uri.parse(server);

    var headers = {
      'accept': 'application/json',
      'Authorization': client.credentials.accessToken,
      "Content-type": "application/json"
    };

    try {
      Response response = await client.post(Uri(scheme: serverUri.scheme, host: serverUri.host, port: serverUri.port, path: endpoint),
        headers: headers,
        body: jsonEncode(data));
      return response;
    } on TimeoutException catch(_) {
      DatabaseMgr().isOnline = false;
      // throw TimeoutException;
    } on SocketException catch(_) {
      DatabaseMgr().isOnline = false;
      // throw SocketException;
    }
  }

  Future<dynamic> _securePostFormRequest(String endpoint, Map<String, dynamic> data) async {
    Uri serverUri = Uri.parse(server);

    var headers = {
      'accept': 'application/json',
      'Authorization': client.credentials.accessToken,
      // "Content-type": "application/json"
    };

    try {
      Response response = await client.post(Uri(scheme: serverUri.scheme, host: serverUri.host, port: serverUri.port, path: endpoint),
        headers: headers,
        body: data);
        // body: jsonEncode(data));
      return response;
    } on TimeoutException catch(_) {
      DatabaseMgr().isOnline = false;
      // throw TimeoutException;
    } on SocketException catch(_) {
      DatabaseMgr().isOnline = false;
      // throw SocketException;
    }
  }

  Future<dynamic> _securePutRequest(String endpoint, Object data) async {
    Uri serverUri = Uri.parse(server);

    var headers = {
      'accept': 'application/json',
      'Authorization': client.credentials.accessToken
    };

    try {
      Response response = await client.put(Uri(scheme: serverUri.scheme, host: serverUri.host, port: serverUri.port, path: endpoint),
        headers: headers,
        body: data);
      return response;
    } on TimeoutException catch(_) {
      DatabaseMgr().isOnline = false;
      // throw TimeoutException;
    } on SocketException catch(_) {
      DatabaseMgr().isOnline = false;
      // throw SocketException;
    }
  }

  // Connexion
  Future<bool> testConnexion() async {
    try {
      Response response = await http.get(Uri.parse("$server/test_connexion"),
        headers: {
          'accept': 'application/json'
      });
      DatabaseMgr().isOnline = true;
      return response.body == "true";
    } on SocketException catch (e) {
      print(e);
      DatabaseMgr().isOnline = false;
      return false;
    } on TimeoutException catch (e) {
      print(e);
      DatabaseMgr().isOnline = false;
      return false;
    }
  }

  Future<AppUser?> tryReconnect() async {
    try {
      String? savedCredentials = DatabaseMgr().localMgr.getCredentials();
      if (savedCredentials != null) {
        client = OAuth2Connexion.createClientFromCredentials(savedCredentials: savedCredentials);

        try {
          AppUser user = await fetchUser();
          await DatabaseMgr().localMgr.setUser(user);
          return user;
        }
        catch (e) {
          print('token expired');
          print(e);
          try {
            oauth2.Client? newClient = await OAuth2Connexion.refreshToken(serverUri: server, client: client);
            if (newClient != null) {
              client = newClient;
              DatabaseMgr().localMgr.saveCredentials(client.credentials.toJson());
              
              AppUser user = await fetchUser();
              await DatabaseMgr().localMgr.setUser(user);
              return user;
            }
          }
          catch (e) {
            print('lv2');
            print(e);
          }
        }
        
      }
    }
    on SocketException catch (e) {
      DatabaseMgr().isOnline = false;
      print('toast timeout');
    } on TimeoutException catch (e) {
      DatabaseMgr().isOnline = false;
      print('other exception');
    }

    return null;
  }

  Future<AppUser?> connectWithEmail(String email, String password, {Function? onInvalidEmail, Function? onInvalidPassword}) async {
    try {
      oauth2.Client? _client = await OAuth2Connexion.connectFromPassword(serverUri: server, email: email, password: password);
      if (_client != null) {
        client = _client;

        AppUser user = await fetchUser();
        await DatabaseMgr().localMgr.setUser(user);

        return user;
      }
    }
    on InvalidEmailException catch (e) {
      print(e);
      if (onInvalidEmail != null) {
        onInvalidEmail();
      }
    }
    on InvalidPasswordException catch (e) {
      print(e);
      if (onInvalidPassword != null) {
        onInvalidPassword();
      }
    }
    
    return null;
  }

  Future<AppUser?> registerWithEmail(String email, String password, {Function(AppUser)? onSuccess, Function(String)? onFailure}) async {
    try {
      oauth2.Client? _client = await OAuth2Connexion.createClientFromPassword(serverUri: server, email: email, password: password);
      if (_client != null) {
        client = _client;
        print(client.credentials.accessToken);

        AppUser user = await fetchUser();
        await DatabaseMgr().localMgr.setUser(user);

        onSuccess??(user);
        return user;
      }
    }
    on IncorrectPasswordException catch(e) {
      print(e);
      onFailure??("Incorrect password");
    }
    on EmailAlreadyExistsException catch(e) {
      onFailure??("Email already exists");
    }
    catch (e) {
      print(e);
    }
    
    return null;
  }


  // users

  Future<AppUser> fetchUser() async {

    final response = await _secureGetRequest('/users/me');

    if (response != null && response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      print(jsonDecode(response.body));
      return AppUser.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load user');
    }
  }

  Future<bool> updateUser(UserUpdate userUpdate) async {
    final response = await _securePostJsonRequest('/users/me/update', 
      userUpdate.toJson()
    );

    if (response != null && response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      try {
        dynamic data = jsonDecode(response.body);
        print(data);

        return true;
      }
      catch (e) {
        print(e);
        return false;
      }
    }
    return false;
  }


  // Book

  Future<Book> fetchBook(String bookId) async {
    final response = await _secureGetRequest('/books/get/$bookId');

    if (response != null && response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      print(jsonDecode(response.body));
      return Book.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to fetch book');
    } 
  }

  Future<bool> createBook(Book book) async {
    final response = await _securePutRequest('/books/create', 
      {
        'name': book.name
      }
    );

    if (response != null && response.statusCode == 201) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      try {
        dynamic data = jsonDecode(response.body);
        print(data);
        Book newBook = Book.fromJson(data);

        DatabaseMgr().localMgr.updateBookId(book.id, data['id']);

        return true;
      }
      catch (e) {
        print(e);
        return false;
      }
    }

    return false;
  }

  Future<bool> updateBook(BookUpdate bookUpdate) async {
    print(bookUpdate.toJson());
    final response = await _securePostJsonRequest('/books/update', 
      bookUpdate.toJson()
    );

    if (response != null && response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      try {
        dynamic data = jsonDecode(response.body);
        print(data);

        return true;
      }
      catch (e) {
        print(e);
        return false;
      }
    }

    return false;
  }


  // Recipe



  Future<Recipe> fetchRecipe(String recipeId) async {
    final response = await _secureGetRequest('/recipes/get/$recipeId');

    if (response != null && response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      print(jsonDecode(response.body));
      return Recipe.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to fetch recipe');
    } 
  }

  Future<bool> createRecipe(Recipe recipe) async {
    print(DatabaseMgr().localMgr.loadCurrentBook());
    final response = await _securePutRequest('/recipes/create', 
      {
        'name': recipe.name,
        'bookId': DatabaseMgr().localMgr.loadCurrentBook()
      }
    );

    if (response != null && response.statusCode == 201) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      try {
        dynamic data = jsonDecode(response.body);
        print(data);

        DatabaseMgr().localMgr.updateRecipeId(recipe.id, data['id']);

        return true;
      }
      catch (e) {
        print(e);
        return false;
      }
    }

    return false;
  }

  Future<bool> updateRecipe(RecipeUpdate recipeUpdate) async {
    print(recipeUpdate.toJson());
    final response = await _securePostJsonRequest('/recipes/update', 
      recipeUpdate.toJson()
    );

    if (response != null && response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      try {
        dynamic data = jsonDecode(response.body);
        print(data);

        return true;
      }
      catch (e) {
        print(e);
        return false;
      }
    }

    return false;
  }


  // Tests
  Future<bool> test() async {
    final response = await _securePostJsonRequest('/test', 
      // recipe.toFormField()
      {
        'tags': ["test", "bonjour"],
        'new': [{'test': 'hello'}],
        'opt': 8
      }
    );
    if (response != null && response.statusCode == 200) {
      print('good');
      return true;
    }

    return false;
  }

  // Future<DateTime> getUserLastUpdate() async {
  //   final response = await _secureGetRequest('get_user_last_update');

  //   if (response != null && response.statusCode == 200) {
  //     // If the server did return a 200 OK response,
  //     // then parse the JSON.
  //     String pythonTime = response.body;
  //     // trick to remove quote from python datetime
  //     pythonTime = pythonTime.substring(1, 24);
  //     return DateTime.parse(pythonTime);
  //   } else {
  //     // If the server did not return a 200 OK response,
  //     // then throw an exception.
  //     throw Exception('Failed to load user');
  //   }
  // }

  // Future<bool> updateUser(AppUser user) async {

  //   final response = await _securePostFormRequest(_concatServerUrl(['update_user']), user.toJson());
    
  //   if (response != null && response.statusCode == 201) {
  //     if (jsonDecode(response.body) is bool) {
  //       return jsonDecode(response.body) as bool;
  //     } else {
  //       throw Exception("wrong answer");
  //     }
  //   } else {
  //     throw Exception('Failed to create user');
  //   }
  // }

  // Future<List<Book>> getUserBooks(String uid) async {
  //   final response = await _secureGetRequest(_concatServerUrl(['get_user_books', uid]));

  //   if (response != null && response.statusCode == 200) {
  //     List<Book> books = [];
  //     for (var data in jsonDecode(response.body)) {
  //       books.add(Book.fromJson(data));
  //     }
  //     return books;
  //   } else {
  //     throw Exception("Failed to get user books");
  //   }
  // }

  // Future<List<String>> getUserBooksId(String uid) async {
  //   final response = await _secureGetRequest(_concatServerUrl(['get_user_books_id', uid]));

  //   if (response != null && response.statusCode == 200) {
  //     List<String> booksId = [];
  //     for (var data in jsonDecode(response.body)) {
  //       booksId.add(data.toString());
  //     }
  //     return booksId;
  //   } else {
  //     throw Exception("Failed to get book recipes Id");
  //   }
  // }

  // Future<void> deleteUser(String uid) async {
  //   final response = await _secureDeleteRequest(_concatServerUrl(['delete_user', uid]));

  //   if (response != null && response.statusCode == 204) {
  //     // If the server did return a 200 OK response,
  //     // then parse the JSON.
  //     print('deleted');
  //   } else {
  //     // If the server did not return a 200 OK response,
  //     // then throw an exception.
  //     throw Exception('Failed to load user');
  //   }
  // }

  // // books
  // Future<bool> bookExsits(String uid) async {
    
  //   final response = await _secureGetRequest(_concatServerUrl(['book_exists', uid]));

  //   if (response != null && response.statusCode == 200) {
  //     return response.body == 'true';
  //   }
  //   return false;
  // }

  // Future<Book> fetchBook(String uid) async {

  //   final response = await _secureGetRequest(_concatServerUrl(['get_book', uid]));

  //   if (response != null && response.statusCode == 200) {
  //     // If the server did return a 200 OK response,
  //     // then parse the JSON.
  //     return Book.fromJson(jsonDecode(response.body));
  //   } else {
  //     // If the server did not return a 200 OK response,
  //     // then throw an exception.
  //     throw Exception('Failed to load book');
  //   }
  // }

  // Future<Book> createBook(Book newBook) async {

  //   final response = await _securePostFormRequest(_concatServerUrl(['add_book']), newBook.toJson());
    
  //   if (response != null && response.statusCode == 201) {
  //     return Book.fromJson(jsonDecode(response.body));
  //   } else {
  //     throw Exception('Failed to create book');
  //   }
  // }

  // Future<DateTime> getBookLastUpdate(String uid) async {
  //   final response = await _secureGetRequest(_concatServerUrl(['get_book_last_update', uid]));

  //   if (response != null && response.statusCode == 200) {
  //     // If the server did return a 200 OK response,
  //     // then parse the JSON.
  //     return DateTime.parse(response.body);
  //   } else {
  //     // If the server did not return a 200 OK response,
  //     // then throw an exception.
  //     throw Exception('Failed to load book');
  //   }
  // }

  // Future<bool> updateBook(Book book) async {

  //   final response = await _securePostFormRequest(_concatServerUrl(['update_book']), book.toJson());
    
  //   if (response != null && response.statusCode == 201) {
  //     if (jsonDecode(response.body) is bool) {
  //       return jsonDecode(response.body) as bool;
  //     } else {
  //       throw Exception("wrong answer");
  //     }
  //   } else {
  //     throw Exception('Failed to create book');
  //   }
  // }

  // Future<List<Recipe>> getBookRecipes(String uid) async {
  //   final response = await _secureGetRequest(_concatServerUrl(['get_book_recipes', uid]));

  //   if (response != null && response.statusCode == 200) {
  //     List<Recipe> recipes = [];
  //     for (var data in jsonDecode(response.body)) {
  //       recipes.add(Recipe.fromJson(data));
  //     }
  //     return recipes;
  //   } else {
  //     throw Exception("Failed to get book recipes");
  //   }
  // }

  // Future<List<String>> getBookRecipesId(String uid) async {
  //   final response = await _secureGetRequest(_concatServerUrl(['get_book_recipes_id', uid]));

  //   if (response != null && response.statusCode == 200) {
  //     List<String> recipesId = [];
  //     for (var data in jsonDecode(response.body)) {
  //       recipesId.add(data.toString());
  //     }
  //     return recipesId;
  //   } else {
  //     throw Exception("Failed to get book recipes Id");
  //   }
  // }

  // Future<void> deleteBook(String uid) async {
  //   final response = await _secureDeleteRequest(_concatServerUrl(['delete_book', uid]));

  //   if (response != null && response.statusCode == 204) {
  //     // If the server did return a 200 OK response,
  //     // then parse the JSON.
  //     print('deleted');
  //   } else {
  //     // If the server did not return a 200 OK response,
  //     // then throw an exception.
  //     throw Exception('Failed to load book');
  //   }
  // }

  // // recipes
  // Future<bool> recipeExsits(String uid) async {
    
  //   final response = await _secureGetRequest(_concatServerUrl(['recipe_exists', uid]));

  //   if (response != null && response.statusCode == 200) {
  //     return response.body == 'true';
  //   }
  //   return false;
  // }

  // Future<Recipe> fetchRecipe(String uid) async {

  //   final response = await _secureGetRequest(_concatServerUrl(['get_recipe', uid]));

  //   if (response != null && response.statusCode == 200) {
  //     // If the server did return a 200 OK response,
  //     // then parse the JSON.
  //     return Recipe.fromJson(jsonDecode(response.body));
  //   } else {
  //     // If the server did not return a 200 OK response,
  //     // then throw an exception.
  //     throw Exception('Failed to load recipe');
  //   }
  // }

  // Future<Recipe> createRecipe(Recipe newRecipe) async {

  //   final response = await _securePostFormRequest(_concatServerUrl(['add_recipe']), newRecipe.toJson());
    
  //   if (response != null && response.statusCode == 201) {
  //     return Recipe.fromJson(jsonDecode(response.body));
  //   } else {
  //     throw Exception('Failed to create recipe');
  //   }
  // }

  // Future<DateTime> getRecipeLastUpdate(String uid) async {
  //   final response = await _secureGetRequest(_concatServerUrl(['get_recipe_last_update', uid]));

  //   if (response != null && response.statusCode == 200) {
  //     // If the server did return a 200 OK response,
  //     // then parse the JSON.
  //     return DateTime.parse(response.body);
  //   } else {
  //     // If the server did not return a 200 OK response,
  //     // then throw an exception.
  //     throw Exception('Failed to load recipe');
  //   }
  // }

  // Future<bool> updateRecipe(Recipe recipe) async {

  //   final response = await _securePostFormRequest(_concatServerUrl(['update_recipe']), recipe.toJson());
    
  //   if (response != null && response.statusCode == 201) {
  //     if (jsonDecode(response.body) is bool) {
  //       return jsonDecode(response.body) as bool;
  //     } else {
  //       throw Exception("wrong answer");
  //     }
  //   } else {
  //     throw Exception('Failed to create recipe');
  //   }
  // }

  // Future<void> deleteRecipe(String uid) async {
  //   final response = await _secureDeleteRequest(_concatServerUrl(['delete_recipe', uid]));

  //   if (response != null && response.statusCode == 204) {
  //     // If the server did return a 200 OK response,
  //     // then parse the JSON.
  //     print('deleted');
  //   } else {
  //     // If the server did not return a 200 OK response,
  //     // then throw an exception.
  //     throw Exception('Failed to load recipe');
  //   }
  // }
}

