import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/firebase/data/event_data.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/firebase/services/auth.dart';
import 'package:webblen/models/event_ticket.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';
import 'package:webblen/widgets/common/state/progress_indicator.dart';
import 'package:webblen/widgets/events/event_block.dart';

class UserTicketsPage extends StatefulWidget {
  @override
  _UserTicketsPageState createState() => _UserTicketsPageState();
}

class _UserTicketsPageState extends State<UserTicketsPage> {
  bool isLoading = true;
  WebblenUser currentUser;
  List<WebblenEvent> events = [];
  List<String> loadedEvents = [];
  Map<String, dynamic> ticsPerEvent = {};

  organizeNumOfTicketsByEvent(List<EventTicket> eventTickets) async {
    eventTickets.forEach((ticket) async {
      if (!loadedEvents.contains(ticket.eventID)) {
        loadedEvents.add(ticket.eventID);
        WebblenEvent event = await EventDataService().getEvent(ticket.eventID);
        if (event != null) {
          events.add(event);
          setState(() {});
        }
      }
      if (ticsPerEvent[ticket.eventID] == null) {
        ticsPerEvent[ticket.eventID] = 1;
      } else {
        ticsPerEvent[ticket.eventID] += 1;
      }
      if (eventTickets.last == ticket) {
        isLoading = false;
        setState(() {});
      }
    });
  }

  Widget ticketList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: EventTicketBlock(
            eventDescHeight: 120,
            event: events[index],
            shareEvent: () => Share.share("https://app.webblen.io/#/event?id=${events[index].id}"),
            numOfTicsForEvent: ticsPerEvent[events[index].id],
            viewEventDetails: null,
            viewEventTickets: () => PageTransitionService(context: context, eventID: events[index].id, currentUser: currentUser)
                .transitionToEventTicketsPage(), //() => e.navigateToWalletTickets(e.id),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    BaseAuth().getCurrentUserID().then((res) {
      WebblenUserData().getUserByID(res).then((res) {
        currentUser = res;
        EventDataService().getPurchasedTickets(currentUser.uid).then((res) {
          organizeNumOfTicketsByEvent(res);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().basicAppBar("My Tickets", context),
      body: isLoading
          ? CustomLinearProgress(progressBarColor: CustomColors.webblenRed)
          : Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: ticketList(),
            ),
    );
  }
}
