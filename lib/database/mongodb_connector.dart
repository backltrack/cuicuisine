import 'dart:async';
import 'dart:io';

import 'package:cuicuisine/database/database_mgr.dart';
import 'package:cuicuisine/database/file_storage.dart';
import 'package:cuicuisine/models/sync_model.dart';
import 'package:cuicuisine/models/update_model.dart';
import 'package:cuicuisine/security/rsa.dart';
import 'package:cuicuisine/utilities/toast_notifier.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:convert';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:package_info_plus/package_info_plus.dart';

import '../utilities/logger.dart';
import 'oauth2.dart';
import '../models/data_model.dart';

final _log = Logger('MongoConnector');

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
  Future<dynamic> retryFuture(Function future, int delay) async {
    _log.fine("retrying in $delay ms");
    await Future.delayed(Duration(milliseconds: delay));
    return await future();
  }

  Future<Response?> _secureGetRequest(String endpoint, {int trials=3}) async {
    if (client == null) { return null; }
    _log.fine("GET $endpoint");

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
      _log.warning("retry ($trials left)");
      return await retryFuture(() => _secureGetRequest(endpoint, trials: trials - 1), 1000);
    }
  }

  Future<Response?> _secureDeleteRequest(String endpoint, Object data, {int trials=3}) async {
    if (client == null) { return null; }
    _log.fine("DELETE $endpoint");
    
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
      _log.warning("retry ($trials left)");
      return await retryFuture(() => _secureDeleteRequest(endpoint, data, trials: trials - 1), 1000);
    }
  }

  Future<Response?> _securePostJsonRequest(String endpoint, Map<String, dynamic> data, {int trials=3}) async {
    if (client == null) { return null; }
    _log.fine("POST Json $endpoint");
    
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
      _log.warning("retry ($trials left)");
      return await retryFuture(() => _securePostJsonRequest(endpoint, data, trials: trials - 1), 1000);
    }
  }

  Future<StreamedResponse?> _securePostMultipartRequest(String endpoint, File file, List<MapEntry<String, String>> form, {int trials=3}) async {
    if (client == null) { return null; }
    _log.fine("POST Multipart $endpoint");
    
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
      _log.warning("retry ($trials left)");
      return await retryFuture(() => _securePostMultipartRequest(endpoint, file, form, trials: trials - 1), 1000);
    }
  }

  Future<dynamic> _securePutRequest(String endpoint, Object data, {int trials=3}) async {
    if (client == null) { return; }
    _log.fine("PUT $endpoint");
    
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
      _log.warning('error', e);
      _log.warning("retry ($trials left)");
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

      bool wasOnline = DatabaseMgr().isOnline;
      bool result = bool.parse(response.body);
      if (wasOnline != result) {
        DatabaseMgr().isOnline = result;
        ToastNotifier().showInfo(result ? "Back online" : "You are offline");
      }
      if (result) await checkMinimumVersion();
      return result;
    } catch (e) {
      _log.warning('error', e);
      DatabaseMgr().isOnline = false;
      ToastNotifier().showError("You are offline");
      return false;
    }
  }

  Future<void> checkMinimumVersion() async {
    try {
      final response = await http.get(
        Uri.parse("$server/version"),
        headers: {'accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final String minimum = data['minimum_app_version'] as String;

      final info = await PackageInfo.fromPlatform();
      final bool compatible = _semverGte(info.version, minimum);
      DatabaseMgr().isCompatible = compatible;
    } catch (_) {
      // Don't change compatibility state on network error — keep last known value.
    }
  }

  /// Returns true if [version] >= [minimum] using simple semver comparison.
  bool _semverGte(String version, String minimum) {
    List<int> parse(String v) =>
        v.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final a = parse(version);
    final b = parse(minimum);
    for (int i = 0; i < 3; i++) {
      final av = i < a.length ? a[i] : 0;
      final bv = i < b.length ? b[i] : 0;
      if (av != bv) return av > bv;
    }
    return true;
  }

  Future<AppUser?> refreshToken() async {
    _log.fine('refreshing token');
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
      _log.warning('error', e);
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
          _log.warning('token expired', e);
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
    String encPwd = await RSAEncrypter.encryptData(password);
    String encEmail = await RSAEncrypter.encryptData(email);
    
    try {
      oauth2.Client? client = await OAuth2Connexion.connectFromPassword(serverUri: server, email: encEmail, password: encPwd);
      if (client != null) {
        this.client = client;

        AppUser user = await fetchUser();
        await DatabaseMgr().localMgr.setUser(user);

        if (onSuccess != null) {
          onSuccess(user);
        }

        return user;
      }
    }
    on InvalidEmailException catch (e) {
      _log.warning('error', e);
      if (onInvalidEmail != null) {
        onInvalidEmail();
      }
    }
    on InvalidPasswordException catch (e) {
      _log.warning('error', e);
      if (onInvalidPassword != null) {
        onInvalidPassword();
      }
    }
    
    return null;
  }

  Future<AppUser?> registerWithEmail(String email, String password, String name, {Function(AppUser)? onSuccess, Function(String)? onFailure}) async {
    String encPwd = await RSAEncrypter.encryptData(password);
    String encEmail = await RSAEncrypter.encryptData(email);
    
    try {
      oauth2.Client? client = await OAuth2Connexion.createClientFromPassword(serverUri: server, email: encEmail, password: encPwd);
      if (client != null) {
        client = client;

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
      _log.warning('error', e);
      onFailure??("Incorrect password");
    }
    on EmailAlreadyExistsException catch(e) {
      _log.warning('error', e);
      onFailure??("Email already exists");
    }
    catch (e) {
      _log.warning('error', e);
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
      return jsonDecode(utf8.decode(response.bodyBytes));
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
    return response != null && response.statusCode == 200;
  }

  Future<int?> getNewerChangesCount(String lastChange) async {
    final response = await _secureGetRequest('/change/newer_count/$lastChange');
    _log.fine("getNewerChangesCount status: ${response?.statusCode ?? 'no response'}");
    if (response != null && response.statusCode == 200) {
      int? count = int.tryParse(utf8.decode(response.bodyBytes));
      if (count != null) {
        return count;
      }
    }
    return null;
  }

  Future<bool> getLatestChanges(String lastChange) async {
    final response = await _secureGetRequest('/change/get/$lastChange');
    _log.fine("getLatestChanges status: ${response?.statusCode ?? 'no response'}");
    if (response != null && response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      _log.fine("changes data: $data");

      if (data['success']) {
        List<dynamic> tmp = data['changes'];
        _log.fine("changes: $tmp");
        if (tmp.isEmpty) {
          _log.fine("no new changes");
          return true;
        }
        List<MongoChange> changes = [];
        for (var element in tmp) {changes.add(MongoChange.fromJson(element));}
        
        for (MongoChange change in changes) {
          if (change.objectType == 'user') {
            AppUser user = await fetchUser();
            AppUser? currentUser = DatabaseMgr().localMgr.getUser();

            if (currentUser != null) {
              currentUser.copyFromUser(user);
              await currentUser.save();
            }
          }
          else if (change.objectType == 'book') {
            if (change.operationType == OperationType.delete) {
              await DatabaseMgr().localMgr.deleteBook(change.objectId, addToQueue: false);
            }
            else {
              Book book = await fetchBook(change.objectId);
              Book? localBook = DatabaseMgr().localMgr.getBook(book.id);

              if (localBook != null) {
                localBook.copyFromBook(book);
                await localBook.save();
              }
              else {
                await DatabaseMgr().localMgr.addBook(book, addToQueue: false);
              }
            }
          }
          else if (change.objectType == 'recipe') {
            if (change.operationType == OperationType.delete) {
              await DatabaseMgr().localMgr.deleteRecipe(change.objectId, addToQueue: false);
            }
            else {
              Recipe? recipe = await fetchRecipe(change.objectId);
              if (recipe == null) {
                _log.warning("failed to fetch recipe ${change.objectId}");
                return false;
              }
              Recipe? localRecipe = DatabaseMgr().localMgr.getRecipe(recipe.id);

              if (localRecipe != null) {
                localRecipe.copyFromRecipe(recipe);
                await localRecipe.save();
              }
              else {
                await DatabaseMgr().localMgr.addRecipe(recipe, addToQueue: false);
              }

              await removeExtraImages(recipe);
              await downloadMissingImages(recipe);
            }
          }

          // add change to local list
          DatabaseMgr().localMgr.addChange(change.changeId);
        }
        return true;
      }
      _log.warning("change not found");
    }
    return false;
  }

  Future<int> fetchAllFromUser() async {
    final response = await _secureGetRequest('/users/me/fetchall');

    if (response != null && response.statusCode == 200) {

      Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data.keys.contains('books') && data.keys.contains('recipes') && data.keys.contains('lastChange')) {
        await DatabaseMgr().localMgr.clearBooks();
        await DatabaseMgr().localMgr.clearRecipes();

        List<dynamic> bookIds = data['books'];
        for (String bookId in bookIds) {
          Book? book = await fetchBook(bookId);
          await DatabaseMgr().localMgr.addBook(book, addToQueue: false);
        }

        List<dynamic> recipeIds = data['recipes'];
        for (String recipeId in recipeIds) {
          Recipe? recipe = await fetchRecipe(recipeId);
          if (recipe != null) {
            await DatabaseMgr().localMgr.addRecipe(recipe, addToQueue: false);

            await removeExtraImages(recipe);
            await downloadMissingImages(recipe);
          }
          else {
            _log.warning("failed to fetch recipe $recipeId");
          }
        }

        String? lastChange = data['lastChange'];
        _log.fine("lastChange: $lastChange");
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

  Future<OperationResult> updateUser(UserUpdate userUpdate) async {
    final response = await _securePostJsonRequest('/users/me/update', userUpdate.toJson());

    if (response != null && response.statusCode == 200) {
      try {
        dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data == null) return OperationResult(action: OperationResultAction.requeue, status: UpdateStatus.error);

        String change = DatabaseMgr().localMgr.createChange();
        final changeResponse = await _securePostJsonRequest('/change/add', {
          'changeId': change,
          'objectType': 'user',
          'operationType': OperationType.update.index,
          'objectId': userUpdate.id
        });
        if (changeResponse != null && bool.parse(changeResponse.body)) {
          DatabaseMgr().localMgr.addChange(change);
          DatabaseMgr().localMgr.updateUserLastUpdate(userUpdate.id, DateTime.parse(data['dateTime']));
          return OperationResult(action: OperationResultAction.delete, status: UpdateStatus.success);
        }
      } catch (e) {
        _log.warning('error', e);
      }
      return OperationResult(action: OperationResultAction.requeue, status: UpdateStatus.error);
    }
    if (response != null) {
      final status = UpdateStatus.getStatusFromHttpCode(response.statusCode);
      return OperationResult(action: OperationResultAction.getActionFromUpdateStatus(status), status: status);
    }
    return OperationResult(action: OperationResultAction.requeue, status: UpdateStatus.error);
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

  Future<OperationResult> createBook(Book book) async {
    final response = await _securePutRequest('/books/create', {
      'id': book.id,
      'name': book.name,
      'tags': jsonEncode(List<Map>.generate(book.tags.length, (index) => book.tags[index].toJson())),
      'bookIngredients': jsonEncode(List<Map>.generate(book.bookIngredients.length, (index) => book.bookIngredients[index].toJson())),
    });

    if (response != null && response.statusCode == 201) {
      try {
        dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data != null) {
          DatabaseMgr().localMgr.updateBookLastUpdate(book.id, DateTime.parse(data['lastUpdate']));
        }
        String change = DatabaseMgr().localMgr.createChange();
        final changeResponse = await _securePostJsonRequest('/change/add', {
          'changeId': change,
          'objectType': 'book',
          'operationType': OperationType.create.index,
          'objectId': book.id
        });
        if (changeResponse != null && bool.parse(changeResponse.body)) {
          DatabaseMgr().localMgr.addChange(change);
        }
      } catch (e) {
        _log.warning('error', e);
      }
      // Server confirmed creation (201): always delete from queue regardless of change registration
      return OperationResult(action: OperationResultAction.delete, status: UpdateStatus.success);
    }
    if (response != null) {
      final status = UpdateStatus.getStatusFromHttpCode(response.statusCode);
      return OperationResult(action: OperationResultAction.getActionFromUpdateStatus(status), status: status);
    }
    return OperationResult(action: OperationResultAction.requeue, status: UpdateStatus.error);
  }

  Future<OperationResult> updateBook(BookUpdate bookUpdate) async {
    final response = await _securePostJsonRequest('/books/update', bookUpdate.toJson());

    if (response != null && response.statusCode == 200) {
      try {
        dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data == null) return OperationResult(action: OperationResultAction.requeue, status: UpdateStatus.error);

        String change = DatabaseMgr().localMgr.createChange();
        final changeResponse = await _securePostJsonRequest('/change/add', {
          'changeId': change,
          'objectType': 'book',
          'operationType': OperationType.update.index,
          'objectId': bookUpdate.id
        });
        if (changeResponse != null && bool.parse(changeResponse.body)) {
          DatabaseMgr().localMgr.addChange(change);
          DatabaseMgr().localMgr.updateBookLastUpdate(bookUpdate.id, DateTime.parse(data['dateTime']));
          return OperationResult(action: OperationResultAction.delete, status: UpdateStatus.success);
        }
      } catch (e) {
        _log.warning('error', e);
      }
      return OperationResult(action: OperationResultAction.requeue, status: UpdateStatus.error);
    }
    if (response != null) {
      final status = UpdateStatus.getStatusFromHttpCode(response.statusCode);
      return OperationResult(action: OperationResultAction.getActionFromUpdateStatus(status), status: status);
    }
    return OperationResult(action: OperationResultAction.requeue, status: UpdateStatus.error);
  }

  Future<bool> revokeUserFromBook(String bookId) async {
    final response = await _secureGetRequest('/books/revokeme/$bookId');

    if (response != null && response.statusCode == 200) {
      try {
        dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
        String change = DatabaseMgr().localMgr.createChange();
        final changeResponse = await _securePostJsonRequest('/change/add', {
          'changeId': change,
          'objectType': 'book',
          'operationType': OperationType.update.index,
          'objectId': bookId
        });
        if (changeResponse != null && bool.parse(changeResponse.body)) {
          DatabaseMgr().localMgr.addChange(change);
          DatabaseMgr().localMgr.updateBookLastUpdate(bookId, DateTime.parse(data['dateTime']));
          return true;
        }
      } catch (e) {
        _log.warning('error', e);
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
        _log.warning('error', e);
        return null;
      }
    }

    return null;
  }

  Future<OperationResult> deleteBook(Book book) async {
    final response = await _secureDeleteRequest('/books/delete', book.id);

    if (response != null && response.statusCode == 200) {
      try {
        String change = DatabaseMgr().localMgr.createChange();
        final changeResponse = await _securePostJsonRequest('/change/add', {
          'changeId': change,
          'objectType': 'book',
          'operationType': OperationType.delete.index,
          'objectId': book.id
        });
        if (changeResponse != null && bool.parse(changeResponse.body)) {
          DatabaseMgr().localMgr.addChange(change);
          return OperationResult(action: OperationResultAction.delete, status: UpdateStatus.success);
        }
      } catch (e) {
        _log.warning('error', e);
      }
      return OperationResult(action: OperationResultAction.requeue, status: UpdateStatus.error);
    }
    if (response != null) {
      final status = UpdateStatus.getStatusFromHttpCode(response.statusCode);
      return OperationResult(action: OperationResultAction.getActionFromUpdateStatus(status), status: status);
    }
    return OperationResult(action: OperationResultAction.requeue, status: UpdateStatus.error);
  }

  Future<Map<String, String>> getBookUserNames(String bookId) async {
    final response = await _secureGetRequest('/books/get_users/$bookId');
    _log.fine("getBookUserNames status: ${response?.statusCode ?? 'no response'}");
    if (response != null && response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Map<String, String>.from(jsonDecode(utf8.decode(response.bodyBytes)));
    }
    
    return {};
  }


  // Recipe

  Future<Recipe?> fetchRecipe(String recipeId) async {
    final response = await _secureGetRequest('/recipes/get/$recipeId');

    if (response != null && response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      try {
        return Recipe.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
      catch (e) {
        _log.warning('error', e);
        return null;
      }
    } else {
      _log.warning("failed to fetch recipe, status: ${response?.statusCode}");
      return null;
    } 
  }

  Future<OperationResult> createRecipe(Recipe recipe) async {
    String bookId = DatabaseMgr().localMgr.getCurrentBookId()!;

    final response = await _securePutRequest('/recipes/create', {
      'id': recipe.id,
      'name': recipe.name,
      'bookId': bookId
    });

    if (response != null && response.statusCode == 201) {
      try {
        dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data != null) {
          DatabaseMgr().localMgr.updateRecipeLastUpdate(recipe.id, DateTime.parse(data['lastUpdate']));
        }
        Book? book = DatabaseMgr().localMgr.getBook(bookId);
        if (book != null) {
          Book newBook = await fetchBook(bookId);
          book.copyFromBook(newBook);
          // Guard against server-side duplicates caused by retried create operations
          book.recipeIds = book.recipeIds.toSet().toList();
          await book.save();
        }

        String changeRecipe = DatabaseMgr().localMgr.createChange();
        final changeRecipeResponse = await _securePostJsonRequest('/change/add', {
          'changeId': changeRecipe,
          'objectType': 'recipe',
          'operationType': OperationType.create.index,
          'objectId': recipe.id
        });
        String changeBook = DatabaseMgr().localMgr.createChange();
        final changeBookResponse = await _securePostJsonRequest('/change/add', {
          'changeId': changeBook,
          'objectType': 'book',
          'operationType': OperationType.update.index,
          'objectId': bookId
        });
        if (changeRecipeResponse != null && bool.parse(changeRecipeResponse.body) &&
            changeBookResponse != null && bool.parse(changeBookResponse.body)) {
          DatabaseMgr().localMgr.addChange(changeRecipe);
          DatabaseMgr().localMgr.addChange(changeBook);
        }
      } catch (e) {
        _log.warning('error', e);
      }
      // Server confirmed creation (201): always delete from queue regardless of change registration
      return OperationResult(action: OperationResultAction.delete, status: UpdateStatus.success);
    }
    if (response != null) {
      final status = UpdateStatus.getStatusFromHttpCode(response.statusCode);
      return OperationResult(action: OperationResultAction.getActionFromUpdateStatus(status), status: status);
    }
    return OperationResult(action: OperationResultAction.requeue, status: UpdateStatus.error);
  }

  Future<OperationResult> updateRecipe(RecipeUpdate recipeUpdate) async {
    final response = await _securePostJsonRequest('/recipes/update', recipeUpdate.toJson());

    if (response != null && response.statusCode == 200) {
      try {
        dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data == null) return OperationResult(action: OperationResultAction.requeue, status: UpdateStatus.error);

        String change = DatabaseMgr().localMgr.createChange();
        final changeResponse = await _securePostJsonRequest('/change/add', {
          'changeId': change,
          'objectType': 'recipe',
          'operationType': OperationType.update.index,
          'objectId': recipeUpdate.id
        });
        if (changeResponse != null && bool.parse(changeResponse.body)) {
          DatabaseMgr().localMgr.addChange(change);
          DatabaseMgr().localMgr.updateRecipeLastUpdate(recipeUpdate.id, DateTime.parse(data['dateTime']));
          return OperationResult(action: OperationResultAction.delete, status: UpdateStatus.success);
        }
      } catch (e) {
        _log.warning('error', e);
      }
      return OperationResult(action: OperationResultAction.requeue, status: UpdateStatus.error);
    }
    if (response != null) {
      final status = UpdateStatus.getStatusFromHttpCode(response.statusCode);
      return OperationResult(action: OperationResultAction.getActionFromUpdateStatus(status), status: status);
    }
    return OperationResult(action: OperationResultAction.requeue, status: UpdateStatus.error);
  }

  Future<OperationResult> deleteRecipe(Recipe recipe) async {
    final response = await _secureDeleteRequest('/recipes/delete', recipe.id);

    if (response != null && response.statusCode == 200) {
      try {
        String change = DatabaseMgr().localMgr.createChange();
        final changeResponse = await _securePostJsonRequest('/change/add', {
          'changeId': change,
          'objectType': 'recipe',
          'operationType': OperationType.delete.index,
          'objectId': recipe.id
        });
        if (changeResponse != null && bool.parse(changeResponse.body)) {
          DatabaseMgr().localMgr.addChange(change);
          return OperationResult(action: OperationResultAction.delete, status: UpdateStatus.success);
        }
      } catch (e) {
        _log.warning('error', e);
      }
      return OperationResult(action: OperationResultAction.requeue, status: UpdateStatus.error);
    }
    if (response != null) {
      final status = UpdateStatus.getStatusFromHttpCode(response.statusCode);
      return OperationResult(action: OperationResultAction.getActionFromUpdateStatus(status), status: status);
    }
    return OperationResult(action: OperationResultAction.requeue, status: UpdateStatus.error);
  }

  Future<OperationResult> uploadImage(RecipeImage recipeImage) async {
    final response = await _securePostMultipartRequest('/image/upload',
      File(recipeImage.path),
      [MapEntry('recipeId', recipeImage.recipeId), MapEntry('imageId', recipeImage.imageId)]
    );

    if (response != null && response.statusCode == 200) {
      return OperationResult(action: OperationResultAction.delete, status: UpdateStatus.success);
    }
    if (response != null) {
      final status = UpdateStatus.getStatusFromHttpCode(response.statusCode);
      return OperationResult(action: OperationResultAction.getActionFromUpdateStatus(status), status: status);
    }
    return OperationResult(action: OperationResultAction.requeue, status: UpdateStatus.error);
  }

  Future<MultipartFile?> downloadImage(String recipeId, String imageId) async {
    final response = await _secureGetRequest('/image/download/$recipeId/$imageId');
    if (response != null && response.statusCode == 200) {
      await DatabaseMgr().localMgr.fileStorage.writeImagefromBytes(bytes: response.bodyBytes, recipeId: recipeId, imageId: imageId);
    }
    else {
      _log.warning("unexpected status downloading image $recipeId/$imageId: ${response?.statusCode}");
    }

    return null;
  }

  Future<OperationResult> deleteImage(String recipeId, String imageId) async {
    final response = await _secureDeleteRequest('/image/delete', {
      'recipeId': recipeId,
      'imageId': imageId
    });

    if (response != null && response.statusCode == 200) {
      return OperationResult(action: OperationResultAction.delete, status: UpdateStatus.success);
    }
    if (response != null) {
      final status = UpdateStatus.getStatusFromHttpCode(response.statusCode);
      return OperationResult(action: OperationResultAction.getActionFromUpdateStatus(status), status: status);
    }
    return OperationResult(action: OperationResultAction.requeue, status: UpdateStatus.error);
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

  Future<String?> getLatestApk() async {
    final response = await _secureGetRequest('/apk/get_latest');
    if (response != null && response.statusCode == 200) {
      String? value = jsonDecode(utf8.decode(response.bodyBytes));
      if (value != null) {
        return value;
      }
    }
    return null;
  }
}