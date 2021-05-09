import 'dart:async';

import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/firestore/data/notification_data_service.dart';
import 'package:webblen/services/permission_handler/permission_handler_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';

class NotificationsViewModel extends BaseViewModel {
  NavigationService _navigationService = locator<NavigationService>();
  PermissionHandlerService _permissionHandlerService = locator<PermissionHandlerService>();
  NotificationDataService _notificationDataService = locator<NotificationDataService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();

  ///USER DATA
  WebblenUser get user => _reactiveUserService.user;

  initialize() async {
    _notificationDataService.clearNotifications(user.id);
    await Future.delayed(Duration(seconds: 3));
    _permissionHandlerService.hasNotificationsPermission();
  }

  navigateBack() {
    _navigationService.back();
  }
}
