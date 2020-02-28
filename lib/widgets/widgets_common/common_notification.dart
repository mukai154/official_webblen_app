import 'package:flutter/material.dart';

import 'package:webblen/styles/flat_colors.dart';

class NotificationBubble extends StatelessWidget {
  final String notificationCount;

  NotificationBubble(
    this.notificationCount,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: FlatColors.webblenRed,
        shape: BoxShape.circle,
      ),
      child: Text(
        notificationCount,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
