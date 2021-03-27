import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RecordingBox extends StatelessWidget {
  final VoidCallback endRecording;
  RecordingBox({this.endRecording});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: endRecording,
      child: Container(
        decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.all(Radius.circular(4.0))),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
          child: Row(
            children: [
              Text(
                'Recording',
                style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8.0),
              Icon(
                FontAwesomeIcons.solidCircle,
                size: 8.0,
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotRecordingBox extends StatelessWidget {
  final VoidCallback beginRecording;
  NotRecordingBox({this.beginRecording});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: beginRecording,
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[Colors.black26, Colors.black26],
            ),
            borderRadius: BorderRadius.all(Radius.circular(4.0))),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
          child: Text(
            'Begin Recording',
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
