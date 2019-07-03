import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/styles/fonts.dart';

class StatsImpact extends StatelessWidget {

  final String impactPoints;
  final Color textColor;
  final double textSize;
  final double iconSize;
  final VoidCallback onTap;
  StatsImpact({this.impactPoints, this.textColor, this.textSize, this.onTap, this.iconSize});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
          children: <Widget>[
            Icon(FontAwesomeIcons.bolt, size: iconSize, color: textColor),
            Container(width: 1.0),
            Fonts().textW500(impactPoints, textSize, textColor, TextAlign.start)
          ]
      ),
    );
  }
}