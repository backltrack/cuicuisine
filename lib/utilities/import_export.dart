import 'dart:io';
import 'package:file_picker/file_picker.dart';

Future<void> exportAllAsJson() async {
  // retrieve all database information to export
  // String data = await getAllUserData();

  // get output directory and export
  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

  if (selectedDirectory != null) {
    File saveFile = File(selectedDirectory + '/export.txt');
    // await saveFile.writeAsString(data);
  }
}

Future<void> importJson(userId) async {
 // get json file path
  FilePickerResult? selectedFile = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.custom, allowedExtensions: ['txt', 'json']);

  if (selectedFile != null) {
    String? file = selectedFile.paths[0];
    if (file != null) {
      String stringData = await File(file).readAsString();
      print(stringData);
      // TODO: refill database
    }
  }
}