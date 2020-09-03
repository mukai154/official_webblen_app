import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';
import 'package:share/share.dart';
import 'package:webblen/firebase/data/event_data.dart';
import 'package:webblen/firebase/data/ticket_data.dart';
import 'package:webblen/models/ticket_distro.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/utils/create_notification.dart';
import 'package:webblen/utils/open_url.dart';
import 'package:webblen/utils/time.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';
import 'package:webblen/widgets/widgets_common/common_button.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';
import 'package:webblen/widgets/widgets_icons/icon_bubble.dart';

class EventDetailsPage extends StatefulWidget {
  final String eventID;
  final WebblenUser currentUser;

  EventDetailsPage({
    this.eventID,
    this.currentUser,
  });

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  bool isLoading = true;
  bool eventStarted = false;
  WebblenEvent event;
  int currentDateTimeInMilliseconds = DateTime.now().millisecondsSinceEpoch;
  DateFormat formatter = DateFormat('MMM dd, yyyy | h:mm a');
  bool eventIsLive = false;
  double eventLat = 0.0;
  double eventLon = 0.0;
  TicketDistro eventTicketDistro;
  List<Map<String, dynamic>> tickets;

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
            event.desc,
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
            event.startDateTimeInMilliseconds == null
                ? Container()
                : Fonts().textW500(
                    '${formatter.format(DateTime.fromMillisecondsSinceEpoch(event.startDateTimeInMilliseconds))}',
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
      eventID: event.id,
    ).transitionToCreateEventPage();
  }

  void viewAttendeesAction() {
    Navigator.of(context).pop();
    PageTransitionService(
      context: context,
      eventID: event.id,
      currentUser: widget.currentUser,
    ).transitionToEventAttendeesPage();
  }

