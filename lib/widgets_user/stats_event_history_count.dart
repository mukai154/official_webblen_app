import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/styles/fonts.dart';

class StatsEventHistoryCount extends StatelessWidget {

  final String eventHistoryCount;
  final Color textColor;
  final double textSize;
  final double iconSize;
  final VoidCallback onTap;
  StatsEventHistoryCount({this.eventHistoryCount, this.textColor, this.textSize, this.iconSize, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child:  Row(
          children: <Widget>[
            Icon(FontAwesomeIcons.calendarAlt, size: iconSize, color: textColor),
            Container(width: 3.0),
            Padding(
              padding: EdgeInsets.only(top: 3.0),
              child: Fonts().textW500(eventHistoryCount, textSize, textColor, TextAlign.start),
            ),
          ]
      ),
    );
  }
}

