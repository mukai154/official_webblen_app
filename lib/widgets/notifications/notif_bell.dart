import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/styles/custom_text.dart';

class NotifBell extends StatelessWidget {
  final int notifCount;

  NotifBell({
    this.notifCount,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            right: 4.0,
            top: 18.0,
          ),
          child: Icon(
            FontAwesomeIcons.bell,
            size: 24.0,
            color: Colors.black,
          ),
        ),
        Positioned(
          top: 12.0,
          right: 0.0,
          child: notifCount != null && notifCount > 0
              ? Container(
                  height: 20.0,
                  width: 20.0,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: CustomText(
                        context: context,
                        text: notifCount.toString(),
                        textColor: Colors.white,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                )
              : Container(
                  height: 0.0,
                  width: 0.0,
                ),
        ),
      ],
    );
  }
}
