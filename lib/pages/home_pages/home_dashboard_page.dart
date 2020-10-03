import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:share/share.dart';
import 'package:video_player/video_player.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/constants/strings.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/utils/time.dart';
import 'package:webblen/widgets/common/alerts/custom_alerts.dart';
import 'package:webblen/widgets/common/buttons/custom_color_button.dart';
import 'package:webblen/widgets/common/containers/text_field_container.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';
import 'package:webblen/widgets/events/event_block.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';

import 'video_play_page.dart';

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
  List<VideoPlayerController> videoControllers = [];
  bool isLoading = true;

  //Scroller & Paging
  final PageStorageBucket bucket = PageStorageBucket();
  TabController _tabController;
  ScrollController recordedStreamsScrollController;
  ScrollController liveEventsScrollController;
  ScrollController virtualEventsScrollController;
  ScrollController savedEventsScrollController;
  int resultsPerPage = 15;

  //Filter
  String areaName = "My Current Location";
  String areaCodeFilter;
  String eventTypeFilter = "None";
  String eventCategoryFilter = "None";

  //Event Results
  int dateTimeInMilliseconds2hoursAgo = DateTime.now().millisecondsSinceEpoch - 7400000;
  CollectionReference eventsRef = FirebaseFirestore.instance.collection("events");
  CollectionReference recordedStreamsRef = FirebaseFirestore.instance.collection("recorded_streams");
  List<DocumentSnapshot> recordedStreamResults = [];
  List<DocumentSnapshot> liveEventResults = [];
  List<DocumentSnapshot> virtualEventResults = [];
  List<DocumentSnapshot> savedEventResults = [];
  List<DocumentSnapshot> followingEventsResults = [];
  DocumentSnapshot lastLiveEventDocSnap;
  DocumentSnapshot lastVirtualEventDocSnap;
  DocumentSnapshot lastSavedEventDocSnap;
  bool loadingAdditionalLiveEvents = false;
  bool moreLiveEventsAvailable = true;
  bool loadingAdditionalVirtualEvents = false;
  bool moreVirtualEventsAvailable = true;
  bool loadingAdditionalSavedEvents = false;
  bool moreSavedEventsAvailable = true;

  //ADMOB
  String adMobUnitID;
  final nativeAdController = NativeAdmobController();
  GoogleMapsPlaces _places = GoogleMapsPlaces(
    apiKey: Strings.googleAPIKEY,
  );

  openVideo(String vidURL, String eventID, String authorID) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false, // set to false
        pageBuilder: (_, __, ___) => VideoPlayPage(currentUser: widget.currentUser, vidURL: vidURL, eventID: eventID, authorID: authorID),
      ),
    );

    // PageTransitionService(context: context, vidURL: vidURL).transitionToVideoPlayPage();
