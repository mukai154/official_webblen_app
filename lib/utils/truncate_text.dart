import 'package:flutter/material.dart';

class TruncText extends StatelessWidget {
  final double containerWidth;
  final String text;
  final double textSize;
  final Color textColor;
  final TextAlign textAlign;

  TruncText({
    this.containerWidth,
    this.text,
    this.textSize,
    this.textColor,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: containerWidth,
      child: Text(
        text,
        textAlign: textAlign != null ? textAlign : TextAlign.left,
        style: TextStyle(
          fontFamily: 'Helvetica Neue',
          fontSize: textSize,
          fontWeight: FontWeight.w700,
          color: textColor != null ? textColor : Colors.black,
        ),
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
