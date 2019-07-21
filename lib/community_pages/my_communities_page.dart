import 'package:flutter/material.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:flutter/services.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/models/community.dart';
import 'package:webblen/widgets_data_streams/stream_community_data.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/widgets_data_streams/stream_user_data.dart';
import 'package:webblen/firebase_data/community_data.dart';
import 'package:webblen/widgets_common/common_progress.dart';
import 'package:webblen/widgets_community/community_row.dart';
import 'package:webblen/models/event.dart';
import 'package:webblen/models/community_news.dart';


class MyCommunitiesPage extends StatefulWidget {

  final String uid;
  final String areaName;
  MyCommunitiesPage({this.uid, this.areaName});

  @override
  _MyCommunitiesPageState createState() => _MyCommunitiesPageState();
}

class _MyCommunitiesPageState extends State<MyCommunitiesPage> {

  StreamSubscription userStream;
  WebblenUser currentUser;
  bool isLoadingMemberData = true;
  bool isLoadingEvents = true;
  bool isLoadingPosts = true;
  List<Community> userComs = [];
  List<Event> events = [];
  List<CommunityNewsPost> newsPosts = [];


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

  getUser(WebblenUser user) async {
    currentUser = user;
    if (currentUser != null){
      getUserCommunities();
    }
  }

  Future<Null> getUserCommunities() async {
    if (currentUser.communities != null && currentUser.communities.isNotEmpty){
      currentUser.communities.forEach((key, val) async {
        String areaName = key;
        List communities = val;
        communities.forEach((com) async {
          await CommunityDataService().searchForCommunityByName(com, areaName).then((result){
            if (!userComs.contains(result)){
              userComs.addAll(result);
            }
            if (currentUser.communities.keys.last == key && communities.last == com && isLoadingMemberData){
              setState(() {
                userComs.toSet().toList();
                userComs.sort((comA, comB) => comA.name[1].compareTo(comB.name[1]));
                isLoadingMemberData = false;
              });
            }
          });
        });
      });
    } else {
      setState(() {
        isLoadingMemberData = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    final appBar = AppBar (
      elevation: 0.0,
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title: Fonts().textW700('My Communities', 20.0, Colors.black, TextAlign.center),
      leading: BackButton(color: FlatColors.darkGray),
      bottom: TabBar(
        indicatorColor: FlatColors.webblenRed,
        labelColor: FlatColors.londonSquare,
        isScrollable: true,
        labelStyle: TextStyle(fontFamily: 'Barlow', fontWeight: FontWeight.w500),
        tabs: <Widget>[
          new Tab(text: "Communities"),
          new Tab(text: "Pending")
        ],
      ),
      actions: <Widget>[
        IconButton(
            icon: Icon(FontAwesomeIcons.plusSquare, color: FlatColors.darkGray, size: 24.0),
            onPressed: () => PageTransitionService(context: context, currentUser: currentUser, areaName: widget.areaName).transitionToNewCommunityPage()
        )
      ],
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: appBar,
        body: TabBarView(
          children: <Widget>[
            isLoadingMemberData
                ? LoadingScreen(context: context, loadingDescription: 'Loading Your Communities...')
                : userComs.isEmpty
                  ? Container(
                      color: FlatColors.clouds,
                      padding: EdgeInsets.only(top: 64.0, left: 8.0, right: 8.0),
                      child: Fonts().textW300('You are not a member of any communities', 18.0, FlatColors.lightAmericanGray, TextAlign.center),

                    )
                  : Container(
                      color: FlatColors.clouds,
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                        itemCount: userComs.length,
                        itemBuilder: (context, index){
                          return CommunityRow(
                            showAreaName: true,
                            community: userComs[index],
                            onClickAction: () => PageTransitionService(context: context, currentUser: currentUser, community: userComs[index]).transitionToCommunityProfilePage(),
                          );
                        },
                      ),
                    ),
            //StreamFollowedCommunities(currentUser: currentUser, locRefID: widget.areaName),
            isLoadingMemberData
                ? LoadingScreen(context: context, loadingDescription: 'Loading Your Communities...')
                : StreamPendingCommunities(currentUser: currentUser, locRefID: widget.areaName)
          ],
        ),
      ),
    );
  }
}

