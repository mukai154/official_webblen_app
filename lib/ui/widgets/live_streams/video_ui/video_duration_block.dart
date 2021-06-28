import 'package:flutter/material.dart';
import 'package:webblen/utils/time_calc.dart';

class VideoDurationBlock extends StatelessWidget {
  final double durationInSeconds;
  VideoDurationBlock({required this.durationInSeconds});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.all(Radius.circular(4.0))),
      height: 24,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              TimeCalc().getStringFromDurationInSeconds(durationInSeconds),
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
