import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
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
import 'package:webblen/widgets/widgets_home_tiles/all_tiles.dart';

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
  ScrollController myEventsScrollController;
  int resultsPerPage = 10;
  //Filter
  String areaName = "My Current Location";
  String areaCodeFilter;
  String eventTypeFilter = "None";
  String eventCategoryFilter = "None";
  //Event Results
  CollectionReference eventsRef = Firestore.instance.collection("events");
  List<DocumentSnapshot> liveEventResults = [];
  List<DocumentSnapshot> virtualEventResults = [];
  List<DocumentSnapshot> savedEventResults = [];
  List<DocumentSnapshot> myEventResults = [];
  DocumentSnapshot lastLiveEventDocSnap;
  DocumentSnapshot lastVirtualEventDocSnap;
  DocumentSnapshot lastSavedEventDocSnap;
  DocumentSnapshot lastMyEventDocSnap;
  bool loadingAdditionalLiveEvents = false;
  bool moreLiveEventsAvailable = true;
  bool loadingAdditionalVirtualEvents = false;
  bool moreVirtualEventsAvailable = true;
  bool loadingAdditionalSavedEvents = false;
  bool moreSavedEventsAvailable = true;
  bool loadingAdditionalMyEvents = false;
  bool moreMyEventsAvailable = true;

  //ADMOB
  AdmobBannerSize bannerSize;
  String adMobUnitID;
  final nativeAdController = NativeAdmobController();

  getLiveEvents() async {
    Query eventsQuery;
    if (eventCategoryFilter == "None" && eventTypeFilter == "None") {
      eventsQuery =
          eventsRef.where('d.nearbyZipcodes', arrayContains: areaCodeFilter).orderBy('d.startDateTimeInMilliseconds', descending: false).limit(resultsPerPage);
    } else if (eventCategoryFilter == "None" && eventTypeFilter != "None") {
      print(eventTypeFilter);
      eventsQuery = eventsRef
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
          .where('d.type', isEqualTo: eventTypeFilter)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .limit(resultsPerPage);
    } else if (eventCategoryFilter != "None" && eventTypeFilter == "None") {
      eventsQuery = eventsRef
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
          .where('d.category', isEqualTo: eventCategoryFilter)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .limit(resultsPerPage);
    } else {
      eventsQuery = eventsRef
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
          .where('d.type', isEqualTo: eventTypeFilter)
          .where('d.category', isEqualTo: eventCategoryFilter)
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
      eventsQuery = eventsRef.where('d.isDigitalEvent', isEqualTo: true).orderBy('d.startDateTimeInMilliseconds', descending: false).limit(resultsPerPage);
    } else if (eventCategoryFilter == "None" && eventTypeFilter != "None") {
      print(eventTypeFilter);
      eventsQuery = eventsRef
          .where('d.isDigitalEvent', isEqualTo: true)
          .where('d.type', isEqualTo: eventTypeFilter)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .limit(resultsPerPage);
    } else if (eventCategoryFilter != "None" && eventTypeFilter == "None") {
      eventsQuery = eventsRef
          .where('d.isDigitalEvent', isEqualTo: true)
          .where('d.category', isEqualTo: eventCategoryFilter)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .limit(resultsPerPage);
    } else {
      eventsQuery = eventsRef
          .where('d.isDigitalEvent', isEqualTo: true)
          .where('d.type', isEqualTo: eventTypeFilter)
          .where('d.category', isEqualTo: eventCategoryFilter)
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
    eventsQuery =
        eventsRef.where('d.savedBy', arrayContains: widget.currentUser.uid).orderBy('d.startDateTimeInMilliseconds', descending: false).limit(resultsPerPage);
    QuerySnapshot querySnapshot = await eventsQuery.getDocuments().catchError((e) => print(e));
    if (querySnapshot.documents.isNotEmpty) {
      lastSavedEventDocSnap = querySnapshot.documents[querySnapshot.documents.length - 1];
      savedEventResults = querySnapshot.documents;
    }
    //isLoading = false;
    setState(() {});
  }

  getMyEvents() async {
    Query eventsQuery =
        eventsRef.where("d.authorID", isEqualTo: widget.currentUser.uid).orderBy('d.startDateTimeInMilliseconds', descending: false).limit(resultsPerPage);
    QuerySnapshot querySnapshot = await eventsQuery.getDocuments().catchError((e) => print(e));
    if (querySnapshot.documents.isNotEmpty) {
      lastMyEventDocSnap = querySnapshot.documents[querySnapshot.documents.length - 1];
      myEventResults = querySnapshot.documents;
    }
    //isLoading = false;
    setState(() {});
  }

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
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastLiveEventDocSnap)
          .limit(resultsPerPage);
    } else if (eventCategoryFilter == "None" && eventTypeFilter != "None") {
      eventsQuery = eventsRef
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
          .where('d.type', isEqualTo: eventTypeFilter)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastLiveEventDocSnap)
          .limit(resultsPerPage);
    } else if (eventCategoryFilter != "None" && eventTypeFilter == "None") {
      eventsQuery = eventsRef
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
          .where('d.category', isEqualTo: eventCategoryFilter)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastLiveEventDocSnap)
          .limit(resultsPerPage);
    } else {
      eventsQuery = eventsRef
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
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
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastVirtualEventDocSnap)
          .limit(resultsPerPage);
    } else if (eventCategoryFilter == "None" && eventTypeFilter != "None") {
      eventsQuery = eventsRef
          .where('d.isDigitalEvent', isEqualTo: true)
          .where('d.type', isEqualTo: eventTypeFilter)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastVirtualEventDocSnap)
          .limit(resultsPerPage);
    } else if (eventCategoryFilter != "None" && eventTypeFilter == "None") {
      eventsQuery = eventsRef
          .where('d.isDigitalEvent', isEqualTo: true)
          .where('d.category', isEqualTo: eventCategoryFilter)
          .orderBy('d.startDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastVirtualEventDocSnap)
          .limit(resultsPerPage);
    } else {
      eventsQuery = eventsRef
          .where('d.isDigitalEvent', isEqualTo: true)
          .where('d.type', isEqualTo: eventTypeFilter)
          .where('d.category', isEqualTo: eventCategoryFilter)
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
        .orderBy('d.startDateTimeInMilliseconds', descending: false)
        .startAfterDocument(lastMyEventDocSnap)
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

  getAdditionalMyEvents() async {
    if (isLoading || !moreMyEventsAvailable || loadingAdditionalMyEvents) {
      return;
    }
    loadingAdditionalMyEvents = true;
    setState(() {});
    Query eventsQuery = eventsRef
        .where("d.authorID", isEqualTo: widget.currentUser.uid)
        .orderBy('d.startDateTimeInMilliseconds', descending: false)
        .startAfterDocument(lastMyEventDocSnap)
        .limit(resultsPerPage);

    QuerySnapshot querySnapshot = await eventsQuery.getDocuments().catchError((e) => print(e));
    lastMyEventDocSnap = querySnapshot.documents[querySnapshot.documents.length - 1];
    myEventResults.addAll(querySnapshot.documents);
    if (querySnapshot.documents.length == 0) {
      moreMyEventsAvailable = false;
    }
    loadingAdditionalMyEvents = false;
    setState(() {});
  }

  Future<void> refreshData() async {
    liveEventResults = [];
    virtualEventResults = [];
    savedEventResults = [];
    myEventResults = [];
    getLiveEvents();
    getVirtualEvents();
    getSavedEvents();
    getMyEvents();
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
    return LiquidPullToRefresh(
      color: CustomColors.webblenRed,
      onRefresh: refreshData,
      child: ListView.builder(
        controller: liveEventsScrollController,
        key: UniqueKey(),
        shrinkWrap: true,
        padding: EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
        ),
        itemCount: liveEventResults.length,
        itemBuilder: (context, index) {
          WebblenEvent event = WebblenEvent.fromMap(Map<String, dynamic>.from(liveEventResults[index].data['d']));
          double num = index / 3;
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
              padding: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: liveEventResults.length - 1 == index ? 16.0 : 0),
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

  Widget listVirtualEvents() {
    return LiquidPullToRefresh(
      color: CustomColors.webblenRed,
      onRefresh: refreshData,
      child: ListView.builder(
        controller: virtualEventsScrollController,
        key: UniqueKey(),
        shrinkWrap: true,
        padding: EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
        ),
        itemCount: virtualEventResults.length,
        itemBuilder: (context, index) {
          WebblenEvent event = WebblenEvent.fromMap(Map<String, dynamic>.from(virtualEventResults[index].data['d']));
          double num = index / 3;
          print(num == num.roundToDouble() && num != 0);
          if (num == num.roundToDouble() && num != 0) {
            return Padding(
              padding: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: virtualEventResults.length - 1 == index ? 16.0 : 0),
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
              padding: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: virtualEventResults.length - 1 == index ? 16.0 : 0),
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

  Widget listSavedEvents() {
    return LiquidPullToRefresh(
      color: CustomColors.webblenRed,
      onRefresh: refreshData,
      child: ListView.builder(
        controller: savedEventsScrollController,
        key: UniqueKey(),
        shrinkWrap: true,
        padding: EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
        ),
        itemCount: savedEventResults.length,
        itemBuilder: (context, index) {
          WebblenEvent event = WebblenEvent.fromMap(Map<String, dynamic>.from(savedEventResults[index].data['d']));
          return Padding(
            padding: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: savedEventResults.length - 1 == index ? 16.0 : 0),
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
        },
      ),
    );
  }

  Widget listMyEvents() {
    return LiquidPullToRefresh(
      color: CustomColors.webblenRed,
      onRefresh: refreshData,
      child: ListView.builder(
        controller: myEventsScrollController,
        key: UniqueKey(),
        shrinkWrap: true,
        padding: EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
        ),
        itemCount: myEventResults.length,
        itemBuilder: (context, index) {
          WebblenEvent event = WebblenEvent.fromMap(Map<String, dynamic>.from(myEventResults[index].data['d']));
          return Padding(
            padding: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: myEventResults.length - 1 == index ? 16.0 : 0),
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
        },
      ),
    );
  }

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
      length: 4,
      vsync: this,
    );
    liveEventsScrollController = ScrollController();
    virtualEventsScrollController = ScrollController();
    savedEventsScrollController = ScrollController();
    myEventsScrollController = ScrollController();
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
    myEventsScrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * myEventsScrollController.position.maxScrollExtent;
      if (myEventsScrollController.position.pixels > triggerFetchMoreSize) {
        getAdditionalMyEvents();
      }
    });
    LocationService().getZipFromLatLon(widget.currentLat, widget.currentLon).then((res) {
      areaCodeFilter = res;
      getSavedEvents();
      getMyEvents();
      getVirtualEvents();
      getLiveEvents();
    });
//    if (Platform.isIOS) {
//      Admob.initialize('ca-app-pub-2136415475966451~5144610810');
//    } else if (Platform.isAndroid) {
//      Admob.initialize('ca-app-pub-2136415475966451~9434499178');
//    }
//    bannerSize = AdmobBannerSize.BANNER;
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
                  flex: 1,
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
                              ).transitionToCreateEventPage(),
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
          GestureDetector(
            onTap: () => PageTransitionService(
              context: context,
              currentUser: widget.currentUser,
              areaName: widget.areaName,
            ).transitionToSearchPage(),
            child: SearchTile(),
          ),
          Container(
            child: TabBar(
              controller: _tabController,
              indicatorColor: CustomColors.webblenRed,
              labelColor: CustomColors.darkGray,
              isScrollable: true,
              tabs: [
                Tab(
                  child: CustomText(
                    context: context,
                    text: "Live Events",
                    textColor: Colors.black,
                    textAlign: TextAlign.center,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Tab(
                  child: CustomText(
                    context: context,
                    text: "Virtual Events",
                    textColor: Colors.black,
                    textAlign: TextAlign.center,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Tab(
                  child: CustomText(
                    context: context,
                    text: "Saved Events",
                    textColor: Colors.black,
                    textAlign: TextAlign.center,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Tab(
                  child: CustomText(
                    context: context,
                    text: "My Events",
                    textColor: Colors.black,
                    textAlign: TextAlign.center,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height > 667.0
                ? MediaQuery.of(context).size.height * 0.696
                : MediaQuery.of(context).size.height > 568.0 ? MediaQuery.of(context).size.height * 0.67 : MediaQuery.of(context).size.height * 0.60,
            width: MediaQuery.of(context).size.width,
            child: DefaultTabController(
              length: 4,
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
                  //MY EVENTS
                  Container(
                    key: PageStorageKey('key3'),
                    color: Colors.white,
                    child: isLoading
                        ? LoadingScreen(
                            context: context,
                            loadingDescription: 'Loading Events...',
                          )
                        : myEventResults.isEmpty
                            ? Column(
                                children: <Widget>[
                                  SizedBox(height: 32.0),
                                  CustomText(
                                    context: context,
                                    text: "You Have Not Made Any Events",
                                    textColor: Colors.black,
                                    textAlign: TextAlign.center,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  SizedBox(height: 8.0),
                                  GestureDetector(
                                    onTap: () => PageTransitionService(
                                      context: context,
                                    ).transitionToCreateEventPage(),
                                    child: CustomText(
                                      context: context,
                                      text: "Create an Event",
                                      textColor: Colors.blueAccent,
                                      textAlign: TextAlign.center,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              )
                            : listMyEvents(),
                  ),
                ],
              ),
            ),
          ),
//          isLoading
//              ? Column(
//                  children: <Widget>[
//                    Padding(
//                      padding: EdgeInsets.only(
//                        top: 8.0,
//                      ),
//                      child: CustomLinearProgress(
//                        progressBarColor: FlatColors.webblenRed,
//                      ),
//                    ),
//                  ],
//                )
//              : Container(
//                  height: MediaQuery.of(context).size.height > 667.0
//                      ? MediaQuery.of(context).size.height * 0.715
//                      : MediaQuery.of(context).size.height > 568.0 ? MediaQuery.of(context).size.height * 0.67 : MediaQuery.of(context).size.height * 0.60,
//                  child: Column(
//                    mainAxisAlignment: MainAxisAlignment.spaceAround,
//                    children: <Widget>[
//                      Padding(
//                        padding: EdgeInsets.symmetric(
//                          vertical: 2.0,
//                          horizontal: 16.0,
//                        ),
//                        child: Row(
//                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                          children: <Widget>[
//                            EventsTile(
//                              onTap: () => didPressEventsTile(),
//                            ),
//                          ],
//                        ),
//                      ),
//                      Padding(
//                        padding: EdgeInsets.symmetric(
//                          vertical: 2.0,
//                          horizontal: 16.0,
//                        ),
//                        child: Row(
//                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                          children: <Widget>[
//                            CommunitiesTile(
//                              onTap: () => didPressDigitalEventsTile(),
//                            ),
//                          ],
//                        ),
//                      ),
//                      Padding(
//                        padding: EdgeInsets.symmetric(
//                          horizontal: 16.0,
//                        ),
//                        child: Row(
//                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                          children: <Widget>[
//                            CalendarTile(
//                              onTap: () => didPressCalendarTile(),
//                            ),
//                            CommunityRequestTile(
//                              onTap: () => didPressCommunityRequestTile(),
//                            ),
//                          ],
//                        ),
//                      ),
//                      Container(
//                        //margin: EdgeInsets.only(top: 8.0),
//                        child: AdmobBanner(
//                          adUnitId: Strings().getAdMobBannerID(),
//                          adSize: bannerSize,
//                          listener: (AdmobAdEvent event, Map<String, dynamic> args) {},
//                        ),
//                      ),
//                    ],
//                  ),
//                ),
        ],
      ),
    );
  }
}
