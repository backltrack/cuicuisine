import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'database_mgr.dart';

class FileStorage {
  static final FileStorage _instance = FileStorage._();

  String storagePath = ".";

  factory FileStorage() {
    return _instance;
  }

  FileStorage._() {
    init();
  }

  void init() async {
    if (!kIsWeb) {
      if (Platform.isLinux) {
        storagePath = '${Platform.environment['HOME']}/.local/share/com.example.cuicuisine/';
      }
      else {
        Directory documentDirectoryPath = await getApplicationDocumentsDirectory();
        storagePath = documentDirectoryPath.path;
      }  
    }
  }

  Future<bool> imageExists({required String recipeId, required String imageId}) async {
    if (kIsWeb) {
      return DatabaseMgr().localMgr.webImageExists(recipeId: recipeId, imageId: imageId);
    }
    String path = idToPath(recipeId: recipeId, imageId: imageId);
    return await File(path).exists();
  }

  String idToPath({required String recipeId, required String imageId}) {
    return p.join(storagePath, "storage", recipeId, imageId);
  }

  Map<String, String>? pathToId(String path) {
    if (path.contains(p.join(storagePath, "storage"))) {
      String imageId = path.split('/').removeLast();
      String recipeId = path.split('/').removeLast();
      return {'imageId': imageId, 'recipeId': recipeId};
    }
    return null;
  }

  Future<Image?> readImage({required String recipeId, required String imageId}) async {
    if (kIsWeb) {
      return await DatabaseMgr().localMgr.readWebImage(recipeId: recipeId, imageId: imageId);
    }
    File file = File(idToPath(recipeId: recipeId, imageId: imageId));
    if (await file.exists()) {
      return Image.file(file);
    }
    return null;
  }

  Future<String?> writeImage({required XFile image, required String recipeId, required String imageId}) async {
    if (kIsWeb) {
      return await DatabaseMgr().localMgr.writeWebImage(image: image, recipeId: recipeId, imageId: imageId);
    }
    String storePath = p.join(storagePath, "storage");
    String recipePath = p.join(storePath, recipeId);
    String imagePath = p.join(recipePath, imageId);

    if (!await File(storePath).exists()) {
      await Directory(storePath).create();
    }
    if (!await File(recipePath).exists()) {
      await Directory(recipePath).create();
    }
    
    try {
      await image.saveTo(imagePath);
      return imagePath;
    } catch (e) {
      print(e);
    }

    return null;
  }

  Future<String?> writeImagefromBytes({required List<int> bytes, required String recipeId, required String imageId}) async {
    if (kIsWeb) {
      return await DatabaseMgr().localMgr.writeWebImagefromBytes(bytes: bytes, recipeId: recipeId, imageId: imageId);
    }
    String storePath = p.join(storagePath, "storage");
    String recipePath = p.join(storePath, recipeId);
    String imagePath = p.join(recipePath, imageId);

    if (!await File(storePath).exists()) {
      await Directory(storePath).create();
    }
    if (!await File(recipePath).exists()) {
      await Directory(recipePath).create();
    }
    
    try {
      File file = File(imagePath);
      await file.writeAsBytes(bytes);
      return imagePath;
    } catch (e) {
      print(e);
    }

    return null;
  }

  Future<bool> deleteImage({required String recipeId, required String imageId}) async {
    if (kIsWeb) {
      return await DatabaseMgr().localMgr.deleteWebImage(recipeId: recipeId, imageId: imageId);
    }
    String path = idToPath(recipeId: recipeId, imageId: imageId);
    if (await File(path).exists()) {
      try {
        await File(path).delete();
        return true;
      }
      catch (e) {
        return false;
      }
    }
    return false;
  }

  Future<List<String>> getAllRecipeImages(String recipeId) async {
    if (kIsWeb) {
      return [];
    }
    String storePath = p.join(storagePath, "storage");
    String recipePath = p.join(storePath, recipeId);

    List<String> images = [];

    if (!await File(storePath).exists()) {
      await Directory(storePath).create();
    }
    if (!await File(recipePath).exists()) {
      await Directory(recipePath).create();
    }
    
    List<FileSystemEntity> imagesList = Directory(recipePath).listSync();
    for (FileSystemEntity entity in imagesList) {
      if (entity is File) {
        images.add(entity.path);
      }
    }
    return images;
  }
}