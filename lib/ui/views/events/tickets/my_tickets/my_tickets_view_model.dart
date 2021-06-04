import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_event_ticket.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/firestore/data/ticket_distro_data_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/services/share/share_service.dart';
import 'package:webblen/utils/time_calc.dart';

class MyTicketsViewModel extends ReactiveViewModel {
  CustomNavigationService customNavigationService = locator<CustomNavigationService>();
  TicketDistroDataService _ticketDistroDataService = locator<TicketDistroDataService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  ShareService shareService = locator<ShareService>();

  ///USER DATA
  WebblenUser get user => _reactiveUserService.user;

  ///EVENT & TICKET DATA
  List<WebblenEvent> events = [];
  List loadedEvents = [];
  Map<String, dynamic> ticsPerEvent = {};

  ///FILTER DATA
  String searchTerm = "";

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_reactiveUserService];

  initialize() async {
    setBusy(true);
    List<WebblenEventTicket> purchasedTickets = await _ticketDistroDataService.getPurchasedTickets(user.id!);
    organizeNumOfTicketsByEvent(purchasedTickets);
    setBusy(false);
  }

  organizeNumOfTicketsByEvent(List<WebblenEventTicket> eventTickets) {
    eventTickets.forEach((ticket) {
      List filter = loadedEvents.where((event) => event['id'] == ticket.eventID).toList(growable: true);
      if (filter.isEmpty) {
        loadedEvents.add({
          'id': ticket.eventID!,
          'eventTitle': ticket.eventTitle!,
          'eventAddress': ticket.address!,
          'eventStartDate': ticket.startDate!,
          'eventStartTime': ticket.startTime!,
          'eventEndTime': ticket.endTime!,
          'eventTimezone': ticket.timezone!,
        });
      }
      if (ticsPerEvent[ticket.eventID] == null) {
        ticsPerEvent[ticket.eventID!] = 1;
      } else {
        ticsPerEvent[ticket.eventID!] += 1;
      }
      if (eventTickets.last == ticket) {
        notifyListeners();
      }
    });

    try {
      loadedEvents.sort((eventA, eventB) => DateTime.now()
          .difference(TimeCalc().getDateTimeFromString(eventA['eventStartDate']))
          .inMilliseconds
          .compareTo(DateTime.now().difference(TimeCalc().getDateTimeFromString(eventB['eventStartDate'])).inMilliseconds));
    } catch (e) {}
  }

  updateSearchTerm(String val) {
    searchTerm = val.toLowerCase();
    notifyListeners();
  }
}
