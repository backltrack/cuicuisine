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


class EmailPasswordValidator {
  static const int passwordLength = 6;

  EmailPasswordValidator();

  static bool isEmailValid(String email) {
    RegExp exp = RegExp(r'^.+@.+\..+$');
    return exp.firstMatch(email) != null;
  }

  static bool checkPasswordLength(String password) {
    return password.length >= passwordLength;
  }

  static bool checkPasswordContainsLowerUpper(String password) {
    return password.toLowerCase() != password && password.toUpperCase() !=  password;
  }

  static bool checkPasswordContainsDigit(String password) {
    RegExp exp = RegExp(r".*\d.*");
    return exp.hasMatch(password);
  }

  static bool checkPasswordContainsSpecials(String password) {
    String test = r"[\W]";
    RegExp exp = RegExp(test);
    print(exp);
    return exp.hasMatch(password);
  }

  static bool isPasswordValid(String password) {
    return checkPasswordLength(password);// && checkPasswordContainsLowerUpper(password) && checkPasswordContainsDigit(password) && checkPasswordContainsSpecials(password);
  }
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