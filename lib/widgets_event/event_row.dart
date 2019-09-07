import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:intl/intl.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/models/event.dart';
import 'package:webblen/models/webblen_user.dart';

class ComEventRow extends StatelessWidget {

  final Event event;
  final VoidCallback transitionToComAction;
  final VoidCallback eventPostAction;
  final bool showCommunity;
  final WebblenUser currentUser;
  ComEventRow({this.event, this.transitionToComAction, this.eventPostAction, this.showCommunity, this.currentUser});


  @override
  Widget build(BuildContext context) {

    DateFormat dateFormatter = DateFormat("MMM d  h:mma");
    DateFormat timeFormatter = DateFormat("h:mma");
    int currentDateTime = DateTime.now().millisecondsSinceEpoch;
    DateTime eventStartDateTime = DateTime.fromMillisecondsSinceEpoch(event.startDateInMilliseconds);
    

    DateTime eventEndDateTime = event.endDateInMilliseconds == null ? null : DateTime.fromMillisecondsSinceEpoch(event.endDateInMilliseconds);
    bool isHappeningNow = false;
    bool isHappeningToday = false;
    if (DateTime.fromMicrosecondsSinceEpoch(event.startDateInMilliseconds).day == DateTime.now().day){
      isHappeningToday = true;
    }
    if (event.endDateInMilliseconds != null){
      isHappeningNow = (event.startDateInMilliseconds < currentDateTime && event.endDateInMilliseconds > currentDateTime) ? true : false;
    }
    return GestureDetector(
      onTap: eventPostAction,
      child: Container(
        margin: EdgeInsets.only(left: 8.0, bottom: 8.0, right: 8.0),
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
            SizedBox(height: 8.0),
            Row(
              children: <Widget>[
                SizedBox(width: 16.0),
                event.flashEvent
                  ? Container()
                  : GestureDetector(
                        onTap: showCommunity ? transitionToComAction : null,
                        child:  Padding(
                          padding: EdgeInsets.only(right: 8.0, top: 4.0, bottom: 8.0),
                          child: Material(
                            borderRadius: BorderRadius.circular(24.0),
                            color: FlatColors.textFieldGray,
                            child: Padding(
                                padding: EdgeInsets.all(6.0),
                                child: Fonts().textW500('${event.communityAreaName}/${event.communityName}', 14.0, Colors.black, TextAlign.center)
                            ),
                          ),
                        )
                    ),
                Container(),
              ],
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.only(top: 16.0),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black, FlatColors.transparent],
                    begin: Alignment(0.0, 1.0),
                    end: Alignment(0.0, -1.0),
                  ),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25.0), bottomRight: Radius.circular(25.0))
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: Fonts().textW700('${event.title}', 26.0, Colors.white, TextAlign.left),

                  ),

                  Row(
                    children: [
                      SizedBox(width: 16.0),
                      Container(
                        padding: EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 255, 89, 89),
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        child: Row(
                          children: [
                            currentDateTime > event.startDateInMilliseconds && !isHappeningNow
                                ? Container(
                              width: 20,
                              height: 20,
                              margin: EdgeInsets.only(left: 4),
                              child: Image.asset(
                                "assets/images/transparent-logo.png",
                                fit: BoxFit.none,
                              ),
                            )
                                : Container(),
                            //Spacer(),
                            SizedBox(width: 4.0),
                            currentDateTime > event.startDateInMilliseconds && !isHappeningNow
                                ? Container(
                              margin: EdgeInsets.only(right: 4),
                              child: Fonts().textW400('${event.eventPayout.toStringAsFixed(2)}', 16.0, Colors.white, TextAlign.left),
                            )
                                : Container(
                                margin: EdgeInsets.only(right: 11),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Fonts().textW400('${event.views} views', 16.0, Colors.white, TextAlign.center),
                                  ],
                                )
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      isHappeningToday && !isHappeningNow
                        ? Fonts().textW700('Starting Soon...', 16.0, Colors.white, TextAlign.right)
                        : isHappeningNow
                        ? Fonts().textW700('Happening Now!', 16.0, Colors.white, TextAlign.right)
                        : eventStartDateTime.difference(DateTime.now()) <= Duration(days: 1) && eventStartDateTime.difference(DateTime.now()) > Duration(days: 0)
                        ? Fonts().textW700('Today ${timeFormatter.format(eventStartDateTime)}', 16.0, Colors.white, TextAlign.right)
                        : eventStartDateTime.difference(DateTime.now()) <= Duration(days: 2) && eventStartDateTime.difference(DateTime.now()) >= Duration(days: 1)
                        ? Fonts().textW400('Tomorrow ${timeFormatter.format(eventStartDateTime)}', 16.0, Colors.white, TextAlign.right)
                        : Fonts().textW400('${dateFormatter.format(eventStartDateTime)}', 16.0, Colors.white, TextAlign.right),
                      SizedBox(width: 16.0),
                    ],
                  ),
                  SizedBox(height: 16.0)
                ],
              ),
            ),

          ],
        )
      ),
    );
  }
}


class ComRecurringEventRow extends StatelessWidget {

  final RecurringEvent event;
  final VoidCallback eventPostAction;
  ComRecurringEventRow({this.event, this.eventPostAction});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: GestureDetector(
        onTap: eventPostAction,
        child: Container(
          width: 250,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              boxShadow: ([
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 1.8,
                  spreadRadius: 0.5,
                  offset: Offset(0.0, 3.0),
                ),
              ])
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 10.0, top: 8.0, right: 4.0),
                child: Fonts().textW700(event.title, 20.0, Colors.black, TextAlign.left),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start ,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      event.recurrenceType == 'daily'
                        ? Padding(
                            padding: EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
                            child: Fonts().textW500('Everyday from ${event.startTime} to ${event.endTime}', 14.0, FlatColors.darkGray, TextAlign.start),
                          )
                          : event.recurrenceType == 'weekly'
                          ? Padding(
                              padding: EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
                              child: Fonts().textW500('Every ${event.dayOfTheWeek} from ${event.startTime} to ${event.endTime}', 14.0, FlatColors.darkGray, TextAlign.start),
                            )
                          : Padding(
                              padding: EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0),
                              child: Fonts().textW500('Every ${event.dayOfTheMonth} ${event.dayOfTheWeek} from ${event.startTime} to ${event.endTime}', 14.0, FlatColors.darkGray, TextAlign.start),
                            )
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}