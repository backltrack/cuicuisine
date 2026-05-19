import 'dart:io';
import 'package:file_picker/file_picker.dart';

Future<void> exportAllAsJson() async {
  // retrieve all database information to export
  // String data = await getAllUserData();

  // get output directory and export
  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

  if (selectedDirectory != null) {
    File saveFile = File('$selectedDirectory/export.txt');
    // await saveFile.writeAsString(data);
  }
}
