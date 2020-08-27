import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final BuildContext context;
  final String text;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final bool underline;
  final int maxLines;

  CustomText({this.context, this.text, this.textColor, this.fontSize, this.fontWeight, this.textAlign, this.underline, this.maxLines});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.00),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
          decoration: underline != null && underline ? TextDecoration.underline : TextDecoration.none,
        ),
        maxLines: maxLines == null ? null : maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
      ),
    );
  }
}
