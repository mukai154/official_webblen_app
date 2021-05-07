import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_event_ticket.dart';
import 'package:webblen/models/webblen_ticket_distro.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/firestore/data/event_data_service.dart';
import 'package:webblen/services/firestore/data/ticket_distro_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/services/share/share_service.dart';

class EventTicketsViewModel extends ReactiveViewModel {
  CustomNavigationService customNavigationService = locator<CustomNavigationService>();
  UserDataService _userDataService = locator<UserDataService>();
  EventDataService _eventDataService = locator<EventDataService>();
  TicketDistroDataService _ticketDistroDataService = locator<TicketDistroDataService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  ShareService shareService = locator<ShareService>();

  ///USER DATA
  WebblenUser get user => _reactiveUserService.user;

  WebblenUser? host;
  WebblenEvent event = WebblenEvent();
  WebblenTicketDistro? ticketDistro;
  List<WebblenEventTicket> tickets = [];

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_reactiveUserService];

  initialize({required String eventID}) async {
    setBusy(true);
    event = await _eventDataService.getEventByID(eventID);
    if (event.isValid()) {
      ticketDistro = await _ticketDistroDataService.getTicketDistroByID(event.id!);
      tickets = await _ticketDistroDataService.getPurchasedTicketsFromEvent(user.id!, event.id!);
      tickets.sort((ticketA, ticketB) => ticketA.name!.compareTo(ticketB.name!));
      host = await _userDataService.getWebblenUserByID(event.authorID);
    } else {
      customNavigationService.navigateBack();
    }
    setBusy(false);
  }
}
