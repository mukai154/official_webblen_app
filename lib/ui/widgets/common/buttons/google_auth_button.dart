import 'package:flutter/material.dart';

class GoogleAuthButton extends StatelessWidget {
  final VoidCallback? action;
  GoogleAuthButton({this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.0),
      child: Material(
        elevation: 0.0,
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(4.0),
          onTap: action,
          child: Container(
            child: Image.asset(
              'assets/images/google_logo.png',
              height: 55,
              width: 55,
            ),
          ),
        ),
      ),
    );
  }
}
