import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'notif_bell.dart';

class NotificationStream extends StatelessWidget {
  final String uid;
  final VoidCallback onTap;

  NotificationStream({
    this.uid,
    this.onTap,
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
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.only(
              right: 8.0,
              top: 6.0,
            ),
            child: NotifBell(
              notifCount: notifCount == null ? 0 : notifCount,
            ),
          ),
        );
      },
    );
  }
}
