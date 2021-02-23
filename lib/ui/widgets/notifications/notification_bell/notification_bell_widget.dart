import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';

import 'notification_bell_model.dart';

class NotificationBellWidget extends StatelessWidget {
  final String uid;
  NotificationBellWidget({
    @required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NotificationBellModel>.reactive(
      onModelReady: (model) => model.initialize(uid),
      viewModelBuilder: () => NotificationBellModel(),
      builder: (context, model, child) => GestureDetector(
        onTap: () => model.navigateToNotificationsView(),
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                right: 4.0,
                top: 0.0,
              ),
              child: Icon(
                FontAwesomeIcons.bell,
                size: 22.0,
                color: appIconColor(),
              ),
            ),
            Positioned(
              top: 0.0,
              right: 4.0,
              child: model.notifCount > 0
                  ? Container(
                      height: 10.0,
                      width: 10.0,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
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
      ),
    );
  }
}
