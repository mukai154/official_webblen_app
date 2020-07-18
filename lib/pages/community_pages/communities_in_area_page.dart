import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:webblen/firebase_data/community_data.dart';
import 'package:webblen/models/community.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/widgets_community/community_row.dart';

class CommunitiesInAreaPage extends StatefulWidget {
  final WebblenUser currentUser;
  final List<Community> communities;
  final String action;
  final String areaName;

  CommunitiesInAreaPage({
    this.currentUser,
    this.communities,
    this.action,
    this.areaName,
  });

  @override
  _CommunitiesInAreaPageState createState() => _CommunitiesInAreaPageState();
}

class _CommunitiesInAreaPageState extends State<CommunitiesInAreaPage> {
  bool isLoading = true;
  List<Community> activeUserComs = [];
  List<Community> pendingUserComs = [];
  List<String> areaNames = [];

  initialize() async {
    activeUserComs = widget.communities;
    setState(() {});
  }

  Future<void> getUserCommunities() async {
    activeUserComs = [];
    await CommunityDataService().getUserCommunities(widget.currentUser.uid).then((result) {
      activeUserComs = result.where((com) => com.status == 'active' && com.areaName == widget.areaName).toList();
      isLoading = false;
      setState(() {});
    });
  }

  int getNumberOfCommunitiesInArea(String areaName) {
    return activeUserComs.where((com) => com.areaName == areaName).length;
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
        data: MediaQuery.of(context).copyWith(
          textScaleFactor: 1.0,
        ),
        child: Fonts().textW700(
          widget.action == 'newEvent' ? 'New Event' : widget.action == 'newPost' ? 'New Post' : 'My Communities in ${widget.areaName}',
          20.0,
          Colors.black,
          TextAlign.center,
        ),
      ),
      leading: BackButton(
        color: Colors.black,
      ),
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: appBar,
        body: Container(
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
                      SizedBox(
                        height: 8.0,
                      ),
                    ],
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.only(
                      bottom: 8.0,
                    ),
                    itemCount: activeUserComs.length,
                    itemBuilder: (context, index) {
                      return CommunityRow(
                        showAreaName: true,
                        community: activeUserComs[index],
                        onClickAction: widget.action == 'newPost'
                            ? () => PageTransitionService(
                                  context: context,
                                  currentUser: widget.currentUser,
                                  community: activeUserComs[index],
                                ).transitionToCommunityCreatePostPage()
                            : () => PageTransitionService(
                                  context: context,
                                  currentUser: widget.currentUser,
                                  community: activeUserComs[index],
                                ).transitionToCommunityProfilePage(),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
