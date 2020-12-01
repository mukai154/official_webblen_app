import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/firebase/data/event_data.dart';
import 'package:webblen/firebase/data/post_data.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/share/share_service.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';
import 'package:webblen/widgets/events/event_block.dart';
import 'package:webblen/widgets/posts/post_block.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';
import 'package:webblen/widgets/widgets_user/user_header.dart';

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
  WebblenUser user;
  bool isOwner = false;
  bool isLoading = true;

  //Scroller & Paging
  final PageStorageBucket bucket = PageStorageBucket();
  TabController _tabController;
  ScrollController postsScrollController;
  ScrollController hostedEventsScrollController;
  ScrollController pastEventsScrollController;
  ScrollController attendedEventsScrollController;
  int resultsPerPage = 10;

  //Event Results
  CollectionReference eventsRef = FirebaseFirestore.instance.collection("events");
  CollectionReference postsRef = FirebaseFirestore.instance.collection("posts");
  List<DocumentSnapshot> postResults = [];
  List<DocumentSnapshot> hostedEventResults = [];
  List<DocumentSnapshot> pastEventResults = [];
  List<DocumentSnapshot> attendedEventResults = [];
  List currentUserFollowingList = [];
  List userFollowersList = [];
  DocumentSnapshot lastPostDocSnap;
  DocumentSnapshot lastHostedEventDocSnap;
  DocumentSnapshot lastPastEventDocSnap;
  DocumentSnapshot lastAttendedEventDocSnap;
  bool loadingAdditionalPosts = false;
  bool morePostsAvailable = true;
  bool loadingAdditionalHostedEvents = false;
  bool moreHostedEventsAvailable = true;
  bool loadingAdditionalPastEvents = false;
  bool morePastEventsAvailable = true;
  bool loadingAdditionalAttendedEvents = false;
  bool moreAttendedEventsAvailable = true;
  int currentDateTimeInMilliseconds = DateTime.now().millisecondsSinceEpoch;

  //ADMOB
  String adMobUnitID;
  final nativeAdController = NativeAdmobController();

  postOptionsDialog(WebblenPost post) async {
    if (post.authorID == widget.currentUser.uid) {
      String action = await showModalActionSheet(
        context: context,
        actions: [
          SheetAction(label: "Edit Post", key: 'editPost'),
          SheetAction(label: "Copy Link", key: 'copyLink'),
          SheetAction(label: "Share", key: 'sharePost'),
          SheetAction(label: "Delete Post", key: 'deletePost', isDestructiveAction: true),
        ],
      );
      if (action == 'editPost') {
        PageTransitionService(context: context, postID: post.id).transitionToCreatePostPage();
      } else if (action == 'copyLink') {
        ShareService().shareContent(post: post, copyLink: true);
        HapticFeedback.mediumImpact();
      } else if (action == 'sharePost') {
        ShareService().shareContent(post: post, copyLink: false);
      } else if (action == 'deletePost') {
        OkCancelResult res = await showOkCancelAlertDialog(
          context: context,
          message: "Delete This Post?",
          okLabel: "Delete",
          cancelLabel: "Cancel",
          isDestructiveAction: true,
        );
        if (res == OkCancelResult.ok) {
          PostDataService().deletePost(post.id);
        }
      }
    } else {
      String action = await showModalActionSheet(
        context: context,
        actions: [
          SheetAction(label: "Copy Link", key: 'copyLink'),
          SheetAction(label: "Share", key: 'share'),
          SheetAction(label: "Report", key: 'report', isDestructiveAction: true),
        ],
      );
      if (action == 'copyLink') {
        ShareService().shareContent(post: post, copyLink: true);
        HapticFeedback.mediumImpact();
      } else if (action == 'share') {
        ShareService().shareContent(post: post, copyLink: false);
      } else if (action == 'report') {
        //PageTransitionService(context: context, isStream: true).transitionToCreatePostPage();
      }
    }
  }

  eventOptionsDialog(WebblenEvent event) async {
    if (event.authorID == widget.currentUser.uid) {
      List<SheetAction<String>> actions = event.endDateTimeInMilliseconds > currentDateTimeInMilliseconds
          ? event.hasTickets
              ? [
                  SheetAction(label: "Edit Event", key: 'editEvent'),
                  SheetAction(label: "Copy Ticket Link", key: 'ticketLink'),
                  SheetAction(label: "Copy Link", key: 'copyLink'),
                  SheetAction(label: "Share", key: 'shareEvent'),
                  SheetAction(label: "Delete Event", key: 'deleteEvent', isDestructiveAction: true),
                ]
              : [
                  SheetAction(label: "Edit Event", key: 'editEvent'),
                  SheetAction(label: "Copy Link", key: 'copyLink'),
                  SheetAction(label: "Share", key: 'shareEvent'),
                  SheetAction(label: "Delete Event", key: 'deleteEvent', isDestructiveAction: true),
                ]
          : [
              SheetAction(label: "Copy Link", key: 'copyLink'),
              SheetAction(label: "Share", key: 'shareEvent'),
              SheetAction(label: "Delete Event", key: 'deleteEvent', isDestructiveAction: true),
            ];
      String action = await showModalActionSheet(
        context: context,
        actions: actions,
      );
      if (action == 'editEvent') {
        PageTransitionService(context: context, eventID: event.id, isStream: event.isDigitalEvent).transitionToCreateEventPage();
      } else if (action == 'ticketLink') {
        ShareService().copyTicketLink(event: event);
        HapticFeedback.mediumImpact();
      } else if (action == 'copyLink') {
        ShareService().shareContent(event: event, copyLink: true);
        HapticFeedback.mediumImpact();
      } else if (action == 'shareEvent') {
        ShareService().shareContent(event: event, copyLink: false);
      } else if (action == 'deleteEvent') {
        OkCancelResult res = await showOkCancelAlertDialog(
          context: context,
          message: "Delete This Event?",
          okLabel: "Delete",
          cancelLabel: "Cancel",
          isDestructiveAction: true,
        );
        if (res == OkCancelResult.ok) {
          EventDataService().deleteEvent(event.id);
        }
      }
    } else {
      String action = await showModalActionSheet(
        context: context,
        actions: [
          SheetAction(label: "Copy Link", key: 'copyLink'),
          SheetAction(label: "Share", key: 'share'),
          SheetAction(label: "Report", key: 'report', isDestructiveAction: true),
        ],
      );
      if (action == 'copyLink') {
        ShareService().shareContent(event: event, copyLink: true);
        HapticFeedback.mediumImpact();
      } else if (action == 'share') {
        ShareService().shareContent(event: event, copyLink: false);
      } else if (action == 'report') {
        //PageTransitionService(context: context, isStream: true).transitionToCreatePostPage();
      }
    }
  }

  getPosts() async {
    Query query = postsRef.where('authorID', isEqualTo: user.uid).orderBy('postDateTimeInMilliseconds', descending: true).limit(resultsPerPage);
    QuerySnapshot querySnapshot = await query.get().catchError((e) => print(e));
    if (querySnapshot.docs.isNotEmpty) {
      lastPostDocSnap = querySnapshot.docs[querySnapshot.docs.length - 1];
      postResults = querySnapshot.docs;
    }
    isLoading = false;
    setState(() {});
  }

  getHostedEvents() async {
    Query eventsQuery;
    eventsQuery = eventsRef
        .where('d.authorID', isEqualTo: user.uid)
        .where("d.endDateTimeInMilliseconds", isGreaterThan: currentDateTimeInMilliseconds)
        .orderBy('d.endDateTimeInMilliseconds', descending: false)
        .limit(resultsPerPage);
    QuerySnapshot querySnapshot = await eventsQuery.get().catchError((e) => print(e));
    if (querySnapshot.docs.isNotEmpty) {
      lastHostedEventDocSnap = querySnapshot.docs[querySnapshot.docs.length - 1];
      hostedEventResults = querySnapshot.docs;
    }
    isLoading = false;
    setState(() {});
  }

  getPastEvents() async {
    Query eventsQuery;
    eventsQuery = eventsRef
        .where('d.authorID', isEqualTo: user.uid)
        .where("d.endDateTimeInMilliseconds", isLessThan: currentDateTimeInMilliseconds)
        .orderBy('d.endDateTimeInMilliseconds', descending: true)
        .limit(resultsPerPage);
    QuerySnapshot querySnapshot = await eventsQuery.get().catchError((e) => print(e));
    if (querySnapshot.docs.isNotEmpty) {
      lastPastEventDocSnap = querySnapshot.docs[querySnapshot.docs.length - 1];
      pastEventResults = querySnapshot.docs;
    }
  }

  getAttendedEvents() async {
    Query eventsQuery;
    eventsQuery = eventsRef.where('d.attendees', arrayContains: user.uid).orderBy('d.startDateTimeInMilliseconds', descending: true).limit(resultsPerPage);
    QuerySnapshot querySnapshot = await eventsQuery.get().catchError((e) => print(e));
    if (querySnapshot.docs.isNotEmpty) {
      lastAttendedEventDocSnap = querySnapshot.docs[querySnapshot.docs.length - 1];
      attendedEventResults = querySnapshot.docs;
    }
    setState(() {});
  }

  getAdditionalPosts() async {
    if (isLoading || !morePostsAvailable || loadingAdditionalPosts) {
      return;
    }
    loadingAdditionalPosts = true;
    setState(() {});
    Query query = postsRef
        .where("authorID", isEqualTo: user.uid)
        .orderBy('postDateTimeInMilliseconds', descending: true)
        .startAfterDocument(lastPostDocSnap)
        .limit(resultsPerPage);

    QuerySnapshot querySnapshot = await query.get().catchError((e) => print(e));
    lastPostDocSnap = querySnapshot.docs.last;
    postResults.addAll(querySnapshot.docs);
    if (querySnapshot.docs.length == 0) {
      morePostsAvailable = false;
    }
    loadingAdditionalPosts = false;
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
        .where("d.endDateTimeInMilliseconds", isGreaterThan: currentDateTimeInMilliseconds)
        .orderBy('d.endDateTimeInMilliseconds', descending: false)
        .startAfterDocument(lastHostedEventDocSnap)
        .limit(resultsPerPage);

    QuerySnapshot querySnapshot = await eventsQuery.get().catchError((e) => print(e));
    lastHostedEventDocSnap = querySnapshot.docs[querySnapshot.docs.length - 1];
    hostedEventResults.addAll(querySnapshot.docs);
    if (querySnapshot.docs.length == 0) {
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
        .where("d.authorID", isEqualTo: user.uid)
        .where("d.endDateTimeInMilliseconds", isLessThan: currentDateTimeInMilliseconds)
        .orderBy('d.endDateTimeInMilliseconds', descending: true)
        .startAfterDocument(lastPastEventDocSnap)
        .limit(resultsPerPage);

    QuerySnapshot querySnapshot = await eventsQuery.get().catchError((e) => print(e));
    lastPastEventDocSnap = querySnapshot.docs[querySnapshot.docs.length - 1];
    pastEventResults.addAll(querySnapshot.docs);
    if (querySnapshot.docs.length == 0) {
      morePastEventsAvailable = false;
    }
    loadingAdditionalPastEvents = true;
    setState(() {});
  }

  getAdditionalAttendedEvents() async {
    if (isLoading || !moreAttendedEventsAvailable || loadingAdditionalAttendedEvents) {
      return;
    }
    loadingAdditionalAttendedEvents = true;
    setState(() {});
    Query eventsQuery = eventsRef
        .where("d.attendees", arrayContains: user.uid)
        .orderBy('d.startDateTimeInMilliseconds', descending: true)
        .startAfterDocument(lastAttendedEventDocSnap)
        .limit(resultsPerPage);

    QuerySnapshot querySnapshot = await eventsQuery.get().catchError((e) => print(e));
    lastAttendedEventDocSnap = querySnapshot.docs[querySnapshot.docs.length - 1];
    attendedEventResults.addAll(querySnapshot.docs);
    if (querySnapshot.docs.length == 0) {
      moreAttendedEventsAvailable = false;
    }
    loadingAdditionalAttendedEvents = false;
    setState(() {});
  }

  Widget listPosts() {
    return LiquidPullToRefresh(
      color: CustomColors.webblenRed,
      onRefresh: refreshData,
      child: ListView.builder(
        controller: postsScrollController,
        physics: AlwaysScrollableScrollPhysics(),
        key: UniqueKey(),
        shrinkWrap: true,
        padding: EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
        ),
        itemCount: postResults.length,
        itemBuilder: (context, index) {
          WebblenPost post = WebblenPost.fromMap(Map<String, dynamic>.from(postResults[index].data()));
          return Padding(
            padding: EdgeInsets.only(bottom: postResults.length - 1 == index ? 16.0 : 0),
            child: Container(
              child: Column(
                children: [
                  SizedBox(height: 8.0),
                  post.imageURL == null
                      ? PostTextBlock(
                          currentUID: widget.currentUser.uid,
                          post: post,
                          viewUser: null, //() => transitionToUserPage(post.authorID),
                          viewPost: () => PageTransitionService(context: context, postID: post.id).transitionToPostViewPage(),
                          postOptions: () => postOptionsDialog(post),
                        )
                      : PostImgBlock(
                          currentUID: widget.currentUser.uid,
                          post: post,
                          viewUser: null, //() => transitionToUserPage(post.authorID),
                          //shareEvent: () => Share.share("https://app.webblen.io/#/post?id=${post.id}"),
                          viewPost: () => PageTransitionService(context: context, postID: post.id).transitionToPostViewPage(),
                          postOptions: () => postOptionsDialog(post),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget listHostedEvents() {
    return LiquidPullToRefresh(
      color: CustomColors.webblenRed,
      onRefresh: refreshData,
      child: ListView.builder(
        controller: hostedEventsScrollController,
        physics: AlwaysScrollableScrollPhysics(),
        key: UniqueKey(),
        shrinkWrap: true,
        padding: EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
        ),
        itemCount: hostedEventResults.length,
        itemBuilder: (context, index) {
          WebblenEvent event = WebblenEvent.fromMap(Map<String, dynamic>.from(hostedEventResults[index].data()['d']));
          double num = index / 15;
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
                      viewEventDetails: () =>
                          PageTransitionService(context: context, currentUser: widget.currentUser, eventID: event.id).transitionToEventPage(),
                      eventOptions: () => eventOptionsDialog(event),
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
                viewEventDetails: () => PageTransitionService(context: context, currentUser: widget.currentUser, eventID: event.id).transitionToEventPage(),
                eventOptions: () => eventOptionsDialog(event),
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
        physics: AlwaysScrollableScrollPhysics(),
        key: UniqueKey(),
        shrinkWrap: true,
        padding: EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
        ),
        itemCount: pastEventResults.length,
        itemBuilder: (context, index) {
          WebblenEvent event = WebblenEvent.fromMap(Map<String, dynamic>.from(pastEventResults[index].data()['d']));
          double num = index / 15;
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
                      viewEventDetails: () =>
                          PageTransitionService(context: context, currentUser: widget.currentUser, eventID: event.id).transitionToEventPage(),
                      eventOptions: () => eventOptionsDialog(event),
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
                viewEventDetails: () => PageTransitionService(context: context, currentUser: widget.currentUser, eventID: event.id).transitionToEventPage(),
                eventOptions: () => eventOptionsDialog(event),
              ),
            );
          }
        },
      ),
    );
  }

  Widget listAttendedEvents() {
    return LiquidPullToRefresh(
      color: CustomColors.webblenRed,
      onRefresh: refreshData,
      child: ListView.builder(
        controller: attendedEventsScrollController,
        physics: AlwaysScrollableScrollPhysics(),
        key: UniqueKey(),
        shrinkWrap: true,
        padding: EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
        ),
        itemCount: attendedEventResults.length,
        itemBuilder: (context, index) {
          WebblenEvent event = WebblenEvent.fromMap(Map<String, dynamic>.from(attendedEventResults[index].data()['d']));
          double num = index / 15;
          if (num == num.roundToDouble() && num != 0) {
            return Padding(
              padding: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: attendedEventResults.length - 1 == index ? 16.0 : 0),
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
                        viewEventDetails: () =>
                            PageTransitionService(context: context, currentUser: widget.currentUser, eventID: event.id).transitionToEventPage(),
                        eventOptions: () => eventOptionsDialog(event)),
                  ],
                ),
              ),
            );
          } else {
            return Padding(
              padding: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: attendedEventResults.length - 1 == index ? 16.0 : 0),
              child: EventBlock(
                event: event,
                viewEventDetails: () => PageTransitionService(context: context, currentUser: widget.currentUser, eventID: event.id).transitionToEventPage(),
                eventOptions: () => eventOptionsDialog(event),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> refreshData() async {
    postResults = [];
    hostedEventResults = [];
    pastEventResults = [];
    getPosts();
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
    currentUserFollowingList = widget.currentUser.following.toList(growable: true);
    WebblenUserData().getFollowers(user.uid).then((res) {
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
      length: 4,
      vsync: this,
    );
    postsScrollController = ScrollController();
    hostedEventsScrollController = ScrollController();
    pastEventsScrollController = ScrollController();
    attendedEventsScrollController = ScrollController();
    postsScrollController.addListener(() {
      double triggerFetchMoreSize = 0.2 * postsScrollController.position.maxScrollExtent;
      if (postsScrollController.position.pixels > triggerFetchMoreSize) {
        getAdditionalPosts();
      }
    });
    hostedEventsScrollController.addListener(() {
      double triggerFetchMoreSize = 0.2 * hostedEventsScrollController.position.maxScrollExtent;
      if (hostedEventsScrollController.position.pixels > triggerFetchMoreSize) {
        getAdditionalHostedEvents();
      }
    });
    pastEventsScrollController.addListener(() {
      double triggerFetchMoreSize = 0.2 * pastEventsScrollController.position.maxScrollExtent;
      if (pastEventsScrollController.position.pixels > triggerFetchMoreSize) {
        getAdditionalPastEvents();
      }
    });
    attendedEventsScrollController.addListener(() {
      double triggerFetchMoreSize = 0.2 * attendedEventsScrollController.position.maxScrollExtent;
      if (attendedEventsScrollController.position.pixels > triggerFetchMoreSize) {
        getAdditionalAttendedEvents();
      }
    });
    getPosts();
    getHostedEvents();
    getPastEvents();
    getAttendedEvents();
  }

  @override
  void dispose() {
    super.dispose();
    postsScrollController.dispose();
    hostedEventsScrollController.dispose();
    pastEventsScrollController.dispose();
    attendedEventsScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark,
    );
    return Scaffold(
      appBar: WebblenAppBar().actionAppBar(
        "@${user.username}",
        Container(),
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
                stream: FirebaseFirestore.instance.collection("webblen_user").doc(user.uid).snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                  if (!userSnapshot.hasData) return Container();
                  var userData = userSnapshot.data.data();
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
                      followUnfollowAction: followers.contains(widget.currentUser.uid)
                          ? () => WebblenUserData().unFollowUser(widget.currentUser.uid, user.uid)
                          : () => WebblenUserData().followUser(widget.currentUser.uid, user.uid),
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
                      isFollowing: followers.contains(widget.currentUser.uid) ? true : false,
                    ),
                  );
                },
              ),
              Container(
                height: 30,
                margin: EdgeInsets.only(bottom: 8),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelPadding: EdgeInsets.symmetric(horizontal: 10),
                  indicatorColor: CustomColors.webblenRed,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black54,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicator: BoxDecoration(borderRadius: BorderRadius.circular(10), color: CustomColors.webblenRed),
                  tabs: [
                    Tab(
                      child: Container(
                        height: 30,
                        width: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Posts",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        height: 30,
                        width: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Events",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        height: 30,
                        width: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Past Events",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        height: 30,
                        width: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Check-Ins",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: DefaultTabController(
                    length: 4,
                    child: TabBarView(
                      controller: _tabController,
                      children: <Widget>[
                        //Posts
                        Container(
                          key: PageStorageKey('key0'),
                          color: Colors.white,
                          child: isLoading
                              ? LoadingScreen(
                                  context: context,
                                  loadingDescription: 'Loading Posts...',
                                )
                              : postResults.isEmpty
                                  ? LiquidPullToRefresh(
                                      onRefresh: refreshData,
                                      color: CustomColors.webblenRed,
                                      child: Center(
                                        child: ListView(
                                          shrinkWrap: true,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                                              child: Image.asset(
                                                'assets/images/beach_sun.png',
                                                height: 200,
                                                fit: BoxFit.contain,
                                                filterQuality: FilterQuality.medium,
                                              ),
                                            ),
                                            SizedBox(height: 8.0),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  constraints: BoxConstraints(
                                                    maxWidth: MediaQuery.of(context).size.width - 16,
                                                  ),
                                                  child: Text(
                                                    "@${user.username} Has Not Posted Anything",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : listPosts(),
                        ),
                        //Hosted EVENTS
                        Container(
                          key: PageStorageKey('key1'),
                          color: Colors.white,
                          child: isLoading
                              ? LoadingScreen(
                                  context: context,
                                  loadingDescription: 'Loading Hosted Events...',
                                )
                              : hostedEventResults.isEmpty
                                  ? LiquidPullToRefresh(
                                      onRefresh: refreshData,
                                      color: CustomColors.webblenRed,
                                      child: Center(
                                        child: ListView(
                                          shrinkWrap: true,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                                              child: Image.asset(
                                                'assets/images/beach_sun.png',
                                                height: 200,
                                                fit: BoxFit.contain,
                                                filterQuality: FilterQuality.medium,
                                              ),
                                            ),
                                            SizedBox(height: 8.0),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  constraints: BoxConstraints(
                                                    maxWidth: MediaQuery.of(context).size.width - 16,
                                                  ),
                                                  child: Text(
                                                    "@${user.username} Has No Any Streams/Events",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : listHostedEvents(),
                        ),
                        //Past Events
                        Container(
                          key: PageStorageKey('key2'),
                          color: Colors.white,
                          child: isLoading
                              ? LoadingScreen(
                                  context: context,
                                  loadingDescription: 'Loading Past Events...',
                                )
                              : pastEventResults.isEmpty
                                  ? LiquidPullToRefresh(
                                      onRefresh: refreshData,
                                      color: CustomColors.webblenRed,
                                      child: Center(
                                        child: ListView(
                                          shrinkWrap: true,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                                              child: Image.asset(
                                                'assets/images/beach_sun.png',
                                                height: 200,
                                                fit: BoxFit.contain,
                                                filterQuality: FilterQuality.medium,
                                              ),
                                            ),
                                            SizedBox(height: 8.0),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  constraints: BoxConstraints(
                                                    maxWidth: MediaQuery.of(context).size.width - 16,
                                                  ),
                                                  child: Text(
                                                    "@${user.username} Has No Past Streams/Events",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : listPastEvents(),
                        ),
                        //Attended Events
                        Container(
                          key: PageStorageKey('key3'),
                          color: Colors.white,
                          child: isLoading
                              ? LoadingScreen(
                                  context: context,
                                  loadingDescription: 'Loading Attended Events...',
                                )
                              : attendedEventResults.isEmpty
                                  ? LiquidPullToRefresh(
                                      onRefresh: refreshData,
                                      color: CustomColors.webblenRed,
                                      child: Center(
                                        child: ListView(
                                          shrinkWrap: true,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                                              child: Image.asset(
                                                'assets/images/beach_sun.png',
                                                height: 200,
                                                fit: BoxFit.contain,
                                                filterQuality: FilterQuality.medium,
                                              ),
                                            ),
                                            SizedBox(height: 8.0),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  constraints: BoxConstraints(
                                                    maxWidth: MediaQuery.of(context).size.width - 16,
                                                  ),
                                                  child: Text(
                                                    "@${user.username} Has Not Attended Any Streams/Events",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : listAttendedEvents(),
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
