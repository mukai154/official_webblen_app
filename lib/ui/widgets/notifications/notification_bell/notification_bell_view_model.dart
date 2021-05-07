import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/services/firestore/data/notification_data_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';

class NotificationBellViewModel extends StreamViewModel<int> {
  NotificationDataService _notificationDataService = locator<NotificationDataService>();
  CustomNavigationService _customNavigationService = locator<CustomNavigationService>();
  String? currentUID;
  int? notifCount = 0;

  initialize(String? uid) async {
    currentUID = uid;
    notifyListeners();
  }

  ///STREAM DATA
  @override
  void onData(int? data) {
    if (data != 0) {
      notifCount = data;
      notifyListeners();
    }
  }

  @override
  Stream<int> get stream => streamNotifCount();

  Stream<int> streamNotifCount() async* {
    while (currentUID != null) {
      await Future.delayed(Duration(seconds: 3));
      int res = await _notificationDataService.getNumberOfUnreadNotifications(currentUID);
      yield res;
    }
  }

  ///NAVIGATION
  navigateToNotificationsView() {
    notifCount = 0;
    notifyListeners();
    _customNavigationService.navigateToNotificationsView();
  }
}
