import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/firestore/notification_data_service.dart';

class NotificationsViewModel extends BaseViewModel {
  AuthService _authService = locator<AuthService>();
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  SnackbarService _snackbarService = locator<SnackbarService>();
  NotificationDataService _notificationDataService = locator<NotificationDataService>();

  ///HELPER
  ScrollController notificationsScrollController = ScrollController();

  String uid;

  ///DATA RESULTS
  List<DocumentSnapshot> notifResults = [];
  DocumentSnapshot lastNotifDocSnap;

  bool loadingAdditionalNotifications = false;
  bool moreNotificationsAvailable = true;

  bool isReloading = true;
  int resultsLimit = 20;

  initialize() async {
    setBusy(true);
    uid = await _authService.getCurrentUserID();
    notificationsScrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * notificationsScrollController.position.maxScrollExtent;
      if (notificationsScrollController.position.pixels > triggerFetchMoreSize) {
        loadAdditionalNotifications();
      }
    });
    notifyListeners();
    _notificationDataService.changeUnreadNotificationStatus(uid);
    await loadNotifications();
    setBusy(false);
    await Future.delayed(Duration(seconds: 2));
    askForNotificationsPermission();
  }

  Future<void> refreshData() async {
    isReloading = true;
    notifResults = [];
    notifyListeners();
    await loadNotifications();
  }

  loadNotifications() async {
    notifResults = await _notificationDataService.loadNotifications(
      uid: uid,
      resultsLimit: resultsLimit,
    );
    isReloading = false;
    notifyListeners();
  }

  loadAdditionalNotifications() async {
    if (loadingAdditionalNotifications || !moreNotificationsAvailable) {
      return;
    }
    loadingAdditionalNotifications = true;
    notifyListeners();
    List<DocumentSnapshot> newResults = await _notificationDataService.loadAdditionalNotifications(
      lastDocSnap: notifResults[notifResults.length - 1],
      resultsLimit: resultsLimit,
      uid: uid,
    );
    if (newResults.length == 0) {
      moreNotificationsAvailable = false;
    } else {
      notifResults.addAll(newResults);
    }
    loadingAdditionalNotifications = false;
    notifyListeners();
  }

  askForNotificationsPermission() async {
    PermissionStatus permissionStatus = await Permission.notification.status;
    if (permissionStatus.isUndetermined) {
      permissionStatus = await Permission.notification.request();
    } else if (permissionStatus.isDenied) {
      DialogResponse response = await _dialogService.showConfirmationDialog(
        title: "Notifications are Disabled",
        description: "Open app settings to enable notifications",
        cancelTitle: "Cancel",
        confirmationTitle: "Open App Settings",
        barrierDismissible: true,
      );
      if (response.confirmed) {
        AppSettings.openNotificationSettings();
      }
    }
  }

  ///NAVIGATION
  navigateBack() {
    _navigationService.back();
  }
}
