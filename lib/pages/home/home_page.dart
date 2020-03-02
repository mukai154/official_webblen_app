import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:webblen/animations/shake_animation.dart';
import 'package:webblen/firebase/data/platform_data.dart';
import 'package:webblen/firebase/services/messaging.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/location/device_location.dart';
import 'package:webblen/services/network/network_status.dart';
import 'package:webblen/widgets/home/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:webblen/widgets/home/bottom_nav_bar/check_in_button.dart';
import 'package:webblen/widgets/home/drawer_menu/drawer_menu.dart';

import 'tabs/account_tab.dart';
import 'tabs/main_tab.dart';
import 'tabs/news_tab.dart';
import 'tabs/wallet_tab.dart';

class HomePage extends StatefulWidget {
  final String currentUserUID;
  HomePage({this.currentUserUID});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey homeScaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = true;
  bool isConnectedToNetwork = false;
  bool updateRequired = false;
  bool hasLocationPermission = false;
  bool checkInAvailable = false;
  LocationData locationData;
  int pageIndex = 0;

  final PageStorageBucket pageStorageBucket = PageStorageBucket();
  final Key mainPageKey = PageStorageKey('mainPageKey');
  final Key newsPageKey = PageStorageKey('newsPageKey');
  final Key walletPageKey = PageStorageKey('walletPageKey');
  final Key settingsPageKey = PageStorageKey('settingsPageKey');

  initialize() async {
    //Check Network Connection
    isConnectedToNetwork = await NetworkStatus().isConnected();
    if (isConnectedToNetwork) {
      //Check if Update is Available
      updateRequired = await PlatformDataService().isUpdateRequired();
      if (!updateRequired) {
        //Configure Messaging
        FirebaseMessagingService().updateFirebaseMessaging(context, widget.currentUserUID);
        //Check Location Permissions
        hasLocationPermission = await DeviceLocationService().hasLocationPermission();
        if (hasLocationPermission) {
          //Get Location Data
          locationData = await DeviceLocationService().getCurrentLocation(context);
        }
      }
    }
    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    //Configure User
    WebblenUser currentUser = Provider.of<WebblenUser>(context);

    //Dashboard Tabs
    final pageTabs = [
      MainTab(),
      NewsTab(),
      WalletTab(),
      AccountTab(),
    ];

    return Scaffold(
      key: homeScaffoldKey,
      drawer: UserDrawerMenu(context: context, currentUser: currentUser, hasEarningsAccount: false).buildUserDrawerMenu(),
      body: Container(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: checkInAvailable
          ? ShakeAnimation(
              widgetToShake: CheckInButton(
                checkInAction: null, //() => didPressCheckIn(),
                checkInAvailable: true,
              ),
            )
          : CheckInButton(
              checkInAction: null, //() => CheckInButton(),
              checkInAvailable: false,
            ),
      bottomNavigationBar: BottomNavBar(
        notchedShape: CircularNotchedRectangle(),
        backgroundColor: Colors.white,
        onTabSelected: (int index) {
          setState(() {
            pageIndex = index;
          });
        },
        icons: [
          FontAwesomeIcons.home,
          FontAwesomeIcons.newspaper,
          FontAwesomeIcons.wallet,
          FontAwesomeIcons.userAlt,
        ],
      ),
    );
  }
}
