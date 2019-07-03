import 'package:flutter/material.dart';
import 'package:webblen/models/community.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/firebase_services/community_data.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/widgets_user/user_details_profile_pic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/widgets_common/common_button.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/widgets_data_streams/stream_community_data.dart';
import 'package:webblen/services_general/services_show_alert.dart';

class CommunityProfilePage extends StatefulWidget {

  final WebblenUser currentUser;
  final Community community;

  CommunityProfilePage({this.community, this.currentUser});

  @override
  _CommunityProfilePageState createState() => _CommunityProfilePageState();
}

class _CommunityProfilePageState extends State<CommunityProfilePage> with SingleTickerProviderStateMixin {

  TabController _tabController;
  ScrollController _scrollController;
  List memberUIDs = [];
  List followerUIDs = [];
  
  void followUnfollowAction() async {
    await CommunityDataService().updateFollowers(widget.currentUser.uid, widget.community.areaName, widget.community.name).then((followList){
      followerUIDs = followList;
      setState(() {});
    });

  }

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
    setState(() {
      memberUIDs = widget.community.memberIDs.toList(growable: true)..shuffle();
      followerUIDs = widget.community.followers.toList(growable: true);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool boxIsScrolled){
          return <Widget>[
            SliverAppBar(
              backgroundColor: Colors.white,
              title: Fonts().textW700(widget.community.name, 24.0, Colors.black, TextAlign.center),
              pinned: true,
              floating: true,
              snap: false,
              brightness: Brightness.light,
              leading: BackButton(color: FlatColors.darkGray),
              actions: <Widget>[
                widget.community.memberIDs.contains((widget.currentUser.uid))
                ? IconButton(
                    icon: Icon(FontAwesomeIcons.ellipsisH, color: FlatColors.darkGray, size: 24.0),
                    onPressed: (){
                      ShowAlertDialogService().showCommunityOptionsDialog(
                              context,
                              (){
                                Navigator.of(context).pop();
                                PageTransitionService(context: context, currentUser: widget.currentUser, community: widget.community).transitionToChoosePostTypePage();
                              },
                              (){
                                Navigator.of(context).pop();
                                PageTransitionService(context: context, currentUser: widget.currentUser, community: widget.community).transitionToCommunityInvitePage();
                              },
                              (){
                                Navigator.of(context).pop();
                                ShowAlertDialogService().showDetailedConfirmationDialog(
                                    context,
                                    "Leave ${widget.community.name}?",
                                    memberUIDs.length <= 3
                                        ? "WARNING: Community's with less than 3 members are automatically disbanded"
                                        :"You'll need to attend more of this community's events or be invited to rejoin",
                                    "Leave",
                                    (){
                                      Navigator.of(context).pop();
                                      ShowAlertDialogService().showLoadingDialog(context);
                                      CommunityDataService().updateMembers(widget.currentUser.uid, widget.community.areaName, widget.community.name).then((error){
                                        if (error.isEmpty){
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                        } else {
                                          Navigator.of(context).pop();
                                          ShowAlertDialogService().showFailureDialog(context, "Uh Oh!", "There was an issue... Please Try Again");
                                        }
                                      });
                                    },
                                    () => Navigator.of(context).pop()
                                );
                              }
                      );
                    }
                  )
                : Container(),
              ],
              expandedHeight: 270.0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  margin: EdgeInsets.only(top: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () => PageTransitionService(context: context, currentUser: widget.currentUser, userIDs: memberUIDs, viewingMembersOrAttendees: true).transitionToUserSearchPage(),
                              child: Container(
                                width: 130.0,
                                child: Stack(
                                  children: <Widget>[
                                    memberUIDs[0] != null ? UserProfilePicFromUID(uid: memberUIDs[0], size: 70.0) : Container(),
                                    Positioned(
                                      left: 30.0,
                                      child: memberUIDs.length > 1 ? UserProfilePicFromUID(uid: memberUIDs[1], size: 70.0) : Container(),
                                    ),
                                    Positioned(
                                      left: 60.0,
                                      child: memberUIDs.length > 2 ? UserProfilePicFromUID(uid: memberUIDs[2], size: 70.0) : Container(),
                                    )

                                  ],
                                ),
                              ),
                            )

                          ],
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[

                          GestureDetector(
                            onTap: () => PageTransitionService(context: context, currentUser: widget.currentUser, userIDs: memberUIDs, viewingMembersOrAttendees: true).transitionToUserSearchPage(),
                            child: Fonts().textW500('${memberUIDs.length} Active Members', 16.0, FlatColors.darkGray, TextAlign.center),
                          ),
                          GestureDetector(
                            onTap: () => PageTransitionService(context: context, currentUser: widget.currentUser, userIDs: followerUIDs, viewingMembersOrAttendees: true).transitionToUserSearchPage(),
                            child: Fonts().textW500('${followerUIDs.length} Followers', 16.0, FlatColors.darkGray, TextAlign.center),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          CustomColorButton(
                            text: followerUIDs.contains(widget.currentUser.uid) ? 'Unfollow' : 'Follow',
                            textColor: followerUIDs.contains(widget.currentUser.uid) ? Colors.redAccent : FlatColors.darkGray,
                            backgroundColor: followerUIDs.contains(widget.currentUser.uid) ? Colors.white : Colors.white,
                            onPressed: followUnfollowAction,
                            height: 35.0,
                            width: 150.0,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              bottom: TabBar(
                indicatorColor: FlatColors.webblenRed,
                labelColor: FlatColors.darkGray,
                isScrollable: true,
                labelStyle: TextStyle(fontFamily: 'Barlow', fontWeight: FontWeight.w500),
                tabs: [
                  Tab(text: 'Upcoming Events'),
                  Tab(text: 'Regular Events'),
                  Tab(text: 'Posts/News'),
                ],
                controller: _tabController,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            StreamCommunitySpecialEvents(currentUser: widget.currentUser, community: widget.community),
            Container(
              child: ListView(
                children: <Widget>[
                  StreamCommunityDailyEvents(currentUser: widget.currentUser, community: widget.community),
                  StreamCommunityWeeklyEvents(currentUser: widget.currentUser, community: widget.community),
                  StreamCommunityMonthlyEvents(currentUser: widget.currentUser, community: widget.community)
                ],
              ),
            ),
            StreamCommunityNewsPosts(currentUser: widget.currentUser, community: widget.community),
          ],
        ),
      ),
    );

  }
}
