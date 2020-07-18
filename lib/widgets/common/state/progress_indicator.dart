import 'package:flutter/material.dart';

class CustomLinearProgress extends StatelessWidget {
  final Color progressBarColor;

  CustomLinearProgress({
    this.progressBarColor,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        accentColor: progressBarColor,
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

class CustomCircleProgress extends StatelessWidget {
  final double containerHeight;
  final double containerWidth;
  final double progressHeight;
  final double progressWidth;
  final Color progressColor;

  CustomCircleProgress(
    this.containerHeight,
    this.containerWidth,
    this.progressHeight,
    this.progressWidth,
    this.progressColor,
  );

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        accentColor: progressColor,
      ),
      child: Container(
        height: containerHeight,
        width: containerWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: progressHeight,
              width: progressWidth,
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}
