import 'package:flutter/material.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DiscoverTile extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 30.0),
      child: Row(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(FontAwesomeIcons.star, color: Colors.black87, size: 24.0),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Fonts().textW700('Discover', 20.0, Colors.black, TextAlign.left),
                Fonts().textW500('Find Popular and Active Communities Near You', 12.0, Colors.black87, TextAlign.left),
              ],
            ),
          )
        ],
      ),
    );
  }
}