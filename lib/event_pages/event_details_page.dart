import 'package:flutter/material.dart';
import 'package:webblen/utils/open_url.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/utils/create_notification.dart';
import 'package:webblen/utils/device_calendar.dart';
import 'package:webblen/widgets_icons/icon_bubble.dart';
import 'package:webblen/widgets_common/common_appbar.dart';
import 'package:webblen/utils/payment_calc.dart';
import 'package:webblen/widgets_common/common_button.dart';
import 'package:webblen/firebase_services/event_data.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/widgets_data_streams/stream_event_details.dart';
import 'package:webblen/models/event.dart';
import 'package:intl/intl.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:share/share.dart';
import 'dart:math';

class EventDetailsPage extends StatefulWidget {

  final Event event;
  final WebblenUser currentUser;
  final bool eventIsLive;
  EventDetailsPage({this.event, this.currentUser, this.eventIsLive});
  
  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {

  int currentDateTime = DateTime.now().millisecondsSinceEpoch;
  DateFormat formatter = DateFormat('MMM d, y h:mma');

  Widget eventCaption(){
    return Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Fonts().textW700('Details', 24.0, FlatColors.darkGray, TextAlign.left),
          Fonts().textW400(widget.event.description, 18.0, FlatColors.lightAmericanGray, TextAlign.left),
        ],
      ),
    );
  }

  Widget eventDate(){
    return Row(
      children: <Widget>[
        Column(
          children: <Widget>[
            Icon(FontAwesomeIcons.calendar, size: 24.0, color: FlatColors.darkGray),
          ],
        ),
        SizedBox(width: 4.0),
        Column(
          children: <Widget>[
            SizedBox(height: 4.0),
            widget.event.startDateInMilliseconds == null ? Container() : Fonts().textW500('${formatter.format(DateTime.fromMillisecondsSinceEpoch(widget.event.startDateInMilliseconds))}', 18.0, FlatColors.darkGray, TextAlign.left),
          ],
        ),
      ],
    );
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.event.endDateInMilliseconds != null && currentDateTime < widget.event.endDateInMilliseconds) EventDataService().updateEstimatedTurnout(widget.event.eventKey);
    if (widget.currentUser.notifySuggestedEvents){
      if (widget.event.startDateInMilliseconds != null){
        CreateNotification().createTimedNotification(
            Random().nextInt(9),
            widget.event.startDateInMilliseconds - 1800000,
            "Event Happening Soon!",
            "The Event: ${widget.event.title} starts in 30 minutes! Be sure to check in to get paid!",
            widget.event.eventKey
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {

    Widget eventView(){
      double estimatedPayout = (widget.event.eventPayout.toDouble() * 0.05);
      double potentialEarnings = widget.event.attendees.length == 0 ? 0.00 : estimatedPayout/widget.event.attendees.length.toDouble();
      return ListView(
        children: <Widget>[
          Container(
            height: 300.0,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: <Widget>[
                CachedNetworkImage(imageUrl: widget.event.imageURL, fit: BoxFit.cover, height: 300.0, width: MediaQuery.of(context).size.width)
              ],
            ),
          ),
          widget.event.recurrence == 'none'
            ? Padding(
            padding: EdgeInsets.only(left: 16.0, top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
//                    Material(
//                      borderRadius: BorderRadius.circular(18.0),
//                      color: Colors.black12,
//                      child: Padding(
//                          padding: EdgeInsets.all(6.0),
//                          child: widget.eventIsLive || (widget.event.endDateInMilliseconds != null && currentDateTime > widget.event.endDateInMilliseconds)
//                              ? Fonts().textW700('Payout Pool: \$${estimatedPayout.toStringAsFixed(2)}', 14.0, Colors.black54, TextAlign.center)
//                              : Fonts().textW700('Estimated Payout: \$${PaymentCalc().getEventValueEstimate(widget.event.estimatedTurnout).toStringAsFixed(2)}', 14.0, Colors.black54, TextAlign.center)
//                      ),
//                    ),
                    SizedBox(height: 4.0),
                    Material(
                      borderRadius: BorderRadius.circular(24.0),
                      color: FlatColors.webblenRed,
                      child: Padding(
                        padding: EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0, bottom: 4.0),
                        child: Row(
                          children: <Widget>[
                            SizedBox(width: 4.0),
                            Fonts().textW700('Estimated Earnings: ', 18.0, Colors.white, TextAlign.left),
                            Image.asset("assets/images/transparent_logo_xxsmall.png", height: 20.0, width: 20.0),
                            SizedBox(width: 4.0),
                            widget.event.attendees.contains(widget.currentUser.uid)
                                ? Fonts().textW700('${PaymentCalc().getPotentialEarnings(widget.event.estimatedTurnout).toStringAsFixed(2)}', 14.0, Colors.white, TextAlign.center)
                                : Fonts().textW700('0.00', 14.0, Colors.white, TextAlign.center)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    (widget.event.endDateInMilliseconds != null && currentDateTime > widget.event.endDateInMilliseconds)
                        ? IconButton(
                            icon: Icon(FontAwesomeIcons.shareAlt, color: FlatColors.darkGray, size: 18.0),
                            onPressed: () => Share.share(
                              widget.eventIsLive
                                  ? "Checkout the event ${widget.event.title} happening now! \n Where: ${widget.event.address}  \n Be sure to check in with Webblen! https://www.webblen.io"
                                  : "There's a cool event happening soon! ${widget.event.title} \n Where: ${widget.event.address} \n When: ${formatter.format(DateTime.fromMillisecondsSinceEpoch(widget.event.startDateInMilliseconds))} \n Be sure to check Webblen for more information! https://www.webblen.io"
                            ),
                          )
                        : Container()
                  ],
                ),

              ],
            ),
          )
          : Container(),

          StreamEventDetails(
            currentUser: widget.currentUser,
            detailType: 'caption',
            eventKey: widget.event.eventKey,
            placeholderWidget: eventCaption(),
          ),
          widget.eventIsLive
              ? Container()
              : Padding(
            padding: EdgeInsets.only(left: 16.0, top: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    widget.event.address == null ? Container() : Icon(FontAwesomeIcons.directions, size: 24.0, color: FlatColors.darkGray),
                  ],
                ),
                SizedBox(width: 8.0),
                Column(
                  children: <Widget>[
                    SizedBox(height: 4.0),
                    widget.event.address == null ? Container() :
                        Container(
                          width: 320,
                          child: Fonts().textW400('${widget.event.address.replaceAll(', USA', '').replaceAll(', United States', '')}', 16.0, FlatColors.darkGray, TextAlign.left),
                        ),
                  ],
                ),
              ],
            ),
          ),
          widget.eventIsLive || widget.event.address == null
              ? Container()
              : Padding(
            padding: EdgeInsets.only(left: 16.0, top: 4.0),
            child: InkWell(
              onTap: () => OpenUrl().openMaps(context, widget.event.location['geopoint'].latitude.toString(), widget.event.location['geopoint'].longitude.toString()),
              child: Fonts().textW500(' View in Maps', 16.0, FlatColors.webblenDarkBlue, TextAlign.left),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(left: 16.0, top: 24.0),
              child: widget.eventIsLive || (widget.event.endDateInMilliseconds != null && currentDateTime > widget.event.endDateInMilliseconds)
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  CustomColorButton(
                    text: widget.event.attendees.isNotEmpty ? 'View Attendees' : 'No One Has Checked in Here...',
                    textColor: FlatColors.darkGray,
                    backgroundColor: Colors.white,
                    onPressed: widget.event.attendees.isNotEmpty
                        ? () => PageTransitionService(context: context, eventKey: widget.event.eventKey, currentUser: widget.currentUser).transitionToEventAttendeesPage()
                        : null,
                    height: 45.0,
                    width: widget.event.attendees.isNotEmpty ? 200.0 : 300,
                    vPadding: 0.0,
                    hPadding: 0.0,
                  ),
                ],
              )
                  : StreamEventDetails(
                currentUser: widget.currentUser,
                detailType: 'date',
                eventKey: widget.event.eventKey,
                placeholderWidget: eventDate(),
              )
          ),
          widget.eventIsLive || widget.event.startDateInMilliseconds == null || currentDateTime > widget.event.endDateInMilliseconds
              ? Container()
              : Padding(
            padding: EdgeInsets.only(left: 16.0, top: 2.0),
            child: InkWell(
              onTap: () => DeviceCalendar().addEventToCalendar(context, widget.event),
              child: Fonts().textW500(' Add to Calendar', 14.0, FlatColors.webblenDarkBlue, TextAlign.left),
            ),
          ),
          widget.event.fbSite.isNotEmpty || widget.event.twitterSite.isNotEmpty || widget.event.website.isNotEmpty
              ? Padding(
            padding: EdgeInsets.only(left: 16.0, top: 24.0),
            child: Fonts().textW700('Additional Info', 18.0, FlatColors.darkGray, TextAlign.left),
          )
              : Container(),
          Padding(
            padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                widget.event.fbSite.isNotEmpty
                    ? GestureDetector(
                  onTap: () => OpenUrl().launchInWebViewOrVC(context, widget.event.fbSite),
                  child: IconBubble(
                    icon: Icon(FontAwesomeIcons.facebookF, size: 20.0, color: Colors.white),
                    color: FlatColors.darkGray,
                    size: 35.0,
                  ),
                )
                    : Container(),
                widget.event.fbSite.isNotEmpty ? SizedBox(width: 16.0) : Container(),
                widget.event.twitterSite.isNotEmpty
                    ? GestureDetector(
                  onTap: () => OpenUrl().launchInWebViewOrVC(context, widget.event.twitterSite),
                  child: IconBubble(
                    icon: Icon(FontAwesomeIcons.twitter, size: 18.0, color: Colors.white),
                    color: FlatColors.darkGray,
                    size: 35.0,
                  ),
                )
                    : Container(),
                widget.event.twitterSite.isNotEmpty ? SizedBox(width: 16.0) : Container(),
                widget.event.website.isNotEmpty
                    ? GestureDetector(
                  onTap: () => OpenUrl().launchInWebViewOrVC(context, widget.event.website),
                  child: IconBubble(
                    icon: Icon(FontAwesomeIcons.link, size: 18.0, color: Colors.white),
                    color: FlatColors.darkGray,
                    size: 35.0,
                  ),
                ) : Container(),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: WebblenAppBar().actionAppBar(
          widget.event.title,
          widget.event.authorUid == widget.currentUser.uid && !widget.eventIsLive
          ? IconButton(
              icon: Icon(FontAwesomeIcons.trash, size: 18.0, color: FlatColors.darkGray),
              onPressed: () => ShowAlertDialogService().showConfirmationDialog(
                  context,
                  "Delete this event?",
                  'Delete',
                  (){
                    EventDataService().deleteEvent(widget.event.eventKey).then((error){
                      if (error.isEmpty){
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).pop();
                        ShowAlertDialogService().showFailureDialog(context, 'Uh Oh', 'There was an issue deleting this event. Please try again');
                      }
                    });
                  },
                (){
                    Navigator.of(context).pop();
                }
              ),
            )
          : Container()
      ),
      body: eventView(),
    );
  }
}

