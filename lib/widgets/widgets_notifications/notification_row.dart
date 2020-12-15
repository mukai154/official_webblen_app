import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/models/webblen_notification.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/utils/time_calc.dart';

class NotificationRow extends StatelessWidget {
  final WebblenNotification notification;
  final VoidCallback notificationAction;

  NotificationRow({
    this.notification,
    this.notificationAction,
  });

  @override
  Widget build(BuildContext context) {
    final notifColor = notification.notificationType == "deposit" ? FlatColors.darkMountainGreen : Colors.black;

    final notifIcon = notification.notificationType == "deposit"
        ? Icon(
            FontAwesomeIcons.plus,
            size: 16.0,
            color: notifColor,
          )
        : notification.notificationType == "post"
            ? Icon(
                FontAwesomeIcons.comment,
                size: 20.0,
                color: notifColor,
              )
            : notification.notificationType == "event"
                ? Icon(
                    FontAwesomeIcons.calendar,
                    size: 20.0,
                    color: notifColor,
                  )
                : Icon(
                    FontAwesomeIcons.bell,
                    size: 20.0,
                    color: notifColor,
                  );

    final cardContent = Row(
      children: <Widget>[
        notifIcon,
        SizedBox(
          width: 12.0,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 8.0,
            ),
            notification.notificationType == "deposit"
                ? Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.82,
                    ),
                    child: Fonts().textW500(
                      notification.notificationDescription,
                      14.0,
                      notifColor,
                      TextAlign.left,
                    ),
                  )
                : Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.82,
                    ),
                    child: Fonts().textW700(
                      notification.notificationType == "user" ? "@${notification.notificationTitle}" : notification.notificationTitle,
                      14.0,
                      notifColor,
                      TextAlign.left,
                    ),
                  ),
            notification.notificationType == "deposit" || notification.notificationType == "event"
                ? Container()
                : Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.82,
                    ),
                    child: Fonts().textW400(
                      notification.notificationDescription,
                      14.0,
                      notifColor,
                      TextAlign.left,
                    ),
                  ),
            SizedBox(
              height: 2.0,
            ),
            Fonts().textW400(
              TimeCalc().getPastTimeFromMilliseconds(notification.notificationExpDate - 1209600000),
              12.0,
              FlatColors.lightAmericanGray,
              TextAlign.right,
            ),
          ],
        ),
      ],
    );

    return GestureDetector(
      onTap: notificationAction,
      child: Container(
        color: Colors.white,
        margin: EdgeInsets.only(
          bottom: 4.0,
        ),
        padding: EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        child: cardContent,
      ),
    );
  }
}
