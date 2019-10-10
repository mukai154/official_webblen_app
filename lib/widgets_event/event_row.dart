import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:intl/intl.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/models/event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/utils/time_calc.dart';

class ComEventRow extends StatelessWidget {

  final Event event;
  final VoidCallback transitionToComAction;
  final VoidCallback eventPostAction;
  final bool showCommunity;
  final WebblenUser currentUser;
  ComEventRow({this.event, this.transitionToComAction, this.eventPostAction, this.showCommunity, this.currentUser});


  @override
  Widget build(BuildContext context) {

    DateFormat timeFormatter = DateFormat("h:mma");
    int currentDateTime = DateTime.now().millisecondsSinceEpoch;
    DateTime eventStartDateTime = DateTime.fromMillisecondsSinceEpoch(event.startDateInMilliseconds);
    bool isHappeningNow = false;
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
              padding: EdgeInsets.only(top: 8.0),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black, FlatColors.transparent],
                    begin: Alignment(0.0, 0.6),
                    end: Alignment(0.0, -1.0),
                  ),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25.0), bottomRight: Radius.circular(25.0))
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Fonts().textW700('${event.title}', 26.0, Colors.white, TextAlign.left),
                    )

                  ),

                  Row(
                    children: [
                      SizedBox(width: 16.0),
                      Container(
                        padding: EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: FlatColors.textFieldGray,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Row(
                          children: [
                        currentDateTime > event.startDateInMilliseconds
                            ? event.attendees == null || event.attendees.isEmpty
                              ? Fonts().textW500('0 Check Ins', 12.0, Colors.white, TextAlign.center)
                                : Fonts().textW500(
                                event.attendees .length == 1 ? '${ event.attendees .length} Check Ins' : '${ event.attendees.length} Check Ins',
                                14.0, Colors.black,
                                TextAlign.center
                                )
                            : Fonts().textW500('${event.views} views', 12.0, Colors.black, TextAlign.center),
                          ],
                        ),
                      ),
//                        Row(
//                          mainAxisAlignment: MainAxisAlignment.center,
//                          children: [
//                            currentDateTime > event.startDateInMilliseconds && !isHappeningNow
//                                ? Container(
//                              width: 20,
//                              height: 20,
//                              margin: EdgeInsets.only(left: 4),
//                              child: Image.asset(
//                                "assets/images/transparent-logo.png",
//                                fit: BoxFit.none,
//                              ),
//                            )
//                                : Container(),
//                            //Spacer(),
//                            SizedBox(width: 4.0),
//                            currentDateTime > event.startDateInMilliseconds && !isHappeningNow
//                                ? Container(
//                              margin: EdgeInsets.only(right: 4),
//                              child: Fonts().textW400('${event.eventPayout.toStringAsFixed(2)}', 16.0, Colors.white, TextAlign.left),
//                            )
//                                : Container(
//                                //margin: EdgeInsets.only(right: 11),
//                                child: Row(
//                                  mainAxisAlignment: MainAxisAlignment.center,
//                                  children: <Widget>[
//                                    Fonts().textW400('${event.views} views', 16.0, Colors.white, TextAlign.center),
//                                  ],
//                                )
//                            ),
//                          ],
//                        ),

                      Spacer(),
                      Fonts().textW400(TimeCalc().getWhenEventIsHappening(event.startDateInMilliseconds, event.endDateInMilliseconds, timeFormatter.format(eventStartDateTime)), 16.0, Colors.white, TextAlign.right),
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

class EventCarouselTile extends StatelessWidget {


  final Event event;
  final VoidCallback transitionToComAction;
  final VoidCallback eventPostAction;
  final double size;
  EventCarouselTile({this.event, this.transitionToComAction, this.eventPostAction, this.size});


  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: eventPostAction,
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: size - 12,
              width: size - 12,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(event.imageURL),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.only(topRight: Radius.circular(16.0), topLeft: Radius.circular(16.0))
              ),
              child: Container(),
            ),
        //SizedBox(height: 4.0),
        Container(
            height: size - 120,
              width: size - 12,
              decoration: BoxDecoration(
                color: FlatColors.textFieldGray,
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(16.0), bottomLeft: Radius.circular(16.0))
              ),
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Fonts().textW500('${event.title}', null, Colors.black, TextAlign.center),
              )
            ),
          ],
        ),
      ),
    );
  }
}
