import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FacebookBtn extends StatelessWidget {

  final String buttonText = "Login with Facebook";
  final colorFacebook = Color.fromRGBO(59, 89, 152, 1.0);
  final VoidCallback action;
  FacebookBtn({this.action});

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 6.0),
      child: Material(
        elevation: 2.0,
        color: colorFacebook,
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
                Icon(FontAwesomeIcons.facebook, color: Colors.white, size: 18.0),
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