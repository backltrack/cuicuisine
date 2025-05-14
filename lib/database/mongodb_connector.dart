import 'dart:async';
import 'dart:io';

import 'package:cuicuisine/database/database_mgr.dart';
import 'package:cuicuisine/database/file_storage.dart';
import 'package:cuicuisine/models/sync_model.dart';
import 'package:cuicuisine/models/update_model.dart';
import 'package:cuicuisine/security/rsa.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:convert';
import 'package:oauth2/oauth2.dart' as oauth2;

import 'oauth2.dart';
import '../models/data_model.dart';

class MongoConnector {
  String server = '';
  oauth2.Client? client;
  
  MongoConnector({required this.server});

  Future<bool> setServer(String server) async {
    try {
      Response response = await http.get(Uri.parse("$server/test_connexion"),
        headers: {
          'accept': 'application/json'
        }
      );
      DatabaseMgr().isOnline = true;
      DatabaseMgr().localMgr.saveServerUri(server);
      this.server = server;
      return response.body == "true";
    } catch (_) {
      return false;
    }
  }

  // helper
  retryFuture(future, delay) {
    print("retrying in $delay ms");
    Future.delayed(Duration(milliseconds: delay), () {
      future();
    });
  }

  Future<dynamic> _secureGetRequest(String endpoint, {int trials=3}) async {
    if (client == null) { return; }
    print("GET $endpoint");

    Uri serverUri = Uri.parse(server);

    var headers = {
      'accept': 'application/json',
      'Authorization': client!.credentials.accessToken
    };

    try {
      Response response = await client!.get(Uri(scheme: serverUri.scheme, host: serverUri.host, port: serverUri.port, path: endpoint), 
        headers: headers).timeout(const Duration(seconds: 10));
        
      if (response.statusCode == 401) {
        if (await refreshToken() != null) {
          return await _secureGetRequest(endpoint, trials: trials - 1);
        }
      }
      return response;
    } catch (e) {
      if (trials == 0) {
        DatabaseMgr().isOnline = false;
        return null;
      }
      print("try again : $trials");
      return await retryFuture(() => _secureGetRequest(endpoint, trials: trials - 1), 1000);
    }
  }

  Future<dynamic> _secureDeleteRequest(String endpoint, Object data, {int trials=3}) async {
    if (client == null) { return; }
    print("DELETE $endpoint");
    
    Uri serverUri = Uri.parse(server);

    var headers = {
      'accept': 'application/json',
      'Authorization': client!.credentials.accessToken,
      'Content-type': 'application/json'
    };

    try {
      Response response = await client!.delete(Uri(scheme: serverUri.scheme, host: serverUri.host, port: serverUri.port, path: endpoint),
        headers: headers,
        body: jsonEncode(data));

      if (response.statusCode == 401) {
        if (await refreshToken() != null) {
          return await _secureDeleteRequest(endpoint, data, trials: trials - 1);
        }
      }
      return response;
    } catch (e) {
      if (trials == 0) {
        DatabaseMgr().isOnline = false;
        return null;
      }
      print("try again : $trials");
      return await retryFuture(() => _secureDeleteRequest(endpoint, data, trials: trials - 1), 1000);
    }
  }

  Future<dynamic> _securePostJsonRequest(String endpoint, Map<String, dynamic> data, {int trials=3}) async {
    if (client == null) { return; }
    print("POST Json $endpoint");
    
    Uri serverUri = Uri.parse(server);

    var headers = {
      'accept': 'application/json',
      'Authorization': client!.credentials.accessToken,
      'Content-type': 'application/json'
    };

    try {
      Response response = await client!.post(Uri(scheme: serverUri.scheme, host: serverUri.host, port: serverUri.port, path: endpoint),
        headers: headers,
        body: jsonEncode(data));
      
      if (response.statusCode == 401) {
        if (await refreshToken() != null) {
          return await _securePostJsonRequest(endpoint, data, trials: trials - 1);
        }
      }
      return response;
    } catch (e) {
      if (trials == 0) {
        DatabaseMgr().isOnline = false;
        return null;
      }
      print("try again : $trials");
      return await retryFuture(() => _securePostJsonRequest(endpoint, data, trials: trials - 1), 1000);
    }
  }

