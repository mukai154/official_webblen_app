import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/constants/custom_colors.dart';

class StreamUserNotifications extends StatelessWidget {
  final String uid;
  final VoidCallback notifAction;
  final bool pageIsActive;

  StreamUserNotifications({
    this.uid,
    this.notifAction,
    this.pageIsActive,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection("user_notifications")
          .where(
            'uid',
            isEqualTo: uid,
          )
          .where(
            'notificationSeen',
            isEqualTo: false,
          )
          .snapshots(),
      builder: (BuildContext context, notifSnapshot) {
        if (!notifSnapshot.hasData) return Container();
        int notifCount = notifSnapshot.data.documents.length;
        return GestureDetector(
          onTap: notifAction,
          child: Stack(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  right: 4.0,
                  top: 0.0,
                ),
                child: Icon(
                  FontAwesomeIcons.solidEnvelope,
                  size: 22.0,
                  color: pageIsActive ? CustomColors.webblenRed : CustomColors.darkGray,
                ),
              ),
              Positioned(
                top: 0.0,
                right: 0.0,
                child: notifCount != null && notifCount > 0
                    ? Container(
                        height: 10.0,
                        width: 10.0,
                        decoration: BoxDecoration(
                          color: CustomColors.webblenRed,
                          shape: BoxShape.circle,
                        ),
                      )
                    : Container(
                        height: 0.0,
                        width: 0.0,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
