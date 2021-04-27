import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';

class NotificationRow extends StatelessWidget {
  final String header;
  final String subHeader;
  final String notifType;
  final VoidCallback onTap;
  NotificationRow({
    required this.onTap,
    required this.header,
    required this.subHeader,
    required this.notifType,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
              child: Icon(
                notifType == "post"
                    ? FontAwesomeIcons.comment
                    : notifType == "deposit"
                        ? FontAwesomeIcons.plus
                        : notifType == "event"
                            ? FontAwesomeIcons.calendar
                            : notifType == "user"
                                ? FontAwesomeIcons.userAlt
                                : FontAwesomeIcons.envelope,
                color: notifType == "deposit" ? CustomColors.cashAppGreen : appFontColor(),
                size: 16,
              ),
            ),
            SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    child: Text(
                      header,
                      style: TextStyle(
                        fontSize: 16,
                        color: appFontColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subHeader.isEmpty ? "View Now" : subHeader,
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
    );
  }
}
