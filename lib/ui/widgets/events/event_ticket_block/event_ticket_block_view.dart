import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';

class EventTicketBlock extends StatelessWidget {
  final String eventTitle;
  final String eventAddress;
  final String eventStartDate;
  final String eventStartTime;
  final String eventEndTime;
  final String eventTimezone;
  final int numOfTicsForEvent;
  final VoidCallback viewEventTickets;
  EventTicketBlock({
    required this.eventTitle,
    required this.eventAddress,
    required this.eventStartDate,
    required this.eventStartTime,
    required this.eventEndTime,
    required this.eventTimezone,
    required this.numOfTicsForEvent,
    required this.viewEventTickets,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: viewEventTickets,
      child: Container(
        margin: EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: appBackgroundColor(),
          boxShadow: [
            BoxShadow(
              color: appShadowColor(),
              spreadRadius: 1.5,
              blurRadius: 1.0,
              offset: Offset(0.0, 0.0),
            ),
          ],
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomText(
              text: eventTitle,
              textAlign: TextAlign.left,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: appFontColor(),
            ),
            SizedBox(height: 8.0),
            CustomText(
              text: eventAddress,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: appFontColorAlt(),
            ),
            SizedBox(height: 2.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CustomText(
                  text: "$eventStartDate | $eventStartTime - $eventEndTime $eventTimezone",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: appFontColorAlt(),
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      CustomText(
                        text: numOfTicsForEvent.toString(),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: appFontColorAlt(),
                      ),
                      SizedBox(width: 4.0),
                      Icon(
                        FontAwesomeIcons.ticketAlt,
                        size: 18.0,
                        color: appFontColorAlt(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
