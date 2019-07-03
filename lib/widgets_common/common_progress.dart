import 'package:flutter/material.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';

class CustomLinearProgress extends StatelessWidget {

  final Color progressBarColor;
  CustomLinearProgress({this.progressBarColor});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        accentColor: progressBarColor,
      ),
      child: Container(
        height: 2.0,
        child: LinearProgressIndicator(backgroundColor: Colors.transparent),
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

  CustomCircleProgress(this.containerHeight, this.containerWidth, this.progressHeight, this.progressWidth, this.progressColor);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
          accentColor: progressColor
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

class ProgressDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: CustomCircleProgress(60.0, 60.0, 30.0, 30.0, Colors.grey),
    );
  }
}

class LoadingScreen extends StatelessWidget {

  final BuildContext context;
  final String loadingDescription;
  LoadingScreen({this.context, this.loadingDescription});

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: MediaQuery.of(context).size.width,
      child: new Column /*or Column*/(
        children: <Widget>[
          SizedBox(height: 230.0),
          CustomLinearProgress(progressBarColor: FlatColors.webblenRed),
          SizedBox(height: 12.0),
          loadingDescription != null
              ? Fonts().textW500(loadingDescription, 15.0, FlatColors.darkGray, TextAlign.center)
              : Container()
          //SizedBox(height: 16.0),
        ],
      ),
    );
  }
}