class RecurringEventDetailsPage extends StatelessWidget {

  final RecurringEvent event;
  final WebblenUser currentUser;

  RecurringEventDetailsPage({this.event, this.currentUser});

  Widget eventCaption(){
    return Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Fonts().textW700('Details', 24.0, FlatColors.darkGray, TextAlign.left),
          Fonts().textW400(event.description, 18.0, FlatColors.lightAmericanGray, TextAlign.left),
        ],
      ),
    );
  }

  Widget eventDate(){
    return Row(
      children: <Widget>[
        Column(
          children: <Widget>[
            Icon(FontAwesomeIcons.calendar, size: 24.0, color: FlatColors.darkGray),
          ],
        ),
        SizedBox(width: 4.0),
        Column(
          children: <Widget>[
            SizedBox(height: 4.0),
            event.recurrenceType == 'daily'
                ? Fonts().textW500('Everyday from ${event.startTime} to ${event.endTime}', 18.0, FlatColors.darkGray, TextAlign.start)
                : event.recurrenceType == 'weekly'
                ? Fonts().textW500('Every ${event.dayOfTheWeek} from  ${event.startTime} to ${event.endTime}', 18.0, FlatColors.darkGray, TextAlign.start)
                : Fonts().textW500('Every ${event.dayOfTheMonth} ${event.dayOfTheWeek} from  ${event.startTime} to ${event.endTime}', 18.0, FlatColors.darkGray, TextAlign.start),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    Widget eventView(){
      return ListView(
        children: <Widget>[
          Container(
            height: 300.0,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: <Widget>[
                CachedNetworkImage(imageUrl: event.imageURL, fit: BoxFit.cover, height: 300.0, width: MediaQuery.of(context).size.width)
              ],
            ),
          ),
          eventCaption(),
          Padding(
            padding: EdgeInsets.only(left: 16.0, top: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                   event.address == null ? Container() : Icon(FontAwesomeIcons.directions, size: 24.0, color: FlatColors.darkGray),
                  ],
                ),
                SizedBox(width: 8.0),
                Column(
                  children: <Widget>[
                    SizedBox(height: 4.0),
                    event.address == null ? Container() :
                    Container(
                      width: 320,
                      child: Fonts().textW400('${event.address.replaceAll(', USA', '').replaceAll(', United States', '')}', 16.0, FlatColors.darkGray, TextAlign.left),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16.0, top: 4.0),
            child: InkWell(
              onTap: () => OpenUrl().openMaps(context, event.location['geopoint'].latitude.toString(), event.location['geopoint'].longitude.toString()),
              child: Fonts().textW500(' View in Maps', 16.0, FlatColors.webblenDarkBlue, TextAlign.left),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(left: 16.0, top: 24.0),
              child: eventDate()
          ),
          event.fbSite.isNotEmpty || event.twitterSite.isNotEmpty || event.website.isNotEmpty
              ? Padding(
            padding: EdgeInsets.only(left: 16.0, top: 24.0),
            child: Fonts().textW700('Additional Info', 18.0, FlatColors.darkGray, TextAlign.left),
          )
              : Container(),
          Padding(
            padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                event.fbSite.isNotEmpty
                    ? GestureDetector(
                  onTap: () => OpenUrl().launchInWebViewOrVC(context, event.fbSite),
                  child: IconBubble(
                    icon: Icon(FontAwesomeIcons.facebookF, size: 20.0, color: Colors.white),
                    color: FlatColors.darkGray,
                    size: 35.0,
                  ),
                )
                    : Container(),
                event.fbSite.isNotEmpty ? SizedBox(width: 16.0) : Container(),
                event.twitterSite.isNotEmpty
                    ? GestureDetector(
                  onTap: () => OpenUrl().launchInWebViewOrVC(context, event.twitterSite),
                  child: IconBubble(
                    icon: Icon(FontAwesomeIcons.twitter, size: 18.0, color: Colors.white),
                    color: FlatColors.darkGray,
                    size: 35.0,
                  ),
                )
                    : Container(),
                event.twitterSite.isNotEmpty ? SizedBox(width: 16.0) : Container(),
                event.website.isNotEmpty
                    ? GestureDetector(
                  onTap: () => OpenUrl().launchInWebViewOrVC(context, event.website),
                  child: IconBubble(
                    icon: Icon(FontAwesomeIcons.link, size: 18.0, color: Colors.white),
                    color: FlatColors.darkGray,
                    size: 35.0,
                  ),
                ) : Container(),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: WebblenAppBar().actionAppBar(
          event.title,
          event.authorUid == currentUser.uid
              ? IconButton(
            icon: Icon(FontAwesomeIcons.trash, size: 18.0, color: FlatColors.darkGray),
            onPressed: () => ShowAlertDialogService().showConfirmationDialog(
                context,
                "Delete this event?",
                'Delete',
                    (){
                  EventDataService().deleteRecurringEvent(event.eventKey).then((error){
                    if (error.isEmpty){
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pop();
                      ShowAlertDialogService().showFailureDialog(context, 'Uh Oh', 'There was an issue deleting this event. Please try again');
                    }
                  });
                },
                    (){
                  Navigator.of(context).pop();
                }
            ),
          )
              : Container()
      ),
      body: eventView(),
    );
  }
}


