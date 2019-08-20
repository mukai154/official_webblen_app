import 'package:flutter/material.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';

class WebblenEventsTile extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 30.0),
      child: Row(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(FontAwesomeIcons.hotjar, color: FlatColors.webblenRed, size: 24.0),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Shimmer.fromColors(
                  baseColor: FlatColors.webblenRed,
                  highlightColor: FlatColors.webblenPink,
                  child: Text(
                    'Webblen Events',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
                Fonts().textW500('Discounted Tickets and Pricing to Exclusive Webblen Events', 10.0, Colors.black87, TextAlign.left),
              ],
            ),
          )
        ],
      ),
    );
  }
}