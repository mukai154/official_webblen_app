import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_event_ticket.dart';
import 'package:webblen/services/firestore/data/ticket_distro_data_service.dart';
import 'package:webblen/services/share/share_service.dart';

class TicketDetailsViewModel extends BaseViewModel {
  TicketDistroDataService _ticketDistroDataService = locator<TicketDistroDataService>();
  ShareService shareService = locator<ShareService>();

  WebblenEventTicket? ticket;

  initialize({required String id}) async {
    setBusy(true);
    ticket = await _ticketDistroDataService.getTicketByID(id);
    notifyListeners();
    setBusy(false);
  }
}
