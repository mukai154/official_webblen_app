import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';

class CustomLinearProgress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        accentColor: appActiveColor(),
      ),
      child: Container(
        height: 2.0,
        child: LinearProgressIndicator(
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}
