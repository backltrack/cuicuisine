import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
    Directory documentDirectoryPath = await getApplicationDocumentsDirectory();
    storagePath = documentDirectoryPath.path;
  }

  Future<bool> imageExists({required String recipeId, required String imageId}) async {
    String path = p.join(storagePath, "storage", recipeId, imageId);
    return await File(path).exists();
  }

  Future<Image?> readImage({required String recipeId, required String imageId}) async {
    String path = p.join(storagePath, "storage", recipeId, imageId);
    File file = File(path);
    if (await file.exists()) {
      return Image.file(file);
    }
    return null;
  }

  Future<String?> writeImage({required XFile image, required String recipeId, required String imageId}) async {
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
}