import 'package:flutter/material.dart';
import 'package:stacked_themes/stacked_themes.dart';

Widget customText({
  @required BuildContext context,
  @required String text,
  @required double fontSize,
  @required FontWeight fontWeight,
  Color color,
}) {
  return Text(
    text,
    style: TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color == null
          ? getThemeManager(context).isDarkMode
              ? Colors.white70
              : Colors.black
          : color,
    ),
  );
}
