import 'package:flutter/material.dart';
import 'package:webblen/constants/custom_colors.dart';

final String fontFamily = "Helvetica Neue";

ThemeData regularTheme = ThemeData(
  backgroundColor: Colors.white,
  brightness: Brightness.light,
  fontFamily: fontFamily,
);

ThemeData darkTheme = ThemeData(
  backgroundColor: CustomColors.webblenDarkGray,
  brightness: Brightness.dark,
  fontFamily: fontFamily,
);

List<ThemeData> appThemes = [
  regularTheme,
  darkTheme,
];
