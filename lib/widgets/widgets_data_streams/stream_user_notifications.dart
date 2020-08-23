import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:webblen/widgets/widgets_notifications/notification_icon.dart';

class StreamUserNotifications extends StatelessWidget {
  final String uid;
  final VoidCallback notifAction;

  StreamUserNotifications({
    this.uid,
    this.notifAction,
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
          child: NotificationIcon(
            notificationCount: notifCount == null ? 0 : notifCount,
          ),
        );
      },
    );
  }
}
