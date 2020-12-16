class StringValidator {
  bool isUsernameValid(String val) {
    bool userNameIsValid = RegExp(r'^[a-zA-Z0-9]+$').hasMatch(val);
    return userNameIsValid;
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
}
