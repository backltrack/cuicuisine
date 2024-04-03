import 'dart:async';
import 'dart:convert';

import 'package:cuicuisine/database/database_mgr.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

class InvalidEmailException implements Exception {
  @override
  String toString() {
    return "InvalidEmailException: This Email address doesn't exist in the database.";
  }
}

class InvalidPasswordException implements Exception {
  @override
  String toString() {
    return "InvalidPasswordException: Wrong password, try again.";
  }
}

class IncorrectPasswordException implements Exception {
  @override
  String toString() {
    return "IncorrectPasswordException: Password doesn't satisfy security contraints.";
  }
}

class EmailAlreadyExistsException implements Exception {
  @override
  String toString() {
    return "EmailAlreadyExistsException: An account using this email already exists.";
  }
}


class OAuth2Connexion {

  OAuth2Connexion();


  /// Either load an OAuth2 client from saved credentials or authenticate a new
  /// one.
  static oauth2.Client createClientFromCredentials({required String savedCredentials}) {
    var credentials = oauth2.Credentials.fromJson(savedCredentials);
    return oauth2.Client(credentials);
  }

  static Future<oauth2.Client?> connectFromPassword({required String serverUri, required String email, required String password}) async {

    try {
      oauth2.Client client = await oauth2.resourceOwnerPasswordGrant(Uri.parse("$serverUri/token"), email, password);

      DatabaseMgr().localMgr.saveCredentials(client.credentials.toJson());
      
      return client;

    } on Exception catch(e) {
      if (e.toString().contains("Incorrect email")) {

        throw InvalidEmailException();
      }
      else if (e.toString().contains("Incorrect password")) {
        throw InvalidPasswordException();
      }
      else {
        print(e);
      }
    }
    
    return null;
  }

  static Future<oauth2.Client?> createClientFromPassword({required String serverUri, required String email, required String password}) async {

    try {
      oauth2.Client client = await oauth2.resourceOwnerPasswordGrant(Uri.parse("$serverUri/register"), email, password);
      print(client.credentials.toJson());

      DatabaseMgr().localMgr.saveCredentials(client.credentials.toJson());
      
      return client;

    } on Exception catch(e) {
      if (e.toString().contains("Incorrect password")) {

        throw IncorrectPasswordException();
      }
      else if (e.toString().contains("Email already exists")) {

        throw EmailAlreadyExistsException();
      }
      else {
        print(e);
      }
    }
    
    return null;
  }

  static Future<oauth2.Client?> refreshToken({required String serverUri, required oauth2.Client client}) async {
    Uri server = Uri.parse(serverUri);

    var body = {
      'grant_type': 'refresh_token',
      'refresh_token': client.credentials.refreshToken
    };

    var response = await client.post(Uri(scheme: server.scheme, host: server.host, port: server.port, path: '/refresh_token'), 
      body: body);
    
    Map<String, dynamic> data = jsonDecode(response.body);
    oauth2.Credentials newCred = oauth2.Credentials(
      data['access_token'],
      refreshToken: client.credentials.refreshToken,
      scopes: client.credentials.scopes,
      //expiration: DateTime.fromMillisecondsSinceEpoch(data['expires_in']*1000),
      tokenEndpoint: client.credentials.tokenEndpoint,
      idToken: client.credentials.idToken
    );
    oauth2.Client newclient = oauth2.Client(newCred);

    DatabaseMgr().localMgr.saveCredentials(client.credentials.toJson());

    return newclient;
  }
}

