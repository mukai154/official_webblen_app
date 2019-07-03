import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:intl/intl.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/models/event.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/firebase_services/community_data.dart';
import 'package:webblen/models/community.dart';
import 'package:webblen/models/webblen_user.dart';

class ComEventRow extends StatelessWidget {

  final Event event;
  final VoidCallback eventPostAction;
  final bool showCommunity;
  final WebblenUser currentUser;
  ComEventRow({this.event, this.eventPostAction, this.showCommunity, this.currentUser});


  @override
  Widget build(BuildContext context) {

    void transitionToCommunityProfile() async {
      Community com = await CommunityDataService().getCommunity(event.communityAreaName, event.communityName);
      PageTransitionService(context: context, currentUser: currentUser, community: com).transitionToCommunityProfilePage();
    }

    DateFormat formatter = DateFormat("MMM d  h:mma");
    int currentDateTime = DateTime.now().millisecondsSinceEpoch;
    String startDateTime = event.startDateInMilliseconds == null ? null : formatter.format(DateTime.fromMillisecondsSinceEpoch(event.startDateInMilliseconds));
    DateTime eventEndDateTime = event.endDateInMilliseconds == null ? null : DateTime.fromMillisecondsSinceEpoch(event.endDateInMilliseconds);
    bool isHappeningNow = false;
    if (event.endDateInMilliseconds != null){
      isHappeningNow = (event.startDateInMilliseconds < currentDateTime && event.endDateInMilliseconds > currentDateTime) ? true : false;
    }
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: GestureDetector(
        onTap: eventPostAction,
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Container(
                height: 280,
                decoration: BoxDecoration(
                    image: DecorationImage(image: CachedNetworkImageProvider(event.imageURL), fit: BoxFit.cover)
                ),
              ),
              SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 8.0, right: 8.0),
                    constraints: BoxConstraints(
                        maxWidth: 300
                    ),
                    child: Fonts().textW800(event.title, 24.0, Colors.black, TextAlign.start),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Material(
                      borderRadius: BorderRadius.circular(24.0),
                      color: currentDateTime < event.endDateInMilliseconds ? FlatColors.webblenRed : Colors.black12,
                      child: Padding(
                        padding: EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0, bottom: 4.0),
                        child: Row(
                          children: <Widget>[
                            Image.asset("assets/images/transparent_logo_xxsmall.png", height: 18.0, width: 18.0),
                            SizedBox(width: 3.0),
                            currentDateTime < event.endDateInMilliseconds
                                ? Fonts().textW700('${event.estimatedTurnout.toDouble().toStringAsFixed(2) }', 12.0, Colors.white, TextAlign.center)
                                : Fonts().textW700('${event.eventPayout.toStringAsFixed(2)}', 12.0, FlatColors.darkGray, TextAlign.center)
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start ,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 16
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                    child: Fonts().textW400(event.description, 18.0, FlatColors.darkGray, TextAlign.start),
                  )
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start ,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  event.startDateInMilliseconds == null
                      ? Container()
                      : isHappeningNow
                      ? Padding(
                    padding: EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
                    child: Fonts().textW500('Happening Now', 14.0, Colors.red, TextAlign.start),
                  )
                      : Padding(
                    padding: EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
                    child: Fonts().textW400(startDateTime, 14.0, Colors.black, TextAlign.start),
                  ),
                  GestureDetector(
                      onTap: showCommunity ? () => transitionToCommunityProfile() : null,
                      child:  Padding(
                        padding: EdgeInsets.only(right: 8.0, top: 4.0, bottom: 8.0),
                        child: Material(
                          borderRadius: BorderRadius.circular(24.0),
                          color: Colors.black12,
                          child: Padding(
                              padding: EdgeInsets.all(6.0),
                              child: Fonts().textW400('${event.communityAreaName}/${event.communityName}', 12.0, Colors.black, TextAlign.center)
                          ),
                        ),
                      )
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
                child: Fonts().textW800(event.title, 18.0, FlatColors.darkGray, TextAlign.left),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start ,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
//                      Padding(
//                        padding: EdgeInsets.only(left: 8.0, top: 4.0, bottom: 8.0),
//                        child: Material(
//                          borderRadius: BorderRadius.circular(8.0),
//                          color: FlatColors.casandoraYellow,
//                          child: Padding(
//                              padding: EdgeInsets.all(4.0),
//                              child: Fonts().textW700('Average Payout Pool: \$${event.estimatedTurnout.toStringAsFixed(2)}', 12.0, Colors.white, TextAlign.center)
//                          ),
//                        ),
//                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      event.recurrenceType == 'daily'
                        ? Padding(
                            padding: EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0),
                            child: Fonts().textW500('Everyday from ${event.startTime} to ${event.endTime}', 14.0, FlatColors.darkGray, TextAlign.start),
                          )
                          : event.recurrenceType == 'weekly'
                          ? Padding(
                              padding: EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0),
                              child: Fonts().textW500('Every ', 14.0, FlatColors.darkGray, TextAlign.start),
                            )
                          : Padding(
                              padding: EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0),
                              child: Fonts().textW500('Every ', 14.0, FlatColors.darkGray, TextAlign.start),
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