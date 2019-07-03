import 'package:flutter/material.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';

class MyCommunitiesTile extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.only(left: 30.0),
      child: Row(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.people, color: Colors.black, size: 28.0),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Fonts().textW700('My Communities', 20.0, Colors.black, TextAlign.left),
                Fonts().textW500("Communities that you're a part of or follow", 12.0, Colors.black, TextAlign.left),
              ],
            ),
          )
        ],
      ),
    );
  }
}