//    Widget widget = Container(
//      height: MediaQuery.of(context).size.height - 32,
//      width: MediaQuery.of(context).size.width - 32,
//      child: AspectRatio(
//        aspectRatio: controller.value.aspectRatio,
//        child: Stack(
//          alignment: Alignment.bottomCenter,
//          children: <Widget>[
//            VideoPlayer(controller),
//            _ControlsOverlay(controller: controller),
//            VideoProgressIndicator(controller, allowScrubbing: true),
//          ],
//        ),
//      ),
//    );
//    ShowAlertDialogService().showCustomWidgetDialog(context, widget);
  }

  getRecordedStreams() async {
    QuerySnapshot querySnapshot = await recordedStreamsRef
        .where('showAllUsers', isEqualTo: true)
        .where('expiration', isGreaterThanOrEqualTo: DateTime.now().millisecondsSinceEpoch)
        .get()
        .catchError((e) => print(e));
    if (querySnapshot.docs.isNotEmpty) {
      recordedStreamResults.addAll(querySnapshot.docs);
    }
    querySnapshot = await recordedStreamsRef
        .where('showAllUsers', isEqualTo: false)
        .where('nearbyZipcodes', arrayContains: areaCodeFilter)
        .where('expiration', isGreaterThanOrEqualTo: DateTime.now().millisecondsSinceEpoch)
        .get()
        .catchError((e) => print(e));
    if (querySnapshot.docs.isNotEmpty) {
      recordedStreamResults.addAll(querySnapshot.docs);
    }
    if (recordedStreamResults.isNotEmpty) {
      recordedStreamResults.sort((docA, docB) => docB.data()['expiration'].compareTo(docA.data()['expiration']));
      setState(() {});
    }
  }

  getLiveEvents() async {
    Query eventsQuery;
    if (eventCategoryFilter == "None" && eventTypeFilter == "None") {
      eventsQuery = eventsRef
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
          .where('d.isDigitalEvent', isEqualTo: false)
          .where('d.privacy', isEqualTo: "public")
          .where("d.endDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .orderBy('d.endDateTimeInMilliseconds', descending: false)
          .limit(resultsPerPage);
    } else if (eventCategoryFilter == "None" && eventTypeFilter != "None") {
      eventsQuery = eventsRef
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
          .where('d.type', isEqualTo: eventTypeFilter)
          .where('d.isDigitalEvent', isEqualTo: false)
          .where('d.privacy', isEqualTo: "public")
          .where("d.endDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .orderBy('d.endDateTimeInMilliseconds', descending: false)
          .limit(resultsPerPage);
    } else if (eventCategoryFilter != "None" && eventTypeFilter == "None") {
      eventsQuery = eventsRef
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
          .where('d.category', isEqualTo: eventCategoryFilter)
          .where('d.isDigitalEvent', isEqualTo: false)
          .where('d.privacy', isEqualTo: "public")
          .where("d.endDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .orderBy('d.endDateTimeInMilliseconds', descending: false)
          .limit(resultsPerPage);
    } else {
      eventsQuery = eventsRef
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
          .where('d.type', isEqualTo: eventTypeFilter)
          .where('d.category', isEqualTo: eventCategoryFilter)
          .where('d.isDigitalEvent', isEqualTo: false)
          .where('d.privacy', isEqualTo: "public")
          .where("d.endDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .orderBy('d.endDateTimeInMilliseconds', descending: false)
          .limit(resultsPerPage);
    }
    QuerySnapshot querySnapshot = await eventsQuery.get().catchError((e) => print(e));
    if (querySnapshot.docs.isNotEmpty) {
      lastLiveEventDocSnap = querySnapshot.docs[querySnapshot.docs.length - 1];
      liveEventResults = querySnapshot.docs;
    }
    isLoading = false;
    setState(() {});
  }

  getVirtualEvents() async {
    Query eventsQuery;
    if (eventCategoryFilter == "None" && eventTypeFilter == "None") {
      eventsQuery = eventsRef
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
          .where('d.isDigitalEvent', isEqualTo: true)
          .where('d.privacy', isEqualTo: "public")
          .where("d.endDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .orderBy('d.endDateTimeInMilliseconds', descending: false)
          .limit(resultsPerPage);
    } else if (eventCategoryFilter == "None" && eventTypeFilter != "None") {
      eventsQuery = eventsRef
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
          .where('d.isDigitalEvent', isEqualTo: true)
          .where('d.type', isEqualTo: eventTypeFilter)
          .where('d.privacy', isEqualTo: "public")
          .where("d.endDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .orderBy('d.endDateTimeInMilliseconds', descending: false)
          .limit(resultsPerPage);
    } else if (eventCategoryFilter != "None" && eventTypeFilter == "None") {
      eventsQuery = eventsRef
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
          .where('d.isDigitalEvent', isEqualTo: true)
          .where('d.category', isEqualTo: eventCategoryFilter)
          .where('d.privacy', isEqualTo: "public")
          .where("d.endDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .orderBy('d.endDateTimeInMilliseconds', descending: false)
          .limit(resultsPerPage);
    } else {
      eventsQuery = eventsRef
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
          .where('d.isDigitalEvent', isEqualTo: true)
          .where('d.type', isEqualTo: eventTypeFilter)
          .where('d.category', isEqualTo: eventCategoryFilter)
          .where('d.privacy', isEqualTo: "public")
          .where("d.endDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .orderBy('d.endDateTimeInMilliseconds', descending: false)
          .limit(resultsPerPage);
    }
    QuerySnapshot querySnapshot = await eventsQuery.get().catchError((e) => print(e));
    if (querySnapshot.docs.isNotEmpty) {
      lastVirtualEventDocSnap = querySnapshot.docs[querySnapshot.docs.length - 1];
      virtualEventResults = querySnapshot.docs;
    }
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
          .where('d.isDigitalEvent', isEqualTo: false)
          .where('d.privacy', isEqualTo: "public")
          .where("d.endDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .orderBy('d.endDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastLiveEventDocSnap)
          .limit(resultsPerPage);
    } else if (eventCategoryFilter == "None" && eventTypeFilter != "None") {
      eventsQuery = eventsRef
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
          .where('d.isDigitalEvent', isEqualTo: false)
          .where('d.privacy', isEqualTo: "public")
          .where("d.endDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .where('d.type', isEqualTo: eventTypeFilter)
          .orderBy('d.endDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastLiveEventDocSnap)
          .limit(resultsPerPage);
    } else if (eventCategoryFilter != "None" && eventTypeFilter == "None") {
      eventsQuery = eventsRef
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
          .where('d.category', isEqualTo: eventCategoryFilter)
          .where('d.privacy', isEqualTo: "public")
          .where("d.endDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .orderBy('d.endDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastLiveEventDocSnap)
          .limit(resultsPerPage);
    } else {
      eventsQuery = eventsRef
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
          .where('d.isDigitalEvent', isEqualTo: false)
          .where('d.type', isEqualTo: eventTypeFilter)
          .where('d.category', isEqualTo: eventCategoryFilter)
          .where('d.privacy', isEqualTo: "public")
          .where("d.endDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .orderBy('d.endDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastLiveEventDocSnap)
          .limit(resultsPerPage);
    }

    QuerySnapshot querySnapshot = await eventsQuery.get().catchError((e) => print(e));
    lastLiveEventDocSnap = querySnapshot.docs[querySnapshot.docs.length - 1];
    liveEventResults.addAll(querySnapshot.docs);
    if (querySnapshot.docs.length == 0) {
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
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
          .where('d.isDigitalEvent', isEqualTo: true)
          .where('d.privacy', isEqualTo: "public")
          .where("d.endDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .orderBy('d.endDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastVirtualEventDocSnap)
          .limit(resultsPerPage);
    } else if (eventCategoryFilter == "None" && eventTypeFilter != "None") {
      eventsQuery = eventsRef
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
          .where('d.isDigitalEvent', isEqualTo: true)
          .where('d.type', isEqualTo: eventTypeFilter)
          .where('d.privacy', isEqualTo: "public")
          .where("d.endDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .orderBy('d.endDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastVirtualEventDocSnap)
          .limit(resultsPerPage);
    } else if (eventCategoryFilter != "None" && eventTypeFilter == "None") {
      eventsQuery = eventsRef
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
          .where('d.isDigitalEvent', isEqualTo: true)
          .where('d.category', isEqualTo: eventCategoryFilter)
          .where('d.privacy', isEqualTo: "public")
          .where("d.endDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .orderBy('d.endDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastVirtualEventDocSnap)
          .limit(resultsPerPage);
    } else {
      eventsQuery = eventsRef
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
          .where('d.isDigitalEvent', isEqualTo: true)
          .where('d.type', isEqualTo: eventTypeFilter)
          .where('d.category', isEqualTo: eventCategoryFilter)
          .where('d.privacy', isEqualTo: "public")
          .where("d.endDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .orderBy('d.endDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastVirtualEventDocSnap)
          .limit(resultsPerPage);
    }

    QuerySnapshot querySnapshot = await eventsQuery.get().catchError((e) => print(e));
    lastVirtualEventDocSnap = querySnapshot.docs[querySnapshot.docs.length - 1];
    virtualEventResults.addAll(querySnapshot.docs);
    if (querySnapshot.docs.length == 0) {
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
        .where("d.endDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
        .orderBy('d.endDateTimeInMilliseconds', descending: false)
        .startAfterDocument(lastSavedEventDocSnap)
        .limit(resultsPerPage);

    QuerySnapshot querySnapshot = await eventsQuery.get().catchError((e) => print(e));
    lastSavedEventDocSnap = querySnapshot.docs[querySnapshot.docs.length - 1];
    savedEventResults.addAll(querySnapshot.docs);
    if (querySnapshot.docs.length == 0) {
      moreSavedEventsAvailable = false;
    }
    loadingAdditionalSavedEvents = false;
    setState(() {});
  }

  setNewLocation() async {
    Navigator.of(context).pop();
    Prediction p = await PlacesAutocomplete.show(
      context: context,
      apiKey: Strings.googleAPIKEY,
      onError: (res) {
        print(res.errorMessage);
      },
      //proxyBaseUrl: Strings.proxyMapsURL,
      mode: Mode.overlay,
      language: "en",
      components: [
        Component(
          Component.country,
          "us",
        ),
      ],
    );
    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);
    double lat = detail.result.geometry.location.lat;
    double lon = detail.result.geometry.location.lng;
    CustomAlerts().showLoadingAlert(context, "Setting Location...");
    Map<dynamic, dynamic> locationData = await LocationService().reverseGeocodeLatLon(lat, lon);
    areaCodeFilter = locationData['zipcode'];
    areaName = locationData['city'];
    setState(() {});
    refreshData();
    Navigator.of(context).pop();
    lat = detail.result.geometry.location.lat;
    lon = detail.result.geometry.location.lng;
  }

  Future<void> refreshData() async {
    liveEventResults = [];
    virtualEventResults = [];
    recordedStreamResults = [];
    getRecordedStreams();
    getLiveEvents();
    getVirtualEvents();
    //getSavedEvents();
  }

  Future<void> refreshFromPreferences() async {
    Navigator.of(context).pop();
    isLoading = true;
    setState(() {});
    liveEventResults = [];
    virtualEventResults = [];
    getRecordedStreams();
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
            onTap: () => setNewLocation(),
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
    ShowAlertDialogService().showCustomWidgetDialog(context, widget);
  }

  Widget listRecordedStreams() {
    return Container(
      height: 235,
      decoration: BoxDecoration(
          border: Border(
        bottom: BorderSide(color: Colors.black12, width: 1.0),
      )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Text(
              "What's Happening?",
              style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Text(
              "See What People Are Up to In $areaName",
              style: TextStyle(color: Colors.black45, fontSize: 14, fontWeight: FontWeight.w400),
            ),
          ),
          Container(
            height: 190,
            child: ListView.builder(
              controller: recordedStreamsScrollController,
              physics: AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              key: UniqueKey(),
              shrinkWrap: true,
              padding: EdgeInsets.only(
                top: 4.0,
                bottom: 4.0,
              ),
              itemCount: recordedStreamResults.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: GestureDetector(
                    onTap: () => openVideo(
                      recordedStreamResults[index].data()['downloadURL'],
                      recordedStreamResults[index].data()['eventID'],
                      recordedStreamResults[index].data()['authorID'],
                    ),
                    child: Container(
                      width: 150,
                      height: 190,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 100,
                            width: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: CachedNetworkImageProvider(
                                  recordedStreamResults[index].data()['imageURL'],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            recordedStreamResults[index].data()['title'],
                            style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            Time().getPastTimeFromMilliseconds(recordedStreamResults[index].data()['postedTimeInMilliseconds']),
                            style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget listLiveEvents() {
    return LiquidPullToRefresh(
      color: CustomColors.webblenRed,
      onRefresh: refreshData,
      child: ListView.builder(
        controller: liveEventsScrollController,
        physics: AlwaysScrollableScrollPhysics(),
        key: UniqueKey(),
        shrinkWrap: true,
        padding: EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
        ),
        itemCount: liveEventResults.length,
        itemBuilder: (context, index) {
          WebblenEvent event = WebblenEvent.fromMap(Map<String, dynamic>.from(liveEventResults[index].data()['d']));
          double num = index / 15;
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
                        adUnitID: adMobUnitID, //'ca-app-pub-3940256099942544/3986624511',
                        numberAds: 1,
                        controller: nativeAdController,
                        type: NativeAdmobType.banner,
                      ),
                    ),
                    EventBlock(
                      currentUID: widget.currentUser.uid,
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
      ),
    );
  }

  Widget listVirtualEvents() {
    return LiquidPullToRefresh(
      color: CustomColors.webblenRed,
      onRefresh: refreshData,
      child: ListView.builder(
        controller: virtualEventsScrollController,
        physics: AlwaysScrollableScrollPhysics(),
        key: UniqueKey(),
        shrinkWrap: true,
        padding: EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
        ),
        itemCount: virtualEventResults.length,
        itemBuilder: (context, index) {
          WebblenEvent event = WebblenEvent.fromMap(Map<String, dynamic>.from(virtualEventResults[index].data()['d']));
          double num = index / 15;
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
                        error: Container(),
                        adUnitID: adMobUnitID, //'ca-app-pub-3940256099942544/3986624511',
                        numberAds: 3,
                        controller: nativeAdController,
                        type: NativeAdmobType.banner,
                      ),
                    ),
                    EventBlock(
                      currentUID: widget.currentUser.uid,
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
            return index == 0
                ? Padding(
                    padding: EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: liveEventResults.length - 1 == index ? 16.0 : 0),
                    child: Container(
                      child: Column(
                        children: [
                          listRecordedStreams(),
                          SizedBox(height: 8.0),
                          EventBlock(
                            currentUID: widget.currentUser.uid,
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
                  )
                : Padding(
                    padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: virtualEventResults.length - 1 == index ? 16.0 : 0),
                    child: EventBlock(
                      currentUID: widget.currentUser.uid,
                      event: event,
                      shareEvent: () => Share.share("https://app.webblen.io/#/event?id=${event.id}"),
                      viewEventDetails: () =>
                          PageTransitionService(context: context, currentUser: widget.currentUser, eventID: event.id).transitionToEventPage(),
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

  @override
  void initState() {
    super.initState();
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
    liveEventsScrollController = ScrollController();
    virtualEventsScrollController = ScrollController();
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
    areaName = widget.areaName;
    setState(() {});
    LocationService().getZipFromLatLon(widget.currentLat, widget.currentLon).then((res) {
      areaCodeFilter = res;
      //getSavedEvents();
      getRecordedStreams();
      getVirtualEvents();
      getLiveEvents();
    });
  }

  @override
  void dispose() {
    super.dispose();
    liveEventsScrollController.dispose();
    virtualEventsScrollController.dispose();
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
                        child: areaName.length <= 6
                            ? Fonts().textW700(
                                areaName,
                                40,
                                Colors.black,
                                TextAlign.left,
                              )
                            : areaName.length <= 8
                                ? Fonts().textW700(
                                    areaName,
                                    35,
                                    Colors.black,
                                    TextAlign.left,
                                  )
                                : areaName.length <= 10
                                    ? Fonts().textW700(
                                        areaName,
                                        30,
                                        Colors.black,
                                        TextAlign.left,
                                      )
                                    : areaName.length <= 12
                                        ? Fonts().textW700(
                                            areaName,
                                            25,
                                            Colors.black,
                                            TextAlign.left,
                                          )
                                        : Fonts().textW700(
                                            areaName,
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
                              child: Container(
                                height: 30,
                                width: 30,
                                child: Icon(
                                  FontAwesomeIcons.slidersH,
                                  size: 20.0,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => PageTransitionService(
                                context: context,
                                currentUser: widget.currentUser,
                              ).transitionToSearchPage(),
                              child: Container(
                                height: 30,
                                width: 30,
                                child: Icon(
                                  FontAwesomeIcons.search,
                                  size: 20.0,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => showNewEventOrStreamDialog(),
                              child: Container(
                                height: 30,
                                width: 30,
                                child: Icon(
                                  FontAwesomeIcons.plus,
                                  size: 20.0,
                                  color: Colors.black,
                                ),
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
            height: 50,
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
                      child: CustomText(
                        context: context,
                        text: "Stream",
                        textColor: Colors.black,
                        textAlign: TextAlign.center,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
//                    Tab(
//                      child: CustomText(
//                        context: context,
//                        text: "Saved",
//                        textColor: Colors.black,
//                        textAlign: TextAlign.center,
//                        fontSize: 15.0,
//                        fontWeight: FontWeight.w500,
//                      ),
//                    ),
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
                    //LIVE EVENTS
                    Container(
                        key: PageStorageKey('key0'),
                        color: Colors.white,
                        child: isLoading
                            ? LoadingScreen(
                                context: context,
                                loadingDescription: 'Loading Streams...',
                              )
                            : virtualEventResults.isEmpty && recordedStreamResults.isEmpty
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context).size.width - 16,
                                            ),
                                            child: Text(
                                              "We Could Not Find Any Streams \nAccording to Your Preferences",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
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
                                            child: Text(
                                              "Change My Preferences",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, color: CustomColors.electronBlue),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 100.0),
                                    ],
                                  )
                                : recordedStreamResults.isNotEmpty && virtualEventResults.isEmpty
                                    ? Column(
                                        children: [
                                          SizedBox(height: 8.0),
                                          listRecordedStreams(),
                                          SizedBox(height: 8.0),
                                          Text(
                                            "We Could Not Find Any Streams \nAccording to Your Preferences",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      )
                                    : listVirtualEvents()),
                    //VIRTUAL EVENTS
                    Container(
                      key: PageStorageKey('key1'),
                      color: Colors.white,
                      child: isLoading
                          ? LoadingScreen(
                              context: context,
                              loadingDescription: 'Loading Events...',
                            )
                          : liveEventResults.isEmpty
                              ? LiquidPullToRefresh(
                                  onRefresh: refreshData,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context).size.width - 16,
                                            ),
                                            child: Text(
                                              "We Could Not Find Any Events \nAccording to Your Preferences",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
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
                                            child: Text(
                                              "Change My Preferences",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, color: CustomColors.electronBlue),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 100.0),
                                    ],
                                  ),
                                )
                              : listLiveEvents(),
                    ),
                    //SAVED EVENTS
//                    Container(
//                      key: PageStorageKey('key2'),
//                      color: Colors.white,
//                      child: isLoading
//                          ? LoadingScreen(
//                              context: context,
//                              loadingDescription: 'Loading Saved Events...',
//                            )
//                          : savedEventResults.isEmpty
//                              ? Column(
//                                  mainAxisAlignment: MainAxisAlignment.center,
//                                  children: <Widget>[
//                                    Row(
//                                      mainAxisAlignment: MainAxisAlignment.center,
//                                      children: <Widget>[
//                                        Container(
//                                          constraints: BoxConstraints(
//                                            maxWidth: MediaQuery.of(context).size.width - 16,
//                                          ),
//                                          child: CustomText(
//                                            context: context,
//                                            text: "You Do Not Have Any Upcoming Events Saved",
//                                            textColor: Colors.black,
//                                            textAlign: TextAlign.center,
//                                            fontSize: 16.0,
//                                            fontWeight: FontWeight.w500,
//                                          ),
//                                        )
//                                      ],
//                                    ),
//                                  ],
//                                )
//                              : listSavedEvents(),
//                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
