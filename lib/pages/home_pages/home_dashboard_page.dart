import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:share/share.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/constants/strings.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/common/buttons/custom_color_button.dart';
import 'package:webblen/widgets/common/containers/text_field_container.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';
import 'package:webblen/widgets/events/event_block.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';

class HomeDashboardPage extends StatefulWidget {
  final WebblenUser currentUser;
  final bool updateRequired;
  final String areaName;
  final Key key;
  final double currentLat;
  final double currentLon;
  final Widget notifWidget;

  HomeDashboardPage({
    this.currentUser,
    this.updateRequired,
    this.areaName,
    this.currentLat,
    this.currentLon,
    this.key,
    this.notifWidget,
  });

  @override
  _HomeDashboardPageState createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> with SingleTickerProviderStateMixin {
  bool isLoading = true;
  //Scroller & Paging
  final PageStorageBucket bucket = PageStorageBucket();
  TabController _tabController;
  ScrollController liveEventsScrollController;
  ScrollController virtualEventsScrollController;
  ScrollController savedEventsScrollController;
//  ScrollController followingEventsScrollController;
  int resultsPerPage = 10;
  //Filter
  String areaName = "My Current Location";
  String areaCodeFilter;
  String eventTypeFilter = "None";
  String eventCategoryFilter = "None";
  //Event Results
  int dateTimeInMilliseconds2hoursAgo = DateTime.now().millisecondsSinceEpoch - 7400000;
  CollectionReference eventsRef = Firestore.instance.collection("events");
  List<DocumentSnapshot> liveEventResults = [];
  List<DocumentSnapshot> virtualEventResults = [];
  List<DocumentSnapshot> savedEventResults = [];
  List<DocumentSnapshot> followingEventsResults = [];
  DocumentSnapshot lastLiveEventDocSnap;
  DocumentSnapshot lastVirtualEventDocSnap;
  DocumentSnapshot lastSavedEventDocSnap;
//  DocumentSnapshot lastFollowingEventDocSnap;
  bool loadingAdditionalLiveEvents = false;
  bool moreLiveEventsAvailable = true;
  bool loadingAdditionalVirtualEvents = false;
  bool moreVirtualEventsAvailable = true;
  bool loadingAdditionalSavedEvents = false;
  bool moreSavedEventsAvailable = true;
//  bool loadingAdditionalFollowingEvents = false;
//  bool moreFollowingsAvailable = true;

  //ADMOB
  String adMobUnitID;
  final nativeAdController = NativeAdmobController();

  getLiveEvents() async {
    Query eventsQuery;
    if (eventCategoryFilter == "None" && eventTypeFilter == "None") {
      eventsQuery = eventsRef
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
          .where("d.startDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .limit(resultsPerPage);
    } else if (eventCategoryFilter == "None" && eventTypeFilter != "None") {
      print(eventTypeFilter);
      eventsQuery = eventsRef
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
          .where("d.startDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .where('d.type', isEqualTo: eventTypeFilter)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .limit(resultsPerPage);
    } else if (eventCategoryFilter != "None" && eventTypeFilter == "None") {
      eventsQuery = eventsRef
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
          .where('d.category', isEqualTo: eventCategoryFilter)
          .where("d.startDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .limit(resultsPerPage);
    } else {
      eventsQuery = eventsRef
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
          .where('d.type', isEqualTo: eventTypeFilter)
          .where('d.category', isEqualTo: eventCategoryFilter)
          .where("d.startDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .limit(resultsPerPage);
    }
    QuerySnapshot querySnapshot = await eventsQuery.getDocuments().catchError((e) => print(e));
    if (querySnapshot.documents.isNotEmpty) {
      lastLiveEventDocSnap = querySnapshot.documents[querySnapshot.documents.length - 1];
      liveEventResults = querySnapshot.documents;
    }
    isLoading = false;
    setState(() {});
  }

  getVirtualEvents() async {
    Query eventsQuery;
    if (eventCategoryFilter == "None" && eventTypeFilter == "None") {
      eventsQuery = eventsRef
          .where('d.isDigitalEvent', isEqualTo: true)
          .where("d.startDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .limit(resultsPerPage);
    } else if (eventCategoryFilter == "None" && eventTypeFilter != "None") {
      print(eventTypeFilter);
      eventsQuery = eventsRef
          .where('d.isDigitalEvent', isEqualTo: true)
          .where('d.type', isEqualTo: eventTypeFilter)
          .where("d.startDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .limit(resultsPerPage);
    } else if (eventCategoryFilter != "None" && eventTypeFilter == "None") {
      eventsQuery = eventsRef
          .where('d.isDigitalEvent', isEqualTo: true)
          .where('d.category', isEqualTo: eventCategoryFilter)
          .where("d.startDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .limit(resultsPerPage);
    } else {
      eventsQuery = eventsRef
          .where('d.isDigitalEvent', isEqualTo: true)
          .where('d.type', isEqualTo: eventTypeFilter)
          .where('d.category', isEqualTo: eventCategoryFilter)
          .where("d.startDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .limit(resultsPerPage);
    }
    QuerySnapshot querySnapshot = await eventsQuery.getDocuments().catchError((e) => print(e));
    if (querySnapshot.documents.isNotEmpty) {
      lastVirtualEventDocSnap = querySnapshot.documents[querySnapshot.documents.length - 1];
      virtualEventResults = querySnapshot.documents;
    }
    //isLoading = false;
    setState(() {});
  }

  getSavedEvents() async {
    Query eventsQuery;
    eventsQuery = eventsRef
        .where('d.savedBy', arrayContains: widget.currentUser.uid)
        .where("d.startDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
        .orderBy('d.startDateTimeInMilliseconds', descending: false)
        .limit(resultsPerPage);
    QuerySnapshot querySnapshot = await eventsQuery.getDocuments().catchError((e) => print(e));
    if (querySnapshot.documents.isNotEmpty) {
      lastSavedEventDocSnap = querySnapshot.documents[querySnapshot.documents.length - 1];
      savedEventResults = querySnapshot.documents;
    }
    //isLoading = false;
    setState(() {});
  }

//  getFollowedEvents() async {
//    Query eventsQuery = eventsRef
//        .where("d.startDateTimeInMilliseconds", isGreaterThan: DateTime.now().millisecondsSinceEpoch - 3)
//        .orderBy('d.startDateTimeInMilliseconds', descending: true)
//        .limit(resultsPerPage);
//    QuerySnapshot querySnapshot = await eventsQuery.getDocuments().catchError((e) => print(e));
//    if (querySnapshot.documents.isNotEmpty) {
//      lastFollowingEventDocSnap = querySnapshot.documents[querySnapshot.documents.length - 1];
//      followingEventsResults = querySnapshot.documents;
//    }
//    //isLoading = false;
//    setState(() {});
//  }

  getAdditionalLiveEvents() async {
    if (isLoading || !moreLiveEventsAvailable || loadingAdditionalLiveEvents) {
      return;
    }
    loadingAdditionalLiveEvents = true;
    setState(() {});
    Query eventsQuery;
    if (eventCategoryFilter == "None" && eventTypeFilter == "None") {
      eventsQuery = eventsRef
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
          .where("d.startDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastLiveEventDocSnap)
          .limit(resultsPerPage);
    } else if (eventCategoryFilter == "None" && eventTypeFilter != "None") {
      eventsQuery = eventsRef
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
          .where("d.startDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .where('d.type', isEqualTo: eventTypeFilter)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastLiveEventDocSnap)
          .limit(resultsPerPage);
    } else if (eventCategoryFilter != "None" && eventTypeFilter == "None") {
      eventsQuery = eventsRef
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
          .where("d.startDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .where('d.category', isEqualTo: eventCategoryFilter)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastLiveEventDocSnap)
          .limit(resultsPerPage);
    } else {
      eventsQuery = eventsRef
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
          .where("d.startDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .where('d.type', isEqualTo: eventTypeFilter)
          .where('d.category', isEqualTo: eventCategoryFilter)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastLiveEventDocSnap)
          .limit(resultsPerPage);
    }

    QuerySnapshot querySnapshot = await eventsQuery.getDocuments().catchError((e) => print(e));
    lastLiveEventDocSnap = querySnapshot.documents[querySnapshot.documents.length - 1];
    liveEventResults.addAll(querySnapshot.documents);
    if (querySnapshot.documents.length == 0) {
      moreLiveEventsAvailable = false;
    }
    loadingAdditionalLiveEvents = false;
    setState(() {});
  }

  getAdditionalVirtualEvents() async {
    if (isLoading || !moreVirtualEventsAvailable || loadingAdditionalVirtualEvents) {
      return;
    }
    loadingAdditionalVirtualEvents = true;
    setState(() {});
    Query eventsQuery;
    if (eventCategoryFilter == "None" && eventTypeFilter == "None") {
      eventsQuery = eventsRef
          .where('d.isDigitalEvent', isEqualTo: true)
          .where("d.startDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastVirtualEventDocSnap)
          .limit(resultsPerPage);
    } else if (eventCategoryFilter == "None" && eventTypeFilter != "None") {
      eventsQuery = eventsRef
          .where('d.isDigitalEvent', isEqualTo: true)
          .where('d.type', isEqualTo: eventTypeFilter)
          .where("d.startDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastVirtualEventDocSnap)
          .limit(resultsPerPage);
    } else if (eventCategoryFilter != "None" && eventTypeFilter == "None") {
      eventsQuery = eventsRef
          .where('d.isDigitalEvent', isEqualTo: true)
          .where('d.category', isEqualTo: eventCategoryFilter)
          .where("d.startDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastVirtualEventDocSnap)
          .limit(resultsPerPage);
    } else {
      eventsQuery = eventsRef
          .where('d.isDigitalEvent', isEqualTo: true)
          .where('d.type', isEqualTo: eventTypeFilter)
          .where('d.category', isEqualTo: eventCategoryFilter)
          .where("d.startDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastVirtualEventDocSnap)
          .limit(resultsPerPage);
    }

    QuerySnapshot querySnapshot = await eventsQuery.getDocuments().catchError((e) => print(e));
    lastVirtualEventDocSnap = querySnapshot.documents[querySnapshot.documents.length - 1];
    virtualEventResults.addAll(querySnapshot.documents);
    if (querySnapshot.documents.length == 0) {
      moreVirtualEventsAvailable = false;
    }
    loadingAdditionalVirtualEvents = false;
    setState(() {});
  }

  getAdditionalSavedEvents() async {
    if (isLoading || !moreSavedEventsAvailable || loadingAdditionalSavedEvents) {
      return;
    }
    loadingAdditionalSavedEvents = true;
    setState(() {});
    Query eventsQuery = eventsRef
        .where("d.savedBy", isEqualTo: widget.currentUser.uid)
        .where("d.startDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
        .orderBy('d.startDateTimeInMilliseconds', descending: false)
        .startAfterDocument(lastSavedEventDocSnap)
        .limit(resultsPerPage);

    QuerySnapshot querySnapshot = await eventsQuery.getDocuments().catchError((e) => print(e));
    lastSavedEventDocSnap = querySnapshot.documents[querySnapshot.documents.length - 1];
    savedEventResults.addAll(querySnapshot.documents);
    if (querySnapshot.documents.length == 0) {
      moreSavedEventsAvailable = false;
    }
    loadingAdditionalSavedEvents = false;
    setState(() {});
  }

//  getAdditionalMyEvents() async {
//    if (isLoading || !moreFollowingEventsAvailable || loadingAdditionalFollowingEvents) {
//      return;
//    }
//    loadingAdditionalFollowingEvents = true;
//    setState(() {});
//    Query eventsQuery = eventsRef
//        .where("d.authorID", isEqualTo: widget.currentUser.uid)
//        .orderBy('d.startDateTimeInMilliseconds', descending: true)
//        .startAfterDocument(lastFollowingEventDocSnap)
//        .limit(resultsPerPage);
//
//    QuerySnapshot querySnapshot = await eventsQuery.getDocuments().catchError((e) => print(e));
//    lastMyEventDocSnap = querySnapshot.documents[querySnapshot.documents.length - 1];
//    myEventResults.addAll(querySnapshot.documents);
//    if (querySnapshot.documents.length == 0) {
//      moreMyEventsAvailable = false;
//    }
//    loadingAdditionalMyEvents = false;
//    setState(() {});
//  }

  Future<void> refreshData() async {
    liveEventResults = [];
    virtualEventResults = [];
    savedEventResults = [];
    getLiveEvents();
    getVirtualEvents();
    getSavedEvents();
  }

  Future<void> refreshFromPreferences() async {
    Navigator.of(context).pop();
    isLoading = true;
    setState(() {});
    liveEventResults = [];
    virtualEventResults = [];
    getLiveEvents();
    getVirtualEvents();
  }

  showEventPreferenceDialog() {
    Widget widget = Container(
      height: 325.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomText(
            context: context,
            text: "Event Preferences",
            textColor: Colors.black,
            textAlign: TextAlign.center,
            fontSize: 24.0,
            fontWeight: FontWeight.w700,
          ),
          SizedBox(height: 16.0),
          CustomText(
            context: context,
            text: "Location:",
            textColor: Colors.black,
            textAlign: TextAlign.left,
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
          ),
          SizedBox(height: 4.0),
          GestureDetector(
            onTap: null,
            child: TextFieldContainer(
              height: 30.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomText(
                    context: context,
                    text: "$areaName",
                    textColor: Colors.black,
                    textAlign: TextAlign.left,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.0),
          CustomText(
            context: context,
            text: "Category:",
            textColor: Colors.black,
            textAlign: TextAlign.left,
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
          ),
          SizedBox(height: 4.0),
          TextFieldContainer(
            height: 35,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 6,
              ),
              child: DropdownButton(
                  style: TextStyle(fontSize: 12.0, color: Colors.black),
                  isExpanded: true,
                  underline: Container(),
                  value: eventCategoryFilter,
                  items: Strings.eventCategoryFilters.map((String val) {
                    return DropdownMenuItem<String>(
                      value: val,
                      child: Text(val),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      eventCategoryFilter = val;
                    });
                    Navigator.of(context).pop();
                    showEventPreferenceDialog();
                  }),
            ),
          ),
          SizedBox(height: 16.0),
          CustomText(
            context: context,
            text: "Type:",
            textColor: Colors.black,
            textAlign: TextAlign.left,
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
          ),
          SizedBox(height: 4.0),
          TextFieldContainer(
            height: 35,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 6,
              ),
              child: DropdownButton(
                  style: TextStyle(fontSize: 12.0, color: Colors.black),
                  isExpanded: true,
                  underline: Container(),
                  value: eventTypeFilter,
                  items: Strings.eventTypeFilters.map((String val) {
                    return DropdownMenuItem<String>(
                      value: val,
                      child: Text(val),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      eventTypeFilter = val;
                    });
                    Navigator.of(context).pop();
                    showEventPreferenceDialog();
                  }),
            ),
          ),
          SizedBox(height: 16.0),
          CustomColorButton(
            text: "Apply",
            textColor: Colors.white,
            backgroundColor: CustomColors.darkMountainGreen,
            height: 45.0,
            width: 200.0,
            onPressed: () => refreshFromPreferences(),
          ),
        ],
      ),
    );
    ShowAlertDialogService().showFormDialog(context, widget);
  }

  Widget listLiveEvents() {
    return ListView.builder(
      controller: liveEventsScrollController,
      key: UniqueKey(),
      shrinkWrap: true,
      itemCount: liveEventResults.length,
      itemBuilder: (context, index) {
        WebblenEvent event = WebblenEvent.fromMap(Map<String, dynamic>.from(liveEventResults[index].data['d']));
        double num = index / 15;
        print(num == num.roundToDouble() && num != 0);
        if (num == num.roundToDouble() && num != 0) {
          return Padding(
            padding: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: liveEventResults.length - 1 == index ? 16.0 : 0),
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
                    currentUID: widget.currentUser.uid,
                    event: event,
                    shareEvent: () => Share.share("https://app.webblen.io/#/event?id=${event.id}"),
                    viewEventDetails: () => PageTransitionService(context: context, currentUser: widget.currentUser, eventID: event.id).transitionToEventPage(),
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
            padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: liveEventResults.length - 1 == index ? 16.0 : 0),
            child: EventBlock(
              currentUID: widget.currentUser.uid,
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
    );
  }

  Widget listVirtualEvents() {
    return ListView.builder(
      controller: virtualEventsScrollController,
      key: UniqueKey(),
      shrinkWrap: true,
      itemCount: virtualEventResults.length,
      itemBuilder: (context, index) {
        WebblenEvent event = WebblenEvent.fromMap(Map<String, dynamic>.from(virtualEventResults[index].data['d']));
        double num = index / 15;
        print(num == num.roundToDouble() && num != 0);
        if (num == num.roundToDouble() && num != 0) {
          return Padding(
            padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: virtualEventResults.length - 1 == index ? 16.0 : 0),
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
                    currentUID: widget.currentUser.uid,
                    event: event,
                    shareEvent: () => Share.share("https://app.webblen.io/#/event?id=${event.id}"),
                    viewEventDetails: () => PageTransitionService(context: context, currentUser: widget.currentUser, eventID: event.id).transitionToEventPage(),
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
            padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: virtualEventResults.length - 1 == index ? 16.0 : 0),
            child: EventBlock(
              currentUID: widget.currentUser.uid,
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
    );
  }

  Widget listSavedEvents() {
    return ListView.builder(
      controller: savedEventsScrollController,
      key: UniqueKey(),
      shrinkWrap: true,
      itemCount: savedEventResults.length,
      itemBuilder: (context, index) {
        WebblenEvent event = WebblenEvent.fromMap(Map<String, dynamic>.from(savedEventResults[index].data['d']));
        return Padding(
          padding: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: savedEventResults.length - 1 == index ? 16.0 : 0),
          child: EventBlock(
            currentUID: widget.currentUser.uid,
            event: event,
            shareEvent: () => Share.share("https://app.webblen.io/#/event?id=${event.id}"),
            viewEventDetails: () => PageTransitionService(context: context, currentUser: widget.currentUser, eventID: event.id).transitionToEventPage(),
            viewEventTickets: null,
            numOfTicsForEvent: null,
            eventImgSize: MediaQuery.of(context).size.width - 16,
            eventDescHeight: 120.0,
          ),
        );
      },
    );
  }

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

//  Widget listMyEvents() {
//    return LiquidPullToRefresh(
//      color: CustomColors.webblenRed,
//      onRefresh: refreshData,
//      child: ListView.builder(
//        controller: myEventsScrollController,
//        key: UniqueKey(),
//        shrinkWrap: true,
//        itemCount: myEventResults.length,
//        itemBuilder: (context, index) {
//          WebblenEvent event = WebblenEvent.fromMap(Map<String, dynamic>.from(myEventResults[index].data['d']));
//          return Padding(
//            padding: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: myEventResults.length - 1 == index ? 16.0 : 0),
//            child: EventBlock(
//              event: event,
//              shareEvent: () => Share.share("https://app.webblen.io/#/event?id=${event.id}"),
//              viewEventDetails: () => PageTransitionService(context: context, currentUser: widget.currentUser, eventID: event.id).transitionToEventPage(),
//              viewEventTickets: null,
//              numOfTicsForEvent: null,
//              eventImgSize: MediaQuery.of(context).size.width - 16,
//              eventDescHeight: 120.0,
//            ),
//          );
//        },
//      ),
//    );
//  }

  @override
  void initState() {
    super.initState();
    //loadData();
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
    liveEventsScrollController = ScrollController();
    virtualEventsScrollController = ScrollController();
    savedEventsScrollController = ScrollController();
    liveEventsScrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * liveEventsScrollController.position.maxScrollExtent;
      if (liveEventsScrollController.position.pixels > triggerFetchMoreSize) {
        getAdditionalLiveEvents();
      }
    });
    virtualEventsScrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * virtualEventsScrollController.position.maxScrollExtent;
      if (virtualEventsScrollController.position.pixels > triggerFetchMoreSize) {
        getAdditionalVirtualEvents();
      }
    });
    savedEventsScrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * savedEventsScrollController.position.maxScrollExtent;
      if (savedEventsScrollController.position.pixels > triggerFetchMoreSize) {
        getAdditionalSavedEvents();
      }
    });
//    followingEventsScrollController.addListener(() {
//      double triggerFetchMoreSize = 0.9 * followingEventsScrollController.position.maxScrollExtent;
//      if (followingEventsScrollController.position.pixels > triggerFetchMoreSize) {
//        getAdditionalMyEvents();
//      }
//    });
    LocationService().getZipFromLatLon(widget.currentLat, widget.currentLon).then((res) {
      areaCodeFilter = res;
      getSavedEvents();
//      getMyEvents();
      getVirtualEvents();
      getLiveEvents();
    });
  }

  @override
  void dispose() {
    super.dispose();
    liveEventsScrollController.dispose();
    virtualEventsScrollController.dispose();
    savedEventsScrollController.dispose();
//    followingEventsScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MediaQuery(
                        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                        child: widget.areaName.length <= 6
                            ? Fonts().textW700(
                                widget.areaName,
                                40,
                                Colors.black,
                                TextAlign.left,
                              )
                            : widget.areaName.length <= 8
                                ? Fonts().textW700(
                                    widget.areaName,
                                    35,
                                    Colors.black,
                                    TextAlign.left,
                                  )
                                : widget.areaName.length <= 10
                                    ? Fonts().textW700(
                                        widget.areaName,
                                        30,
                                        Colors.black,
                                        TextAlign.left,
                                      )
                                    : widget.areaName.length <= 12
                                        ? Fonts().textW700(
                                            widget.areaName,
                                            25,
                                            Colors.black,
                                            TextAlign.left,
                                          )
                                        : Fonts().textW700(
                                            widget.areaName,
                                            20,
                                            Colors.black,
                                            TextAlign.left,
                                          ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
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
                            GestureDetector(
                              onTap: () => showEventPreferenceDialog(),
                              child: Icon(
                                FontAwesomeIcons.slidersH,
                                size: 20.0,
                                color: Colors.black,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => PageTransitionService(
                                context: context,
                                currentUser: widget.currentUser,
                              ).transitionToSearchPage(),
                              child: Icon(
                                FontAwesomeIcons.search,
                                size: 20.0,
                                color: Colors.black,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => showNewEventOrStreamDialog(),
                              child: Icon(
                                FontAwesomeIcons.plus,
                                size: 20.0,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TabBar(
                  controller: _tabController,
                  indicatorColor: CustomColors.webblenRed,
                  labelColor: CustomColors.darkGray,
                  isScrollable: true,
                  tabs: [
                    Tab(
                      child: CustomText(
                        context: context,
                        text: "Events",
                        textColor: Colors.black,
                        textAlign: TextAlign.center,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Tab(
                      child: CustomText(
                        context: context,
                        text: "Streams",
                        textColor: Colors.black,
                        textAlign: TextAlign.center,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Tab(
                      child: CustomText(
                        context: context,
                        text: "Saved",
                        textColor: Colors.black,
                        textAlign: TextAlign.center,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: LiquidPullToRefresh(
              onRefresh: refreshData,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: DefaultTabController(
                  length: 3,
                  child: TabBarView(
                    controller: _tabController,
                    children: <Widget>[
                      //LIVE EVENTS
                      Container(
                        key: PageStorageKey('key0'),
                        color: Colors.white,
                        child: isLoading
                            ? LoadingScreen(
                                context: context,
                                loadingDescription: 'Loading Live Events...',
                              )
                            : liveEventResults.isEmpty
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
                                              text: "We Could Not Find Any Live Events According to Your Preferences",
                                              textColor: Colors.black,
                                              textAlign: TextAlign.center,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 8.0),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: () => showEventPreferenceDialog(),
                                            child: CustomText(
                                              context: context,
                                              text: "Change My Preferences",
                                              textColor: Colors.blueAccent,
                                              textAlign: TextAlign.center,
                                              underline: false,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : listLiveEvents(),
                      ),
                      //VIRTUAL EVENTS
                      Container(
                        key: PageStorageKey('key1'),
                        color: Colors.white,
                        child: isLoading
                            ? LoadingScreen(
                                context: context,
                                loadingDescription: 'Loading Virtual Events...',
                              )
                            : virtualEventResults.isEmpty
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
                                              text: "We Could Not Find Any Virtual Events According to Your Preferences",
                                              textColor: Colors.black,
                                              textAlign: TextAlign.center,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 8.0),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: () => showEventPreferenceDialog(),
                                            child: CustomText(
                                              context: context,
                                              text: "Change My Preferences",
                                              textColor: Colors.blueAccent,
                                              textAlign: TextAlign.center,
                                              underline: false,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : listVirtualEvents(),
                      ),
                      //SAVED EVENTS
                      Container(
                        key: PageStorageKey('key2'),
                        color: Colors.white,
                        child: isLoading
                            ? LoadingScreen(
                                context: context,
                                loadingDescription: 'Loading Saved Events...',
                              )
                            : savedEventResults.isEmpty
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
                                              text: "You Do Not Have Any Upcoming Events Saved",
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
                                : listSavedEvents(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
