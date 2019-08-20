import 'package:flutter/material.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/widgets_home_tiles/all_tiles.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/firebase_data/ad_data.dart';
import 'package:webblen/models/local_ad.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:webblen/widgets_ads/ad_carousel.dart';
import 'package:webblen/widgets_common/common_progress.dart';
import 'package:webblen/widgets_user/user_carousel.dart';
import 'package:webblen/models/event.dart';
import 'package:webblen/widgets_home_tiles/webblen_events_tile.dart';
import 'package:webblen/firebase_data/event_data.dart';

class HomeDashboardPage extends StatefulWidget {

  final WebblenUser currentUser;
  final bool updateRequired;
  final String areaName;
  final Key key;
  final double currentLat;
  final double currentLon;
  final Widget accountWidget;
  final Widget notifWidget;

  HomeDashboardPage({this.currentUser, this.updateRequired, this.areaName, this.currentLat, this.currentLon, this.key, this.accountWidget, this.notifWidget});

  @override
  _HomeDashboardPageState createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {

  List<LocalAd> ads = [];
  List<WebblenUser> randomNearbyUsers = [];
  List<Event> webblenEvents = [];
  String nearbyUserCount;
  bool isLoading = true;

  bool updateAlertIsEnabled(){
    bool showAlert = false;
    if (widget.updateRequired){
      showAlert = true;
    }
    return showAlert;
  }

  loadData(){
    //GET nearby ads
    AdDataService().getNearbyAds(widget.currentLat, widget.currentLon).then((res){
      ads = res;
      //GET Webblen Events
      EventDataService().getExclusiveWebblenEvents().then((res){
        webblenEvents = res;
        //GET Number of Nearby Users
        UserDataService().getNumberOfNearbyUsers(widget.currentLat, widget.currentLon).then((res){
          nearbyUserCount = res;
          //GET Nearby Users
          UserDataService().get10RandomUsers(widget.currentLat, widget.currentLon).then((res){
            if (this.mounted){
              randomNearbyUsers = res;
              isLoading = false;
              setState(() {});
            }
          });
        });
      });
    });
  }

  void didPressDiscoverTile(){
    if (widget.currentUser != null && !widget.updateRequired){
      PageTransitionService(context: context, uid: widget.currentUser.uid, areaName: widget.areaName).transitionToDiscoverPage();
    } else if (updateAlertIsEnabled()){
      ShowAlertDialogService().showUpdateDialog(context);
    }
  }

  void didPressSearchTile(){
    if (widget.currentUser != null && !widget.updateRequired){
      PageTransitionService(context: context, currentUser: widget.currentUser, areaName: widget.areaName).transitionToSearchPage();
    } else if (updateAlertIsEnabled()){
      ShowAlertDialogService().showUpdateDialog(context);
    }
  }

  void didPressMyCommunitiesTile(){
    if (widget.currentUser != null && !widget.updateRequired){
      PageTransitionService(context: context, uid: widget.currentUser.uid, areaName: widget.areaName).transitionToMyCommunitiesPage();
    } else if (updateAlertIsEnabled()){
      ShowAlertDialogService().showUpdateDialog(context);
    }
  }

  void didPressCommunityActivityTile(){
    if (widget.currentUser != null && !widget.updateRequired){
      PageTransitionService(context: context, currentUser: widget.currentUser).transitionToUserRanksPage();
    } else if (updateAlertIsEnabled()){
      ShowAlertDialogService().showUpdateDialog(context);
    }
  }

  void didPressWebblenEventsTile(){
    if (widget.currentUser != null && !widget.updateRequired){
      PageTransitionService(context: context, currentUser: widget.currentUser, events: webblenEvents).transitionToWebblenEventsPage();
    } else if (updateAlertIsEnabled()){
      ShowAlertDialogService().showUpdateDialog(context);
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
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
            margin: EdgeInsets.only(left: 16, top: 30, right: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     Fonts().textW700('Home', 40, Colors.black, TextAlign.left),
                    ]
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        widget.notifWidget
                      ]
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        widget.accountWidget
                      ]
                  ),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () => PageTransitionService(context: context, currentUser: widget.currentUser, areaName: widget.areaName).transitionToSearchPage(),
            child: SearchTile(),
          ),
          Container(
            margin: EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0, bottom: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                randomNearbyUsers.isEmpty
                  ? Fonts().textW700('Searching...', 18.0, Colors.black, TextAlign.left)
                  : Fonts().textW700('$nearbyUserCount People Nearby', 18.0, Colors.black, TextAlign.left),
                FlatButton(
                  onPressed: () => didPressCommunityActivityTile(),
                  color: Colors.transparent,
                  textColor: Colors.black,
                  padding: EdgeInsets.all(0),
                  child: Fonts().textW400('See More', 16.0, FlatColors.webblenRed, TextAlign.right),
                ),
              ],
            ),
          ),
          isLoading
              ? Container(
                  margin: EdgeInsets.symmetric(vertical: 50.0),
                  height: 1.0,
                  child: CustomLinearProgress(progressBarColor: Colors.black12),
                )
              :  randomNearbyUsers.isEmpty
                  ? Container()
                  : UserCarousel(currentUser: widget.currentUser, users: randomNearbyUsers),
          ads.isEmpty || webblenEvents.isNotEmpty ? Container() : AdCarousel(ads: ads),
          webblenEvents.isEmpty
            ? Container()
            : Container(
            height: 60.0,
            margin: EdgeInsets.only(bottom: 8.0),
            child: BasicTile(
              child: WebblenEventsTile(),
              onTap: () => didPressWebblenEventsTile(),
            ),
          ),
          Container(
            height: 60.0,
            child: BasicTile(
              child: DiscoverTile(),
              onTap: () => didPressDiscoverTile(),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 8.0),
            height: 60.0,
            child: BasicTile(
              child: MyCommunitiesTile(),
              onTap: () => didPressMyCommunitiesTile(),
            ),
          ),
        ],
      ),
    );
  }
}
