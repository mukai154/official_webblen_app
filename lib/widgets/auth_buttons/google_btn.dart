import 'package:flutter/material.dart';

class GoogleBtn extends StatelessWidget {
  final VoidCallback action;
  GoogleBtn({this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(4.0),
        onTap: () {
          action();
        },
        child: Container(
          child: Image.asset(
            'assets/images/google_logo.png',
            height: 55,
            width: 55,
          ),
        ),
      ),
    );
  }
}
