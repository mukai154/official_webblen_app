import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:share/share.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';
import 'package:webblen/widgets/events/event_block.dart';
import 'package:webblen/widgets/widgets_common/common_alert.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';
import 'package:webblen/widgets/widgets_user/user_details_header.dart';

class CurrentUserPage extends StatefulWidget {
  final WebblenUser currentUser;
  final WebblenUser webblenUser;
  final backButtonIsDisabled;

  CurrentUserPage({
    this.currentUser,
    this.webblenUser,
    this.backButtonIsDisabled,
  });

  @override
  _CurrentUserPageState createState() => _CurrentUserPageState();
}

class _CurrentUserPageState extends State<CurrentUserPage> with SingleTickerProviderStateMixin {
  WebblenUser user;
  bool isOwner = false;
  bool isLoading = true;
  //Scroller & Paging
  final PageStorageBucket bucket = PageStorageBucket();
  TabController _tabController;
  ScrollController _scrollController;
  ScrollController hostedEventsScrollController;
  ScrollController pastEventsScrollController;
  int resultsPerPage = 10;

  //User Relationship
  bool isFriendsWithUser = false;
  String friendRequestStatus = "";

  //Event Results
  CollectionReference eventsRef = Firestore.instance.collection("events");
  List<DocumentSnapshot> hostedEventResults = [];
  List<DocumentSnapshot> pastEventResults = [];
  List followingList = [];
  List userFollowersList = [];
  DocumentSnapshot lastHostedEventDocSnap;
  DocumentSnapshot lastPastEventDocSnap;
  bool loadingAdditionalHostedEvents = false;
  bool moreHostedEventsAvailable = true;
  bool loadingAdditionalPastEvents = false;
  bool morePastEventsAvailable = true;

  //ADMOB
  String adMobUnitID;
  final nativeAdController = NativeAdmobController();

  followUnfollowAction() async {
    if (followingList.contains(user.uid)) {
      followingList.remove(user.uid);
      userFollowersList.remove(widget.currentUser.uid);
    } else {
      followingList.add(user.uid);
      userFollowersList.add(widget.currentUser.uid);
    }
    setState(() {});
    WebblenUserData().updateFollowing(widget.currentUser.uid, user.uid, followingList, userFollowersList);
  }

  getHostedEvents() async {
    Query eventsQuery;
    eventsQuery = eventsRef.where('d.authorID', isEqualTo: user.uid).orderBy('d.startDateTimeInMilliseconds', descending: true).limit(resultsPerPage);
    QuerySnapshot querySnapshot = await eventsQuery.getDocuments().catchError((e) => print(e));
    if (querySnapshot.documents.isNotEmpty) {
      lastHostedEventDocSnap = querySnapshot.documents[querySnapshot.documents.length - 1];
      hostedEventResults = querySnapshot.documents;
    }
    isLoading = false;
    setState(() {});
  }

  getPastEvents() async {
    Query eventsQuery;
    eventsQuery = eventsRef.where('d.attendees', arrayContains: user.uid).orderBy('d.startDateTimeInMilliseconds', descending: true).limit(resultsPerPage);
    QuerySnapshot querySnapshot = await eventsQuery.getDocuments().catchError((e) => print(e));
    if (querySnapshot.documents.isNotEmpty) {
      lastPastEventDocSnap = querySnapshot.documents[querySnapshot.documents.length - 1];
      pastEventResults = querySnapshot.documents;
    }
    //isLoading = false;
    setState(() {});
  }

