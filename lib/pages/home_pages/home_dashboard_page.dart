import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:webblen/firebase_data/event_data.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:webblen/models/event.dart';
import 'package:webblen/models/local_ad.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/utils/strings.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';
import 'package:webblen/widgets/widgets_home_tiles/all_tiles.dart';

class HomeDashboardPage extends StatefulWidget {
  final WebblenUser currentUser;
  final bool updateRequired;
  final String areaName;
  final Key key;
  final double currentLat;
  final double currentLon;
  final Widget accountWidget;
  final Widget notifWidget;

  HomeDashboardPage({
    this.currentUser,
    this.updateRequired,
    this.areaName,
    this.currentLat,
    this.currentLon,
    this.key,
    this.accountWidget,
    this.notifWidget,
  });

  @override
  _HomeDashboardPageState createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  AdmobBannerSize bannerSize;
  List<LocalAd> ads = [];
  List<WebblenUser> randomNearbyUsers = [];
  List<Event> webblenEvents = [];
  List<Event> recommendedEvents = [];
  String nearbyUserCount;
  bool isLoading = true;

  bool updateAlertIsEnabled() {
    bool showAlert = false;
    if (widget.updateRequired) {
      showAlert = true;
    }
    return showAlert;
  }

  loadData() {
    EventDataService().getExclusiveWebblenEvents().then((res) {
      webblenEvents = res;
      //GET Recommended Events
      EventDataService()
          .getRecommendedEvents(
        widget.currentUser.uid,
        widget.areaName,
      )
          .then((res) {
        recommendedEvents = res;
        //GET Number of Nearby Users
        UserDataService()
            .getNumberOfNearbyUsers(
          widget.currentLat,
          widget.currentLon,
        )
            .then((res) {
          nearbyUserCount = res;
          if (this.mounted) {
            isLoading = false;
            setState(() {});
          }
        });
      });
    });
  }

  void didPressSearchTile() {
    if (widget.currentUser != null && !widget.updateRequired) {
      PageTransitionService(
        context: context,
        currentUser: widget.currentUser,
        areaName: widget.areaName,
      ).transitionToSearchPage();
    } else if (updateAlertIsEnabled()) {
      ShowAlertDialogService().showUpdateDialog(context);
    }
  }

  void didPressCommunitiesTile() {
    if (widget.currentUser != null && !widget.updateRequired) {
      PageTransitionService(
        context: context,
        uid: widget.currentUser.uid,
        areaName: widget.areaName,
      ).transitionToCommunitiesPage();
    } else if (updateAlertIsEnabled()) {
      ShowAlertDialogService().showUpdateDialog(context);
    }
  }

  void didPressEventsTile() {
    if (widget.currentUser != null && !widget.updateRequired) {
      PageTransitionService(
        context: context,
        currentUser: widget.currentUser,
        lat: widget.currentLat,
        lon: widget.currentLon,
      ).transitionToEventsPage();
    } else if (updateAlertIsEnabled()) {
      ShowAlertDialogService().showUpdateDialog(context);
    }
  }

  void didPressCalendarTile() {
    if (widget.currentUser != null && !widget.updateRequired) {
      PageTransitionService(
        context: context,
        currentUser: widget.currentUser,
      ).transitionToCalendarPage();
    } else if (updateAlertIsEnabled()) {
      ShowAlertDialogService().showUpdateDialog(context);
    }
  }

  void didPressCommunityRequestTile() {
    if (widget.currentUser != null && !widget.updateRequired) {
      PageTransitionService(
        context: context,
        currentUser: widget.currentUser,
        areaName: widget.areaName,
      ).transitionToCommunityRequestPage();
    } else if (updateAlertIsEnabled()) {
      ShowAlertDialogService().showUpdateDialog(context);
    }
  }

//  void didPressCommunityActivityTile() {
//    if (widget.currentUser != null && !widget.updateRequired) {
//      PageTransitionService(
//        context: context,
//        currentUser: widget.currentUser,
//      ).transitionToUserRanksPage();
//    } else if (updateAlertIsEnabled()) {
//      ShowAlertDialogService().showUpdateDialog(context);
//    }
//  }

//  void didPressWebblenEventsTile() {
//    if (widget.currentUser != null && !widget.updateRequired) {
//      PageTransitionService(
//        context: context,
//        currentUser: widget.currentUser,
//        events: webblenEvents,
//      ).transitionToWebblenEventsPage();
//    } else if (updateAlertIsEnabled()) {
//      ShowAlertDialogService().showUpdateDialog(context);
//    }
//  }

  @override
  void initState() {
    super.initState();
    loadData();
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
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MediaQuery(
                        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                        child: widget.areaName.length <= 6
                            ? Fonts().textW700(
                                widget.areaName,
                                40,
                                Colors.black,
                                TextAlign.left,
                              )
                            : widget.areaName.length <= 8
                                ? Fonts().textW700(
                                    widget.areaName,
                                    35,
                                    Colors.black,
                                    TextAlign.left,
                                  )
                                : widget.areaName.length <= 10
                                    ? Fonts().textW700(
                                        widget.areaName,
                                        30,
                                        Colors.black,
                                        TextAlign.left,
                                      )
                                    : widget.areaName.length <= 12
                                        ? Fonts().textW700(
                                            widget.areaName,
                                            25,
                                            Colors.black,
                                            TextAlign.left,
                                          )
                                        : Fonts().textW700(
                                            widget.areaName,
                                            20,
                                            Colors.black,
                                            TextAlign.left,
                                          ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      widget.notifWidget,
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      widget.accountWidget,
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => PageTransitionService(
              context: context,
              currentUser: widget.currentUser,
              areaName: widget.areaName,
            ).transitionToSearchPage(),
            child: SearchTile(),
          ),
          isLoading
              ? Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        top: 8.0,
                      ),
                      child: CustomLinearProgress(
                        progressBarColor: FlatColors.webblenRed,
                      ),
                    ),
                  ],
                )
              : Container(
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
                            CommunityRequestTile(
                              onTap: () => didPressCommunityRequestTile(),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        //margin: EdgeInsets.only(top: 8.0),
                        child: AdmobBanner(
                          adUnitId: Strings().getAdMobBannerID(),
                          adSize: bannerSize,
                          listener: (AdmobAdEvent event, Map<String, dynamic> args) {
//            handleEvent(event, args, 'Banner');
                          },
                        ),
                      ),
//                      Row(
//                        mainAxisAlignment: MainAxisAlignment.start,
//                        children: <Widget>[
//                          Container(
//                            //width: MediaQuery.of(context).size.width/1.5,
//                            child: Padding(
//                              padding: EdgeInsets.only(
//                                left: 16.0,
//                                top: 16.0,
//                                bottom: 8.0,
//                              ),
//                              child: MediaQuery(
//                                data: MediaQuery.of(context).copyWith(
//                                  textScaleFactor: 1.0,
//                                ),
//                                child: Fonts().textW700(
//                                  'Events You Might Like',
//                                  18.0,
//                                  Colors.black,
//                                  TextAlign.left,
//                                ),
//                              ),
//                            ),
//                          ),
//                        ],
//                      ),
//                      webblenEvents.isEmpty
//                          ? recommendedEvents.isEmpty
//                              ? Container()
//                              : EventCarousel(
//                                  events: recommendedEvents,
//                                  currentUser: widget.currentUser,
//                                )
//                          : WebblenEventsTile(
//                              onTap: () => didPressWebblenEventsTile(),
//                            ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
