import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_event_ticket.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/firestore/data/event_data_service.dart';
import 'package:webblen/services/firestore/data/purchased_ticket_data_service.dart';

@singleton
class UserTicketsViewModel extends BaseViewModel {
  NavigationService _navigationService = locator<NavigationService>();
  PurchasedTicketDataService _purchasedTicketDataService =
      locator<PurchasedTicketDataService>();
  EventDataService _eventDataService = locator<EventDataService>();

  //HELPERS
  ScrollController webblenClothesScrollController = ScrollController();
  ScrollController cashScrollController = ScrollController();

  ///DATA RESULTS
  List<DocumentSnapshot> userPurchasedTicketsResults = [];
  Map<WebblenEvent, dynamic> eventsUserHasTicketsForWithNumOfTickets = {};

  DocumentSnapshot lastUserPurchasedTicketDocSnap;

  bool loadingUserPurchasedTickets = true;
  bool loadingAdditionalUserPurchasedTickets = false;
  bool moreUserPurchasedTicketsAvailable = true;

  int resultsLimit = 10;

  WebblenUser user;

  ///INITIALIZE
  void initialize(BuildContext context) async {
    setBusy(true);

    Map<String, dynamic> args = RouteData.of(context).arguments;
    WebblenUser currentUser = args['currentUser'] ?? "";

    user = currentUser;

    //load additional content on scroll
    webblenClothesScrollController.addListener(() {
      double triggerFetchMoreSize =
          0.9 * webblenClothesScrollController.position.maxScrollExtent;
      if (webblenClothesScrollController.position.pixels >
          triggerFetchMoreSize) {
        loadAdditionalUserPurchasedTickets();
      }
    });
    notifyListeners();

    //load content data
    await loadData();

    await organizeNumOfTicketsByEvent(userPurchasedTicketsResults);

    setBusy(false);
  }

  ///LOAD ALL DATA
  Future loadData() async {
    await loadUserPurchasedTickets();
  }

  Future loadUserPurchasedTickets() async {
    //load posts with params
    userPurchasedTicketsResults =
        await _purchasedTicketDataService.loadUserPurchasedTickets(
      uid: user.id,
      resultsLimit: resultsLimit,
    );

    // for (DocumentSnapshot purchasedTicket in userPurchasedTicketsResults) {
    //   WebblenEvent event =
    //       await _eventDataService.getEventByID(purchasedTicket.id);
    //   eventsUserHasTicketsFor.add(event);
    // }

    //set loading posts status
    loadingUserPurchasedTickets = false;
    notifyListeners();
  }

  Future loadAdditionalUserPurchasedTickets() async {
    //check if already loading posts or no more posts available
    if (loadingAdditionalUserPurchasedTickets ||
        !moreUserPurchasedTicketsAvailable) {
      return;
    }

    //set loading additional posts status
    loadingAdditionalUserPurchasedTickets = true;
    notifyListeners();

    //load additional posts
    List<DocumentSnapshot> newResults =
        await _purchasedTicketDataService.loadAdditionalUserPurchasedTickets(
      uid: user.id,
      lastDocSnap:
          userPurchasedTicketsResults[userPurchasedTicketsResults.length - 1],
      resultsLimit: resultsLimit,
    );

    //notify if no more posts available
    if (newResults.length == 0) {
      moreUserPurchasedTicketsAvailable = false;
    } else {
      userPurchasedTicketsResults.addAll(newResults);

      // eventsUserHasTicketsFor = [];

      // for (DocumentSnapshot purchasedTicket in newResults) {
      //   WebblenEvent event =
      //       await _eventDataService.getEventByID(purchasedTicket.id);
      //   eventsUserHasTicketsFor.add(event);
      // }
    }

    //set loading additional posts status
    loadingAdditionalUserPurchasedTickets = false;
    notifyListeners();
  }

  organizeNumOfTicketsByEvent(
      List<DocumentSnapshot> userPurchasedTickets) async {
    userPurchasedTickets.forEach((ticket) async {
      WebblenEventTicket currentTicket = WebblenEventTicket.fromMap(
        ticket.data(),
      );
      print(currentTicket);
      WebblenEvent currentEvent = await _eventDataService.getEventByID(
        currentTicket.eventID,
      );

      if (eventsUserHasTicketsForWithNumOfTickets[currentEvent] == null) {
        eventsUserHasTicketsForWithNumOfTickets[currentEvent] = 1;
      } else {
        eventsUserHasTicketsForWithNumOfTickets[currentEvent] += 1;
      }

      // if (!loadedEvents.contains(ticket.eventID)) {
      //   loadedEvents.add(ticket.eventID);
      //   WebblenEvent event = await EventDataService().getEvent(ticket.eventID);
      //   if (event != null) {
      //     events.add(event);
      //     setState(() {});
      //   }
      // }
      // if (ticsPerEvent[ticket.eventID] == null) {
      //   ticsPerEvent[ticket.eventID] = 1;
      // } else {
      //   ticsPerEvent[ticket.eventID] += 1;
      // }
      // if (eventTickets.last == ticket) {
      //   isLoading = false;
      //   setState(() {});
      // }
    });
  }

  ///NAVIGATION
// replaceWithPage() {
//   _navigationService.replaceWith(PageRouteName);
// }
//
// navigateToPage() {
//   _navigationService.navigateTo(PageRouteName);
// }

}