  getAdditionalHostedEvents() async {
    if (isLoading || !moreHostedEventsAvailable || loadingAdditionalHostedEvents) {
      return;
    }
    loadingAdditionalHostedEvents = true;
    setState(() {});
    Query eventsQuery = eventsRef
        .where("d.authorID", isEqualTo: user.uid)
        .orderBy('d.startDateTimeInMilliseconds', descending: true)
        .startAfterDocument(lastHostedEventDocSnap)
        .limit(resultsPerPage);

    QuerySnapshot querySnapshot = await eventsQuery.getDocuments().catchError((e) => print(e));
    lastHostedEventDocSnap = querySnapshot.documents[querySnapshot.documents.length - 1];
    hostedEventResults.addAll(querySnapshot.documents);
    if (querySnapshot.documents.length == 0) {
      moreHostedEventsAvailable = false;
    }
    loadingAdditionalHostedEvents = false;
    setState(() {});
  }

  getAdditionalPastEvents() async {
    if (isLoading || !morePastEventsAvailable || loadingAdditionalPastEvents) {
      return;
    }
    loadingAdditionalPastEvents = true;
    setState(() {});
    Query eventsQuery = eventsRef
        .where("d.attendees", arrayContains: user.uid)
        .orderBy('d.startDateTimeInMilliseconds', descending: true)
        .startAfterDocument(lastPastEventDocSnap)
        .limit(resultsPerPage);

    QuerySnapshot querySnapshot = await eventsQuery.getDocuments().catchError((e) => print(e));
    lastPastEventDocSnap = querySnapshot.documents[querySnapshot.documents.length - 1];
    pastEventResults.addAll(querySnapshot.documents);
    if (querySnapshot.documents.length == 0) {
      morePastEventsAvailable = false;
    }
    loadingAdditionalPastEvents = false;
    setState(() {});
  }

