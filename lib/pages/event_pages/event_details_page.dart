import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';

import 'package:webblen/firebase_data/calendar_event_data.dart';
import 'package:webblen/firebase_data/event_data.dart';
import 'package:webblen/models/calendar_event.dart';
import 'package:webblen/models/event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_location.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/utils/create_notification.dart';
import 'package:webblen/utils/open_url.dart';
import 'package:webblen/utils/time.dart';
import 'package:webblen/widgets/widgets_common/common_appbar.dart';
import 'package:webblen/widgets/widgets_icons/icon_bubble.dart';

class EventDetailsPage extends StatefulWidget {
  final Event event;
  final WebblenUser currentUser;
  final bool eventIsLive;

  EventDetailsPage({
    this.event,
    this.currentUser,
    this.eventIsLive,
  });

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  int currentDateTime = DateTime.now().millisecondsSinceEpoch;
  DateFormat formatter = DateFormat('MMM dd, yyyy | h:mm a');
  double eventLat = 0.0;
  double eventLon = 0.0;

  Widget eventCaption() {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Fonts().textW700(
            'Details',
            24.0,
            Colors.black,
            TextAlign.left,
          ),
          Fonts().textW500(
            widget.event.description,
            18.0,
            Colors.black,
            TextAlign.left,
          ),
        ],
      ),
    );
  }

  Widget eventDate() {
    return Row(
      children: <Widget>[
        Column(
          children: <Widget>[
            Icon(
              FontAwesomeIcons.calendar,
              size: 24.0,
              color: FlatColors.darkGray,
            ),
          ],
        ),
        SizedBox(
          width: 4.0,
        ),
        Column(
          children: <Widget>[
            SizedBox(
              height: 4.0,
            ),
            widget.event.startDateInMilliseconds == null
                ? Container()
                : Fonts().textW500(
                    '${formatter.format(DateTime.fromMillisecondsSinceEpoch(widget.event.startDateInMilliseconds))}',
                    18.0,
                    FlatColors.darkGray,
                    TextAlign.left,
                  ),
          ],
        ),
      ],
    );
  }

  void editEventAction() {
    Navigator.of(context).pop();
    PageTransitionService(
      context: context,
      event: widget.event,
      currentUser: widget.currentUser,
      isRecurring: false,
    ).transitionToCreateEditEventPage();
  }

  void viewAttendeesAction() {
    Navigator.of(context).pop();
    PageTransitionService(
      context: context,
      eventKey: widget.event.eventKey,
      currentUser: widget.currentUser,
    ).transitionToEventAttendeesPage();
  }

  void shareEventAction() {
    Navigator.of(context).pop();
    PageTransitionService(
      context: context,
      currentUser: widget.currentUser,
      event: widget.event,
    ).transitionToChatInviteSharePage();
  }

  void addEventToCalendar() async {
    ShowAlertDialogService().showLoadingDialog(context);
    String timezone = await Time().getLocalTimezone();
    CreateNotification().createTimedNotification(
      randomBetween(0, 99),
      widget.event.startDateInMilliseconds - 900000,
      widget.event.title,
      "Event Starts in 15 Minutes!",
      '',
    );
    CalendarEvent calEvent = CalendarEvent(
      title: widget.event.title,
      description: widget.event.description,
      data: widget.event.communityAreaName + "/" + widget.event.communityName,
      key: widget.event.eventKey,
      timezone: timezone,
      dateTime: formatter.format(
        DateTime.fromMillisecondsSinceEpoch(
          widget.event.startDateInMilliseconds,
        ),
      ),
      type: 'saved',
    );

    CalendarEventDataService()
        .saveEvent(
      widget.currentUser.uid,
      calEvent,
    )
        .then((e) {
      Navigator.of(context).pop();
      if (e.isEmpty) {
        ShowAlertDialogService().showSuccessDialog(
          context,
          "Event Saved!",
          "This Event is Now in Your Calendar",
        );
      } else {
        ShowAlertDialogService().showFailureDialog(
          context,
          "Uh Oh!",
          'There was an issue saving this event. Please try again later',
        );
      }
    });
  }

  void deleteEventAction() {
    ShowAlertDialogService()
        .showConfirmationDialog(context, "Delete this event?", 'Delete', () {
      EventDataService().deleteEvent(widget.event.eventKey).then((error) {
        if (error.isEmpty) {
          PageTransitionService(context: context).returnToRootPage();
        } else {
          Navigator.of(context).pop();
          ShowAlertDialogService().showFailureDialog(
            context,
            'Uh Oh',
            'There was an issue deleting this event. Please try again',
          );
        }
      });
    }, () {
      Navigator.of(context).pop();
    });
  }

  showEventOptions() {
    ShowAlertDialogService().showEventOptionsDialog(
        context,
        widget.event.startDateInMilliseconds <
                DateTime.now().millisecondsSinceEpoch
            ? viewAttendeesAction
            : null,
        shareEventAction,
        widget.event.startDateInMilliseconds >
                    DateTime.now().millisecondsSinceEpoch &&
                widget.currentUser.uid == widget.event.authorUid
            ? editEventAction
            : null,
        widget.currentUser.uid == widget.event.authorUid &&
                widget.event.startDateInMilliseconds >
                    DateTime.now().millisecondsSinceEpoch
            ? deleteEventAction
            : null);
  }

  @override
  void initState() {
    super.initState();
    eventLat =
        LocationService().getLatFromGeopoint(widget.event.location['geopoint']);
    eventLon =
        LocationService().getLonFromGeopoint(widget.event.location['geopoint']);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget eventView() {
      return ListView(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.width - 32,
            margin: EdgeInsets.only(
              top: 8,
              left: 16.0,
              right: 16.0,
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: CachedNetworkImageProvider(widget.event.imageURL),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
          widget.event.recurrence == 'none'
              ? Padding(
                  padding: EdgeInsets.only(
                    left: 16.0,
                    top: 8.0,
                    right: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Material(
                            borderRadius: BorderRadius.circular(24.0),
                            color: FlatColors.textFieldGray,
                            child: Padding(
                              padding: EdgeInsets.all(6.0),
                              child: widget.event.flashEvent
                                  ? Fonts().textW500(
                                      'FLASH EVENT',
                                      14.0,
                                      Colors.black,
                                      TextAlign.center,
                                    )
                                  : Fonts().textW500(
                                      '${widget.event.communityAreaName}/${widget.event.communityName}',
                                      14.0,
                                      Colors.black,
                                      TextAlign.center,
                                    ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 4.0,
                          ),
                          currentDateTime >
                                      widget.event.startDateInMilliseconds &&
                                  currentDateTime <
                                      widget.event.endDateInMilliseconds
                              ? Container(
                                  width: 20,
                                  height: 20,
                                  margin: EdgeInsets.only(
                                    left: 4,
                                  ),
                                  child: Image.asset(
                                    "assets/images/webblen_logo.png",
                                    fit: BoxFit.none,
                                  ),
                                )
                              : Container(),
                          //Spacer(),
                          SizedBox(
                            width: 4.0,
                          ),
                          currentDateTime >
                                      widget.event.startDateInMilliseconds &&
                                  currentDateTime <
                                      widget.event.endDateInMilliseconds
                              ? Container(
                                  margin: EdgeInsets.only(
                                    right: 4,
                                  ),
                                  child: Fonts().textW400(
                                    '${widget.event.eventPayout.toStringAsFixed(2)}',
                                    16.0,
                                    Colors.white,
                                    TextAlign.left,
                                  ),
                                )
                              : Container(
                                  margin: EdgeInsets.only(
                                    right: 11,
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Fonts().textW500(
                                        '${widget.event.views} views',
                                        16.0,
                                        Colors.black54,
                                        TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                )
              : Container(),
          Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Fonts().textW700(
                  'Details',
                  24.0,
                  Colors.black,
                  TextAlign.left,
                ),
                Fonts().textW500(
                  widget.event.description,
                  16.0,
                  Colors.black,
                  TextAlign.left,
                ),
              ],
            ),
          ),
          widget.eventIsLive
              ? Container()
              : Padding(
                  padding: EdgeInsets.only(
                    left: 16.0,
                    top: 16.0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          widget.event.address == null
                              ? Container()
                              : Icon(
                                  FontAwesomeIcons.directions,
                                  size: 24.0,
                                  color: Colors.black,
                                ),
                        ],
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      Column(
                        children: <Widget>[
                          SizedBox(
                            height: 4.0,
                          ),
                          widget.event.address == null
                              ? Container()
                              : Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.8,
                                  ),
                                  child: Fonts().textW400(
                                    '${widget.event.address.replaceAll(', USA', '').replaceAll(', United States', '')}',
                                    16.0,
                                    Colors.black,
                                    TextAlign.left,
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
          widget.eventIsLive || widget.event.address == null
              ? Container()
              : Padding(
                  padding: EdgeInsets.only(
                    left: 16.0,
                    top: 4.0,
                  ),
                  child: InkWell(
                    onTap: () => OpenUrl().openMaps(
                        context, eventLat.toString(), eventLon.toString()),
                    child: Fonts().textW500(
                      'View in Maps',
                      14.0,
                      FlatColors.webblenDarkBlue,
                      TextAlign.left,
                    ),
                  ),
                ),
          Padding(
            padding: EdgeInsets.only(
              left: 18.0,
              top: 24.0,
            ),
            child: Row(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.calendar,
                      size: 20.0,
                      color: Colors.black,
                    ),
                  ],
                ),
                SizedBox(
                  width: 8.0,
                ),
                Column(
                  children: <Widget>[
                    SizedBox(
                      height: 4.0,
                    ),
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      child: Fonts().textW400(
                        formatter.format(
                          DateTime.fromMillisecondsSinceEpoch(
                              widget.event.startDateInMilliseconds),
                        ),
                        16.0,
                        Colors.black,
                        TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          widget.eventIsLive ||
                  widget.event.startDateInMilliseconds == null ||
                  currentDateTime > widget.event.endDateInMilliseconds
              ? Container()
              : Padding(
                  padding: EdgeInsets.only(
                    left: 16.0,
                    top: 2.0,
                  ),
                  child: InkWell(
                    onTap: () => addEventToCalendar(),
                    child: Fonts().textW500(
                      'Add to Calendar',
                      14.0,
                      FlatColors.webblenDarkBlue,
                      TextAlign.left,
                    ),
                  ),
                ),
          widget.event.fbSite.isNotEmpty ||
                  widget.event.twitterSite.isNotEmpty ||
                  widget.event.website.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.only(
                    left: 16.0,
                    top: 24.0,
                  ),
                  child: Fonts().textW700(
                    'Additional Info',
                    18.0,
                    FlatColors.darkGray,
                    TextAlign.left,
                  ),
                )
              : Container(),
          Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              top: 8.0,
              bottom: 32.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                widget.event.fbSite.isNotEmpty
                    ? GestureDetector(
                        onTap: () => OpenUrl().launchInWebViewOrVC(
                          context,
                          widget.event.fbSite,
                        ),
                        child: IconBubble(
                          icon: Icon(
                            FontAwesomeIcons.facebookF,
                            size: 20.0,
                            color: Colors.white,
                          ),
                          color: FlatColors.darkGray,
                          size: 35.0,
                        ),
                      )
                    : Container(),
                widget.event.fbSite.isNotEmpty
                    ? SizedBox(
                        width: 16.0,
                      )
                    : Container(),
                widget.event.twitterSite.isNotEmpty
                    ? GestureDetector(
                        onTap: () => OpenUrl().launchInWebViewOrVC(
                          context,
                          widget.event.twitterSite,
                        ),
                        child: IconBubble(
                          icon: Icon(
                            FontAwesomeIcons.twitter,
                            size: 18.0,
                            color: Colors.white,
                          ),
                          color: FlatColors.darkGray,
                          size: 35.0,
                        ),
                      )
                    : Container(),
                widget.event.twitterSite.isNotEmpty
                    ? SizedBox(
                        width: 16.0,
                      )
                    : Container(),
                widget.event.website.isNotEmpty
                    ? GestureDetector(
                        onTap: () => OpenUrl().launchInWebViewOrVC(
                          context,
                          widget.event.website,
                        ),
                        child: IconBubble(
                          icon: Icon(
                            FontAwesomeIcons.link,
                            size: 18.0,
                            color: Colors.white,
                          ),
                          color: FlatColors.darkGray,
                          size: 35.0,
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: WebblenAppBar().actionAppBar(
        widget.event.title,
        IconButton(
          icon: Icon(
            FontAwesomeIcons.ellipsisH,
            size: 18.0,
            color: Colors.black,
          ),
          onPressed: () => showEventOptions(),
        ),
      ),
      body: eventView(),
    );
  }
}

class RecurringEventDetailsPage extends StatelessWidget {
  final RecurringEvent event;
  final WebblenUser currentUser;

  RecurringEventDetailsPage({
    this.event,
    this.currentUser,
  });

  Widget eventCaption() {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Fonts().textW700(
            'Details',
            24.0,
            Colors.black,
            TextAlign.left,
          ),
          Fonts().textW500(
            event.description,
            18.0,
            Colors.black,
            TextAlign.left,
          ),
        ],
      ),
    );
  }

  Widget eventDate(BuildContext context) {
    return Row(
      children: <Widget>[
        Column(
          children: <Widget>[
            Icon(
              FontAwesomeIcons.calendar,
              size: 24.0,
              color: Colors.black,
            ),
          ],
        ),
        SizedBox(
          width: 4.0,
        ),
        Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                left: 6.0,
              ),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              child: event.recurrenceType == 'daily'
                  ? Fonts().textW400(
                      'Everyday from ${event.startTime} to ${event.endTime}',
                      14.0,
                      Colors.black,
                      TextAlign.start,
                    )
                  : event.recurrenceType == 'weekly'
                      ? Fonts().textW400(
                          'Every ${event.dayOfTheWeek} from  ${event.startTime} to ${event.endTime}',
                          14.0,
                          Colors.black,
                          TextAlign.start,
                        )
                      : Fonts().textW400(
                          'Every ${event.dayOfTheMonth} ${event.dayOfTheWeek} from  ${event.startTime} to ${event.endTime}',
                          14.0,
                          Colors.black,
                          TextAlign.start,
                        ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    void deleteEventAction() {
      Navigator.of(context).pop();
      ShowAlertDialogService()
          .showConfirmationDialog(context, "Delete this event?", 'Delete', () {
        EventDataService().deleteRecurringEvent(event.eventKey).then((error) {
          if (error.isEmpty) {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pop();
            ShowAlertDialogService().showFailureDialog(
              context,
              'Uh Oh',
              'There was an issue deleting this event. Please try again',
            );
          }
        });
      }, () {
        Navigator.of(context).pop();
      });
    }

    showEventOptions() {
      ShowAlertDialogService().showEventOptionsDialog(
        context,
        null,
        null,
        null,
        deleteEventAction,
      );
    }

    Widget eventView() {
      return Container(
        color: Colors.white,
        child: ListView(
          children: <Widget>[
            Container(
              height: 300.0,
              width: MediaQuery.of(context).size.width - 16,
              child: Stack(
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: event.imageURL,
                    fit: BoxFit.cover,
                    height: 300.0,
                    width: MediaQuery.of(context).size.width,
                  ),
                ],
              ),
            ),
            eventCaption(),
            Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                top: 16.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      event.address == null
                          ? Container()
                          : Icon(
                              FontAwesomeIcons.directions,
                              size: 24.0,
                              color: Colors.black,
                            ),
                    ],
                  ),
                  SizedBox(
                    width: 8.0,
                  ),
                  Column(
                    children: <Widget>[
                      SizedBox(
                        height: 4.0,
                      ),
                      event.address == null
                          ? Container()
                          : Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.8,
                              ),
                              child: Fonts().textW400(
                                '${event.address.replaceAll(', USA', '').replaceAll(', United States', '')}',
                                14.0,
                                Colors.black,
                                TextAlign.left,
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                top: 8.0,
              ),
              child: InkWell(
                onTap: () => OpenUrl().openMaps(
                  context,
                  event.location['geopoint'].latitude.toString(),
                  event.location['geopoint'].longitude.toString(),
                ),
                child: Fonts().textW500(
                  ' View in Maps',
                  14.0,
                  FlatColors.webblenDarkBlue,
                  TextAlign.left,
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(
                  left: 16.0,
                  top: 24.0,
                ),
                child: eventDate(context)),
            event.fbSite.isNotEmpty ||
                    event.twitterSite.isNotEmpty ||
                    event.website.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.only(
                      left: 16.0,
                      top: 24.0,
                    ),
                    child: Fonts().textW700(
                      'Additional Info',
                      18.0,
                      Colors.black,
                      TextAlign.left,
                    ),
                  )
                : Container(),
            Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                top: 8.0,
                bottom: 32.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  event.fbSite.isNotEmpty
                      ? GestureDetector(
                          onTap: () => OpenUrl().launchInWebViewOrVC(
                            context,
                            event.fbSite,
                          ),
                          child: IconBubble(
                            icon: Icon(
                              FontAwesomeIcons.facebookF,
                              size: 20.0,
                              color: Colors.white,
                            ),
                            color: FlatColors.facebookBlue,
                            size: 35.0,
                          ),
                        )
                      : Container(),
                  event.fbSite.isNotEmpty
                      ? SizedBox(
                          width: 16.0,
                        )
                      : Container(),
                  event.twitterSite.isNotEmpty
                      ? GestureDetector(
                          onTap: () => OpenUrl().launchInWebViewOrVC(
                            context,
                            event.twitterSite,
                          ),
                          child: IconBubble(
                            icon: Icon(
                              FontAwesomeIcons.twitter,
                              size: 18.0,
                              color: Colors.white,
                            ),
                            color: FlatColors.twinkleBlue,
                            size: 35.0,
                          ),
                        )
                      : Container(),
                  event.twitterSite.isNotEmpty
                      ? SizedBox(
                          width: 16.0,
                        )
                      : Container(),
                  event.website.isNotEmpty
                      ? GestureDetector(
                          onTap: () => OpenUrl().launchInWebViewOrVC(
                            context,
                            event.website,
                          ),
                          child: IconBubble(
                            icon: Icon(
                              FontAwesomeIcons.link,
                              size: 18.0,
                              color: Colors.white,
                            ),
                            color: FlatColors.darkGray,
                            size: 35.0,
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: WebblenAppBar().actionAppBar(
        event.title,
        currentUser.uid == event.authorUid
            ? IconButton(
                icon: Icon(
                  FontAwesomeIcons.ellipsisH,
                  size: 18.0,
                  color: Colors.black,
                ),
                onPressed: () => showEventOptions(),
              )
            : Container(),
      ),
      body: eventView(),
    );
  }
}
