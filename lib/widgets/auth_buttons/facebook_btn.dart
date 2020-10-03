import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FacebookBtn extends StatelessWidget {
  final colorFacebook = Color.fromRGBO(59, 89, 152, 1.0);
  final VoidCallback action;
  FacebookBtn({this.action});

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.0),
      child: Material(
        elevation: 2.0,
        color: colorFacebook,
        borderRadius: BorderRadius.circular(4.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(4.0),
          onTap: () {
            action();
          },
          child: Container(
            height: 45.0,
            width: 45.0,
            child: Center(
              child: Icon(FontAwesomeIcons.facebookF, color: Colors.white, size: 24.0),
            ),
          ),
        ),
      ),
    );
  }
}
