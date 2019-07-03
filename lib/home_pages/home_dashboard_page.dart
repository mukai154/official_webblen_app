import 'package:flutter/material.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/widgets_home_tiles/all_tiles.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/widgets_data_streams/stream_local_ads.dart';
import 'package:webblen/models/local_ad.dart';
import 'package:webblen/firebase_services/ad_data.dart';

class HomeDashboardPage extends StatefulWidget {

  final WebblenUser currentUser;
  final bool updateRequired;
  final String areaName;
  final double currentLat;
  final double currentLon;
  final Key key;

  HomeDashboardPage({this.currentUser, this.updateRequired, this.areaName, this.currentLat, this.currentLon, this.key});

  @override
  _HomeDashboardPageState createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {

  bool adsExist = false;

  bool updateAlertIsEnabled(){
    bool showAlert = false;
    if (widget.updateRequired){
      showAlert = true;
    }
    return showAlert;
  }

  void didPressCheckIn(){
    if (widget.currentUser != null && !widget.updateRequired){
      PageTransitionService(context: context, currentUser: widget.currentUser).transitionToCheckInPage();
    } else if (widget.updateRequired){
      ShowAlertDialogService().showUpdateDialog(context);
    }
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

  @override
  void initState() {
    super.initState();
    AdDataService().adsExist(widget.currentLat, widget.currentLon).then((result){
      setState(() {
        adsExist = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FlatColors.lynxWhite,
      child: Stack(
        children: <Widget>[
          StaggeredGridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 0.0,
            mainAxisSpacing: 8.0,
            padding: EdgeInsets.symmetric(vertical: 16.0),
            children: <Widget>[
              BasicTile(
                child: SearchTile(),
                onTap: () => didPressSearchTile(),
              ),
              StreamLocalAds(lat: widget.currentLat, lon: widget.currentLon),
              BasicTile(
                child: CommunityActivityTile(currentUser: widget.currentUser, lat: widget.currentLat, lon: widget. currentLon),
                onTap: () => didPressCommunityActivityTile(),
              ),
              BasicTile(
                child: DiscoverTile(),
                onTap: () => didPressDiscoverTile(),
              ),
              BasicTile(
                child: MyCommunitiesTile(),
                onTap: () => didPressMyCommunitiesTile(),
              ),
            ],
            staggeredTiles: [
              StaggeredTile.extent(2, 50.0),
              adsExist ? StaggeredTile.extent(2, 100.0) : StaggeredTile.extent(0, 0.0),
              StaggeredTile.extent(2, 160.0),
              StaggeredTile.extent(2, 75.0),
              StaggeredTile.extent(2, 75.0),
            ],
          ),
        ],
      ),
    );
  }
}
