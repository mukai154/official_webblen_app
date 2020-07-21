import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/styles/fonts.dart';

class AppleBtn extends StatelessWidget {
  final String buttonText = "Login with Apple";
  final colorApple = Colors.black;
  final VoidCallback action;
  AppleBtn({this.action});

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 6.0),
      child: Material(
        elevation: 2.0,
        color: colorApple,
        borderRadius: BorderRadius.circular(14.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.0),
          onTap: () {
            action();
          },
          child: Container(
            height: 45.0,
            width: MediaQuery.of(context).size.width * 0.85,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(FontAwesomeIcons.apple, color: Colors.white, size: 18.0),
                SizedBox(width: 16.0),
                MediaQuery(
                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), child: Fonts().textW700(buttonText, 15.0, Colors.white, TextAlign.left)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
