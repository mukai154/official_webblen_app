import 'package:flutter/material.dart';
import 'package:webblen/widgets_notifications/notification_bell.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StreamUserNotifications extends StatelessWidget {

  final String uid;
  final VoidCallback notifAction;

  StreamUserNotifications({this.uid, this.notifAction});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection("user_notifications")
            .where('uid', isEqualTo: uid)
            .where('notificationSeen', isEqualTo: false)
            .snapshots(),
        builder: (BuildContext context, notifSnapshot) {
          if (!notifSnapshot.hasData) return Container();
          int notifCount = notifSnapshot.data.documents.length;
          return GestureDetector(
            onTap: notifAction,
            child: Padding(
              padding: EdgeInsets.only(right: 8.0, top: 6.0),
              child: NotificationBell(notificationCount: notifCount == null ? 0 : notifCount),
            ),
          );
        });
  }
}
