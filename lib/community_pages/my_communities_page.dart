import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:webblen/firebase_data/community_data.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:webblen/models/community.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets_common/common_progress.dart';
import 'package:webblen/widgets_community/community_row.dart';

class MyCommunitiesPage extends StatefulWidget {
  final String uid;
  final String areaName;
  final String action;
  MyCommunitiesPage({this.uid, this.areaName, this.action});

  @override
  _MyCommunitiesPageState createState() => _MyCommunitiesPageState();
}

class _MyCommunitiesPageState extends State<MyCommunitiesPage> {
  WebblenUser currentUser;
  bool isLoading = true;
  List<Community> activeUserComs = [];
  List<Community> pendingUserComs = [];
  List<String> areaNames = [];

  initialize() async {
    UserDataService().getUserByID(widget.uid).then((result) async {
      currentUser = result;
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
    setState(() {});
  }

  sortCommunitiesByArea() {
    activeUserComs.forEach((com) {
      if (!areaNames.contains(com.areaName)) {
        areaNames.add(com.areaName);
      }
    });
    areaNames.sort((comA, comB) => comA.compareTo(comB));
  }

  List<Community> getCommunitiesInArea(String areaName) {
    return activeUserComs.where((com) => com.areaName == areaName).toSet().toList(growable: true);
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      elevation: 0.0,
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: Fonts().textW700(
            widget.action == 'newEvent' ? 'New Event' : widget.action == 'newPost' ? 'New Post' : 'My Communities', 20.0, Colors.black, TextAlign.center),
      ),
      leading: BackButton(color: FlatColors.darkGray),
      bottom: widget.action == 'newEvent' || widget.action == 'newPost'
          ? PreferredSize(child: Container(), preferredSize: null)
          : TabBar(
              indicatorColor: FlatColors.webblenRed,
              labelColor: FlatColors.londonSquare,
              isScrollable: true,
              labelStyle: TextStyle(fontFamily: 'Helvetica Neue', fontWeight: FontWeight.w500),
              tabs: <Widget>[new Tab(text: "Cities"), new Tab(text: "Pending Communties")],
            ),
      actions: <Widget>[
        widget.action == 'newEvent' || widget.action == 'newPost'
            ? Container()
            : IconButton(
                icon: Icon(FontAwesomeIcons.plusSquare, color: Colors.black, size: 24.0),
                onPressed: () => PageTransitionService(context: context, currentUser: currentUser, areaName: widget.areaName).transitionToNewCommunityPage())
      ],
    );

    return widget.action == 'newEvent' || widget.action == 'newPost'
        ? Scaffold(
            appBar: appBar,
            body: isLoading
                ? LoadingScreen(context: context, loadingDescription: 'Loading Your Communities...')
                : Container(
                    color: Colors.white,
                    child: LiquidPullToRefresh(
                      color: FlatColors.webblenRed,
                      onRefresh: getUserCommunities,
                      child: activeUserComs.isEmpty
                          ? ListView(
                              children: <Widget>[
                                SizedBox(height: 64.0),
                                MediaQuery(
                                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                  child: Fonts().textW500('You Are Not a Member of Any Active Communities', 14.0, Colors.black45, TextAlign.center),
                                ),
                                MediaQuery(
                                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                    child: Fonts().textW300('Pull Down To Refresh', 14.0, Colors.black26, TextAlign.center)),
                                SizedBox(height: 8.0),
                              ],
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.only(bottom: 8.0),
                              itemCount: areaNames.length,
                              itemBuilder: (context, index) {
                                return AreaRow(
                                  areaName: areaNames[index],
                                  numberOfCommunities: getCommunitiesInArea(areaNames[index]).length,
                                  onTapAction: () => PageTransitionService(
                                          context: context,
                                          currentUser: currentUser,
                                          areaName: widget.areaName,
                                          action: widget.action,
                                          communities: getCommunitiesInArea(areaNames[index]))
                                      .transitionToCommunitiesInAreaPage(),
                                );
                              },
                            ),
                    ),
                  ),
          )
        : DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: appBar,
              body: TabBarView(
                children: <Widget>[
                  isLoading
                      ? LoadingScreen(context: context, loadingDescription: 'Loading Your Communities...')
                      : Container(
                          color: Colors.white,
                          child: LiquidPullToRefresh(
                            color: FlatColors.webblenRed,
                            onRefresh: getUserCommunities,
                            child: activeUserComs.isEmpty
                                ? ListView(
                                    children: <Widget>[
                                      SizedBox(height: 64.0),
                                      MediaQuery(
                                        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                        child: Fonts().textW500('You Are Not a Member of Any Active Communities', 14.0, Colors.black45, TextAlign.center),
                                      ),
                                      MediaQuery(
                                          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                          child: Fonts().textW300('Pull Down To Refresh', 14.0, Colors.black26, TextAlign.center)),
                                      SizedBox(height: 8.0),
                                    ],
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.only(bottom: 8.0),
                                    itemCount: areaNames.length,
                                    itemBuilder: (context, index) {
                                      return AreaRow(
                                        areaName: areaNames[index],
                                        numberOfCommunities: getCommunitiesInArea(areaNames[index]).length,
                                        onTapAction: () => PageTransitionService(
                                                context: context,
                                                currentUser: currentUser,
                                                areaName: widget.areaName,
                                                action: 'none',
                                                communities: getCommunitiesInArea(areaNames[index]))
                                            .transitionToCommunitiesInAreaPage(),
                                      );
                                    },
                                  ),
                          ),
                        ),
                  isLoading
                      ? LoadingScreen(context: context, loadingDescription: 'Loading Your Communities...')
                      : Container(
                          color: Colors.white,
                          child: LiquidPullToRefresh(
                            color: FlatColors.webblenRed,
                            onRefresh: getUserCommunities,
                            child: pendingUserComs.isEmpty
                                ? ListView(
                                    children: <Widget>[
                                      SizedBox(height: 64.0),
                                      MediaQuery(
                                        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                        child: Fonts().textW500('You Currently Have No Communities Pending', 14.0, Colors.black45, TextAlign.center),
                                      ),
                                      SizedBox(height: 8.0),
                                      MediaQuery(
                                          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                                          child: Fonts().textW300('Pull Down To Refresh', 14.0, Colors.black26, TextAlign.center)),
                                    ],
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.only(bottom: 8.0),
                                    itemCount: pendingUserComs.length,
                                    itemBuilder: (context, index) {
                                      return CommunityRow(
                                        showAreaName: true,
                                        community: pendingUserComs[index],
                                        onClickAction: () =>
                                            PageTransitionService(context: context, currentUser: currentUser, community: pendingUserComs[index])
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
