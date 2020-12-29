import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';

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
          ? appFontColor()
          : color,
    ),
  );
}
