import 'package:flutter/material.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/widgets_data_streams/stream_community_data.dart';
import 'package:webblen/widgets_data_streams/stream_nearby_events.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/widgets_data_streams/stream_user_data.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/services_general/services_location.dart';
import 'package:webblen/widgets_common/common_progress.dart';

class DiscoverPage extends StatefulWidget {

  final String uid;
  final String areaName;
  DiscoverPage({this.uid, this.areaName});

  @override
  _DiscoverPageState createState() => new _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {

  StreamSubscription userStream;
  WebblenUser currentUser;
  double currentLat;
  double currentLon;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  initialize() async {
    StreamUserData.getUserStream(widget.uid, getUser).then((StreamSubscription<DocumentSnapshot> s){
      userStream = s;
    });
  }

  getUser(WebblenUser user){
    currentUser = user;
    if (currentUser != null){
      loadLocation();
    }
  }

  Future<Null> loadLocation() async {
    LocationService().getCurrentLocation(context).then((location){
      if (this.mounted){
        if (location != null){
          currentLat = location.latitude;
          currentLon = location.longitude;
          isLoading = false;
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ** APP BAR
    final appBar = AppBar (
      elevation: 0.0,
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title: Fonts().textW700('Discover', 24.0, Colors.black, TextAlign.center),
      leading: BackButton(color: FlatColors.darkGray),
      bottom: new TabBar(
        indicatorColor: FlatColors.webblenRed,
        labelColor: FlatColors.darkGray,
        isScrollable: true,
        labelStyle: TextStyle(fontFamily: 'Barlow', fontWeight: FontWeight.w500),
        tabs: <Widget>[
          new Tab(text: "Most Popular"),
          new Tab(text: "Most Active"),
          new Tab(text: "Nearby Events"),
        ],
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(FontAwesomeIcons.search, color: Colors.black, size: 18.0),
          onPressed: () => PageTransitionService(context: context, currentUser: currentUser, areaName: widget.areaName).transitionToSearchPage(),
        ),
      ],
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: appBar,
        body: TabBarView(
          children: <Widget>[
            isLoading
                ? LoadingScreen(context: context, loadingDescription: 'Searching for Top Communities...')
                : Container(
                    color: FlatColors.clouds,
                    child: StreamTopCommunities(currentUser: currentUser, locRefID: widget.areaName),
                  ),
            isLoading
                ? LoadingScreen(context: context, loadingDescription: 'Searching for Top Communities...')
                : Container(
                    color: FlatColors.clouds,
                    child: StreamActiveCommunities(currentUser: currentUser, locRefID: widget.areaName),
                  ),
            isLoading
                ? LoadingScreen(context: context, loadingDescription: 'Searching for Top Communities...')
                : Container(
                    color: FlatColors.clouds,
                    child: StreamNearbyEvents(currentUser: currentUser, currentLat: currentLat, currentLon: currentLon),
                  ),
          ],
        ),
      )
    );
  }

}