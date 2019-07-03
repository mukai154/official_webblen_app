import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:webblen/widgets_common/common_progress.dart';
import 'package:webblen/widgets_common/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/firebase_services/event_data.dart';
import 'package:webblen/firebase_services/auth.dart';
import 'package:webblen/firebase_services/user_data.dart';
import 'package:webblen/firebase_services/platform_data.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/services_location.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:webblen/models/community_news.dart';
import 'package:webblen/firebase_services/firebase_notification_services.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/widgets_home/user_drawer_menu.dart';
import 'package:webblen/widgets_data_streams/stream_user_notifications.dart';
import 'package:webblen/widgets_data_streams/stream_user_account.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/widgets_data_streams/stream_user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'home_pages/home_dashboard_page.dart';
import 'home_pages/event_feed_page.dart';
import 'home_pages/news_feed_page.dart';
import 'home_pages/wallet_page.dart';
import 'home_pages/location_permissions_page.dart';
import 'home_pages/update_required_page.dart';
import 'home_pages/location_unavailable_page.dart';
import 'styles/fonts.dart';
import 'widgets_home/app_bar_action.dart';
import 'widgets_data_streams/stream_user_transactions.dart';
import 'user_pages/notifications_page.dart';
import 'package:webblen/widgets_data_streams/stream_local_ads.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {

  RefreshController refreshController = RefreshController();

  var _homeScaffoldKey = GlobalKey<ScaffoldState>();

  final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  String notifToken;

  StreamSubscription userStream;
  WebblenUser currentUser;
  bool updateRequired = false;
  String uid;
  NetworkImage userImage;
  bool isLoading = true;
  bool isNewUser = false;
  int activeUserCount;
  double currentLat;
  double currentLon;
  List<CommunityNewsPost> communityNewsPosts;
  bool didClickNotice = false;
  bool checkInFound = false;
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
      Firestore.instance.collection("users").document(uid).get().then((
          userDoc) {
        if (userDoc.exists) {
          StreamUserData.getUserStream(uid, getUser).then((
              StreamSubscription<DocumentSnapshot> s) {
            userStream = s;
          });
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil('/setup', (Route<dynamic> route) => false);
        }
      });
    });
  }

  getUser(WebblenUser user) {
    currentUser = user;
    if (currentUser != null) {
      isNewUser = currentUser.isNew;
      EventDataService().receiveEventPoints(currentUser.eventHistory);
      FirebaseNotificationsService().updateFirebaseMessageToken(uid);
      FirebaseNotificationsService().configFirebaseMessaging(context, currentUser);
      loadLocation();
    }
  }

  Future<Null> loadLocation() async {
    LocationService().getCurrentLocation(context).then((location) {
      if (this.mounted) {
        if (location != null) {
          hasLocation = true;
          currentLat = location.latitude;
          currentLon = location.longitude;
          UserDataService().updateUserCheckIn(uid, currentLat, currentLon);
          PlatformDataService().getAreaName(currentLat, currentLon).then((area) {
            if (area.isEmpty) {
              webblenIsAvailable = false;
            }
            areaName = area;
            isLoading = false;
            setState(() {});
          });
        } else {
          hasLocation = false;
          isLoading = false;
          setState(() {});
        }
        PlatformDataService().isUpdateAvailable().then((updateIsAvailable) {
          if (updateIsAvailable) {
            setState(() {
              updateRequired = updateIsAvailable;
            });
          }
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

    final appBarCenter = pageIndex == 0
        ? Image.asset('assets/images/webblen_logo_text.jpg', width: 170.0, fit: BoxFit.cover,)
        : pageIndex == 1
        ? Fonts().textW700('News', 24.0, Colors.black, TextAlign.center)
        : pageIndex == 2
        ? Fonts().textW700('Events', 24.0, Colors.black, TextAlign.center)
        : Fonts().textW700('Wallet', 24.0, Colors.black, TextAlign.center);

    final appBarAction = pageIndex == 0
        ? uid != null ? StreamUserNotifications(uid: uid, notifAction: () => didPressNotificationsBell(), isLoading: isLoading) : Container()
        : pageIndex == 1
          ? uid != null
            ? CreateNewsPostAction(action: () => PageTransitionService(context: context, uid: uid, newEventOrPost: 'post').transitionToChooseCommunityPage())
            : Container()
        : pageIndex == 2
          ? uid != null
            ? CreateEventAction(action: () => PageTransitionService(context: context, uid: uid, newEventOrPost: 'event').transitionToChooseCommunityPage())
            : Container()
        : uid != null
          ? StreamUserTransactionsIcon(
              uid: uid,
              onTapAction: () => PageTransitionService(context: context, currentUser: currentUser).transitionToTransactionHistoryPage(),
            )
          : Container();

    final pageViews = [
      HomeDashboardPage(updateRequired: updateRequired, currentUser: currentUser, areaName: areaName, currentLat: currentLat, currentLon: currentLon, key: homePageKey),
      NewsFeedPage(currentUser: currentUser, key: newsPageKey,  discoverAction: isLoading ? null : () => PageTransitionService(context: context, uid: uid, areaName: areaName).transitionToDiscoverPage()),
      EventFeedPage(currentUser: currentUser, key: eventsPageKey, discoverAction: isLoading ? null : () => PageTransitionService(context: context, uid: uid, areaName: areaName).transitionToDiscoverPage()),
      WalletPage(currentUser: currentUser, key: walletPageKey)
    ];

    return Scaffold(
        appBar: WebblenAppBar().homeAppBar(
            uid != null
                ? StreamUserAccount(uid: uid, accountAction: () => didPressAccountButton())
                : Container(),
            appBarCenter,
            appBarAction
        ),
        key: _homeScaffoldKey,
        drawer: UserDrawerMenu(context: context, uid: uid).buildUserDrawerMenu(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: isLoading
            ? Container()
            : InkWell(
            onTap: () => didPressCheckIn(),
            child: Container(
              height: 70.0,
              width: 70.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(35.0)),
                  gradient: LinearGradient(
                      colors: [FlatColors.webblenRed, FlatColors.webblenPink]),
                  boxShadow: ([
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 1.8,
                      spreadRadius: 0.5,
                      offset: Offset(0.0, 3.0),
                    ),
                  ])
              ),
              child: Center(
                child: Icon(FontAwesomeIcons.mapMarkerAlt, color: Colors.white, size: 30.0),
              ),
            )
        ),
        bottomNavigationBar: isLoading
            ? Container()
            : FABBottomAppBar(
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
            child: isLoading == true ? LoadingScreen(context: context, loadingDescription: "Registering Location...")
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

