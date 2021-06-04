import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/services/firestore/data/notification_data_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';

class NotificationBellViewModel extends StreamViewModel<int> {
  NotificationDataService _notificationDataService = locator<NotificationDataService>();
  CustomNavigationService _customNavigationService = locator<CustomNavigationService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  int unreadNotifications = 0;

  ///STREAM DATA
  @override
  void onData(int? data) {
    if (data != null && data != unreadNotifications) {
      unreadNotifications = data;
      notifyListeners();
    }
  }

  @override
  Stream<int> get stream => checkNotifications();

  Stream<int> checkNotifications() async* {
    while (_reactiveUserService.user.isValid()) {
      await Future.delayed(Duration(seconds: 3));
      int res = await _notificationDataService.unreadNotifications(_reactiveUserService.user.id);
      yield res;
    }
  }

  ///NAVIGATION
  navigateToNotificationsView() {
    unreadNotifications = 0;
    notifyListeners();
    _customNavigationService.navigateToNotificationsView();
  }
}
