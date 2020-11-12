import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/firebase/data/event_data.dart';
import 'package:webblen/firebase/data/ticket_data.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/models/ticket_distro.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/utils/create_notification.dart';
import 'package:webblen/utils/open_url.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';
import 'package:webblen/widgets/widgets_common/common_button.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';
import 'package:webblen/widgets/widgets_icons/icon_bubble.dart';

import 'create_event_page.dart';

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
  WebblenUser host;
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
  bool canUploadVideo = false;

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
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CreateEventPage(eventID: event.id, isStream: event.isDigitalEvent)));
  }

  void viewAttendeesAction() {
    Navigator.of(context).pop();
    PageTransitionService(
      context: context,
      eventID: event.id,
      userIDs: event.attendees,
      currentUser: widget.currentUser,
      pageTitle: "Attendees",
    ).transitionToUserListPage();
  }

  void scanForTicketsAction() {
    Navigator.of(context).pop();
    PageTransitionService(
      context: context,
      event: event,
    ).transitionToTicketScanPage();
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

  void createEventReminder() async {
    CreateNotification().createTimedNotification(
      event.title.length,
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
      widget.currentUser.uid == event.authorID && event.startDateTimeInMilliseconds > DateTime.now().millisecondsSinceEpoch && !event.hasTickets
          ? deleteEventAction
          : null,
      widget.currentUser.uid == event.authorID && event.hasTickets ? scanForTicketsAction : null,
    );
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
      if (event.startDateTimeInMilliseconds < currentDateTimeInMilliseconds) {
        eventStarted = true;
      }
      WebblenUserData().getUserByID(event.authorID).then((res) {
        host = res;
        if (event.authorID != widget.currentUser.uid) {
          createEventReminder();
          WebblenUserData().canUploadVideoAndIsAdmin(widget.currentUser.uid).then((res) {
            canUploadVideo = res;
            setState(() {});
          });
        } else {
          WebblenUserData().canUploadVideo(widget.currentUser.uid).then((res) {
            canUploadVideo = res;
          });
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
          child: Text(
            event.title,
            style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            '${event.startDate} ${event.startTime} ${event.timezone}',
            style: TextStyle(color: CustomColors.webblenRed, fontSize: 14, fontWeight: FontWeight.bold),
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
                18.0,
                Colors.black,
                TextAlign.left,
              ),
              Fonts().textW400(
                event.desc,
                14.0,
                Colors.black,
                TextAlign.left,
              ),
              SizedBox(height: 16.0),
              Fonts().textW700(
                'Address',
                16.0,
                Colors.black,
                TextAlign.left,
              ),
              SizedBox(
                height: 2.0,
              ),
              event.streetAddress == null
                  ? Container()
                  : Text(
                      '${event.streetAddress.replaceAll(', USA', '').replaceAll(', United States', '')}',
                      style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w400),
                    ),
              event.venueName == null || event.venueName.isEmpty
                  ? Container()
                  : Text(
                      '${event.venueName}',
                      style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w400),
                    ),
              SizedBox(height: 4.0),
              InkWell(
                onTap: () => OpenUrl().openMaps(context, eventLat.toString(), eventLon.toString()),
                child: Text(
                  'View in Maps',
                  style: TextStyle(color: CustomColors.webblenRed, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.0),
        GestureDetector(
          onTap: () => PageTransitionService(
            context: context,
            currentUser: widget.currentUser,
            webblenUser: host,
          ).transitionToUserPage(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  "Hosted By ",
                  style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  "@${host.username}",
                  style: TextStyle(color: CustomColors.webblenRed, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 4.0),
        // Padding(
        //   padding: EdgeInsets.symmetric(horizontal: 16.0),
        //   child: Text(
        //     event.category,
        //     style: TextStyle(color: Colors.black38, fontSize: 14, fontWeight: FontWeight.w500),
        //   ),
        // ),
        // Padding(
        //   padding: EdgeInsets.symmetric(horizontal: 16.0),
        //   child: Text(
        //     event.type,
        //     style: TextStyle(color: Colors.black38, fontSize: 14, fontWeight: FontWeight.w500),
        //   ),
        // ),
        event.fbUsername.isNotEmpty || event.twitterUsername.isNotEmpty || event.website.isNotEmpty
            ? Padding(
                padding: EdgeInsets.only(
                  left: 16.0,
                  top: 24.0,
                ),
                child: Text(
                  "Additional Info",
                  style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
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
              event.instaUsername != null && event.instaUsername.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () => OpenUrl().launchInWebViewOrVC(
                          context,
                          "https://www.instagram.com/${event.instaUsername.replaceAll("@", "").trim()}",
                        ),
                        child: IconBubble(
                          icon: Icon(
                            FontAwesomeIcons.instagram,
                            size: 25.0,
                            color: Colors.white,
                          ),
                          color: CustomColors.webblenPink,
                          size: 40.0,
                        ),
                      ),
                    )
                  : Container(),
              event.fbUsername != null && event.fbUsername.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () => OpenUrl().launchInWebViewOrVC(
                          context,
                          "https://www.facebook.com/${event.fbUsername.replaceAll("@", "").trim()}",
                        ),
                        child: IconBubble(
                          icon: Icon(
                            FontAwesomeIcons.facebookF,
                            size: 25.0,
                            color: Colors.white,
                          ),
                          color: CustomColors.facebookBlue,
                          size: 40.0,
                        ),
                      ),
                    )
                  : Container(),
              event.twitterUsername != null && event.twitterUsername.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () => OpenUrl().launchInWebViewOrVC(
                          context,
                          "https://www.twitter.com/${event.twitterUsername.replaceAll("@", "").trim()}",
                        ),
                        child: IconBubble(
                          icon: Icon(
                            FontAwesomeIcons.twitter,
                            size: 20.0,
                            color: Colors.white,
                          ),
                          color: CustomColors.twitterBlue,
                          size: 40.0,
                        ),
                      ),
                    )
                  : Container(),
              event.website != null && event.website.isNotEmpty
                  ? GestureDetector(
                      onTap: () => OpenUrl().launchInWebViewOrVC(
                        context,
                        event.website.contains("https://") || event.website.contains("http://") ? event.website : "https://${event.website}",
                      ),
                      child: IconBubble(
                        icon: Icon(
                          FontAwesomeIcons.link,
                          size: 20.0,
                          color: Colors.white,
                        ),
                        color: CustomColors.darkMountainGreen,
                        size: 40.0,
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
        canUploadVideo
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: GestureDetector(
                  onTap: () => PageTransitionService(
                    context: context,
                    currentUser: widget.currentUser,
                    event: event,
                  ).transitionToUserPage(),
                  child: CustomColorButton(
                    onPressed: () => PageTransitionService(context: context, event: event, currentUser: widget.currentUser).transitionToUploadStreamVideoPage(),
                    text: "UPLOAD STREAM/VIDEO",
                    textColor: Colors.black,
                    backgroundColor: Colors.white,
                    textSize: 14.0,
                    height: 35,
                    width: MediaQuery.of(context).size.width - 32,
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().actionAppBar(
        isLoading
            ? ''
            : event.isDigitalEvent
                ? "Stream"
                : "Event",
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
                                    currentDateTimeInMilliseconds > event.endDateTimeInMilliseconds
                                        ? CustomColorButton(
                                            text: "Stream Has Ended",
                                            textSize: 14.0,
                                            textColor: Colors.black,
                                            backgroundColor: Colors.white,
                                            height: 35.0,
                                            width: MediaQuery.of(context).size.width * 0.4,
                                            onPressed: null,
                                          )
                                        : CustomColorButton(
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
                                            ).transitionToDigitalEventHostPage(),
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
                                    Fonts().textW700("Stream", 16.0, Colors.black, TextAlign.left),
                                    Fonts().textW300("on Webblen", 14.0, Colors.black, TextAlign.left),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    currentDateTimeInMilliseconds > event.endDateTimeInMilliseconds
                                        ? CustomColorButton(
                                            text: "Stream Has Ended",
                                            textSize: 14.0,
                                            textColor: Colors.black,
                                            backgroundColor: Colors.white,
                                            height: 35.0,
                                            width: MediaQuery.of(context).size.width * 0.4,
                                            onPressed: null,
                                          )
                                        : CustomColorButton(
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
                                            ).transitionToDigitalEventViewerPage(),
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
