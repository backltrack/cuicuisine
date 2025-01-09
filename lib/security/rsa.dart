import 'package:flutter/services.dart' show rootBundle;

import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart'; // For RSA key parsing

class RSAEncrypter {
  static final RSAEncrypter _instance = RSAEncrypter._internal();

  factory RSAEncrypter() => _instance;

  RSAEncrypter._internal();

  static Future<String> encryptData(String plainText) async {
    final parser = RSAKeyParser();
    
    final publicPem = await rootBundle.loadString('assets/keys/public_key.pem');
    RSAPublicKey publicKey = parser.parse(publicPem) as RSAPublicKey;

    final encrypter = Encrypter(RSA(publicKey: publicKey, encoding: RSAEncoding.OAEP, digest: RSADigest.SHA1));

    // Encrypt the data
    final encryptedData = encrypter.encrypt(plainText);
    return encryptedData.base64;  // Encrypted output in base64 format
  }
}
