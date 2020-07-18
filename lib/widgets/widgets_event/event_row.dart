import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/utils/time_calc.dart';

class ComEventRow extends StatelessWidget {
  final WebblenEvent event;
  final VoidCallback transitionToComAction;
  final VoidCallback eventPostAction;
  final VoidCallback shareEventAction;
  final bool showCommunity;
  final WebblenUser currentUser;

  ComEventRow({
    this.event,
    this.transitionToComAction,
    this.eventPostAction,
    this.shareEventAction,
    this.showCommunity,
    this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    DateFormat timeFormatter = DateFormat("h:mma");
    int currentDateTime = DateTime.now().millisecondsSinceEpoch;
    DateTime eventStartDateTime = DateTime.fromMillisecondsSinceEpoch(event.startDateTimeInMilliseconds);
    bool isHappeningNow = false;
    if (event.endTime != null) {
      isHappeningNow = (event.startDateTimeInMilliseconds < currentDateTime) ? true : false;
    }
    return GestureDetector(
      onTap: eventPostAction,
      child: Container(
        margin: EdgeInsets.only(
          left: 8.0,
          bottom: 8.0,
          right: 8.0,
        ),
        height: MediaQuery.of(context).size.width - 16,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(event.imageURL),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 8.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  onTap: shareEventAction,
                  child: Container(
                    margin: EdgeInsets.only(
                      right: 16.0,
                    ),
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.all(
                        Radius.circular(25),
                      ),
                    ),
                    child: Icon(
                      FontAwesomeIcons.share,
                      color: Colors.white,
                      size: 14.0,
                    ),
                  ),
                ),
              ],
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.only(
                top: 8.0,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black,
                    FlatColors.transparent,
                  ],
                  begin: Alignment(0.0, 0.6),
                  end: Alignment(0.0, -1.0),
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25.0),
                  bottomRight: Radius.circular(25.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4.0,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Fonts().textW700(
                        '${event.title}',
                        26.0,
                        Colors.white,
                        TextAlign.left,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 16.0,
                      ),
                      Container(
                        padding: EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: FlatColors.textFieldGray,
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            currentDateTime > event.startDateTimeInMilliseconds
                                ? event.attendees == null || event.attendees.isEmpty
                                    ? Fonts().textW500('0 Check Ins', 12.0, Colors.black, TextAlign.center)
                                    : Fonts().textW500(
                                        event.attendees.length == 1 ? '${event.attendees.length} Check Ins' : '${event.attendees.length} Check Ins',
                                        14.0,
                                        Colors.black,
                                        TextAlign.center)
                                : Fonts().textW500(
                                    '${event.clicks} views',
                                    12.0,
                                    Colors.black,
                                    TextAlign.center,
                                  ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Fonts().textW400(
                        TimeCalc().getWhenEventIsHappening(
                          event.startDateTimeInMilliseconds,
                          event.startDateTimeInMilliseconds + 7200000,
                          timeFormatter.format(eventStartDateTime),
                        ),
                        16.0,
                        Colors.white,
                        TextAlign.right,
                      ),
                      SizedBox(
                        width: 16.0,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16.0,
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

class EventChatRow extends StatelessWidget {
  final WebblenEvent event;
  final VoidCallback eventPostAction;

  EventChatRow({
    this.event,
    this.eventPostAction,
  });

  @override
  Widget build(BuildContext context) {
    DateFormat timeFormatter = DateFormat("h:mma");
    DateTime eventStartDateTime = DateTime.fromMillisecondsSinceEpoch(event.startDateTimeInMilliseconds);

    return GestureDetector(
      onTap: eventPostAction,
      child: Container(
        height: 200,
        width: 200,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(event.imageURL),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 8.0),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 16.0,
                ),
              ],
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.only(
                top: 8.0,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black,
                    FlatColors.transparent,
                  ],
                  begin: Alignment(0.0, 0.6),
                  end: Alignment(0.0, -1.0),
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25.0),
                  bottomRight: Radius.circular(25.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                        child: Container(
                          width: 165,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Fonts().textW700(
                              '${event.title}',
                              26.0,
                              Colors.white,
                              TextAlign.left,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Fonts().textW400(
                        TimeCalc().getWhenEventIsHappening(
                          event.startDateTimeInMilliseconds,
                          event.startDateTimeInMilliseconds,
                          timeFormatter.format(eventStartDateTime),
                        ),
                        12.0,
                        Colors.white,
                        TextAlign.right,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8.0,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
