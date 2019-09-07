import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:webblen/widgets_common/common_progress.dart';
import 'package:webblen/widgets_common/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/firebase_data/event_data.dart';
import 'package:webblen/firebase_data/auth.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:webblen/firebase_data/platform_data.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/services_location.dart';
import 'package:webblen/models/community_news.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/widgets_home/user_drawer_menu.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'home_pages/home_dashboard_page.dart';
import 'home_pages/event_feed_page.dart';
import 'home_pages/news_feed_page.dart';
import 'home_pages/wallet_page.dart';
import 'home_pages/location_permissions_page.dart';
import 'home_pages/update_required_page.dart';
import 'home_pages/location_unavailable_page.dart';
import 'user_pages/notifications_page.dart';
import 'package:webblen/widgets_data_streams/stream_user_account.dart';
import 'package:webblen/widgets_data_streams/stream_user_notifications.dart';
//import 'package:webblen/utils/geofencing.dart';
import 'widgets_home/check_in_floating_action.dart';
import 'package:webblen/firebase_services/remote_messaging.dart';

class HomePage extends StatefulWidget {

  final String simLocation;
  final double simLat;
  final double simLon;
  HomePage({this.simLocation, this.simLat, this.simLon});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {

  var _homeScaffoldKey = GlobalKey<ScaffoldState>();

  final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
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
  List<CommunityNewsPost> communityNewsPosts;
  bool didClickNotice = false;
  bool checkInAvailable = false;
  bool hasLocation = false;
  bool webblenIsAvailable = true;
  bool viewedAd = false;
  String areaName;
  int pageIndex = 0;

  final PageStorageBucket pageStorageBucket = PageStorageBucket();
  final Key homePageKey = PageStorageKey('homeKey');
  final Key newsPageKey = PageStorageKey('newsPageKey');
  final Key eventsPageKey = PageStorageKey('eventsPageKey');
  final Key walletPageKey = PageStorageKey('walletPageKey');

  Future<Null> initialize() async {
    BaseAuth().currentUser().then((val) {
      uid = val;
      UserDataService().checkIfUserExists(uid).then((exists){
        if (exists) {
          getUserAndLocation(uid);
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil('/setup', (Route<dynamic> route) => false);
        }
      });
    });
  }

  getUserAndLocation(String uid) {
    UserDataService().getUserByID(uid).then((user){
      currentUser = user;
      FirebaseMessagingService().updateFirebaseMessageToken(uid);
      FirebaseMessagingService().configFirebaseMessaging(context, currentUser);
      loadLocation();
    });
  }

  Future<Null> loadLocation() async {
    if (widget.simLocation != null){
      simLocation = widget.simLocation;
      currentLat = widget.simLat;
      currentLon = widget.simLon;
      hasLocation = true;
      getPlatformData(currentLat, currentLon);
    } else {
      LocationService().getCurrentLocation(context).then((location) {
        if (this.mounted) {
          if (location != null) {
            hasLocation = true;
            currentLat = location.latitude;
            currentLon = location.longitude;
            UserDataService().updateUserAppOpen(uid, currentLat, currentLon);
            //GeoFencing().addAndCreateGeoFencesFromEvents(currentLat, currentLon, uid);
            EventDataService().areCheckInsAvailable(currentLat, currentLon).then((result){
              checkInAvailable = result;
              getPlatformData(currentLat, currentLon);
            });
          } else {
            hasLocation = false;
            isLoading = false;
            setState(() {});
          }
        }
      });
    }
  }

  Future<Null> getPlatformData(double lat, double lon) async {
    PlatformDataService().getAreaName(lat, lon).then((area) {
      if (area.isEmpty) {
        webblenIsAvailable = false;
      }
      areaName = area;
      isLoading = false;
      setState(() {});
    });
    PlatformDataService().isUpdateAvailable().then((updateIsAvailable) {
      if (updateIsAvailable) {
        setState(() {
          updateRequired = updateIsAvailable;
        });
      }
    });
  }

  bool updateAlertIsEnabled(){
    bool showAlert = false;
    if (!isLoading && updateRequired){
      showAlert = true;
    }
    return showAlert;
  }

  void didPressNotificationsBell(){
    if (!isLoading && currentUser.username != null && !updateAlertIsEnabled() && hasLocation){
      returnIndexFromNotifPage(context);
    } else if (updateAlertIsEnabled()){
      ShowAlertDialogService().showUpdateDialog(context);
    }
  }

  void didPressCheckIn(){
    if (!isLoading && currentUser.username != null && !updateAlertIsEnabled() && hasLocation){
      PageTransitionService(context: context, currentUser: currentUser).transitionToCheckInPage();
    } else if (updateAlertIsEnabled()){
      ShowAlertDialogService().showUpdateDialog(context);
    }
  }

  void didPressAccountButton(){
    if (!isLoading && currentUser != null && !updateAlertIsEnabled() && hasLocation){
      _homeScaffoldKey.currentState.openDrawer();
    } else if (updateAlertIsEnabled()){
      ShowAlertDialogService().showUpdateDialog(context);
    }
  }

  void returnIndexFromNotifPage(BuildContext context) async {
    final returningPageIndex = await Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationPage(currentUser: currentUser)));
      if (returningPageIndex != null){
        setState(() {
          pageIndex = returningPageIndex;
        });
      }

  }

  void reloadData(){
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
        areaName: areaName,
        currentLat: currentLat,
        currentLon: currentLon,
        key: homePageKey,
        notifWidget: StreamUserNotifications(uid: uid, notifAction: () => didPressNotificationsBell()),//() => didPressNotificationsBell(),
        accountWidget: StreamUserAccount(uid: uid, accountAction: () => didPressAccountButton()),
      ),
      NewsFeedPage(uid: uid, key: newsPageKey,  discoverAction: isLoading ? null : () => PageTransitionService(context: context, uid: uid, areaName: areaName).transitionToDiscoverPage()),
      EventFeedPage(currentUser: currentUser, areaName: areaName, key: eventsPageKey, currentLat: currentLat, currentLon: currentLon, discoverAction: isLoading ? null : () => PageTransitionService(context: context, uid: uid, areaName: areaName).transitionToDiscoverPage()),
      WalletPage(currentUser: currentUser, key: walletPageKey)
    ];

    return Scaffold(
        key: _homeScaffoldKey,
        drawer: UserDrawerMenu(context: context, currentUser: currentUser).buildUserDrawerMenu(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        //() => didPressCheckIn(
        floatingActionButton: isLoading
          ? CustomCircleProgress(20.0, 20.0, 20.0, 20.0, FlatColors.webblenRed)
          : CheckInFloatingAction(
              checkInAction: () => didPressCheckIn(),
              checkInAvailable: checkInAvailable,
            ),
        bottomNavigationBar: FABBottomAppBar(
          centerItemText: 'Check In',
          notchedShape: CircularNotchedRectangle(),
          backgroundColor: Colors.white,
          onTabSelected: (int index) {
            setState(() {
              pageIndex = index;
            });
          },
          items: [
            FABBottomAppBarItem(iconData: FontAwesomeIcons.home, text: 'Home'),
            FABBottomAppBarItem(iconData: FontAwesomeIcons.newspaper, text: 'News'),
            FABBottomAppBarItem(iconData: FontAwesomeIcons.calendarDay, text: 'Events'),
            FABBottomAppBarItem(iconData: FontAwesomeIcons.wallet, text: 'Wallet'),
          ],
        ),
        body: PageStorage(
            bucket: pageStorageBucket,
            child: isLoading == true ? Container()
                : !hasLocation
                ? LocationPermissionsPage(reloadAction: () => reloadData())
                : !webblenIsAvailable
                ? LocationUnavailablePage(currentUser: currentUser)
                : updateRequired
                ? UpdateRequiredPage()
                : pageViews[pageIndex]
        ),
    );
  }
}




