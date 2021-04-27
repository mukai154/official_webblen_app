import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ViewerCountBox extends StatelessWidget {
  final int? viewCount;
  ViewerCountBox({this.viewCount});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.all(Radius.circular(4.0))),
      height: 24,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              FontAwesomeIcons.eye,
              color: Colors.white,
              size: 12,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              '$viewCount',
              style: TextStyle(color: Colors.white, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
