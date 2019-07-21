import 'package:flutter/material.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NotificationBell extends StatelessWidget {

  final int notificationCount;
  NotificationBell({this.notificationCount});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: 4.0, top: 18.0),
          child: Icon(FontAwesomeIcons.bell, size: 24.0, color: Colors.black),
        ),
        new Positioned(
         top: 12.0,
         right: 0.0,
         child: notificationCount != null && notificationCount > 0
             ? Container(
                  height: 20.0,
                  width: 20.0,
                  decoration: BoxDecoration(
                    color: FlatColors.webblenRed,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Fonts().textW500(notificationCount.toString(), 12.0, Colors.white, TextAlign.center),
                    ),
                  )
                )
             : Container(height: 0.0, width: 0.0)
        )
      ] 
    );
  }
}