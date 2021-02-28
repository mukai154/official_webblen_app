import 'dart:math';

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

///RANDOM STRING GENERATOR
String getRandomString(int length) => String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

///STRING VALIDATION
bool isValidUrl(String val) {
  bool urlValid =
      RegExp(r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?").hasMatch(val);
  return urlValid;
}

bool isValidEmail(String val) {
  bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val);
  return emailValid;
}

bool isValidPassword(String val) {
  bool passwordValid = RegExp(
          r'^(?:(?=.*?[A-Z])(?:(?=.*?[0-9])(?=.*?[-!@#$%^&*()_[\]{},.<>+=])|(?=.*?[a-z])(?:(?=.*?[0-9])|(?=.*?[-!@#$%^&*()_[\]{},.<>+=])))|(?=.*?[a-z])(?=.*?[0-9])(?=.*?[-!@#$%^&*()_[\]{},.<>+=]))[A-Za-z0-9!@#$%^&*()_[\]{},.<>+=-]{7,50}$')
      .hasMatch(val);
  return passwordValid;
}

bool isValidString(String val) {
  bool isValid = true;
  if (val == null || val.isEmpty) {
    isValid = false;
  }
  return isValid;
}

///OTHER
String getLastWordInString(String val) {
  List words = val.split(" ");
  return words.last;
}

String replaceLastWordInString(String originalString, String newWord) {
  if (originalString.split(" ").length == 1) {
    return "$newWord";
  } else {
    return originalString.substring(0, originalString.lastIndexOf(" ")) + " $newWord";
  }
}

List<String> getListOfUsernamesFromString(String val) {
  List<String> usernames = [];
  List<String> words = val.split(" ");
  words.forEach((word) {
    if (word.startsWith("@")) {
      String username = word.substring(1, word.length - 1);
      usernames.add(username);
    }
  });
  return usernames;
}
