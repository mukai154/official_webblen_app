import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';

class CheckInAttendeesViewModel extends BaseViewModel {
  CustomNavigationService customNavigationService = locator<CustomNavigationService>();

  String? eventID;

  initialize(String? id) {
    if (id != null) {
      eventID = id;
      notifyListeners();
    }
  }

  navigateToScanTickets() {
    customNavigationService.navigateToTicketScanner(eventID!);
  }

  navigateToAttendeeSearch() {
    customNavigationService.navigateToUSDBalanceHistoryView();
  }
}
