import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';

import 'notification_bell_view_model.dart';

class NotificationBellView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NotificationBellViewModel>.reactive(
      viewModelBuilder: () => NotificationBellViewModel(),
      builder: (context, model, child) => model.unreadNotifications > 0
          ? GestureDetector(
              onTap: () => model.navigateToNotificationsView(),
              child: Container(
                height: 25,
                width: 25,
                padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                decoration: BoxDecoration(
                  color: appActiveColor(),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Text(
                      model.unreadNotifications >= 10
                        ? "10+"
                        : model.unreadNotifications.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : GestureDetector(
              onTap: () => model.navigateToNotificationsView(),
              child: Container(
                height: 25,
                width: 25,
                child: Center(
                  child: Icon(
                    FontAwesomeIcons.bell,
                    size: 20,
                    color: appIconColor(),
                  ),
                ),
              ),
            ),
    );
  }
}
