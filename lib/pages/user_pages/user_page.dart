import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:webblen/firebase/data/event_data.dart';
import 'package:webblen/firebase_data/chat_data.dart';
import 'package:webblen/firebase_data/community_data.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:webblen/firebase_data/webblen_notification_data.dart';
import 'package:webblen/models/community.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/widgets_common/common_alert.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';
import 'package:webblen/widgets/widgets_community/community_row.dart';
import 'package:webblen/widgets/widgets_event/event_list.dart';
import 'package:webblen/widgets/widgets_event/event_row.dart';
import 'package:webblen/widgets/widgets_user/user_details_header.dart';

class UserPage extends StatefulWidget {
  final WebblenUser currentUser;
  final WebblenUser webblenUser;

  UserPage({
    this.currentUser,
    this.webblenUser,
  });

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> with SingleTickerProviderStateMixin {
  ScrollController _scrollController;
  bool isFriendsWithUser = false;
  bool isLoading = true;
  String friendRequestStatus = "";
  List<Community> communities = [];
  List<WebblenEvent> events = [];

  Future<void> loadUserData() async {
    events = await EventDataService().getUserEventHistory(widget.webblenUser.uid);
    events.sort((e1, e2) => e2.startDateTimeInMilliseconds.compareTo(e1.startDateTimeInMilliseconds));
    communities = await CommunityDataService().getUserCommunities(widget.webblenUser.uid);
    communities = communities.where((com) => com.status == 'active').toList();
    communities.sort((comA, comB) => comA.name[1].compareTo(comB.name[1]));
    isLoading = false;
    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> loadEventHistory() async {
    events = await EventDataService().getUserEventHistory(widget.webblenUser.uid);
    events.sort((e1, e2) => e2.startDateTimeInMilliseconds.compareTo(e1.startDateTimeInMilliseconds));
    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> getUserCommunities() async {
    communities = [];
    await CommunityDataService().getUserCommunities(widget.webblenUser.uid).then((result) {
      communities = result.where((com) => com.status == 'active').toList();
      communities.sort((comA, comB) => comA.name[1].compareTo(comB.name[1]));
      isLoading = false;
      if (this.mounted) {
        setState(() {});
      }
    });
  }

  void transitionToMessenger(String chatDocKey) {
    ChatDataService().updateSeenMessage(chatDocKey, widget.currentUser.uid);
    PageTransitionService(
      context: context,
      currentUser: widget.currentUser,
      chatKey: chatDocKey,
    ).transitionToChatPage();
  }

  Future<Null> deleteFriendConfirmation() async {
    Navigator.of(context).pop();
    ShowAlertDialogService().showConfirmationDialog(
      context,
      "Are You Sure You Want to no longer be friends with @${widget.webblenUser.username}?",
      "Remove Friend",
      () => removeFriend(),
      () => Navigator.of(context).pop(),
    );
  }

  Future<Null> sendFriendRequest() async {
    Navigator.of(context).pop();
    ShowAlertDialogService().showLoadingDialog(context);
    WebblenNotificationDataService()
        .sendFriendRequest(
      widget.currentUser.uid,
      widget.webblenUser.uid,
      widget.currentUser.username,
    )
        .then((error) {
      Navigator.of(context).pop();
      if (error.isEmpty) {
        ShowAlertDialogService().showSuccessDialog(
          context,
          "Friend Request Sent!",
          "@" + widget.webblenUser.username + " Will Need to Confirm Your Request",
        );
        friendRequestStatus = "pending";
        setState(() {});
      } else {
        ShowAlertDialogService().showFailureDialog(context, "Request Failed", error);
      }
    });
  }

  Future<Null> removeFriend() async {
    Navigator.of(context).pop();
    ShowAlertDialogService().showLoadingDialog(context);
    UserDataService()
        .removeFriend(
      widget.currentUser.uid,
      widget.webblenUser.uid,
    )
        .then((requestStatus) {
      Navigator.of(context).pop();
      if (requestStatus == null) {
        ShowAlertDialogService().showSuccessDialog(
          context,
          "Friend Deleted",
          "You and @" + widget.webblenUser.username + " are no longer friends",
        );
        friendRequestStatus = "not friends";
        setState(() {});
      } else {
        ShowAlertDialogService().showFailureDialog(
          context,
          "Request Failed",
          requestStatus,
        );
      }
    });
  }

  confirmFriendRequest() async {
    Navigator.of(context).pop();
    ShowAlertDialogService().showLoadingDialog(context);
    WebblenNotificationDataService()
        .acceptFriendRequest(
      widget.currentUser.uid,
      widget.webblenUser.uid,
      null,
    )
        .then((success) {
      if (success) {
        friendRequestStatus = "friends";
        setState(() {});
        Navigator.of(context).pop();
        ShowAlertDialogService().showSuccessDialog(
          context,
          "Friend Added!",
          "You and @" + widget.webblenUser.username + " are now friends",
        );
      } else {
        Navigator.of(context).pop();
        ShowAlertDialogService().showFailureDialog(
          context,
          "There was an Issue!",
          "Please Try Again Later",
        );
      }
    });
  }

  denyFriendRequest() async {
    Navigator.of(context).pop();
    ShowAlertDialogService().showLoadingDialog(context);
    WebblenNotificationDataService()
        .denyFriendRequest(
      widget.currentUser.uid,
      widget.webblenUser.uid,
      null,
    )
        .then((success) {
      if (success) {
        friendRequestStatus = "not friends";
        setState(() {});
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pop();
        ShowAlertDialogService().showFailureDialog(
          context,
          "There was an Issue!",
          "Please Try Again Later",
        );
      }
    });
  }

  void messageUser() {
    ShowAlertDialogService().showLoadingDialog(context);
    ChatDataService().checkIfChatExists([
      widget.currentUser.uid,
      widget.webblenUser.uid,
    ]).then((chatKey) {
      if (chatKey != null && chatKey.isNotEmpty) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        transitionToMessenger(chatKey);
      } else {
        ChatDataService().createChat(widget.currentUser.uid, [
          widget.currentUser.uid,
          widget.webblenUser.uid,
        ]).then((chatKey) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          transitionToMessenger(chatKey);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    loadUserData();
    UserDataService()
        .checkFriendStatus(
      widget.currentUser.uid,
      widget.webblenUser.uid,
    )
        .then((friendStatus) {
      friendRequestStatus = friendStatus;
      if (friendStatus == "friends") {
        isFriendsWithUser = true;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark,
    );
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: 1.0,
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          body: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (
              context,
              boxIsScrolled,
            ) {
              return <Widget>[
                SliverAppBar(
                  brightness: Brightness.light,
                  backgroundColor: Colors.white,
                  title: Fonts().textW700(
                    "People",
                    24.0,
                    Colors.black,
                    TextAlign.center,
                  ),
                  pinned: true,
                  floating: true,
                  snap: false,
                  leading: BackButton(
                    color: Colors.black,
                  ),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(
                        FontAwesomeIcons.ellipsisH,
                        size: 24.0,
                        color: Colors.black,
                      ),
                      onPressed: () => ShowAlertDialogService().showAlert(
                        context,
                        UserDetailsOptionsDialog(
                          addFriendAction: () => sendFriendRequest(),
                          friendRequestStatus: friendRequestStatus,
                          confirmRequestAction: () => confirmFriendRequest(),
                          denyRequestAction: () => denyFriendRequest(),
                          blockUserAction: null,
                          hideFromUserAction: null,
                          removeFriendAction: () => deleteFriendConfirmation(),
                          messageUserAction: messageUser,
                        ),
                        true,
                      ),
                    ),
                  ],
                  expandedHeight: 185.0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      margin: EdgeInsets.only(
                        top: 32.0,
                      ),
                      child: UserDetailsHeader(
                        username: widget.webblenUser.username,
                        userPicUrl: widget.webblenUser.profile_pic,
                        ap: widget.webblenUser.ap,
                        apLvl: widget.webblenUser.apLvl,
                        eventHistoryCount: widget.webblenUser.eventHistory.length.toString(),
                        communityCount: communities.length.toString(),
                        viewFriendsAction: null,
                        addFriendAction: null,
                        isLoading: isLoading,
                      ),
                    ),
                  ),
                  bottom: TabBar(
                    indicatorColor: FlatColors.webblenRed,
                    labelColor: FlatColors.darkGray,
                    isScrollable: true,
                    labelStyle: TextStyle(
                      fontFamily: 'Helvetica Neue',
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: [
                      Tab(
                        text: 'Communities',
                      ),
                      Tab(
                        text: 'Past Events',
                      ),
                    ],
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: <Widget>[
                Container(
                  color: Colors.white,
                  child: LiquidPullToRefresh(
                    color: FlatColors.webblenRed,
                    onRefresh: getUserCommunities,
                    child: isLoading
                        ? ListView(
                            children: <Widget>[
                              SizedBox(
                                height: 64.0,
                              ),
                              Fonts().textW500(
                                'Loading Communities...',
                                14.0,
                                Colors.black45,
                                TextAlign.center,
                              ),
                            ],
                          )
                        : communities.isEmpty
                            ? ListView(
                                children: <Widget>[
                                  SizedBox(
                                    height: 64.0,
                                  ),
                                  Fonts().textW500(
                                    'No Communities Found',
                                    14.0,
                                    Colors.black45,
                                    TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: 8.0,
                                  ),
                                  Fonts().textW300(
                                    'Pull Down To Refresh',
                                    14.0,
                                    Colors.black26,
                                    TextAlign.center,
                                  ),
                                ],
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.only(
                                  bottom: 8.0,
                                ),
                                itemCount: communities.length,
                                itemBuilder: (context, index) {
                                  return CommunityRow(
                                    showAreaName: true,
                                    community: communities[index],
                                    onClickAction: () => PageTransitionService(
                                      context: context,
                                      currentUser: widget.currentUser,
                                      community: communities[index],
                                    ).transitionToCommunityProfilePage(),
                                  );
                                },
                              ),
                  ),
                ),
                isLoading
                    ? ListView(
                        children: <Widget>[
                          SizedBox(
                            height: 64.0,
                          ),
                          Fonts().textW500(
                            'Loading Events...',
                            14.0,
                            Colors.black45,
                            TextAlign.center,
                          ),
                        ],
                      )
                    : EventList(
                        events: events,
                        currentUser: widget.currentUser,
                        refreshData: loadEventHistory,
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CurrentUserPage extends StatefulWidget {
  final WebblenUser currentUser;
  final Key key;

  CurrentUserPage({
    this.currentUser,
    this.key,
  });

  @override
  _CurrentUserPageState createState() => _CurrentUserPageState();
}

class _CurrentUserPageState extends State<CurrentUserPage> {
  ScrollController _scrollController;
  List<Community> communities = [];
  List<WebblenEvent> events = [];
  bool isLoadingEvents = true;
  bool isLoadingComs = true;

  Future<void> getEventHistory() async {
    events = [];
    EventDataService().getUserEventHistory(widget.currentUser.uid).then((res) {
      events = res;
      events.sort((e1, e2) => e2.startDateTimeInMilliseconds.compareTo(e1.startDateTimeInMilliseconds));
      if (this.mounted) {
        isLoadingEvents = false;
        setState(() {});
      }
    });
  }

  Future<void> getUserCommunities() async {
    communities = [];
    await CommunityDataService().getUserCommunities(widget.currentUser.uid).then((result) {
      communities = result.where((com) => com.status == 'active').toList();
      communities.sort((comA, comB) => comA.name[1].compareTo(comB.name[1]));
      if (this.mounted) {
        isLoadingComs = false;
        setState(() {});
      }
    });
  }

  initialize() async {
    _scrollController = ScrollController();
    await getEventHistory();
    await getUserCommunities();
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
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: 1.0,
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          body: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, boxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  brightness: Brightness.light,
                  backgroundColor: Colors.white,
                  title: Fonts().textW700(
                    "My Account",
                    24.0,
                    Colors.black,
                    TextAlign.center,
                  ),
                  pinned: true,
                  floating: true,
                  snap: true,
                  actions: [
                    IconButton(
                      onPressed: () => PageTransitionService(context: context, currentUser: widget.currentUser).transitionToSettingsPage(),
                      icon: Icon(FontAwesomeIcons.cog, color: Colors.black, size: 20.0),
                    ),
                  ],
                  expandedHeight: 185.0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      margin: EdgeInsets.only(
                        top: 32.0,
                      ),
                      child: UserDetailsHeader(
                        username: widget.currentUser.username,
                        userPicUrl: widget.currentUser.profile_pic,
                        ap: widget.currentUser.ap,
                        apLvl: widget.currentUser.apLvl,
                        eventHistoryCount: widget.currentUser.eventHistory.length.toString(),
                        communityCount: communities.length.toString(),
                        viewFriendsAction: null,
                        addFriendAction: null,
                        isLoading: isLoadingComs,
                      ),
                    ),
                  ),
                  bottom: TabBar(
                    indicatorColor: FlatColors.webblenRed,
                    labelColor: FlatColors.darkGray,
                    isScrollable: true,
                    labelStyle: TextStyle(
                      fontFamily: 'Helvetica Neue',
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: [
                      Tab(
                        text: 'Communities',
                      ),
                      Tab(
                        text: 'Past Events',
                      ),
                    ],
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: <Widget>[
                Container(
                  color: Colors.white,
                  child: isLoadingComs
                      ? LoadingScreen(
                          context: context,
                          loadingDescription: 'Loading Communities...',
                        )
                      : LiquidPullToRefresh(
                          color: FlatColors.webblenRed,
                          onRefresh: getUserCommunities,
                          child: communities.isEmpty
                              ? ListView(
                                  children: <Widget>[
                                    SizedBox(height: 64.0),
                                    Fonts().textW500(
                                      'No Communities Found',
                                      14.0,
                                      Colors.black45,
                                      TextAlign.center,
                                    ),
                                    SizedBox(
                                      height: 8.0,
                                    ),
                                    Fonts().textW300(
                                      'Pull Down To Refresh',
                                      14.0,
                                      Colors.black26,
                                      TextAlign.center,
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.only(
                                    bottom: 8.0,
                                  ),
                                  itemCount: communities.length,
                                  itemBuilder: (context, index) {
                                    return CommunityRow(
                                      showAreaName: true,
                                      community: communities[index],
                                      onClickAction: () => PageTransitionService(
                                        context: context,
                                        currentUser: widget.currentUser,
                                        community: communities[index],
                                      ).transitionToCommunityProfilePage(),
                                    );
                                  },
                                ),
                        ),
                ),
                Container(
                  color: Colors.white,
                  child: isLoadingEvents
                      ? LoadingScreen(
                          context: context,
                          loadingDescription: 'Loading Events...',
                        )
                      : LiquidPullToRefresh(
                          color: FlatColors.webblenRed,
                          onRefresh: getEventHistory,
                          child: events.isEmpty
                              ? ListView(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 64.0,
                                    ),
                                    Fonts().textW500(
                                      'No Events Found',
                                      14.0,
                                      Colors.black45,
                                      TextAlign.center,
                                    ),
                                    SizedBox(
                                      height: 8.0,
                                    ),
                                    Fonts().textW300(
                                      'Pull Down To Refresh',
                                      14.0,
                                      Colors.black26,
                                      TextAlign.center,
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.only(
                                    bottom: 8.0,
                                  ),
                                  itemCount: events.length,
                                  itemBuilder: (context, index) {
                                    return ComEventRow(
                                      event: events[index],
                                      showCommunity: true,
                                      currentUser: widget.currentUser,
                                      eventPostAction: () => PageTransitionService(
                                        context: context,
                                        currentUser: widget.currentUser,
                                        event: events[index],
                                        eventIsLive: false,
                                      ).transitionToEventPage(),
                                    );
                                  },
                                ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