  Future<dynamic> _securePostMultipartRequest(String endpoint, File file, List<MapEntry<String, String>> form, {int trials=3}) async {
    if (client == null) { return; }
    print("POST Multipart $endpoint");
    
    Uri serverUri = Uri.parse(server);

    var headers = {
      'accept': 'application/json',
      'Authorization': client!.credentials.accessToken,
      'Content-Type': 'multipart/form-data'
    };

    try {
      var request = MultipartRequest('POST', Uri(scheme: serverUri.scheme, host: serverUri.host, port: serverUri.port, path: endpoint));
      request.files.add(await MultipartFile.fromPath('file', file.path, filename: file.path.split('/').last));
      request.headers.addAll(headers);
      request.fields.addEntries(form);
      StreamedResponse response = await client!.send(request);

      if (response.statusCode == 401) {
        if (await refreshToken() != null) {
          return await _securePostMultipartRequest(endpoint, file, form, trials: trials - 1);
        }
      }
      return response;
    } catch (e) {
      if (trials == 0) {
        DatabaseMgr().isOnline = false;
        return null;
      }
      print("try again : $trials");
      return await retryFuture(() => _securePostMultipartRequest(endpoint, file, form, trials: trials - 1), 1000);
    }
  }

  Future<dynamic> _securePutRequest(String endpoint, Object data, {int trials=3}) async {
    if (client == null) { return; }
    print("PUT $endpoint");
    
    Uri serverUri = Uri.parse(server);

    var headers = {
      'accept': 'application/json',
      'Authorization': client!.credentials.accessToken
    };

    try {
      Response response = await client!.put(Uri(scheme: serverUri.scheme, host: serverUri.host, port: serverUri.port, path: endpoint),
        headers: headers,
        body: data);

      if (response.statusCode == 401) {
        if (await refreshToken() != null) {
          return await _securePutRequest(endpoint, data, trials: trials - 1);
        }
      }
      return response;
    } catch (e) {
      if (trials == 0) {
        DatabaseMgr().isOnline = false;
        return null;
      }
      print("try again : $trials");
      return await retryFuture(() => _securePutRequest(endpoint, data, trials: trials - 1), 1000);
    }
  }

  // Connexion
  Future<bool> testConnexion() async {
    try {
      Response response = await http.get(Uri.parse("$server/test_connexion"),
        headers: {
          'accept': 'application/json'
      });
      
      DatabaseMgr().isOnline = response.body == "true";
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

  Future<AppUser?> refreshToken() async {
    print('refreshing token...');
    try {
      oauth2.Client? newClient = await OAuth2Connexion.refreshToken(serverUri: server, client: client!);
      if (newClient != null) {
        client = newClient;
        DatabaseMgr().localMgr.saveCredentials(client!.credentials.toJson());
        
        AppUser user = await fetchUser();
        await DatabaseMgr().localMgr.setUser(user);
        return user;
      }
    }
    catch (e) {
      print(e);
    }
    return null;
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
        }
        
      }
    }
    on SocketException {
      DatabaseMgr().isOnline = false;
    } on TimeoutException {
      DatabaseMgr().isOnline = false;
    }

