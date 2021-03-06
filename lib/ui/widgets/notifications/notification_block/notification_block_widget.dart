import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/enums/notifcation_type.dart';
import 'package:webblen/models/webblen_notification.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';

import 'notification_block_model.dart';

class NotificationBlockWidget extends StatelessWidget {
  final WebblenNotification notification;
  NotificationBlockWidget({
    required this.notification,
  });

  Widget notifIcon() {
    return Icon(
      notification.type == NotificationType.follower
          ? FontAwesomeIcons.user
          : notification.type == NotificationType.postComment || notification.type == NotificationType.postCommentReply
              ? FontAwesomeIcons.comment
              : notification.type == NotificationType.event
                  ? FontAwesomeIcons.calendar
                  : notification.type == NotificationType.stream
                      ? FontAwesomeIcons.broadcastTower
                      : notification.type == NotificationType.post
                          ? FontAwesomeIcons.newspaper
                          : notification.type == NotificationType.webblenReceived
                              ? FontAwesomeIcons.plus
                              : FontAwesomeIcons.bell,
      color: notification.type == NotificationType.webblenReceived ? CustomColors.cashAppGreen : appFontColor(),
      size: 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NotificationBlockModel>.reactive(
      disposeViewModel: false,
      initialiseSpecialViewModelsOnce: true,
      fireOnModelReadyOnce: true,
      viewModelBuilder: () => NotificationBlockModel(),
      builder: (context, model, child) => GestureDetector(
        onTap: () => model.onTap(notifType: notification.type, data: notification.additionalData),
        child: Container(
          width: screenWidth(context),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border(
              bottom: BorderSide(width: 0.5, color: appBorderColorAlt()),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                child: notifIcon(),
              ),
              horizontalSpaceTiny,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      child: Text(
                        notification.header!,
                        style: TextStyle(
                          fontSize: 14,
                          color: appFontColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      notification.subHeader == null || notification.subHeader!.isEmpty ? "View" : notification.subHeader!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