  Widget listHostedEvents() {
    return LiquidPullToRefresh(
      color: CustomColors.webblenRed,
      onRefresh: refreshData,
      child: ListView.builder(
        controller: hostedEventsScrollController,
        key: UniqueKey(),
        shrinkWrap: true,
        padding: EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
        ),
        itemCount: hostedEventResults.length,
        itemBuilder: (context, index) {
          WebblenEvent event = WebblenEvent.fromMap(Map<String, dynamic>.from(hostedEventResults[index].data['d']));
          double num = index / 15;
          print(num == num.roundToDouble() && num != 0);
          if (num == num.roundToDouble() && num != 0) {
            return Padding(
              padding: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: hostedEventResults.length - 1 == index ? 16.0 : 0),
              child: Container(
                child: Column(
                  children: [
                    Container(
                      height: 70,
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(bottom: 20.0),
                      child: NativeAdmob(
                        // Your ad unit id
                        loading: Container(),
                        adUnitID: 'ca-app-pub-3940256099942544/3986624511',
                        numberAds: 3,
                        controller: nativeAdController,
                        type: NativeAdmobType.banner,
                      ),
                    ),
                    EventBlock(
                      event: event,
                      shareEvent: () => Share.share("https://app.webblen.io/#/event?id=${event.id}"),
                      viewEventDetails: () =>
                          PageTransitionService(context: context, currentUser: widget.currentUser, eventID: event.id).transitionToEventPage(),
                      viewEventTickets: null,
                      numOfTicsForEvent: null,
                      eventImgSize: MediaQuery.of(context).size.width - 16,
                      eventDescHeight: 120.0,
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Padding(
              padding: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: hostedEventResults.length - 1 == index ? 16.0 : 0),
              child: EventBlock(
                event: event,
                shareEvent: () => Share.share("https://app.webblen.io/#/event?id=${event.id}"),
                viewEventDetails: () => PageTransitionService(context: context, currentUser: widget.currentUser, eventID: event.id).transitionToEventPage(),
                viewEventTickets: null,
                numOfTicsForEvent: null,
                eventImgSize: MediaQuery.of(context).size.width - 16,
                eventDescHeight: 120.0,
              ),
            );
          }
        },
      ),
    );
  }

  Widget listPastEvents() {
    return LiquidPullToRefresh(
      color: CustomColors.webblenRed,
      onRefresh: refreshData,
      child: ListView.builder(
        controller: pastEventsScrollController,
        key: UniqueKey(),
        shrinkWrap: true,
        padding: EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
        ),
        itemCount: pastEventResults.length,
        itemBuilder: (context, index) {
          WebblenEvent event = WebblenEvent.fromMap(Map<String, dynamic>.from(pastEventResults[index].data['d']));
          double num = index / 15;
          print(num == num.roundToDouble() && num != 0);
          if (num == num.roundToDouble() && num != 0) {
            return Padding(
              padding: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: pastEventResults.length - 1 == index ? 16.0 : 0),
              child: Container(
                child: Column(
                  children: [
                    Container(
                      height: 70,
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(bottom: 20.0),
                      child: NativeAdmob(
                        // Your ad unit id
                        loading: Container(),
                        adUnitID: 'ca-app-pub-3940256099942544/3986624511',
                        numberAds: 3,
                        controller: nativeAdController,
                        type: NativeAdmobType.banner,
                      ),
                    ),
                    EventBlock(
                      event: event,
                      shareEvent: () => Share.share("https://app.webblen.io/#/event?id=${event.id}"),
                      viewEventDetails: () =>
                          PageTransitionService(context: context, currentUser: widget.currentUser, eventID: event.id).transitionToEventPage(),
                      viewEventTickets: null,
                      numOfTicsForEvent: null,
                      eventImgSize: MediaQuery.of(context).size.width - 16,
                      eventDescHeight: 120.0,
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Padding(
              padding: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: pastEventResults.length - 1 == index ? 16.0 : 0),
              child: EventBlock(
                event: event,
                shareEvent: () => Share.share("https://app.webblen.io/#/event?id=${event.id}"),
                viewEventDetails: () => PageTransitionService(context: context, currentUser: widget.currentUser, eventID: event.id).transitionToEventPage(),
                viewEventTickets: null,
                numOfTicsForEvent: null,
                eventImgSize: MediaQuery.of(context).size.width - 16,
                eventDescHeight: 120.0,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> refreshData() async {
    hostedEventResults = [];
    pastEventResults = [];
    getHostedEvents();
    getPastEvents();
  }

  @override
  void initState() {
    super.initState();
    if (widget.webblenUser == null || widget.webblenUser.uid == widget.currentUser.uid) {
      setState(() {
        isOwner = true;
        user = widget.currentUser;
      });
    } else {
      setState(() {
        user = widget.webblenUser;
      });
    }
    followingList = widget.currentUser.following.toList(growable: true);
    WebblenUserData().getFollowingList(widget.currentUser.uid).then((res) {
      userFollowersList = res;
      setState(() {});
    });
    if (Platform.isIOS) {
      adMobUnitID = 'ca-app-pub-2136415475966451/5262349288';
    } else if (Platform.isAndroid) {
      adMobUnitID = 'ca-app-pub-2136415475966451/5805274760';
    }
    setState(() {});
    _tabController = new TabController(
      length: 2,
      vsync: this,
    );
    _scrollController = ScrollController();
    hostedEventsScrollController = ScrollController();
    pastEventsScrollController = ScrollController();
    hostedEventsScrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * hostedEventsScrollController.position.maxScrollExtent;
      if (hostedEventsScrollController.position.pixels > triggerFetchMoreSize) {
        getAdditionalHostedEvents();
      }
    });
    pastEventsScrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * pastEventsScrollController.position.maxScrollExtent;
      if (pastEventsScrollController.position.pixels > triggerFetchMoreSize) {
        getAdditionalPastEvents();
      }
    });
    getHostedEvents();
    getPastEvents();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    hostedEventsScrollController.dispose();
    pastEventsScrollController.dispose();
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
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              height: 70,
              margin: EdgeInsets.only(
                left: 16,
                top: 30,
                right: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        context: context,
                        text: isOwner ? "My Account" : "People",
                        textColor: Colors.black,
                        textAlign: TextAlign.center,
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ],
                  ),
                  Column(
//                    mainAxisAlignment: MainAxisAlignment.start,
//                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: 24,
                          right: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            isOwner
                                ? GestureDetector(
                                    onTap: () => PageTransitionService(context: context, currentUser: widget.currentUser).transitionToSettingsPage(),
                                    child: Icon(FontAwesomeIcons.cog, color: Colors.black, size: 20.0),
                                  )
                                : GestureDetector(
                                    onTap: () => ShowAlertDialogService().showAlert(
                                      context,
                                      UserDetailsOptionsDialog(
                                        addFriendAction: null, //() => sendFriendRequest(),
                                        friendRequestStatus: friendRequestStatus,
                                        confirmRequestAction: null, //() => confirmFriendRequest(),
                                        denyRequestAction: null, //() => denyFriendRequest(),
                                        blockUserAction: null,
                                        hideFromUserAction: null,
                                        removeFriendAction: null, //() => deleteFriendConfirmation(),
                                        messageUserAction: null, //messageUser,
                                      ),
                                      true,
                                    ),
                                    child: Icon(
                                      FontAwesomeIcons.ellipsisH,
                                      size: 24.0,
                                      color: Colors.black,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              child: StreamBuilder(
                stream: Firestore.instance.collection("webblen_user").document(user.uid).snapshots(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData)
                    return Text(
                      "Loading...",
                    );
                  var userData = userSnapshot.data;
                  List following = userData['d']["following"];
                  List followers = userData['d']["followers"];
                  return Container(
                    child: UserDetailsHeader(
                      isOwner: isOwner,
                      username: user.username,
                      userPicUrl: user.profile_pic,
                      uid: user.uid,
                      followersLength: followers.length,
                      followingLength: following.length,
                      followUnfollowAction: () => followUnfollowAction(),
                      viewFollowersAction: () => PageTransitionService(
                        context: context,
                        userIDs: followers,
                        pageTitle: "Followers",
                        currentUser: widget.currentUser,
                      ).transitionToUserListPage(),
                      viewFolllowingAction: () => PageTransitionService(
                        context: context,
                        userIDs: following,
                        currentUser: widget.currentUser,
                        pageTitle: "Following",
                      ).transitionToUserListPage(),
                      isFollowing: followingList == null ? null : followingList.contains(user.uid) ? true : false,
                    ),
                  );
                },
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TabBar(
                    controller: _tabController,
                    labelPadding: EdgeInsets.symmetric(horizontal: 60.0),
                    indicatorColor: CustomColors.webblenRed,
                    labelColor: CustomColors.darkGray,
                    isScrollable: true,
                    tabs: [
                      Tab(
                        child: Icon(FontAwesomeIcons.bars, color: Colors.black, size: 16.0),
                      ),
                      Tab(
                        child: Icon(FontAwesomeIcons.mapMarkerAlt, color: Colors.black, size: 16.0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: DefaultTabController(
                  length: 2,
                  child: TabBarView(
                    controller: _tabController,
                    children: <Widget>[
                      //Hosted EVENTS
                      Container(
                        key: PageStorageKey('key0'),
                        color: Colors.white,
                        child: isLoading
                            ? LoadingScreen(
                                context: context,
                                loadingDescription: 'Loading Hosted Events...',
                              )
                            : hostedEventResults.isEmpty
                                ? Column(
                                    children: <Widget>[
                                      SizedBox(height: 32.0),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context).size.width - 16,
                                            ),
                                            child: CustomText(
                                              context: context,
                                              text: "@${user.username} Has Not Hosted Any Streams/Events",
                                              textColor: Colors.black,
                                              textAlign: TextAlign.center,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  )
                                : listHostedEvents(),
                      ),
                      //Past Events
                      Container(
                        key: PageStorageKey('key1'),
                        color: Colors.white,
                        child: isLoading
                            ? LoadingScreen(
                                context: context,
                                loadingDescription: 'Loading Past Events...',
                              )
                            : pastEventResults.isEmpty
                                ? Column(
                                    children: <Widget>[
                                      SizedBox(height: 32.0),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context).size.width - 16,
                                            ),
                                            child: CustomText(
                                              context: context,
                                              text: "@${user.username} Has Not Hosted Any Streams/Events",
                                              textColor: Colors.black,
                                              textAlign: TextAlign.center,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  )
                                : listPastEvents(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserPage extends StatefulWidget {
  final WebblenUser currentUser;
  final WebblenUser webblenUser;
  final backButtonIsDisabled;

  UserPage({
    this.currentUser,
    this.webblenUser,
    this.backButtonIsDisabled,
  });

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> with SingleTickerProviderStateMixin {
  WebblenUser user;
  bool isOwner = false;
  bool isLoading = true;
  //Scroller & Paging
  final PageStorageBucket bucket = PageStorageBucket();
  TabController _tabController;
  ScrollController _scrollController;
  ScrollController hostedEventsScrollController;
  ScrollController pastEventsScrollController;
  int resultsPerPage = 10;
  List followingList = [];
  List userFollowersList = [];

  //User Relationship
  bool isFriendsWithUser = false;
  String friendRequestStatus = "";

  //Event Results
  CollectionReference eventsRef = Firestore.instance.collection("events");
  List<DocumentSnapshot> hostedEventResults = [];
  List<DocumentSnapshot> pastEventResults = [];
  DocumentSnapshot lastHostedEventDocSnap;
  DocumentSnapshot lastPastEventDocSnap;
  bool loadingAdditionalHostedEvents = false;
  bool moreHostedEventsAvailable = true;
  bool loadingAdditionalPastEvents = false;
  bool morePastEventsAvailable = true;

  //ADMOB
  String adMobUnitID;
  final nativeAdController = NativeAdmobController();

  followUnfollowAction() async {
    if (followingList.contains(user.uid)) {
      followingList.remove(user.uid);
      userFollowersList.remove(widget.currentUser.uid);
    } else {
      followingList.add(user.uid);
      userFollowersList.add(widget.currentUser.uid);
    }
    setState(() {});
    WebblenUserData().updateFollowing(widget.currentUser.uid, user.uid, followingList, userFollowersList);
  }

  getHostedEvents() async {
    Query eventsQuery;
    eventsQuery = eventsRef.where('d.authorID', isEqualTo: user.uid).orderBy('d.startDateTimeInMilliseconds', descending: true).limit(resultsPerPage);
    QuerySnapshot querySnapshot = await eventsQuery.getDocuments().catchError((e) => print(e));
    if (querySnapshot.documents.isNotEmpty) {
      lastHostedEventDocSnap = querySnapshot.documents[querySnapshot.documents.length - 1];
      hostedEventResults = querySnapshot.documents;
    }
    isLoading = false;
    setState(() {});
  }

  getPastEvents() async {
    Query eventsQuery;
    eventsQuery = eventsRef.where('d.attendees', arrayContains: user.uid).orderBy('d.startDateTimeInMilliseconds', descending: true).limit(resultsPerPage);
    QuerySnapshot querySnapshot = await eventsQuery.getDocuments().catchError((e) => print(e));
    if (querySnapshot.documents.isNotEmpty) {
      lastPastEventDocSnap = querySnapshot.documents[querySnapshot.documents.length - 1];
      pastEventResults = querySnapshot.documents;
    }
    //isLoading = false;
    setState(() {});
  }

  getAdditionalHostedEvents() async {
    if (isLoading || !moreHostedEventsAvailable || loadingAdditionalHostedEvents) {
      return;
    }
    loadingAdditionalHostedEvents = true;
    setState(() {});
    Query eventsQuery = eventsRef
        .where("d.authorID", isEqualTo: user.uid)
        .orderBy('d.startDateTimeInMilliseconds', descending: true)
        .startAfterDocument(lastHostedEventDocSnap)
        .limit(resultsPerPage);

    QuerySnapshot querySnapshot = await eventsQuery.getDocuments().catchError((e) => print(e));
    lastHostedEventDocSnap = querySnapshot.documents[querySnapshot.documents.length - 1];
    hostedEventResults.addAll(querySnapshot.documents);
    if (querySnapshot.documents.length == 0) {
      moreHostedEventsAvailable = false;
    }
    loadingAdditionalHostedEvents = false;
    setState(() {});
  }

  getAdditionalPastEvents() async {
    if (isLoading || !morePastEventsAvailable || loadingAdditionalPastEvents) {
      return;
    }
    loadingAdditionalPastEvents = true;
    setState(() {});
    Query eventsQuery = eventsRef
        .where("d.attendees", arrayContains: user.uid)
        .orderBy('d.startDateTimeInMilliseconds', descending: true)
        .startAfterDocument(lastPastEventDocSnap)
        .limit(resultsPerPage);

    QuerySnapshot querySnapshot = await eventsQuery.getDocuments().catchError((e) => print(e));
    lastPastEventDocSnap = querySnapshot.documents[querySnapshot.documents.length - 1];
    pastEventResults.addAll(querySnapshot.documents);
    if (querySnapshot.documents.length == 0) {
      morePastEventsAvailable = false;
    }
    loadingAdditionalPastEvents = false;
    setState(() {});
  }

  Widget listHostedEvents() {
    return LiquidPullToRefresh(
      color: CustomColors.webblenRed,
      onRefresh: refreshData,
      child: ListView.builder(
        controller: hostedEventsScrollController,
        key: UniqueKey(),
        shrinkWrap: true,
        padding: EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
        ),
        itemCount: hostedEventResults.length,
        itemBuilder: (context, index) {
          WebblenEvent event = WebblenEvent.fromMap(Map<String, dynamic>.from(hostedEventResults[index].data['d']));
          double num = index / 15;
          print(num == num.roundToDouble() && num != 0);
          if (num == num.roundToDouble() && num != 0) {
            return Padding(
              padding: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: hostedEventResults.length - 1 == index ? 16.0 : 0),
              child: Container(
                child: Column(
                  children: [
                    Container(
                      height: 70,
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(bottom: 20.0),
                      child: NativeAdmob(
                        // Your ad unit id
                        loading: Container(),
                        adUnitID: 'ca-app-pub-3940256099942544/3986624511',
                        numberAds: 3,
                        controller: nativeAdController,
                        type: NativeAdmobType.banner,
                      ),
                    ),
                    EventBlock(
                      event: event,
                      shareEvent: () => Share.share("https://app.webblen.io/#/event?id=${event.id}"),
                      viewEventDetails: () =>
                          PageTransitionService(context: context, currentUser: widget.currentUser, eventID: event.id).transitionToEventPage(),
                      viewEventTickets: null,
                      numOfTicsForEvent: null,
                      eventImgSize: MediaQuery.of(context).size.width - 16,
                      eventDescHeight: 120.0,
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Padding(
              padding: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: hostedEventResults.length - 1 == index ? 16.0 : 0),
              child: EventBlock(
                event: event,
                shareEvent: () => Share.share("https://app.webblen.io/#/event?id=${event.id}"),
                viewEventDetails: () => PageTransitionService(context: context, currentUser: widget.currentUser, eventID: event.id).transitionToEventPage(),
                viewEventTickets: null,
                numOfTicsForEvent: null,
                eventImgSize: MediaQuery.of(context).size.width - 16,
                eventDescHeight: 120.0,
              ),
            );
          }
        },
      ),
    );
  }

  Widget listPastEvents() {
    return LiquidPullToRefresh(
      color: CustomColors.webblenRed,
      onRefresh: refreshData,
      child: ListView.builder(
        controller: pastEventsScrollController,
        key: UniqueKey(),
        shrinkWrap: true,
        padding: EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
        ),
        itemCount: pastEventResults.length,
        itemBuilder: (context, index) {
          WebblenEvent event = WebblenEvent.fromMap(Map<String, dynamic>.from(pastEventResults[index].data['d']));
          double num = index / 15;
          print(num == num.roundToDouble() && num != 0);
          if (num == num.roundToDouble() && num != 0) {
            return Padding(
              padding: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: pastEventResults.length - 1 == index ? 16.0 : 0),
              child: Container(
                child: Column(
                  children: [
                    Container(
                      height: 70,
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(bottom: 20.0),
                      child: NativeAdmob(
                        // Your ad unit id
                        loading: Container(),
                        adUnitID: 'ca-app-pub-3940256099942544/3986624511',
                        numberAds: 3,
                        controller: nativeAdController,
                        type: NativeAdmobType.banner,
                      ),
                    ),
                    EventBlock(
                      event: event,
                      shareEvent: () => Share.share("https://app.webblen.io/#/event?id=${event.id}"),
                      viewEventDetails: () =>
                          PageTransitionService(context: context, currentUser: widget.currentUser, eventID: event.id).transitionToEventPage(),
                      viewEventTickets: null,
                      numOfTicsForEvent: null,
                      eventImgSize: MediaQuery.of(context).size.width - 16,
                      eventDescHeight: 120.0,
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Padding(
              padding: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: pastEventResults.length - 1 == index ? 16.0 : 0),
              child: EventBlock(
                event: event,
                shareEvent: () => Share.share("https://app.webblen.io/#/event?id=${event.id}"),
                viewEventDetails: () => PageTransitionService(context: context, currentUser: widget.currentUser, eventID: event.id).transitionToEventPage(),
                viewEventTickets: null,
                numOfTicsForEvent: null,
                eventImgSize: MediaQuery.of(context).size.width - 16,
                eventDescHeight: 120.0,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> refreshData() async {
    hostedEventResults = [];
    pastEventResults = [];
    getHostedEvents();
    getPastEvents();
  }

  @override
  void initState() {
    super.initState();
    if (widget.webblenUser == null || widget.webblenUser.uid == widget.currentUser.uid) {
      setState(() {
        isOwner = true;
        user = widget.currentUser;
      });
    } else {
      setState(() {
        user = widget.webblenUser;
      });
    }
    followingList = widget.currentUser.following.toList(growable: true);
    WebblenUserData().getFollowingList(widget.currentUser.uid).then((res) {
      userFollowersList = res;
      setState(() {});
    });

    if (Platform.isIOS) {
      adMobUnitID = 'ca-app-pub-2136415475966451/5262349288';
    } else if (Platform.isAndroid) {
      adMobUnitID = 'ca-app-pub-2136415475966451/5805274760';
    }
    setState(() {});
    _tabController = new TabController(
      length: 2,
      vsync: this,
    );
    _scrollController = ScrollController();
    hostedEventsScrollController = ScrollController();
    pastEventsScrollController = ScrollController();
    hostedEventsScrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * hostedEventsScrollController.position.maxScrollExtent;
      if (hostedEventsScrollController.position.pixels > triggerFetchMoreSize) {
        getAdditionalHostedEvents();
      }
    });
    pastEventsScrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * pastEventsScrollController.position.maxScrollExtent;
      if (pastEventsScrollController.position.pixels > triggerFetchMoreSize) {
        getAdditionalPastEvents();
      }
    });
    getHostedEvents();
    getPastEvents();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    hostedEventsScrollController.dispose();
    pastEventsScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark,
    );
    return Scaffold(
      appBar: WebblenAppBar().actionAppBar(
        "@${user.username}",
        isOwner
            ? Container()
            : Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () => ShowAlertDialogService().showAlert(
                    context,
                    UserDetailsOptionsDialog(
                      addFriendAction: null, //() => sendFriendRequest(),
                      friendRequestStatus: friendRequestStatus,
                      confirmRequestAction: null, //() => confirmFriendRequest(),
                      denyRequestAction: null, //() => denyFriendRequest(),
                      blockUserAction: null,
                      hideFromUserAction: null,
                      removeFriendAction: null, //() => deleteFriendConfirmation(),
                      messageUserAction: null, //messageUser,
                    ),
                    true,
                  ),
                  child: Icon(
                    FontAwesomeIcons.ellipsisH,
                    size: 24.0,
                    color: Colors.black,
                  ),
                ),
              ),
      ),
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaleFactor: 1.0,
        ),
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              StreamBuilder(
                stream: Firestore.instance.collection("webblen_user").document(widget.currentUser.uid).snapshots(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData)
                    return Text(
                      "Loading...",
                    );
                  var userData = userSnapshot.data;
                  List following = userData['d']["following"];
                  List followers = userData['d']["followers"];
                  return Container(
                    child: UserDetailsHeader(
                      isOwner: isOwner,
                      username: user.username,
                      userPicUrl: user.profile_pic,
                      uid: user.uid,
                      followersLength: followers.length,
                      followingLength: following.length,
                      followUnfollowAction: () => followUnfollowAction(),
                      viewFollowersAction: () => PageTransitionService(
                        context: context,
                        userIDs: followers,
                        pageTitle: "Followers",
                        currentUser: widget.currentUser,
                      ).transitionToUserListPage(),
                      viewFolllowingAction: () => PageTransitionService(
                        context: context,
                        userIDs: following,
                        currentUser: widget.currentUser,
                        pageTitle: "Following",
                      ).transitionToUserListPage(),
                      isFollowing: following.contains(user.uid) ? true : false,
                    ),
                  );
                },
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TabBar(
                      controller: _tabController,
                      labelPadding: EdgeInsets.symmetric(horizontal: 60.0),
                      indicatorColor: CustomColors.webblenRed,
                      labelColor: CustomColors.darkGray,
                      isScrollable: true,
                      tabs: [
                        Tab(
                          child: Icon(FontAwesomeIcons.bars, color: Colors.black, size: 16.0),
                        ),
                        Tab(
                          child: Icon(FontAwesomeIcons.mapMarkerAlt, color: Colors.black, size: 16.0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: DefaultTabController(
                    length: 2,
                    child: TabBarView(
                      controller: _tabController,
                      children: <Widget>[
                        //Hosted EVENTS
                        Container(
                          key: PageStorageKey('key0'),
                          color: Colors.white,
                          child: isLoading
                              ? LoadingScreen(
                                  context: context,
                                  loadingDescription: 'Loading Hosted Events...',
                                )
                              : hostedEventResults.isEmpty
                                  ? Column(
                                      children: <Widget>[
                                        SizedBox(height: 32.0),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Container(
                                              constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context).size.width - 16,
                                              ),
                                              child: CustomText(
                                                context: context,
                                                text: "@${user.username} Has Not Hosted Any Streams or Events",
                                                textColor: Colors.black,
                                                textAlign: TextAlign.center,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    )
                                  : listHostedEvents(),
                        ),
                        //Past Events
                        Container(
                          key: PageStorageKey('key1'),
                          color: Colors.white,
                          child: isLoading
                              ? LoadingScreen(
                                  context: context,
                                  loadingDescription: 'Loading Past Events...',
                                )
                              : pastEventResults.isEmpty
                                  ? Column(
                                      children: <Widget>[
                                        SizedBox(height: 32.0),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Container(
                                              constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context).size.width - 16,
                                              ),
                                              child: CustomText(
                                                context: context,
                                                text: "@${user.username} Has Not Hosted Any Events",
                                                textColor: Colors.black,
                                                textAlign: TextAlign.center,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    )
                                  : listPastEvents(),
                        ),
                      ],
                    ),
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