//  void shareEventAction() {
//    Navigator.of(context).pop();
//    PageTransitionService(
//      context: context,
//      currentUser: widget.currentUser,
//      event: event,
//    ).transitionToChatInviteSharePage();
//  }

  void shareLinkAction() async {
    Navigator.of(context).pop();
    Share.share("https://app.webblen.io/#/event?id=${event.id}");
//    DynamicLinks().createDynamicLink(event.id, event.title, event.desc, event.imageURL).then((link) {
//      Navigator.of(context).pop();
//      Share.share("https://app.webblen.io/#/event?id=${event.id}");
//    });
  }

  void addEventToCalendar() async {
    ShowAlertDialogService().showLoadingDialog(context);
    String timezone = await Time().getLocalTimezone();
    CreateNotification().createTimedNotification(
      randomBetween(0, 99),
      event.startDateTimeInMilliseconds - 900000,
      event.title,
      "Event Starts in 15 Minutes!",
      '',
    );
  }

  void deleteEventAction() {
    ShowAlertDialogService().showConfirmationDialog(context, "Delete this event?", 'Delete', () {
      EventDataService().deleteEvent(event.id).then((error) {
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
        event.startDateTimeInMilliseconds < DateTime.now().millisecondsSinceEpoch ? viewAttendeesAction : null,
        null, //shareEventAction,
        shareLinkAction,
        event.startDateTimeInMilliseconds > DateTime.now().millisecondsSinceEpoch && widget.currentUser.uid == event.authorID ? editEventAction : null,
        widget.currentUser.uid == event.authorID && event.startDateTimeInMilliseconds > DateTime.now().millisecondsSinceEpoch ? deleteEventAction : null);
  }

  Widget ticketBuilder(TicketDistro ticketDistro) {
    return Container(
      child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: ticketDistro.tickets.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: null,
              child: Container(
                margin: EdgeInsets.only(bottom: 16.0),
                height: 60.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                FontAwesomeIcons.ticketAlt,
                                color: Colors.black,
                                size: 18.0,
                              ),
                              SizedBox(width: 16.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Fonts().textW500(
                                    ticketDistro.tickets[index]["ticketName"],
                                    18.0,
                                    Colors.black,
                                    TextAlign.left,
                                  ),
                                  Fonts().textW300(
                                    ticketDistro.tickets[index]["ticketQuantity"] == "0"
                                        ? "${ticketDistro.tickets[index]["ticketPrice"]} each | Amount Available: SOLD OUT"
                                        : "${ticketDistro.tickets[index]["ticketPrice"]} each | Amount Available: ${ticketDistro.tickets[index]["ticketQuantity"]}",
                                    12.0,
                                    Colors.black,
                                    TextAlign.left,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(FontAwesomeIcons.plusCircle, color: FlatColors.darkMountainGreen, size: 18.0),
                          onPressed: null,
                        ),
                      ],
                    ),
                    SizedBox(height: 4.0),
                    Divider(
                      height: 1.0,
                      thickness: 1.0,
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  @override
  void initState() {
    super.initState();
    EventDataService().getEvent(widget.eventID).then((res) {
      event = res;
      print(event);
      if (event.startDateTimeInMilliseconds < currentDateTimeInMilliseconds) {
        eventStarted = true;
      }
      if (event.hasTickets) {
        TicketDataService().getEventTicketDistro(widget.eventID).then((res) {
          eventTicketDistro = res;
          isLoading = false;
          setState(() {});
        });
      } else {
        isLoading = false;
        setState(() {});
      }
    });
  }

  Widget eventView() {
    return ListView(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.width,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: CachedNetworkImageProvider(event.imageURL),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 8.0),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: CustomText(
            context: context,
            text: event.category,
            textColor: Colors.black,
            textAlign: TextAlign.left,
            fontSize: 24.0,
            fontWeight: FontWeight.w700,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: CustomText(
            context: context,
            text: event.type,
            textColor: Colors.black38,
            textAlign: TextAlign.left,
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ),
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
                event.desc,
                16.0,
                Colors.black,
                TextAlign.left,
              ),
            ],
          ),
        ),
        eventIsLive
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
                        event.streetAddress == null
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 4.0,
                        ),
                        event.streetAddress == null
                            ? Container()
                            : Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                                ),
                                child: CustomText(
                                  context: context,
                                  text: '${event.streetAddress.replaceAll(', USA', '').replaceAll(', United States', '')}',
                                  textColor: Colors.black,
                                  textAlign: TextAlign.left,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                        event.venueName == null
                            ? Container()
                            : CustomText(
                                context: context,
                                text: '${event.venueName}',
                                textColor: Colors.black54,
                                textAlign: TextAlign.left,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                              ),
                      ],
                    ),
                  ],
                ),
              ),
        eventIsLive || event.streetAddress == null
            ? Container()
            : Padding(
                padding: EdgeInsets.only(
                  left: 16.0,
                  top: 4.0,
                ),
                child: InkWell(
                  onTap: () => OpenUrl().openMaps(context, eventLat.toString(), eventLon.toString()),
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
                    child: CustomText(
                      context: context,
                      text: '${event.startDate} ${event.startTime} ${event.timezone}',
                      textColor: Colors.black,
                      textAlign: TextAlign.left,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        eventIsLive || event.startDateTimeInMilliseconds == null //|| currentDateTime > event.endDateInMilliseconds
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
        event.fbUsername.isNotEmpty || event.twitterUsername.isNotEmpty || event.website.isNotEmpty
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
              event.fbUsername != null && event.fbUsername.isNotEmpty
                  ? GestureDetector(
                      onTap: () => OpenUrl().launchInWebViewOrVC(
                        context,
                        event.fbUsername,
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
              event.fbUsername != null && event.fbUsername.isNotEmpty
                  ? SizedBox(
                      width: 16.0,
                    )
                  : Container(),
              event.twitterUsername != null && event.twitterUsername.isNotEmpty
                  ? GestureDetector(
                      onTap: () => OpenUrl().launchInWebViewOrVC(
                        context,
                        event.twitterUsername,
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
              event.twitterUsername != null && event.twitterUsername.isNotEmpty
                  ? SizedBox(
                      width: 16.0,
                    )
                  : Container(),
              event.website != null && event.website.isNotEmpty
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().actionAppBar(
        isLoading ? '' : event.title,
        IconButton(
          icon: Icon(
            FontAwesomeIcons.ellipsisH,
            size: 18.0,
            color: Colors.black,
          ),
          onPressed: () => showEventOptions(),
        ),
      ),
      body: isLoading ? CustomLinearProgress(progressBarColor: FlatColors.webblenRed) : eventView(),
      bottomNavigationBar: !isLoading
          ? event.hasTickets
              ? eventStarted == false
                  ? Container(
                      height: 80.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(
                            color: FlatColors.textFieldGray,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 16.0,
                          bottom: 16.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Fonts().textW700("Tickets Available", 16.0, Colors.black, TextAlign.left),
                                Fonts().textW300("on Webblen", 14.0, Colors.black, TextAlign.left),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                CustomColorButton(
                                  text: "View Tickets",
                                  textSize: 14.0,
                                  textColor: Colors.white,
                                  backgroundColor: FlatColors.webblenRed,
                                  height: 35.0,
                                  width: MediaQuery.of(context).size.width * 0.4,
                                  onPressed: () =>
                                      PageTransitionService(context: context, event: event, currentUser: widget.currentUser).transitionToTicketSelectionPage(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(height: 0, width: 0)
              : event.isDigitalEvent
                  ? event.authorID == widget.currentUser.uid
                      ? Container(
                          height: 80.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              top: BorderSide(
                                color: FlatColors.textFieldGray,
                                width: 1.5,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 16.0,
                              bottom: 16.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Fonts().textW700("Streaming this Event", 16.0, Colors.black, TextAlign.left),
                                    Fonts().textW300("on Webblen", 14.0, Colors.black, TextAlign.left),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    CustomColorButton(
                                      text: "Start Stream",
                                      textSize: 14.0,
                                      textColor: Colors.white,
                                      backgroundColor: FlatColors.webblenRed,
                                      height: 35.0,
                                      width: MediaQuery.of(context).size.width * 0.4,
                                      onPressed: () => PageTransitionService(
                                        context: context,
                                        currentUser: widget.currentUser,
                                        event: event,
                                        clientRole: ClientRole.Broadcaster,
                                      ).transitionToDigitalEventPage(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          height: 80.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              top: BorderSide(
                                color: FlatColors.textFieldGray,
                                width: 1.5,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 16.0,
                              bottom: 16.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Fonts().textW700("Virtual Event", 16.0, Colors.black, TextAlign.left),
                                    Fonts().textW300("on Webblen", 14.0, Colors.black, TextAlign.left),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    CustomColorButton(
                                      text: "Watch Now",
                                      textSize: 14.0,
                                      textColor: Colors.white,
                                      backgroundColor: FlatColors.electronBlue,
                                      height: 35.0,
                                      width: MediaQuery.of(context).size.width * 0.4,
                                      onPressed: () => PageTransitionService(
                                        context: context,
                                        currentUser: widget.currentUser,
                                        event: event,
                                        clientRole: ClientRole.Audience,
                                      ).transitionToDigitalEventPage(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                  : Container(height: 0, width: 0)
          : Container(height: 0, width: 0),
    );
  }
}
