import 'dart:math';

String getInitials(String name) {
  final List<String> splitName = name.split(' ');
  final String firstName = splitName[0];
  final String lastName = splitName.sublist(1).join('').trim();
  if (lastName != "") {
    return firstName[0] + lastName[0];
  } else if (firstName != "") {
    return firstName[0];
  } else {
    return "";
  }
}

String getRandomChar(int length){
  const ch = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
  Random r = Random();
  return String.fromCharCodes(Iterable.generate(
      length, (_) => ch.codeUnitAt(r.nextInt(ch.length))));
}

bool isEmailValid(String email) {
  RegExp exp = RegExp(r'^.+@.+\..+$');
  return exp.firstMatch(email) != null;
}

String beautifyName(String name) {
  return name[0].toUpperCase() + name.substring(1).trim();
}

List<dynamic> moveListItem(List<dynamic> workingList, int oldIndex, int newIndex){
  var item = workingList[oldIndex];
  workingList.removeAt(oldIndex);
  workingList.insert(newIndex, item);
  return workingList;
}