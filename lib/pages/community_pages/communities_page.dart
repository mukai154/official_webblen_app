import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:webblen/firebase_data/community_data.dart';
import 'package:webblen/models/community.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';
import 'package:webblen/widgets/widgets_community/community_row.dart';
import 'package:webblen/widgets/widgets_data_streams/stream_user_data.dart';

class CommunitiesPage extends StatefulWidget {
  final String uid;
  final String areaName;

  CommunitiesPage({
    this.uid,
    this.areaName,
  });

  @override
  _CommunitiesPageState createState() => new _CommunitiesPageState();
}

class _CommunitiesPageState extends State<CommunitiesPage> {
  StreamSubscription userStream;
  WebblenUser currentUser;
  String areaName;
  double currentLat;
  double currentLon;
  bool isLoading = true;
  List<Community> popularComs = [];
  List<Community> activeComs = [];
  List<Community> activeUserComs = [];
  List<Community> pendingUserComs = [];
  List<String> areaNames = [];

  getUser(WebblenUser user) {
    currentUser = user;
    if (currentUser != null) {
      loadData();
    }
  }

  Future<Null> loadData() async {
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

  List<Community> getCommunitiesInArea(String areaName) {
    return activeUserComs.where((com) => com.areaName == areaName).toSet().toList(
          growable: true,
        );
  }

  Future<void> getCommunities() async {
    popularComs = [];
    activeComs = [];
    await CommunityDataService().getNearbyCommunities(currentLat, currentLon).then((result) {
      popularComs = result.where((com) => com.status == 'active').toList();
      activeComs = result.where((com) => com.status == 'active').toList();
      popularComs.sort((comA, comB) => comB.memberIDs.length.compareTo(comA.memberIDs.length));
      activeComs.sort((comA, comB) => comB.lastActivityTimeInMilliseconds.compareTo(comA.lastActivityTimeInMilliseconds));
      getUserCommunities();
    });
  }

  Future<void> getUserCommunities() async {
    activeUserComs = [];
    pendingUserComs = [];
    await CommunityDataService().getUserCommunities(widget.uid).then((result) {
      activeUserComs = result.where((com) => com.status == 'active').toList();
      pendingUserComs = result.where((com) => com.status == 'pending').toList();
      activeUserComs.sort((comA, comB) => comA.name[1].compareTo(comB.name[1]));
      pendingUserComs.sort((comA, comB) => comA.name[1].compareTo(comB.name[1]));
    });
    sortCommunitiesByArea();
    isLoading = false;
    if (this.mounted) {
      setState(() {});
    }
  }

  sortCommunitiesByArea() {
    activeUserComs.forEach((com) {
      if (!areaNames.contains(com.areaName)) {
        areaNames.add(com.areaName);
      }
    });
    areaNames.sort((comA, comB) => comA.compareTo(comB));
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
          'Communities',
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
            text: "Most Popular in ${widget.areaName}",
          ),
          Tab(
            text: "Recently Active in ${widget.areaName}",
          ),
          Tab(
            text: "My Communities",
          ),
          Tab(
            text: "Pending Commmunties",
          ),
        ],
      ),
      actions: <Widget>[
        Row(
          children: <Widget>[
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
            IconButton(
              onPressed: () => PageTransitionService(
                context: context,
              ).transitionToNewCommunityPage(),
              icon: Icon(
                FontAwesomeIcons.plus,
                size: 20.0,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );

    return DefaultTabController(
      length: 4,
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
                          onClickAction: () => PageTransitionService(context: context, currentUser: currentUser, community: popularComs[index])
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
            isLoading
                ? LoadingScreen(
                    context: context,
                    loadingDescription: 'Searching for Top Communities...',
                  )
                : Container(
                    color: Colors.white,
                    child: LiquidPullToRefresh(
                      color: FlatColors.webblenRed,
                      onRefresh: getUserCommunities,
                      child: activeUserComs.isEmpty
                          ? ListView(
                              children: <Widget>[
                                SizedBox(
                                  height: 64.0,
                                ),
                                MediaQuery(
                                  data: MediaQuery.of(context).copyWith(
                                    textScaleFactor: 1.0,
                                  ),
                                  child: Fonts().textW500(
                                    'You Are Not a Member of Any Active Communities',
                                    14.0,
                                    Colors.black45,
                                    TextAlign.center,
                                  ),
                                ),
                                MediaQuery(
                                  data: MediaQuery.of(context).copyWith(
                                    textScaleFactor: 1.0,
                                  ),
                                  child: Fonts().textW300(
                                    'Pull Down To Refresh',
                                    14.0,
                                    Colors.black26,
                                    TextAlign.center,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                              ],
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.only(
                                bottom: 8.0,
                              ),
                              itemCount: areaNames.length,
                              itemBuilder: (context, index) {
                                return AreaRow(
                                  areaName: areaNames[index],
                                  numberOfCommunities: getCommunitiesInArea(areaNames[index]).length,
                                  onTapAction: () => PageTransitionService(
                                    context: context,
                                    currentUser: currentUser,
                                    areaName: areaNames[index],
                                    action: 'none',
                                    communities: getCommunitiesInArea(
                                      areaNames[index],
                                    ),
                                  ).transitionToCommunitiesInAreaPage(),
                                );
                              },
                            ),
                    ),
                  ),
            isLoading
                ? LoadingScreen(
                    context: context,
                    loadingDescription: 'Searching for Top Communities...',
                  )
                : Container(
                    color: Colors.white,
                    child: LiquidPullToRefresh(
                      color: FlatColors.webblenRed,
                      onRefresh: getUserCommunities,
                      child: pendingUserComs.isEmpty
                          ? ListView(
                              children: <Widget>[
                                SizedBox(
                                  height: 64.0,
                                ),
                                MediaQuery(
                                  data: MediaQuery.of(context).copyWith(
                                    textScaleFactor: 1.0,
                                  ),
                                  child: Fonts().textW500(
                                    'You Currently Have No Communities Pending',
                                    14.0,
                                    Colors.black45,
                                    TextAlign.center,
                                  ),
                                ),
                                SizedBox(
                                  height: 8.0,
                                ),
                                MediaQuery(
                                  data: MediaQuery.of(context).copyWith(
                                    textScaleFactor: 1.0,
                                  ),
                                  child: Fonts().textW300(
                                    'Pull Down To Refresh',
                                    14.0,
                                    Colors.black26,
                                    TextAlign.center,
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.only(
                                bottom: 8.0,
                              ),
                              itemCount: pendingUserComs.length,
                              itemBuilder: (context, index) {
                                return CommunityRow(
                                  showAreaName: true,
                                  community: pendingUserComs[index],
                                  onClickAction: () => PageTransitionService(context: context, currentUser: currentUser, community: pendingUserComs[index])
                                      .transitionToCommunityProfilePage(),
                                );
                              },
                            ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
