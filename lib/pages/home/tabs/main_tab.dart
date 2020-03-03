import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:webblen/utils/values/strings.dart';
import 'package:webblen/widgets/home/app_bar/main_app_bar.dart';
import 'package:webblen/widgets/home/tiles/all_tiles.dart';

class MainTab extends StatefulWidget {
  final String uid;
  final String userImageURL;
  final String cityName;
  final VoidCallback didPressUserImage;
  final VoidCallback didPressNotifBell;
  final Key key;

  MainTab({
    this.uid,
    this.userImageURL,
    this.cityName,
    this.didPressUserImage,
    this.didPressNotifBell,
    this.key,
  });

  @override
  _MainTabState createState() => _MainTabState();
}

class _MainTabState extends State<MainTab> {
  AdmobBannerSize bannerSize;

  void didPressSearchTile() {
//    if (widget.currentUser != null && !widget.updateRequired) {
//      PageTransitionService(
//        context: context,
//        currentUser: widget.currentUser,
//        areaName: widget.areaName,
//      ).transitionToSearchPage();
//    } else if (updateAlertIsEnabled()) {
//      ShowAlertDialogService().showUpdateDialog(context);
//    }
  }

  void didPressCommunitiesTile() {
//    if (widget.currentUser != null && !widget.updateRequired) {
//      PageTransitionService(
//        context: context,
//        uid: widget.currentUser.uid,
//        areaName: widget.areaName,
//      ).transitionToCommunitiesPage();
//    } else if (updateAlertIsEnabled()) {
//      ShowAlertDialogService().showUpdateDialog(context);
//    }
  }

  void didPressEventsTile() {
//    if (widget.currentUser != null && !widget.updateRequired) {
//      PageTransitionService(
//        context: context,
//        currentUser: widget.currentUser,
//        lat: widget.currentLat,
//        lon: widget.currentLon,
//      ).transitionToEventsPage();
//    } else if (updateAlertIsEnabled()) {
//      ShowAlertDialogService().showUpdateDialog(context);
//    }
  }

  void didPressCalendarTile() {
//    if (widget.currentUser != null && !widget.updateRequired) {
//      PageTransitionService(
//        context: context,
//        currentUser: widget.currentUser,
//      ).transitionToCalendarPage();
//    } else if (updateAlertIsEnabled()) {
//      ShowAlertDialogService().showUpdateDialog(context);
//    }
  }

  void didPressCommunityRequestTile() {
//    if (widget.currentUser != null && !widget.updateRequired) {
//      PageTransitionService(
//        context: context,
//        currentUser: widget.currentUser,
//        areaName: widget.areaName,
//      ).transitionToCommunityRequestPage();
//    } else if (updateAlertIsEnabled()) {
//      ShowAlertDialogService().showUpdateDialog(context);
//    }
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      Admob.initialize('ca-app-pub-2136415475966451~5144610810');
    } else if (Platform.isAndroid) {
      Admob.initialize('ca-app-pub-2136415475966451~9434499178');
    }
    bannerSize = AdmobBannerSize.BANNER;
//    EventDataService().addEventDataField("d.startDate", "Jan 31");
//    EventDataService().addEventDataField("d.endDate", "Jan 31");
//    EventDataService().addEventDataField("d.startTime", "7:00 PM");
//    EventDataService().addEventDataField("d.endTime", "9:00 PM");
//    EventDataService().addEventDataField("d.timezone", "CST");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
              height: 70,
              margin: EdgeInsets.only(
                left: 16,
                top: 30,
                right: 8,
              ),
              child: MainTabAppBar(
                uid: widget.uid,
                cityName: widget.cityName,
                userImageURL: widget.userImageURL,
                didPressNotifBell: widget.didPressNotifBell,
                didPressUserImage: widget.didPressUserImage,
              )),
          GestureDetector(
            onTap: null,
            child: SearchTile(),
          ),
          Container(
            height: MediaQuery.of(context).size.height > 667.0
                ? MediaQuery.of(context).size.height * 0.715
                : MediaQuery.of(context).size.height > 568.0 ? MediaQuery.of(context).size.height * 0.67 : MediaQuery.of(context).size.height * 0.60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 2.0,
                    horizontal: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      EventsTile(
                        onTap: () => didPressEventsTile(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 2.0,
                    horizontal: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      CommunitiesTile(
                        onTap: () => didPressCommunitiesTile(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      CalendarTile(
                        onTap: () => didPressCalendarTile(),
                      ),
                      HaveAnIdeaTile(
                        onTap: () => didPressCalendarTile(),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: AdmobBanner(
                    adUnitId: Strings().getAdMobBannerID(),
                    adSize: bannerSize,
                    listener: (AdmobAdEvent event, Map<String, dynamic> args) {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
