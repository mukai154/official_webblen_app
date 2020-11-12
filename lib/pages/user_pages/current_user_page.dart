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
import 'package:webblen/widgets/common/text/custom_text.dart';
import 'package:webblen/widgets/events/event_block.dart';
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
  bool isLoading = true;
  //Scroller & Paging
  final PageStorageBucket bucket = PageStorageBucket();
  TabController _tabController;
  ScrollController hostedEventsScrollController;
  ScrollController pastEventsScrollController;
  ScrollController attendedEventsScrollController;
  int resultsPerPage = 10;

  //Event Results
  CollectionReference eventsRef = FirebaseFirestore.instance.collection("events");
  List<DocumentSnapshot> hostedEventResults = [];
  List<DocumentSnapshot> pastEventResults = [];
  List<DocumentSnapshot> attendedEventResults = [];
  List followingList = [];
  List userFollowersList = [];
  DocumentSnapshot lastHostedEventDocSnap;
  DocumentSnapshot lastPastEventDocSnap;
  DocumentSnapshot lastAttendedEventDocSnap;
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

  showNewEventOrStreamDialog() {
    ShowAlertDialogService().showNewEventOrStreamDialog(
      context,
      () {
        Navigator.of(context).pop();
        PageTransitionService(context: context, isStream: false).transitionToCreateEventPage();
      },
      () {
        Navigator.of(context).pop();
        PageTransitionService(context: context, isStream: true).transitionToCreateEventPage();
      },
    );
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
          print(num == num.roundToDouble() && num != 0);
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
              padding: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: attendedEventResults.length - 1 == index ? 16.0 : 0),
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
    attendedEventResults = [];
    getHostedEvents();
    getPastEvents();
    getAttendedEvents();
  }

  @override
  void initState() {
    super.initState();
    if (widget.webblenUser == null || widget.webblenUser.uid == widget.currentUser.uid) {
      setState(() {
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
      length: 3,
      vsync: this,
    );
    hostedEventsScrollController = ScrollController();
    pastEventsScrollController = ScrollController();
    attendedEventsScrollController = ScrollController();
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
    attendedEventsScrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * attendedEventsScrollController.position.maxScrollExtent;
      if (attendedEventsScrollController.position.pixels > triggerFetchMoreSize) {
        getAdditionalAttendedEvents();
      }
    });
    getHostedEvents();
    getPastEvents();
    getAttendedEvents();
  }

  @override
  void dispose() {
    super.dispose();
    hostedEventsScrollController.dispose();
    pastEventsScrollController.dispose();
    attendedEventsScrollController.dispose();
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
                        text: "My Account",
                        textColor: Colors.black,
                        textAlign: TextAlign.center,
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: 20,
                          right: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () => PageTransitionService(context: context, currentUser: widget.currentUser).transitionTFeedbackPage(),
                              child: Container(
                                height: 30,
                                width: 30,
                                child: Icon(FontAwesomeIcons.lightbulb, color: Colors.black, size: 20.0),
                              ),
                            ),
                            SizedBox(width: 16.0),
                            GestureDetector(
                              onTap: () => PageTransitionService(context: context, currentUser: widget.currentUser).transitionToSettingsPage(),
                              child: Container(
                                height: 30,
                                width: 30,
                                child: Icon(FontAwesomeIcons.cog, color: Colors.black, size: 20.0),
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
                stream: FirebaseFirestore.instance.collection("webblen_user").doc(user.uid).snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                  if (!userSnapshot.hasData) return Container(height: 200);
                  var userData = userSnapshot.data.data();
                  List following = userData['d']["following"];
                  List followers = userData['d']["followers"];
                  return Container(
                    child: UserDetailsHeader(
                      isOwner: true,
                      username: user.username,
                      userPicUrl: user.profile_pic,
                      uid: user.uid,
                      followersLength: followers.length,
                      followingLength: following.length,
                      followUnfollowAction: null,
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
                      isFollowing: followingList == null
                          ? null
                          : followingList.contains(user.uid)
                              ? true
                              : false,
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
                    labelPadding: EdgeInsets.symmetric(horizontal: 20.0),
                    indicatorColor: CustomColors.webblenRed,
                    labelColor: CustomColors.darkGray,
                    isScrollable: true,
                    tabs: [
                      Tab(
                        child: Text(
                          "Upcoming",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "Past",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "Check-Ins",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.w500),
                        ),
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
                  length: 3,
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context).size.width - 16,
                                            ),
                                            child: Text(
                                              "@${user.username} Has No Upcoming Streams/Events",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 8.0),
                                      GestureDetector(
                                        onTap: () => showNewEventOrStreamDialog(),
                                        child: Text(
                                          "Change Event or Stream",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, color: CustomColors.electronBlue),
                                        ),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context).size.width - 16,
                                            ),
                                            child: Text(
                                              "@${user.username} Has Not Hosted Any Streams/Events Recently",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 8.0),
                                    ],
                                  )
                                : listPastEvents(),
                      ),
                      //Attended EVENTS
                      Container(
                        key: PageStorageKey('key2'),
                        color: Colors.white,
                        child: isLoading
                            ? LoadingScreen(
                                context: context,
                                loadingDescription: 'Loading Attended Events...',
                              )
                            : attendedEventResults.isEmpty
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                      SizedBox(height: 8.0),
                                    ],
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
    );
  }
}
