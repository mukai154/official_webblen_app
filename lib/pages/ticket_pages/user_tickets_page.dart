import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:slimy_card/slimy_card.dart';
import 'package:webblen/firebase_data/event_data.dart';
import 'package:webblen/models/event_ticket.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/widgets_common/common_button.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';
import 'package:webblen/widgets/widgets_user/user_details_profile_pic.dart';

class UserTicketsPage extends StatefulWidget {
  final WebblenUser currentUser;
  UserTicketsPage({
    this.currentUser,
  });

  @override
  _UserTicketsPageState createState() => _UserTicketsPageState();
}

class _UserTicketsPageState extends State<UserTicketsPage> {
  bool isLoading = true;
  bool isShowingTicketInfo = false;
  List<EventTicket> purchasedTickets = [];

  transitionToEvent(String eventKey) async {
    ShowAlertDialogService().showLoadingDialog(context);
    EventDataService().getEventByKey(eventKey).then((res) {
      Navigator.of(context).pop();
      if (res != null) {
        PageTransitionService(context: context, currentUser: widget.currentUser, event: res, eventIsLive: false).transitionToEventPage();
      } else {
        ShowAlertDialogService().showFailureDialog(context, "That's Odd...", "There Was an Issue Finding this Event. Please Try Again Later");
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    EventDataService().getPurchasedTickets(widget.currentUser.uid).then((res) {
      print(res);
      purchasedTickets = res;
      purchasedTickets.sort((ticketA, ticketB) => ticketA.eventTitle.compareTo(ticketB.eventTitle));
      isLoading = false;
      setState(() {});
    });
  }

  Widget buildEventTickets() {
    return CarouselSlider.builder(
      height: MediaQuery.of(context).size.height,
      enableInfiniteScroll: false,
      //onPageChanged: ,
      itemCount: purchasedTickets.length,
      itemBuilder: (BuildContext context, int index) => StreamBuilder(
        initialData: false,
        stream: slimyCard.stream,
        builder: ((context, snapshot) {
          return Padding(
            padding: const EdgeInsets.only(top: 32.0),
            child: SlimyCard(
              color: Colors.white,
              width: MediaQuery.of(context).size.width - 96,
              topCardHeight: 300,
              bottomCardHeight: 220,
              borderRadius: 15,
              topCardWidget: snapshot.data
                  ? Container(
                      color: Colors.white,
                      child: QrImage(
                        data: purchasedTickets[index].ticketID,
                        version: QrVersions.auto,
                        size: 200.0,
                        gapless: true,
                      ),
                    )
                  : Container(
                      child: Column(
                        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: 32.0),
                          UserDetailsProfilePic(userPicUrl: purchasedTickets[index].eventImageURL, size: 125),
                          //Image.asset('assets/images/webblen_logo.png', height: 150.0, width: 150.0, fit: BoxFit.contain),
                          SizedBox(height: 16),
                          Fonts().textW700(
                            purchasedTickets[index].eventTitle,
                            24.0,
                            Colors.black,
                            TextAlign.center,
                          ),
                          Fonts().textW400(
                            purchasedTickets[index].ticketName,
                            18.0,
                            Colors.black,
                            TextAlign.center,
                          ),
                        ],
                      ),
                    ),
              bottomCardWidget: snapshot.data
                  ? Container()
                  : Container(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 8.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          //mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Fonts().textW700(
                              purchasedTickets[index].eventTitle,
                              24.0,
                              Colors.black,
                              TextAlign.left,
                            ),
                            SizedBox(height: 8.0),
                            Fonts().textW400(
                              "Type: ${purchasedTickets[index].ticketName}",
                              16.0,
                              Colors.black,
                              TextAlign.left,
                            ),
                            SizedBox(height: 4.0),
                            Fonts().textW400(
                              "Date: ${purchasedTickets[index].startDate} ${purchasedTickets[index].startTime}",
                              14.0,
                              Colors.black,
                              TextAlign.left,
                            ),
                            SizedBox(height: 4.0),
                            Fonts().textW400(
                              "Address: ${purchasedTickets[index].address}",
                              14.0,
                              Colors.black,
                              TextAlign.left,
                            ),
                            CustomColorButton(
                              height: 40.0,
                              backgroundColor: Colors.white,
                              textColor: Colors.black,
                              text: "View Additional Info",
                              textSize: 16.0,
                              onPressed: () => transitionToEvent(purchasedTickets[index].eventID),
                            ),
                          ],
                        ),
                      ),
                    ),
              slimeEnabled: true,
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        brightness: Brightness.light,
        backgroundColor: Color(0xFFF9F9F9),
        title: Text(
          'My Tickets',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        leading: BackButton(color: Colors.black),
      ),
      body: isLoading
          ? CustomLinearProgress(progressBarColor: FlatColors.webblenRed)
          : purchasedTickets.length == 0
              ? Padding(
                  padding: EdgeInsets.only(top: 32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Fonts().textW400("You Do Not Have Any Tickets", 18.0, FlatColors.darkGray, TextAlign.center),
                    ],
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        FlatColors.webblenRed,
                        FlatColors.webblenPink,
                      ],
                    ),
                  ),
                  child: ListView(
                    children: <Widget>[
                      buildEventTickets(),
                    ],
                  ),
                ),
    );
  }
}
