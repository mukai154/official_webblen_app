class Strings {
  static final String googleAPIKEY = "AIzaSyBJVHmY_WAjWfpz69S_4n-Bt6HRc-YO6WM";
  static final String proxyMapsURL =
      "https://cors-anywhere.herokuapp.com/https://maps.googleapis.com/maps/api";

  //Methods
  bool isEmailValid(String val) {
    bool emailValid = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(val);
    return emailValid;
  }
}
