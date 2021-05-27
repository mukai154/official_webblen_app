import 'package:flutter/material.dart';
import 'package:webblen/constants/custom_colors.dart';

class LiveNowBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[CustomColors.webblenRed, CustomColors.webblenPink],
          ),
          borderRadius: BorderRadius.all(Radius.circular(4.0))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        child: Text(
          'LIVE',
          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class OffAirBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Colors.black26, Colors.black26],
          ),
          borderRadius: BorderRadius.all(Radius.circular(4.0))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        child: Text(
          'OFF AIR',
          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
