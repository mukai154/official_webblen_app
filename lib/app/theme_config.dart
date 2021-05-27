import 'package:flutter/material.dart';
import 'package:webblen/constants/custom_colors.dart';

final String fontFamily = "Helvetica Neue";

ThemeData regularTheme = ThemeData(
  backgroundColor: Colors.white,
  accentColor: CustomColors.webblenRed,
  brightness: Brightness.light,
  fontFamily: fontFamily,
);

ThemeData darkTheme = ThemeData(
  backgroundColor: CustomColors.webblenDarkGray,
  accentColor: CustomColors.webblenRed,
  brightness: Brightness.dark,
  fontFamily: fontFamily,
);

List<ThemeData> appThemes = [
  regularTheme,
  darkTheme,
];
