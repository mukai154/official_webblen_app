import 'dart:async';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:location/location.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:webblen/firebase/data/event_data.dart';
import 'package:webblen/firebase/data/platform_data.dart';
import 'package:webblen/firebase/services/auth.dart';
import 'package:webblen/firebase/services/remote_messaging.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/pages/home_pages/home_dashboard_page.dart';
import 'package:webblen/pages/home_pages/location_permissions_page.dart';
import 'package:webblen/pages/home_pages/network_status_page.dart';
import 'package:webblen/pages/home_pages/notifications_page.dart';
import 'package:webblen/pages/home_pages/update_required_page.dart';
import 'package:webblen/pages/home_pages/wallet_page.dart';
import 'package:webblen/services/device_permissions.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/utils/network_status.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';
import 'package:webblen/widgets/widgets_data_streams/stream_user_account.dart';
import 'package:webblen/widgets/widgets_data_streams/stream_user_notifications.dart';
import 'package:webblen/widgets/widgets_home/check_in_floating_action.dart';

import 'firebase/data/user_data.dart';
import 'pages/user_pages/user_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  bool isConnectedToNetwork = false;
  var _homeScaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  String notifToken;
  String simLocation = "";
  WebblenUser currentUser;
  bool updateRequired = false;
  String uid;
  NetworkImage userImage;
  bool isLoading = true;
  int activeUserCount;
  double currentLat;
  double currentLon;
  bool didClickNotice = false;
  bool checkInAvailable = false;
  bool hasLocation = false;
  bool webblenIsAvailable = true;
  bool viewedAd = false;
  String areaName;
  int pageIndex = 0;
  bool hasEarningsAccount = false;

  final PageStorageBucket pageStorageBucket = PageStorageBucket();
  final Key homePageKey = PageStorageKey('homeKey');
  final Key newsPageKey = PageStorageKey('newsPageKey');
  final Key walletPageKey = PageStorageKey('walletPageKey');
  final Key userPageKey = PageStorageKey('userPageKey');

  Future<Null> initialize() async {
    isConnectedToNetwork = await NetworkStatus().isConnected();
    if (isConnectedToNetwork) {
      BaseAuth().getCurrentUserID().then((val) {
        uid = val;
        WebblenUserData().checkIfUserExists(uid).then((exists) {
          if (exists) {
            WebblenUserData().getUserByID(uid).then((user) {
              currentUser = user;
              checkPermissions();
            });
          } else {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/setup',
              (Route<dynamic> route) => false,
            );
          }
        });
      });
    } else {
      isLoading = false;
      setState(() {});
    }
  }

  void initDynamicLinks() async {
    final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      ShowAlertDialogService().showLoadingDialog(context);
      String eventID = deepLink.path;
      EventDataService().getEvent(eventID).then((res) {
        Navigator.of(context).pop();
        PageTransitionService(context: context, currentUser: currentUser, eventIsLive: false).transitionToEventPage();
      });
    }

    FirebaseDynamicLinks.instance.onLink(onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;
      if (deepLink != null) {
        ShowAlertDialogService().showLoadingDialog(context);
        String eventID = deepLink.path;
        EventDataService().getEvent(eventID).then((res) {
          Navigator.of(context).pop();
          PageTransitionService(context: context, currentUser: currentUser, eventIsLive: false).transitionToEventPage();
        });
      }
    }, onError: (OnLinkErrorException e) async {
      PageTransitionService(context: context).returnToRootPage();
    });
  }

  checkPermissions() async {
    DevicePermissions().checkLocationPermissions().then((locationPermissions) async {
      print(locationPermissions);
      if (locationPermissions == 'PermissionStatus.unknown') {
        String permissions = await DevicePermissions().requestPermssion();
        if (permissions == 'PermissionStatus.denied') {
          hasLocation = false;
          isLoading = false;
          setState(() {});
        } else {
          loadLocation();
        }
      } else if (locationPermissions == 'PermissionStatus.denied') {
        hasLocation = false;
        isLoading = false;
        setState(() {});
      } else {
        loadLocation();
      }
    });
  }

  Future<Null> loadLocation() async {
    LocationData location = await LocationService().getCurrentLocation(context);
    if (location != null) {
      hasLocation = true;
      currentLat = location.latitude;
      currentLon = location.longitude;
      LocationService().getCityNameFromLatLon(currentLat, currentLon).then((res) {
        areaName = res;
        isLoading = false;
        setState(() {});
      });
      LocationService().getZipFromLatLon(currentLat, currentLon).then((res) {
        WebblenUserData().updateUserAppOpen(uid, res, currentLat, currentLon);
      });
      FirebaseMessagingService().updateFirebaseMessageToken(uid);
      FirebaseMessagingService().configFirebaseMessaging(
        context,
        currentUser,
      );

      initDynamicLinks();
//        GeoFencing().addAndCreateGeoFencesFromEvents(currentLat, currentLon, uid);

    } else {
      hasLocation = false;
      isLoading = false;
      setState(() {});
    }
  }

  Future<Null> getPlatformData(double lat, double lon) async {
    PlatformDataService().isUpdateAvailable().then((updateIsAvailable) {
      if (updateIsAvailable) {
        updateRequired = updateIsAvailable;
      }
      isLoading = false;
      setState(() {});
    });
  }

  bool updateAlertIsEnabled() {
    bool showAlert = false;
    if (!isLoading && updateRequired) {
      showAlert = true;
    }
    return showAlert;
  }

  void didPressNotificationsBell() {
    if (!isLoading && currentUser.username != null && !updateAlertIsEnabled() && hasLocation) {
      returnIndexFromNotifPage(context);
    } else if (updateAlertIsEnabled()) {
      ShowAlertDialogService().showUpdateDialog(context);
    }
  }

  void didPressCheckIn() {
    if (!isLoading && currentUser.username != null && !updateAlertIsEnabled() && hasLocation) {
      HapticFeedback.selectionClick();
      PageTransitionService(
        context: context,
        currentUser: currentUser,
      ).transitionToCheckInPage();
    } else if (updateAlertIsEnabled()) {
      ShowAlertDialogService().showUpdateDialog(context);
    }
  }

  void didPressAccountButton() {
    if (!isLoading && currentUser != null && !updateAlertIsEnabled() && hasLocation) {
      _homeScaffoldKey.currentState.openDrawer();
    } else if (updateAlertIsEnabled()) {
      ShowAlertDialogService().showUpdateDialog(context);
    }
  }

  void returnIndexFromNotifPage(BuildContext context) async {
    final returningPageIndex = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationPage(
          currentUser: currentUser,
        ),
      ),
    );
    if (returningPageIndex != null) {
      setState(() {
        pageIndex = returningPageIndex;
      });
    }
  }

  void reloadData() {
    setState(() {
      isLoading = true;
    });
    initialize();
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageViews = [
      HomeDashboardPage(
        updateRequired: updateRequired,
        currentUser: currentUser,
        areaName: areaName == null ? "Home" : areaName,
        currentLat: currentLat,
        currentLon: currentLon,
        key: homePageKey,
        notifWidget: StreamUserNotifications(uid: uid, notifAction: null), //() => didPressNotificationsBell(),,
      ),
      NotificationPage(
          currentUser: currentUser,
          viewWalletAction: () {
            pageIndex = 2;
            setState(() {});
          }
          //key: newsPageKey,
          ),
      WalletPage(
        currentUser: currentUser,
        key: walletPageKey,
      ),
      CurrentUserPage(
        currentUser: currentUser,
        backButtonIsDisabled: true,
      ),
    ];

    return Scaffold(
      key: _homeScaffoldKey,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      //() => didPressCheckIn(
      floatingActionButton: isLoading
          ? CustomCircleProgress(
              20.0,
              20.0,
              20.0,
              20.0,
              FlatColors.webblenRed,
            )
          : CheckInFloatingAction(
              checkInAction: () => didPressCheckIn(),
              checkInAvailable: false,
              isVirtualEventCheckIn: false,
            ),
      bottomNavigationBar: FABBottomAppBar(
        centerItemText: 'Check In',
        notchedShape: CircularNotchedRectangle(),
        backgroundColor: Colors.white,
        selectedColor: FlatColors.webblenRed,
        onTabSelected: (int index) {
          setState(() {
            pageIndex = index;
          });
        },
        items: [
          FABBottomAppBarItem(
            iconData: FontAwesomeIcons.home,
            text: 'Home',
          ),
          isLoading
              ? FABBottomAppBarItem(
                  customWidget: Container(),
                  text: '',
                )
              : FABBottomAppBarItem(
                  customWidget: StreamUserNotifications(
                    uid: uid,
                    pageIsActive: pageIndex == 1 ? true : false,
                    notifAction: null,
                  ),
                  text: 'Notifications',
                ),
          isLoading
              ? FABBottomAppBarItem(
                  customWidget: Container(),
                  text: '',
                )
              : FABBottomAppBarItem(
                  iconData: FontAwesomeIcons.wallet,
                  text: 'Wallet',
                ),
          isConnectedToNetwork
              ? FABBottomAppBarItem(
                  customWidget: StreamUserAccount(
                    uid: uid,
                    isLoading: isLoading,
                    useBorderColor: pageIndex == 3 ? true : false, //() => didPressAccountButton(),
                  ),
                  text: 'Account',
                )
              : FABBottomAppBarItem(
                  customWidget: Container(),
                  text: 'Account',
                )
        ],
      ),
      body: PageStorage(
        bucket: pageStorageBucket,
        child: isLoading == true
            ? Container()
            : !isConnectedToNetwork
                ? NetworkStatusPage(reloadAction: () => reloadData())
                : !hasLocation
                    ? LocationPermissionsPage(
                        reloadAction: () => reloadData(),
                        enableLocationAction: () => LocationPermissions().openAppSettings(),
                      )
                    : updateRequired ? UpdateRequiredPage() : pageViews[pageIndex],
      ),
    );
  }
}
