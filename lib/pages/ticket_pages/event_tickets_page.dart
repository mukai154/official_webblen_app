import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/firebase/data/event_data.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/firebase/services/auth.dart';
import 'package:webblen/models/event_ticket.dart';
import 'package:webblen/models/ticket_distro.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';
import 'package:webblen/widgets/common/state/progress_indicator.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';
import 'package:webblen/widgets/events/event_purchased_ticket_list.dart';

class WalletEventTicketsPage extends StatefulWidget {
  final String eventID;
  final WebblenUser currentUser;
  WalletEventTicketsPage({this.eventID, this.currentUser});
  @override
  _WalletEventTicketsPageState createState() => _WalletEventTicketsPageState();
}

class _WalletEventTicketsPageState extends State<WalletEventTicketsPage> {
  bool isLoading = true;
  WebblenUser eventHost;
  WebblenEvent event;
  TicketDistro ticketDistro;
  List<EventTicket> tickets = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    BaseAuth().getCurrentUserID().then((res) {
      String uid = res;
      EventDataService().getEvent(widget.eventID).then((res) {
        event = res;
        EventDataService().getEventTicketDistro(widget.eventID).then((res) {
          ticketDistro = res;
          EventDataService().getPurchasedTicketsFromEvent(uid, widget.eventID).then((res) {
            tickets = res;
            tickets.sort((ticketA, ticketB) => ticketA.ticketName.compareTo(ticketB.ticketName));
            WebblenUserData().getUserByID(event.authorID).then((res) {
              eventHost = res;
              isLoading = false;
              setState(() {});
            });
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().basicAppBar(
        'Event Tickets',
        context,
      ),
      body: Container(
        color: Colors.white,
        child: ListView(
          children: <Widget>[
            isLoading ? CustomLinearProgress(progressBarColor: CustomColors.webblenRed) : Container(),
            SizedBox(height: 16.0),
            isLoading
                ? Container(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                  )
                : Container(
                    margin: EdgeInsets.symmetric(horizontal: 24.0),
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        CustomText(
                          context: context,
                          text: event.title,
                          textColor: Colors.black,
                          textAlign: TextAlign.left,
                          fontSize: 32.0,
                          fontWeight: FontWeight.w700,
                        ),
                        Row(
                          children: <Widget>[
                            CustomText(
                              context: context,
                              text: "Hosted By ",
                              textColor: Colors.black,
                              textAlign: TextAlign.left,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500,
                            ),
                            GestureDetector(
                              onTap: () =>
                                  PageTransitionService(context: context, currentUser: widget.currentUser, webblenUser: eventHost).transitionToUserPage(),
                              child: CustomText(
                                context: context,
                                text: "@${eventHost.username}",
                                textColor: CustomColors.webblenRed,
                                textAlign: TextAlign.left,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        Row(
                          children: <Widget>[
                            Icon(
                              FontAwesomeIcons.mapMarkerAlt,
                              size: 14.0,
                              color: Colors.black38,
                            ),
                            SizedBox(width: 4.0),
                            CustomText(
                              context: context,
                              text: "${event.city}, ${event.province}",
                              textColor: Colors.black38,
                              textAlign: TextAlign.left,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                        CustomText(
                          context: context,
                          text: "${event.startDate} | ${event.startTime}",
                          textColor: Colors.black38,
                          textAlign: TextAlign.left,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                        SizedBox(height: 8.0),
                        GestureDetector(
                          onTap: () => PageTransitionService(context: context, eventID: event.id, currentUser: widget.currentUser).transitionToEventPage(),
                          child: CustomText(
                            context: context,
                            text: "View Event Details",
                            textColor: Colors.blueAccent,
                            textAlign: TextAlign.left,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 32.0),
                        CustomText(
                          context: context,
                          text: "Tickets",
                          textColor: Colors.black,
                          textAlign: TextAlign.left,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w700,
                          underline: true,
                        ),
                        EventPurchasedTicketsList(tickets: tickets, validTickets: ticketDistro.validTicketIDs, usedTickets: ticketDistro.usedTicketIDs),
                      ],
                    ),
                  ),
            SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }
}
