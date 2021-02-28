import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/models/webblen_stream.dart';
import 'package:webblen/services/auth/auth_service.dart';

class StreamBlockViewModel extends BaseViewModel {
  AuthService _authService = locator<AuthService>();
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();

  WebblenStream stream;
  bool isHappeningNow;

  initialize(WebblenStream data) {
    stream = data;
    notifyListeners();
    determineIfHappeningNow();
  }

  determineIfHappeningNow() {
    int currentDateInMilli = DateTime.now().millisecondsSinceEpoch;
    int eventStartDateInMilli = stream.startDateTimeInMilliseconds;
    int eventEndDateInMilli = stream.endDateTimeInMilliseconds;
    if (currentDateInMilli >= eventStartDateInMilli && currentDateInMilli <= eventEndDateInMilli) {
      isHappeningNow = true;
    } else {
      isHappeningNow = false;
    }
    notifyListeners();
  }

  ///NAVIGATION
// replaceWithPage() {
//   _navigationService.replaceWith(PageRouteName);
// }
//
  navigateToEventDetails() {
    //_navigationService.navigateTo(PageRouteName);
    //_navigationService.navigateTo(Routes.SettingsViewRoute, arguments: {'data': 'example'});
  }
}