    return null;
  }

  Future<bool> emailExists(String email) async {
    final response = await http.post(Uri.parse("$server/email_exists"),
      headers: {
        'accept': 'application/json',
        'Content-type': 'application/json'
      },
      body: jsonEncode({'email': email})
    );

    if (response.statusCode == 200) {
      return bool.parse(response.body);
    }
    return false;
  }

  Future<AppUser?> connectWithEmail(String email, String password, {Function? onInvalidEmail, Function? onInvalidPassword, Function(AppUser)? onSuccess}) async {
    String enc_pwd = await RSAEncrypter.encryptData(password);
    String enc_email = await RSAEncrypter.encryptData(email);
    
    try {
      oauth2.Client? _client = await OAuth2Connexion.connectFromPassword(serverUri: server, email: enc_email, password: enc_pwd);
      if (_client != null) {
        client = _client;

        AppUser user = await fetchUser();
        await DatabaseMgr().localMgr.setUser(user);

        if (onSuccess != null) {
          onSuccess(user);
        }

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

  Future<AppUser?> registerWithEmail(String email, String password, String name, {Function(AppUser)? onSuccess, Function(String)? onFailure}) async {
    String enc_pwd = await RSAEncrypter.encryptData(password);
    String enc_email = await RSAEncrypter.encryptData(email);
    
    try {
      oauth2.Client? _client = await OAuth2Connexion.createClientFromPassword(serverUri: server, email: enc_email, password: enc_pwd);
      if (_client != null) {
        client = _client;

        AppUser user = await fetchUser();
        await DatabaseMgr().localMgr.setUser(user);

        DatabaseMgr().localMgr.updateUser(name: name);

        if (onSuccess != null) {
          onSuccess(user);
        }
        return user;
      }
    }
    on IncorrectPasswordException catch(e) {
      print(e);
      onFailure??("Incorrect password");
    }
    on EmailAlreadyExistsException catch(e) {
      print(e);
      onFailure??("Email already exists");
    }
    catch (e) {
      print(e);
    }
    
    return null;
  }

  Future<bool> changeUserPassword(String oldPwd, String newPwd) async {
    final response = await _securePostJsonRequest("/users/me/change_password/", 
    {
      "old_pwd": await RSAEncrypter.encryptData(oldPwd),
      "new_pwd": await RSAEncrypter.encryptData(newPwd)
    });

    if (response != null && response.statusCode == 200) {
      return response.body != null && jsonDecode(utf8.decode(response.bodyBytes));
    }
    return false;
  }

  Future<Result> requestPasswordRecovery(String email) async {
    // WARNING Unsecure request
    try {
      Response response = await http.post(Uri.parse("$server/users/request_password_recovery/"),
        headers: {
          'Content-type': 'application/json'
        },
        body: jsonEncode(email)
      );

      if (response.statusCode == 200) {
        return Result.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      return Result(result: false, reason: "Server error");

    } catch (e) {
      return Result(result: false, reason: "Network issue");
    }
  }

  Future<Result> passwordRecovery(String email, String newPassword, String code) async {
    // WARNING Unsecure request
    try {
      Response response = await http.post(Uri.parse("$server/users/password_recovery/"),
        headers: {
          'Content-type': 'application/json'
        },
        body: jsonEncode({
          "email": await RSAEncrypter.encryptData(email),
          "encrypted_password": await RSAEncrypter.encryptData(newPassword),
          "security_code": await RSAEncrypter.encryptData(code)
        })
      );

      if (response.statusCode == 200) {
        return Result.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      return Result(result: false, reason: "Server error");

    } catch (e) {
      return Result(result: false, reason: "Network issue");
    }
  }

  void disconnect() {
    if (client == null) { return; }
    
    client!.close();
    DatabaseMgr().localMgr.deleteCredentials();
  }

  Future<bool> deleteUser() async {
    final response = await _secureDeleteRequest("/users/me/delete", {});
    if (response != null && response.statusCode == 200) {
      if (response.body != null && jsonDecode(utf8.decode(response.bodyBytes))) {
        return true;
      }
    }
    return false;
  }


  Future<void> getLatestChanges(String lastChange) async {
    final response = await _secureGetRequest('/change/get/$lastChange');

    if (response != null && response.statusCode == 200) {
      if (response.body != null) {
        Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

      if (data['result']) {
          List<dynamic> tmp = data['changes'];
          List<MongoChange> changes = [];
          tmp.forEach((element) {changes.add(MongoChange.fromJson(element));});
          
          for (MongoChange change in changes) {
            if (change.objectType == 'user') {
              AppUser user = await fetchUser();
              AppUser? currentUser = DatabaseMgr().localMgr.getUser();

              if (currentUser != null) {
                currentUser.copyFromUser(user);
                currentUser.save();
              }
            }
            else if (change.objectType == 'book') {
              if (change.operationType == OperationType.delete) {
                DatabaseMgr().localMgr.deleteBook(change.objectId);
              }
              else {
                Book book = await fetchBook(change.objectId);
                Book? localBook = DatabaseMgr().localMgr.getBook(book.id);

                if (localBook != null) {
                  localBook.copyFromBook(book);
                  localBook.save();
                }
                else {
                  DatabaseMgr().localMgr.addBook(book, addToQueue: false);
                }
              }
            }
            else if (change.objectType == 'recipe') {
              if (change.operationType == OperationType.delete) {
                DatabaseMgr().localMgr.deleteRecipe(change.objectId);
              }
              else {
                Recipe recipe = await fetchRecipe(change.objectId);
                Recipe? localRecipe = DatabaseMgr().localMgr.getRecipe(recipe.id);

                if (localRecipe != null) {
                  localRecipe.copyFromRecipe(recipe);
                  localRecipe.save();
                }
                else {
                  DatabaseMgr().localMgr.addRecipe(recipe, addToQueue: false);
                }

                removeExtraImages(recipe);
                downloadMissingImages(recipe);
              }
            }

            // add change to local list
            DatabaseMgr().localMgr.addChange(change.changeId);
          }
        }
      }
    }
  }

  Future<int> fetchAllFromUser() async {
    final response = await _secureGetRequest('/users/me/fetchall');

    if (response != null && response.statusCode == 200) {

      Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data.keys.contains('books') && data.keys.contains('recipes') && data.keys.contains('lastChange')) {
        DatabaseMgr().localMgr.clearBooks();
        DatabaseMgr().localMgr.clearRecipes();

        List<dynamic> bookIds = data['books'];
        for (String bookId in bookIds) {
          Book? book = await fetchBook(bookId);
          DatabaseMgr().localMgr.addBook(book, addToQueue: false);
        }

        List<dynamic> recipeIds = data['recipes'];
        for (String recipeId in recipeIds) {
          Recipe? recipe = await fetchRecipe(recipeId);
          DatabaseMgr().localMgr.addRecipe(recipe, addToQueue: false);
          
          removeExtraImages(recipe);
          downloadMissingImages(recipe);
        }

        String? lastChange = data['lastChange'];
        print(lastChange);
        if (lastChange != null) {
          DatabaseMgr().localMgr.addChange(lastChange);
        }

        return bookIds.length + recipeIds.length;
      }
    }
    return 0;
  }

  // users

  Future<AppUser> fetchUser() async {

    final response = await _secureGetRequest('/users/me');

    if (response != null && response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return AppUser.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
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
        dynamic data = jsonDecode(utf8.decode(response.bodyBytes));

        if (data['result']) {
          String change = DatabaseMgr().localMgr.createChange();
          
          final changeResponse = await _securePostJsonRequest('/change/add', {
            'changeId': change,
            'objectType': 'user',
            'operationType': OperationType.update.index,
            'objectId': userUpdate.id
          });
          
          if (bool.parse(changeResponse.body)){
            DatabaseMgr().localMgr.addChange(change);
            
            DatabaseMgr().localMgr.updateUserLastUpdate(userUpdate.id, DateTime.parse(data['dateTime']));
            return true;
          }
        }

        return false;
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
      return Book.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to fetch book');
    } 
  }

  Future<bool> createBook(Book book) async {
    final response = await _securePutRequest('/books/create', 
      {
        'id': book.id,
        'name': book.name
      }
    );

    if (response != null && response.statusCode == 201) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      try {
        dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
        print(data);
        if (data != null && data['result']) {

          DatabaseMgr().localMgr.updateBookLastUpdate(book.id, DateTime.parse(data['lastUpdate']));

          String change = DatabaseMgr().localMgr.createChange();
          
          final changeResponse = await _securePostJsonRequest('/change/add', {
            'changeId': change,
            'objectType': 'book',
            'operationType': OperationType.create.index,
            'objectId': book.id
          });
          
          if (bool.parse(changeResponse.body)){
            DatabaseMgr().localMgr.addChange(change);
            return true;
          }
        }

        return false;
      }
      catch (e) {
        print(e);
        return false;
      }
    }

    return false;
  }

  Future<bool> updateBook(BookUpdate bookUpdate) async {
    final response = await _securePostJsonRequest('/books/update', 
      bookUpdate.toJson()
    );

    if (response != null && response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      try {
        dynamic data = jsonDecode(utf8.decode(response.bodyBytes));

        if (data['result']) {
          String change = DatabaseMgr().localMgr.createChange();
          
          final changeResponse = await _securePostJsonRequest('/change/add', {
            'changeId': change,
            'objectType': 'book',
            'operationType': OperationType.update.index,
            'objectId': bookUpdate.id
          });
          
          if (bool.parse(changeResponse.body)){
            DatabaseMgr().localMgr.addChange(change);

            DatabaseMgr().localMgr.updateBookLastUpdate(bookUpdate.id, DateTime.parse(data['dateTime']));
            return true;
          }
        }

        return false;
      }
      catch (e) {
        print(e);
        return false;
      }
    }

    return false;
  }

  Future<String?> joinBook(String bookId) async {
    final response = await _secureGetRequest('/books/join/$bookId');

    if (response != null && response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      try {
        bool data = jsonDecode(utf8.decode(response.bodyBytes));

        if (data) {
          await DatabaseMgr().synchronization.fetchNew();
        }

        return null;
      }
      catch (e) {
        print(e);
        return null;
      }
    }

    return null;
  }

  Future<bool> deleteBook(Book book) async {
    final response = await _secureDeleteRequest('/books/delete',
      book.id
    );

    if (response != null && response.statusCode == 200) {
      final value = jsonDecode(utf8.decode(response.bodyBytes));
      if (value is bool) {
        String change = DatabaseMgr().localMgr.createChange();

        final changeResponse = await _securePostJsonRequest('/change/add', {
          'changeId': change,
          'objectType': 'book',
          'operationType': OperationType.delete.index,
          'objectId': book.id
        });

        if (bool.parse(changeResponse.body)){
            DatabaseMgr().localMgr.addChange(change);
            return true;
        }
      }
    }

    return false;
  }

  Future<Map<String, String>> getBookUserNames(String bookId) async {
    final response = await _secureGetRequest('/books/get_users/$bookId');

    if (response != null && response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Map<String, String>.from(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    
    return {};
  }


  // Recipe

  Future<Recipe> fetchRecipe(String recipeId) async {
    final response = await _secureGetRequest('/recipes/get/$recipeId');

    if (response != null && response.statusCode == 200 && response.body != null) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Recipe.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to fetch recipe');
    } 
  }

  Future<bool> createRecipe(Recipe recipe) async {
    String bookId = DatabaseMgr().localMgr.loadCurrentBook()!;

    final response = await _securePutRequest('/recipes/create', 
      {
        'id': recipe.id,
        'name': recipe.name,
        'bookId': bookId
      }
    );

    if (response != null && response.statusCode == 201) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      try {
        dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data != null && data['result']) {
          DatabaseMgr().localMgr.updateRecipeLastUpdate(recipe.id, DateTime.parse(data['lastUpdate']));

          Book? book = DatabaseMgr().localMgr.getBook(bookId);
          if (book != null) {
            Book newBook = await fetchBook(bookId);
            book.copyFromBook(newBook);
            book.save();
          }
          
          // change recipe
          String changeRecipe = DatabaseMgr().localMgr.createChange();
          
          final changeRecipeResponse = await _securePostJsonRequest('/change/add', {
            'changeId': changeRecipe,
            'objectType': 'recipe',
            'operationType': OperationType.create.index,
            'objectId': recipe.id
          });

          // change book
          String changeBook = DatabaseMgr().localMgr.createChange();
          
          final changeBookResponse = await _securePostJsonRequest('/change/add', {
            'changeId': changeBook,
            'objectType': 'book',
            'operationType': OperationType.update.index,
            'objectId': bookId
          });
          
          if (bool.parse(changeRecipeResponse.body) && bool.parse(changeBookResponse.body)){
            DatabaseMgr().localMgr.addChange(changeRecipe);
            DatabaseMgr().localMgr.addChange(changeBook);
            return true;
          }
        }


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
    final response = await _securePostJsonRequest('/recipes/update', 
      recipeUpdate.toJson()
    );

    if (response != null && response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      try {
        dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
        
        if (data['result']) {
          String change = DatabaseMgr().localMgr.createChange();
          
          final changeResponse = await _securePostJsonRequest('/change/add', {
            'changeId': change,
            'objectType': 'recipe',
            'operationType': OperationType.update.index,
            'objectId': recipeUpdate.id
          });
          
          if (bool.parse(changeResponse.body)){
            DatabaseMgr().localMgr.addChange(change);

            DatabaseMgr().localMgr.updateRecipeLastUpdate(recipeUpdate.id, DateTime.parse(data['dateTime']));
            return true;
          }
        }

        return false;
      }
      catch (e) {
        print(e);
        return false;
      }
    }

    return false;
  }

  Future<bool> deleteRecipe(Recipe recipe) async {
    final response = await _secureDeleteRequest('/recipes/delete',
      recipe.id
    );

    if (response != null && response.statusCode == 200) {
      final value = jsonDecode(utf8.decode(response.bodyBytes));
      if (value is bool && value) {
        String change = DatabaseMgr().localMgr.createChange();

        final changeResponse = await _securePostJsonRequest('/change/add', {
          'changeId': change,
          'objectType': 'recipe',
          'operationType': OperationType.delete.index,
          'objectId': recipe.id
        });

        if (bool.parse(changeResponse.body)){
            DatabaseMgr().localMgr.addChange(change);
            return true;
        }
      }
    }

    return false;
  }

  Future<bool> uploadImage(RecipeImage recipeImage) async {
    final response = await _securePostMultipartRequest('/image/upload',
      File(recipeImage.path),
      [MapEntry('recipeId', recipeImage.recipeId), MapEntry('imageId', recipeImage.imageId)]
    );

    if (response != null && response.statusCode == 200) {
      return true;
    }

    return false;
  }

  Future<MultipartFile?> downloadImage(String recipeId, String imageId) async {
    final response = await _secureGetRequest('/image/download/$recipeId/$imageId');
    if (response != null && response.statusCode == 200) {
      await DatabaseMgr().localMgr.fileStorage.writeImagefromBytes(bytes: response.bodyBytes, recipeId: recipeId, imageId: imageId);
    }
    else {
      print("WRONG RESPONSE STATUS");
    }

    return null;
  }

  Future<bool> deleteImage(String recipeId, String imageId) async {
    final response = await _secureDeleteRequest('/image/delete', {
      'recipeId': recipeId,
      'imageId': imageId
    });

    if (response != null && response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }

    return false;
  }

  Future<bool> downloadMissingImages(Recipe recipe) async {
    for (String imagePath in recipe.pictures) {
      if (!await DatabaseMgr().localMgr.fileStorage.imageExists(recipeId: recipe.id, imageId: imagePath.split('/').last)) {
        await downloadImage(recipe.id, imagePath.split('/').last);
      }
    }
    return true;
  }

  Future<bool> removeExtraImages(Recipe recipe) async {
    List<String> images = await DatabaseMgr().localMgr.fileStorage.getAllRecipeImages(recipe.id);
    
    for (String imagePath in images) {
      String imageId = DatabaseMgr().localMgr.fileStorage.pathToId(imagePath)!['imageId'] ?? "";
      if (recipe.pictures.contains(imageId)) {
        await FileStorage().deleteImage(recipeId: recipe.id, imageId: imageId);
      }
    }
    return true;
  }
}