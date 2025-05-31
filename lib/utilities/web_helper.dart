import 'package:file_saver/file_saver.dart';

Future<void> downloadFile(String downloadURL) async {
    // Créer un élément d'ancrage HTML
    FileSaver.instance.saveFile(
      name: "cuicuisine",
      ext: "apk",
      link: LinkDetails(link: downloadURL)
    );
}