import 'package:flutter/material.dart';

class CustomColors {
  ///COMMON COLORS
  static const carminPink = Color.fromRGBO(235, 77, 75, 1.0);
  static const turboYellow = Color.fromRGBO(249, 202, 36, 1.0);
  static const facebookBlue = Color.fromRGBO(59, 89, 152, 1.0);
  static const twitterBlue = Color.fromRGBO(29, 161, 242, 1.0);
  static const darkMountainGreen = Color.fromRGBO(16, 172, 132, 1.0);
  static const cashAppGreen = Color.fromRGBO(40, 193, 1, 1.0);
  static const iosOffWhite = Color(0xFFF9F9F9);
  static const textFieldGray = Color.fromARGB(255, 241, 241, 241);
  static const steelGray = Color.fromRGBO(61, 61, 61, 1.0);

  ///WEBBLEN APP COLOR SWATCH
  static const webblenRed = Color.fromRGBO(253, 36, 61, 1.0);
  static const webblenRedLowOpacity = Color.fromRGBO(253, 36, 61, 0.1);
  static const webblenPink = Color.fromRGBO(248, 87, 166, 1.0);
  static const webblenMatteBlue = Color.fromRGBO(63, 61, 86, 1.0);
  static const webblenMidGray = Color.fromRGBO(182, 182, 189, 1.0);
  static const webblenDarkGray = Color.fromRGBO(25, 25, 25, 1.0);

  ///GRADIENTS
  static const LinearGradient webblenGradient = LinearGradient(
    colors: [
      webblenRed,
      webblenPink,
    ],
  );

  static const LinearGradient livestreamBlockGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Colors.black38],
  );
}
