import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/models/webblen_notification.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/utils/time_calc.dart';
import 'package:webblen/widgets/widgets_common/common_button.dart';

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
        : notification.notificationType == "newPost"
            ? Icon(
                FontAwesomeIcons.newspaper,
                size: 20.0,
                color: notifColor,
              )
            : notification.notificationType == "newPostComment"
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

class InviteRequestNotificationRow extends StatelessWidget {
  final WebblenNotification notification;
  final VoidCallback notifAction;
  final VoidCallback confirmRequest;
  final VoidCallback denyRequest;

  InviteRequestNotificationRow({
    this.notification,
    this.notifAction,
    this.confirmRequest,
    this.denyRequest,
  });

  @override
  Widget build(BuildContext context) {
    final requestIcon = notification.notificationType == 'friendRequest'
        ? Icon(
            FontAwesomeIcons.solidHeart,
            size: 16.0,
            color: FlatColors.webblenRed,
          )
        : Icon(
            FontAwesomeIcons.users,
            size: 25.0,
            color: FlatColors.darkMountainGreen,
          );

    final requestContent = Container(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              requestIcon,
            ],
          ),
          SizedBox(
            height: 4.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 300,
                child: Fonts().textW500(
                  notification.notificationDescription,
                  18.0,
                  FlatColors.darkGray,
                  TextAlign.center,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 4.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CustomColorButton(
                text: "Accept",
                textColor: Colors.white,
                backgroundColor: FlatColors.darkMountainGreen,
                height: 40.0,
                width: MediaQuery.of(context).size.width * 0.35,
                onPressed: confirmRequest,
              ),
              CustomColorButton(
                text: "Ignore",
                textColor: FlatColors.darkGray,
                backgroundColor: Colors.white,
                height: 40.0,
                width: MediaQuery.of(context).size.width * 0.35,
                onPressed: denyRequest,
              ),
            ],
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: notifAction,
      child: Container(
        color: Colors.white,
        margin: EdgeInsets.only(
          bottom: 4.0,
        ),
        padding: EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 8.0,
        ),
        child: requestContent,
      ),
    );
  }
}
