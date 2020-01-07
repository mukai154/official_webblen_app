import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import 'package:webblen/firebase_data/community_data.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_location.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/models/community.dart';
import 'package:webblen/widgets/widgets_community/community_row.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';
import 'package:webblen/widgets/widgets_data_streams/stream_user_data.dart';

class DiscoverPage extends StatefulWidget {
  final String uid;
  final String areaName;
  final String simLocation;
  final double simLat;
  final double simLon;

  DiscoverPage({
    this.uid,
    this.areaName,
    this.simLocation,
    this.simLat,
    this.simLon,
  });

  @override
  _DiscoverPageState createState() => new _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  StreamSubscription userStream;
  WebblenUser currentUser;
  String areaName;
  double currentLat;
  double currentLon;
  bool isLoading = true;
  List<Community> popularComs = [];
  List<Community> activeComs = [];

  getUser(WebblenUser user) {
    currentUser = user;
    if (currentUser != null) {
      loadData();
    }
  }

  Future<Null> loadData() async {
    if (widget.simLocation != null) {
      areaName = widget.simLocation;
      currentLat = widget.simLat;
      currentLon = widget.simLon;
      isLoading = false;
      setState(() {});
    } else {
      LocationService().getCurrentLocation(context).then((location) {
        if (this.mounted) {
          if (location != null) {
            areaName = widget.areaName;
            currentLat = location.latitude;
            currentLon = location.longitude;
            getCommunities();
            setState(() {});
          }
        }
      });
    }
  }

  Future<void> getCommunities() async {
    popularComs = [];
    activeComs = [];
    await CommunityDataService()
        .getNearbyCommunities(currentLat, currentLon)
        .then((result) {
      popularComs = result.where((com) => com.status == 'active').toList();
      activeComs = result.where((com) => com.status == 'active').toList();
      popularComs.sort((comA, comB) =>
          comB.memberIDs.length.compareTo(comA.memberIDs.length));
      activeComs.sort((comA, comB) => comB.lastActivityTimeInMilliseconds
          .compareTo(comA.lastActivityTimeInMilliseconds));
      isLoading = false;
      if (this.mounted) {
        setState(() {});
      }
    });
  }

  initialize() async {
    StreamUserData.getUserStream(
      widget.uid,
      getUser,
    ).then((StreamSubscription<DocumentSnapshot> s) {
      userStream = s;
    });
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    // ** APP BAR
    final appBar = AppBar(
      elevation: 0.0,
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaleFactor: 1.0,
        ),
        child: Fonts().textW700(
          'Discover Communities',
          22.0,
          Colors.black,
          TextAlign.center,
        ),
      ),
      leading: BackButton(
        color: Colors.black,
      ),
      bottom: TabBar(
        indicatorColor: FlatColors.webblenRed,
        labelColor: FlatColors.darkGray,
        isScrollable: true,
        labelStyle: TextStyle(
          fontFamily: 'Helvetica',
          fontWeight: FontWeight.w500,
        ),
        tabs: <Widget>[
          Tab(
            text: "Most Popular",
          ),
          Tab(
            text: "Recently Active",
          ),
        ],
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            FontAwesomeIcons.search,
            color: Colors.black,
            size: 18.0,
          ),
          onPressed: () => PageTransitionService(
            context: context,
            currentUser: currentUser,
            areaName: areaName,
          ).transitionToSearchPage(),
        ),
      ],
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: appBar,
        body: TabBarView(
          children: <Widget>[
            isLoading
                ? LoadingScreen(
                    context: context,
                    loadingDescription: 'Searching for Top Communities...',
                  )
                : LiquidPullToRefresh(
                    color: FlatColors.webblenRed,
                    onRefresh: getCommunities,
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.only(
                        bottom: 8.0,
                      ),
                      itemCount: popularComs.length,
                      itemBuilder: (context, index) {
                        return CommunityRow(
                          showAreaName: true,
                          community: popularComs[index],
                          onClickAction: () => PageTransitionService(
                                  context: context,
                                  currentUser: currentUser,
                                  community: popularComs[index])
                              .transitionToCommunityProfilePage(),
                        );
                      },
                    ),
                  ),
            isLoading
                ? LoadingScreen(
                    context: context,
                    loadingDescription: 'Searching for Top Communities...',
                  )
                : LiquidPullToRefresh(
                    color: FlatColors.webblenRed,
                    onRefresh: getCommunities,
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.only(
                        bottom: 8.0,
                      ),
                      itemCount: activeComs.length,
                      itemBuilder: (context, index) {
                        return CommunityRow(
                          showAreaName: true,
                          community: activeComs[index],
                          onClickAction: () => PageTransitionService(
                            context: context,
                            currentUser: currentUser,
                            community: activeComs[index],
                          ).transitionToCommunityProfilePage(),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
