import 'package:flutter/material.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class SearchTile extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.only(left: 30.0),
      child: Row(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.search, color: Colors.black, size: 24.0),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 250.0,
                  child: TypewriterAnimatedTextKit(
                      duration: Duration(seconds: 20),
                      text: [
                        "Find Communities",
                        "Find Events",
                        "Find Things to Do",
                        "Find Friends",
                      ],
                      textStyle: TextStyle(
                        fontFamily: 'Barlow',
                        fontSize: 16.0,
                        color: Colors.black26,
                      ),
                      textAlign: TextAlign.start,
                      alignment: AlignmentDirectional.topStart // or Alignment.topLeft
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}