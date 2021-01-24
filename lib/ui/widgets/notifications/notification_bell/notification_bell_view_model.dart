import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/app/router.gr.dart';
import 'package:webblen/services/firestore/notification_data_service.dart';

class NotificationBellViewModel extends StreamViewModel<int> {
  NavigationService _navigationService = locator<NavigationService>();
  NotificationDataService _notificationDataService = locator<NotificationDataService>();

  String currentUID;
  int notifCount = 0;

  initialize(String uid) async {
    currentUID = uid;
    notifyListeners();
  }

  ///STREAM DATA
  @override
  void onData(int data) {
    if (data != 0) {
      notifCount = data;
      notifyListeners();
    }
  }

  @override
  Stream<int> get stream => streamNotifCount();

  Stream<int> streamNotifCount() async* {
    while (currentUID != null) {
      await Future.delayed(Duration(seconds: 1));
      var res = await _notificationDataService.getNumberOfUnreadNotifications(currentUID);
      if (res is String) {
        yield null;
      } else {
        yield res;
      }
    }
  }

  ///NAVIGATION
  navigateToNotificationsView() {
    notifCount = 0;
    _navigationService.navigateTo(Routes.NotificationsViewRoute);
    notifyListeners();
  }
}
