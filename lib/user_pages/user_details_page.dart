import 'package:flutter/material.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/widgets_user/user_details_header.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/widgets_common/common_alert.dart';
import 'package:webblen/firebase_data/chat_data.dart';
import 'chat_page.dart';
import 'package:webblen/firebase_data/community_data.dart';
import 'package:webblen/models/community.dart';
import 'package:flutter/services.dart';
import 'package:webblen/models/event.dart';
import 'package:webblen/widgets_event/event_list.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:webblen/widgets_community/community_row.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/widgets_event/event_row.dart';
import 'package:webblen/widgets_common/common_progress.dart';
import 'package:webblen/firebase_data/event_data.dart';
import 'package:webblen/firebase_data/webblen_notification_data.dart';

class UserDetailsPage extends StatefulWidget {

  final WebblenUser currentUser;
  final WebblenUser webblenUser;
  UserDetailsPage({this.currentUser, this.webblenUser});

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> with SingleTickerProviderStateMixin{

  ScrollController _scrollController;
  bool isFriendsWithUser = false;
  bool isLoading = true;
  String friendRequestStatus = "";
  List<Community> communities = [];
  List<Event> events = [];

  Future<void> loadEventHistory() async {
    events = [];
    EventDataService().getUserEventHistory(widget.webblenUser.uid).then((res){
      events = res;
      events.sort((e1, e2) => e2.startDateInMilliseconds.compareTo(e1.startDateInMilliseconds));
      setState(() {});
    });
  }

  Future<void> getUserCommunities() async {
    communities = [];
    await CommunityDataService().getUserCommunities(widget.webblenUser.uid).then((result){
      communities = result.where((com) => com.status == 'active').toList();
      communities.sort((comA, comB) => comA.name[1].compareTo(comB.name[1]));
      isLoading = false;
      setState(() {});
    });
  }


  void transitionToMessenger(String chatDocKey, String currentProfileUrl, String currentUsername){
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => Chat(
              currentUser: widget.currentUser,
              chatDocKey: chatDocKey,
              peerProfilePic: widget.webblenUser.profile_pic,
              peerUsername: widget.webblenUser.username,
              peerUID: widget.webblenUser.uid,
            ),
        )
    );
  }

  Future<Null> deleteFriendConfirmation() async {
    Navigator.of(context).pop();
    ShowAlertDialogService().showConfirmationDialog(
        context,
        "Are You Sure You Want to no longer be friends with @${widget.webblenUser.username}?",
        "Remove Friend",
            () => removeFriend(),
            () => Navigator.of(context).pop()
    );
  }

  Future<Null> sendFriendRequest() async {
    Navigator.of(context).pop();
    ShowAlertDialogService().showLoadingDialog(context);
    WebblenNotificationDataService().sendFriendRequest(widget.currentUser.uid,  widget.webblenUser.uid, widget.currentUser.username,).then((error){
      Navigator.of(context).pop();
      if (error.isEmpty){
        ShowAlertDialogService().showSuccessDialog(context, "Friend Request Sent!",  "@" + widget.webblenUser.username + " Will Need to Confirm Your Request");
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
    UserDataService().removeFriend(widget.currentUser.uid, widget.webblenUser.uid).then((requestStatus){
      Navigator.of(context).pop();
      if (requestStatus == null){
        ShowAlertDialogService().showSuccessDialog(context, "Friend Deleted",  "You and @" + widget.webblenUser.username + " are no longer friends");
        friendRequestStatus = "not friends";
        setState(() {});
      } else {
        ShowAlertDialogService().showFailureDialog(context, "Request Failed", requestStatus);
      }
    });
  }

  confirmFriendRequest() async {
    Navigator.of(context).pop();
    ShowAlertDialogService().showLoadingDialog(context);
    WebblenNotificationDataService().acceptFriendRequest(widget.currentUser.uid, widget.webblenUser.uid, null).then((success){
      if (success){
        friendRequestStatus = "friends";
        setState(() {});
        Navigator.of(context).pop();
        ShowAlertDialogService().showSuccessDialog(context, "Friend Added!", "You and @" + widget.webblenUser.username + " are now friends");
      } else {
        Navigator.of(context).pop();
        ShowAlertDialogService().showFailureDialog(context, "There was an Issue!", "Please Try Again Later");
      }
    });
  }

  denyFriendRequest() async {
    Navigator.of(context).pop();
    ShowAlertDialogService().showLoadingDialog(context);
    WebblenNotificationDataService().denyFriendRequest(widget.currentUser.uid, widget.webblenUser.uid, null).then((success){
      if (success){
        friendRequestStatus = "not friends";
        setState(() {});
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pop();
        ShowAlertDialogService().showFailureDialog(context, "There was an Issue!", "Please Try Again Later");
      }
    });
  }

  void messageUser() {
    ShowAlertDialogService().showLoadingDialog(context);
    ChatDataService().checkIfChatExists(widget.currentUser.uid, widget.webblenUser.uid).then((exists){
      if (exists){
        String currentUsername;
        String currentProfileUrl;
        UserDataService().getUserByID(widget.currentUser.uid).then((user){
          currentUsername = user.username;
          currentProfileUrl = user.profile_pic;
          ChatDataService().chatWithUser(widget.currentUser.uid, widget.webblenUser.uid).then((chatDocKey){
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            transitionToMessenger(chatDocKey, currentProfileUrl, currentUsername);
          });
        });
      } else {
        String currentUsername;
        String currentProfileUrl;
        UserDataService().getUserByID(widget.currentUser.uid).then((user){
          currentUsername = user.username;
          currentProfileUrl = user.profile_pic;
          ChatDataService().createChat(widget.currentUser.uid, widget.webblenUser.uid, currentUsername, widget.webblenUser.username, currentProfileUrl, widget.webblenUser.profile_pic).then((chatDocKey){
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            transitionToMessenger(chatDocKey, currentProfileUrl, currentUsername);
          });
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    loadEventHistory();
    UserDataService().checkFriendStatus(widget.currentUser.uid, widget.webblenUser.uid).then((friendStatus){
      friendRequestStatus = friendStatus;
      if (friendStatus == "friends"){
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool boxIsScrolled){
            return <Widget>[
              SliverAppBar(
                brightness: Brightness.light,
                backgroundColor: Colors.white,
                title: Fonts().textW700("@" + widget.webblenUser.username, 24.0, Colors.black, TextAlign.center),
                pinned: true,
                floating: true,
                snap: false,
                leading: BackButton(color: FlatColors.darkGray),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(FontAwesomeIcons.ellipsisH, size: 24.0, color: FlatColors.darkGray),
                    onPressed: () => ShowAlertDialogService()
                        .showAlert(
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
                expandedHeight: 270.0,
                flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      margin: EdgeInsets.only(top: 80.0),
                      child: UserDetailsHeader(
                        username: widget.webblenUser.username,
                        userPicUrl: widget.webblenUser.profile_pic,
                        ap: widget.webblenUser.ap,
                        apLvl: widget.webblenUser.apLvl,
                        eventHistoryCount: widget.webblenUser.eventHistory.length.toString(),
                        viewFriendsAction: null,
                        addFriendAction: null,
                      ),
                    )
                ),
                bottom: TabBar(
                  indicatorColor: FlatColors.webblenRed,
                  labelColor: FlatColors.darkGray,
                  isScrollable: true,
                  labelStyle: TextStyle(fontFamily: 'Barlow', fontWeight: FontWeight.w500),
                  tabs: [
                    Tab(text: 'Communities'),
                    Tab(text: 'Past Events'),
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
                  child: communities.isEmpty
                      ? ListView(
                        children: <Widget>[
                          SizedBox(height: 64.0),
                          Fonts().textW500('No Communities Found', 14.0, Colors.black45, TextAlign.center),
                          SizedBox(height: 8.0),
                          Fonts().textW300('Pull Down To Refresh', 14.0, Colors.black26, TextAlign.center),
                        ],
                      )
                    : ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.only(bottom: 8.0),
                          itemCount: communities.length,
                          itemBuilder: (context, index){
                            return CommunityRow(
                              showAreaName: true,
                              community: communities[index],
                              onClickAction: () => PageTransitionService(context: context, currentUser: widget.currentUser, community: communities[index]).transitionToCommunityProfilePage(),
                            );
                          },
                        ),
                      ),
              ),
              EventList(events: events, currentUser: widget.currentUser, refreshData: loadEventHistory)
            ],
          ),
        ),
      ),
    );
  }
}

class CurrentUserDetailsPage extends StatefulWidget {

  final WebblenUser currentUser;
  CurrentUserDetailsPage({this.currentUser});

  @override
  _CurrentUserDetailsPageState createState() => _CurrentUserDetailsPageState();
}

class _CurrentUserDetailsPageState extends State<CurrentUserDetailsPage> {

  ScrollController _scrollController;
  List<Community> communities = [];
  List<Event> events = [];
  bool isLoading = true;


  Future<void> getEventHistory() async {
    events = [];
    EventDataService().getUserEventHistory(widget.currentUser.uid).then((res){
      events = res;
      events.sort((e1, e2) => e2.startDateInMilliseconds.compareTo(e1.startDateInMilliseconds));
      if (this.mounted){
        setState(() {});
      }
    });
  }

  Future<void> getUserCommunities() async {
    communities = [];
    await CommunityDataService().getUserCommunities(widget.currentUser.uid).then((result){
      communities = result.where((com) => com.status == 'active').toList();
      communities.sort((comA, comB) => comA.name[1].compareTo(comB.name[1]));
      if (this.mounted){
        setState(() {});
      }
    });
  }

  initialize() async {
    _scrollController = ScrollController();
    await getEventHistory();
    await getUserCommunities();
    isLoading = false;
    setState(() {});
  }
  @override
  void initState() {
    super.initState();
    print(widget.currentUser.ap);
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool boxIsScrolled){
            return <Widget>[
              SliverAppBar(
                brightness: Brightness.light,
                backgroundColor: Colors.white,
                title: Fonts().textW700("@" + widget.currentUser.username, 24.0, FlatColors.darkGray, TextAlign.center),
                pinned: true,
                floating: true,
                snap: true,
                leading: BackButton(color: FlatColors.darkGray),
                expandedHeight: 270.0,
                flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      margin: EdgeInsets.only(top: 80.0),
                      child: UserDetailsHeader(
                        username: widget.currentUser.username,
                        userPicUrl: widget.currentUser.profile_pic,
                        ap: widget.currentUser.ap,
                        apLvl: widget.currentUser.apLvl,
                        eventHistoryCount: widget.currentUser.eventHistory.length.toString(),
                        viewFriendsAction: null,
                        addFriendAction: null,
                      ),
                    )
                ),
                bottom: TabBar(
                  indicatorColor: FlatColors.webblenRed,
                  labelColor: FlatColors.darkGray,
                  isScrollable: true,
                  labelStyle: TextStyle(fontFamily: 'Barlow', fontWeight: FontWeight.w500),
                  tabs: [
                    Tab(text: 'Communities'),
                    Tab(text: 'Past Events (${widget.currentUser.eventHistory.length})'),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            children: <Widget>[
              Container(
                color: Colors.white,
                child: isLoading
                    ? LoadingScreen(context: context, loadingDescription: 'Loading Communities...')
                    : LiquidPullToRefresh(
                      color: FlatColors.webblenRed,
                      onRefresh: getUserCommunities,
                      child: communities.isEmpty
                        ? ListView(
                            children: <Widget>[
                              SizedBox(height: 64.0),
                              Fonts().textW500('No Communities Found', 14.0, Colors.black45, TextAlign.center),
                              SizedBox(height: 8.0),
                              Fonts().textW300('Pull Down To Refresh', 14.0, Colors.black26, TextAlign.center),
                            ],
                          )
                        : ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.only(bottom: 8.0),
                        itemCount: communities.length,
                        itemBuilder: (context, index){
                          return CommunityRow(
                            showAreaName: true,
                            community: communities[index],
                            onClickAction: () => PageTransitionService(context: context, currentUser: widget.currentUser, community: communities[index]).transitionToCommunityProfilePage(),
                          );
                        },
                      ),
                    ),
              ),
              Container(
                color: Colors.white,
                child: isLoading
                    ? LoadingScreen(context: context, loadingDescription: 'Loading Events...')
                    : LiquidPullToRefresh(
                        color: FlatColors.webblenRed,
                        onRefresh: getEventHistory,
                        child: events.isEmpty
                          ? ListView(
                              children: <Widget>[
                                SizedBox(height: 64.0),
                                Fonts().textW500('No Events Found', 14.0, Colors.black45, TextAlign.center),
                                SizedBox(height: 8.0),
                                Fonts().textW300('Pull Down To Refresh', 14.0, Colors.black26, TextAlign.center),
                              ],
                            )
                          : ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.only(bottom: 8.0),
                          itemCount: events.length,
                          itemBuilder: (context, index){
                            return ComEventRow(
                                event: events[index],
                                showCommunity: true,
                                currentUser: widget.currentUser,
                                eventPostAction: () => PageTransitionService(context: context, currentUser: widget.currentUser, event: events[index], eventIsLive: false).transitionToEventPage()
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );

  }
}