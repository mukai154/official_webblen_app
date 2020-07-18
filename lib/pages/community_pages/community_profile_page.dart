import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:webblen/firebase_data/community_data.dart';
import 'package:webblen/firebase_data/news_post_data.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:webblen/models/community.dart';
import 'package:webblen/models/community_news.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';
import 'package:webblen/widgets/widgets_community/community_post_row.dart';

class CommunityProfilePage extends StatefulWidget {
  final WebblenUser currentUser;
  final Community community;

  CommunityProfilePage({
    this.community,
    this.currentUser,
  });

  @override
  _CommunityProfilePageState createState() => _CommunityProfilePageState();
}

class _CommunityProfilePageState extends State<CommunityProfilePage> with SingleTickerProviderStateMixin {
  //() => PageTransitionService(context: context, currentUser: widget.currentUser, userIDs: memberUIDs, viewingMembersOrAttendees: true).transitionToUserSearchPage(),
  //  () => PageTransitionService(context: context, community: widget.community).transitionToComImagePage(),

  TabController _tabController;
  ScrollController _scrollController;
  List memberUIDs = [];
  List followerUIDs = [];
  List<WebblenEvent> events = [];
  List<CommunityNewsPost> posts = [];
  bool isLoading = true;
  bool isAdmin = false;

  checkAdminStatus() async {
    UserDataService().checkAdminStatus(widget.currentUser.uid).then((res) {
      if (res) {
        isAdmin = res;
        if (this.mounted) {
          setState(() {});
        }
      }
    });
  }

  void followUnfollowAction() async {
    ShowAlertDialogService().showLoadingDialog(context);
    await CommunityDataService()
        .updateCommunityFollowers(
      widget.community.areaName,
      widget.community.name,
      widget.currentUser.uid,
    )
        .then((success) {
      if (success) {
        Navigator.of(context).pop();
        if (followerUIDs.contains(widget.currentUser.uid)) {
          followerUIDs.remove(widget.currentUser.uid);
          setState(() {});
        } else {
          followerUIDs.add(widget.currentUser.uid);
          setState(() {});
        }
      } else {
        Navigator.of(context).pop();
        ShowAlertDialogService().showFailureDialog(
          context,
          'There Was an Issue Following this Community',
          'Please Try Again Later',
        );
      }
    });
  }

  Future<Null> getCommunityNewsPosts(bool reloadingData) async {
    posts = [];
    await NewsPostDataService()
        .getCommunityNewsPosts(
      widget.community.areaName,
      widget.community.name,
    )
        .then((result) {
      posts = result;
      posts.sort((postA, postB) => postB.datePostedInMilliseconds.compareTo(postA.datePostedInMilliseconds));
    });
    if (reloadingData) {
      setState(() {});
    }
  }

  Future<void> reloadPosts() async {
    getCommunityNewsPosts(true);
  }

  addEventAction() {
    Navigator.of(context).pop();
    PageTransitionService(
      context: context,
      currentUser: widget.currentUser,
      community: widget.community,
    ).transitionToCommunityCreatePostPage();
  }

  viewMembersAction() {
    Navigator.of(context).pop();
    PageTransitionService(
      context: context,
      currentUser: widget.currentUser,
      userIDs: memberUIDs,
      viewingMembersOrAttendees: true,
    ).transitionToUserSearchPage();
  }

  inviteMembersAction() {
    Navigator.of(context).pop();
    PageTransitionService(
      context: context,
      currentUser: widget.currentUser,
      community: widget.community,
    ).transitionToCommunityInvitePage();
  }

  joinAction() {
    Navigator.of(context).pop();
    ShowAlertDialogService().showLoadingDialog(context);
    CommunityDataService()
        .joinCommunity(
      widget.community.areaName,
      widget.community.name,
      widget.currentUser.uid,
    )
        .then((success) {
      if (success) {
        Navigator.of(context).pop();
        memberUIDs.add(widget.currentUser.uid);
        ShowAlertDialogService().showSuccessDialog(
          context,
          "You've Joined ${widget.community.areaName}/${widget.community.name}!",
          "You can now post news and events to this community",
        );
        setState(() {});
      } else {
        Navigator.of(context).pop();
        ShowAlertDialogService().showFailureDialog(
          context,
          "Uh Oh!",
          "There was an issue... Please Try Again",
        );
      }
    });
  }

  leaveAction() {
    Navigator.of(context).pop();
    ShowAlertDialogService().showDetailedConfirmationDialog(
      context,
      "Leave ${widget.community.name}?",
      memberUIDs.length <= 3
          ? "WARNING: Community's with less than 3 members are automatically disbanded"
          : "You'll need to attend more of this community's events or be invited to rejoin",
      "Leave",
      () {
        Navigator.of(context).pop();
        ShowAlertDialogService().showLoadingDialog(context);
        CommunityDataService()
            .leaveCommunity(
          widget.community.areaName,
          widget.community.name,
          widget.currentUser.uid,
        )
            .then((success) {
          if (success) {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pop();
            ShowAlertDialogService().showFailureDialog(
              context,
              "Uh Oh!",
              "There was an issue... Please Try Again",
            );
          }
        });
      },
      () => Navigator.of(context).pop(),
    );
  }

  initialize() async {
    _scrollController = ScrollController();
    memberUIDs = widget.community.memberIDs.toList(
      growable: true,
    );
    await getCommunityNewsPosts(false);
    checkAdminStatus();
    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initialize();
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
        headerSliverBuilder: (
          BuildContext context,
          bool boxIsScrolled,
        ) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: Colors.white,
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0,
                    ),
                    child: Fonts().textW700(
                      widget.community.name,
                      24.0,
                      Colors.black,
                      TextAlign.center,
                    ),
                  ),
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0,
                    ),
                    child: Fonts().textW400(
                      '${memberUIDs.length} Members',
                      16.0,
                      FlatColors.darkGray,
                      TextAlign.center,
                    ),
                  ),
                ],
              ),
              pinned: true,
              floating: true,
              snap: true,
              brightness: Brightness.light,
              leading: BackButton(
                color: Colors.black,
              ),
              actions: <Widget>[
                IconButton(
                    icon: Icon(
                      FontAwesomeIcons.ellipsisH,
                      color: Colors.black,
                      size: 24.0,
                    ),
                    onPressed: () {
                      ShowAlertDialogService().showCommunityOptionsDialog(
                          context,
                          memberUIDs.contains(widget.currentUser.uid),
                          widget.community.communityType,
                          () => viewMembersAction(),
                          () => PageTransitionService(
                                context: context,
                                community: widget.community,
                              ).transitionToComImagePage(),
                          () => addEventAction(),
                          () => inviteMembersAction(),
                          () => leaveAction(),
                          () => joinAction());
                    }),
              ],
            ),
          ];
        },
        body: Container(
          color: Colors.white,
          child: isLoading
              ? LoadingScreen(
                  context: context,
                  loadingDescription: 'Loading News...',
                )
              : LiquidPullToRefresh(
                  color: FlatColors.webblenRed,
                  onRefresh: reloadPosts,
                  child: posts.isEmpty
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
                                'No Posts Found',
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
                            top: 8.0,
                            bottom: 8.0,
                          ),
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            return CommunityPostRow(
                              newsPost: posts[index],
                              currentUser: widget.currentUser,
                              transitionToComAction: null,
                              showCommunity: false,
                            );
                          },
                        ),
                ),
        ),
      ),
    );
  }
}
