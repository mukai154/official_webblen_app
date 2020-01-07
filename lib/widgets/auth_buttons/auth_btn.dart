import 'package:flutter/material.dart';
import 'package:webblen/styles/fonts.dart';

class AuthBtn extends StatelessWidget {
  final String buttonText;
  final VoidCallback action;
  final Icon icon;
  final Color color;
  final Color textColor;
  
  AuthBtn({
    this.action,
    this.buttonText,
    this.icon,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: EdgeInsets.symmetric(
        vertical: 6.0,
      ),
      child: Material(
        elevation: 2.0,
        color: color,
        borderRadius: BorderRadius.circular(25.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(25.0),
          onTap: () {
            action();
          },
          child: Container(
            height: 45.0,
            width: MediaQuery.of(context).size.width * 0.85,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                icon,
                SizedBox(
                  width: 16.0,
                ),
                MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaleFactor: 1.0,
                  ),
                  child: Fonts().textW400(
                    buttonText,
                    16.0,
                    textColor,
                    TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
