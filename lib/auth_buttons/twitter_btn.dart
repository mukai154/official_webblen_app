import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TwitterBtn extends StatelessWidget {

  final String buttonText = "Login with Twitter";
  final colorTwitter = Color.fromRGBO(29, 161, 242, 1.0);
  final VoidCallback action;
  TwitterBtn({this.action});

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      child: Material(
        elevation: 5.0,
        color: colorTwitter,
        borderRadius: BorderRadius.circular(25.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(25.0),
          onTap: () { action(); },
          child: Container(
            height: 45.0,
            width: MediaQuery.of(context).size.width * 0.85,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(FontAwesomeIcons.twitter, color: Colors.white, size: 18.0),
                SizedBox(width: 16.0),
                Text(buttonText, style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}