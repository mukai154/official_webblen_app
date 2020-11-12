import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:share/share.dart';
import 'package:video_player/video_player.dart';
import 'package:webblen/algolia/algolia_search.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/constants/strings.dart';
import 'package:webblen/firebase/data/post_data.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/utils/time.dart';
import 'package:webblen/widgets/common/alerts/custom_alerts.dart';
import 'package:webblen/widgets/common/containers/text_field_container.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';
import 'package:webblen/widgets/events/event_block.dart';
import 'package:webblen/widgets/posts/post_block.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';

import 'video_play_page.dart';

class HomeDashboardPage extends StatefulWidget {
  final WebblenUser currentUser;
  final List tags;
  final bool updateRequired;
  final String areaName;
  final Key key;
  final double currentLat;
  final double currentLon;
  final Widget notifWidget;

  HomeDashboardPage({
    this.currentUser,
    this.tags,
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
  TextEditingController tagTextController = TextEditingController();

  //Scroller & Paging
  final PageStorageBucket bucket = PageStorageBucket();
  TabController _tabController;
  ScrollController recordedStreamsScrollController;
  ScrollController postsScrollController;
  ScrollController eventsScrollController;
  ScrollController followingScrollController;
  ScrollController recommendedScrollController;
  int resultsPerPage = 15;

  //Filter
  String areaName = "";
  String areaCodeFilter = "";
  String tagFilter = "";
  List<String> sortByList = ["Latest", "Most Popular"];
  String sortBy = "Latest";

  //Event Results
  int dateTimeInMilliseconds2hoursAgo = DateTime.now().millisecondsSinceEpoch - 7400000;
  int dateTimeInMilliseconds1MonthAgo = DateTime.now().millisecondsSinceEpoch - 2628000000;
  CollectionReference postsRef = FirebaseFirestore.instance.collection("posts");
  CollectionReference eventsRef = FirebaseFirestore.instance.collection("events");
  CollectionReference recordedStreamsRef = FirebaseFirestore.instance.collection("recorded_streams");
  List<DocumentSnapshot> recordedStreamResults = [];
  List<DocumentSnapshot> postResults = [];
  List<DocumentSnapshot> eventResults = [];
  List<DocumentSnapshot> followingResults = [];
  List<DocumentSnapshot> recommendedResults = [];
  DocumentSnapshot lastPostDocSnap;
  DocumentSnapshot lastEventDocSnap;
  DocumentSnapshot lastFollowingDocSnap;
  DocumentSnapshot lastRecommendedDocSnap;

  bool loadingAdditionalPosts = false;
  bool morePostsAvailable = true;

  bool loadingAdditionalEvents = false;
  bool moreEventsAvailable = true;

  bool loadingAdditionalFollowing = false;
  bool moreFollowingAvailable = true;

  bool loadingAdditionalRecommended = false;
  bool moreRecommendedAvailable = true;

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
  }

  getRecordedStreams() async {
    QuerySnapshot querySnapshot = await recordedStreamsRef
        .where('showAllUsers', isEqualTo: true)
        .where('expiration', isGreaterThanOrEqualTo: DateTime.now().millisecondsSinceEpoch)
        .get()
        .catchError((e) {});
    if (querySnapshot.docs.isNotEmpty) {
      recordedStreamResults.addAll(querySnapshot.docs);
    }
    querySnapshot = await recordedStreamsRef
        .where('showAllUsers', isEqualTo: false)
        .where('nearbyZipcodes', arrayContains: areaCodeFilter)
        .where('expiration', isGreaterThanOrEqualTo: DateTime.now().millisecondsSinceEpoch)
        .get()
        .catchError((e) {
      print(e);
    });
    if (querySnapshot.docs.isNotEmpty) {
      recordedStreamResults.addAll(querySnapshot.docs);
    }
    if (recordedStreamResults.isNotEmpty) {
      recordedStreamResults.sort((docA, docB) => docB.data()['expiration'].compareTo(docA.data()['expiration']));
      setState(() {});
    }
  }

  getPosts() async {
    Query query;
    if (areaCodeFilter.isEmpty) {
      query = postsRef
          .where('postDateTimeInMilliseconds', isGreaterThan: dateTimeInMilliseconds1MonthAgo)
          .orderBy('postDateTimeInMilliseconds', descending: true)
          .limit(resultsPerPage);
    } else {
      query = postsRef
          .where('nearbyZipcodes', arrayContains: areaCodeFilter)
          .where('postDateTimeInMilliseconds', isGreaterThan: dateTimeInMilliseconds1MonthAgo)
          .orderBy('postDateTimeInMilliseconds', descending: true)
          .limit(resultsPerPage);
    }
    QuerySnapshot querySnapshot = await query.get().catchError((e) {
      print(e);
    });
    if (querySnapshot.docs.isNotEmpty) {
      lastPostDocSnap = querySnapshot.docs[querySnapshot.docs.length - 1];
      postResults = querySnapshot.docs;
      if (tagFilter.isNotEmpty) {
        postResults.removeWhere((doc) => !doc.data()['tags'].contains(tagFilter));
      }
      if (sortBy == "Latest") {
        postResults.sort((docA, docB) => docB.data()['postDateTimeInMilliseconds'].compareTo(docA.data()['postDateTimeInMilliseconds']));
      } else {
        postResults.sort((docA, docB) => docB.data()['commentCount'].compareTo(docA.data()['commentCount']));
      }
    }
    isLoading = false;
    setState(() {});
  }

  getEvents() async {
    Query eventsQuery;
    if (areaCodeFilter.isEmpty) {
      eventsQuery = eventsRef
          .where('d.privacy', isEqualTo: "public")
          .where("d.endDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .orderBy("d.endDateTimeInMilliseconds", descending: false)
          .limit(resultsPerPage);
    } else {
      eventsQuery = eventsRef
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
          .where('d.privacy', isEqualTo: "public")
          .where("d.endDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .orderBy("d.endDateTimeInMilliseconds", descending: false)
          .limit(resultsPerPage);
    }
    QuerySnapshot querySnapshot = await eventsQuery.get().catchError((e) {
      print(e);
    });
    if (querySnapshot.docs.isNotEmpty) {
      lastEventDocSnap = querySnapshot.docs[querySnapshot.docs.length - 1];
      eventResults = querySnapshot.docs;
      if (tagFilter.isNotEmpty) {
        eventResults.removeWhere((doc) => !doc.data()['d']['tags'].contains(tagFilter));
      }
      if (sortBy == "Most Popular") {
        eventResults.sort((docA, docB) => docB.data()['d']['clicks'].compareTo(docA.data()['d']['clicks']));
      }
    }
    isLoading = false;
    setState(() {});
  }

  getFollowingPosts() async {
    Query query = postsRef
        .where('followers', arrayContains: widget.currentUser.uid)
        .where('postDateTimeInMilliseconds', isGreaterThan: dateTimeInMilliseconds1MonthAgo)
        .orderBy('postDateTimeInMilliseconds', descending: true);
    QuerySnapshot querySnapshot = await query.get().catchError((e) {
      print(e);
    });
    if (querySnapshot.docs.isNotEmpty) {
      lastFollowingDocSnap = querySnapshot.docs[querySnapshot.docs.length - 1];
      followingResults = querySnapshot.docs;
      if (tagFilter.isNotEmpty) {
        followingResults.removeWhere((doc) => !doc.data()['tags'].contains(tagFilter));
      }
      if (sortBy == "Most Popular") {
        followingResults.sort((docA, docB) => docB.data()['commentCount'].compareTo(docA.data()['commentCount']));
      }
    }
    isLoading = false;
    setState(() {});
  }

  getRecommendedPosts() async {
    // Query query;
    // if (tagFilter == "None" && !sortByPopularity) {
    //   query = postsRef
    //       .where('nearbyZipcodes', arrayContains: areaCodeFilter)
    //       .where('tags', arrayContainsAny: widget.tags)
    //       .orderBy('postDateTimeInMilliseconds', descending: true)
    //       .limit(resultsPerPage);
    // } else if (tagFilter != "None" && !sortByPopularity) {
    //   query = postsRef
    //       .where('nearbyZipcodes', arrayContains: areaCodeFilter)
    //       .where('tags', arrayContainsAny: widget.tags)
    //       .where('tags', arrayContains: tagFilter)
    //       .orderBy('postDateTimeInMilliseconds', descending: true)
    //       .limit(resultsPerPage);
    // } else if (tagFilter == "None" && sortByPopularity) {
    //   query = postsRef.where('tags', arrayContainsAny: widget.tags).orderBy('commentCount', descending: true).limit(resultsPerPage);
    // } else {
    //   query = postsRef
    //       .where('nearbyZipcodes', arrayContains: areaCodeFilter)
    //       .where('tags', arrayContainsAny: widget.tags)
    //       .where('tags', arrayContains: tagFilter)
    //       .orderBy('commentCount', descending: true)
    //       .limit(resultsPerPage);
    // }
    // QuerySnapshot querySnapshot = await query.get().catchError((e) {
    //   print(e);
    // });
    // if (querySnapshot.docs.isNotEmpty) {
    //   lastRecommendedDocSnap = querySnapshot.docs[querySnapshot.docs.length - 1];
    //   recommendedResults = querySnapshot.docs;
    // }
    // isLoading = false;
    // setState(() {});
  }

  getAdditionalEvents() async {
    if (isLoading || !moreEventsAvailable || loadingAdditionalEvents) {
      return;
    }
    loadingAdditionalEvents = true;
    setState(() {});
    Query eventsQuery;
    if (areaCodeFilter.isEmpty) {
      eventsQuery = eventsRef
          .where('d.privacy', isEqualTo: "public")
          .where("d.endDateTimeInMilliseconds", isGreaterThan: dateTimeInMilliseconds2hoursAgo)
          .orderBy("d.endDateTimeInMilliseconds", descending: false)
          .startAfterDocument(lastEventDocSnap)
          .limit(resultsPerPage);
    } else {
      eventsQuery = eventsRef
          .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
          .where('d.privacy', isEqualTo: "public")
          .orderBy("d.endDateTimeInMilliseconds", descending: false)
          .startAfterDocument(lastEventDocSnap)
          .limit(resultsPerPage);
    }

    QuerySnapshot querySnapshot = await eventsQuery.get().catchError((e) {});
    lastEventDocSnap = querySnapshot.docs[querySnapshot.docs.length - 1];
    eventResults.addAll(querySnapshot.docs);
    if (tagFilter.isNotEmpty) {
      eventResults.removeWhere((doc) => !doc.data()['d']['tags'].contains(tagFilter));
    }
    // if (sortBy == "Latest") {
    //   eventResults.sort((docA, docB) => docB.data()['d']['endDateTimeInMilliseconds'].compareTo(docA.data()['d']['endDateTimeInMilliseconds']));
    // } else {
    //   eventResults.sort((docA, docB) => docB.data()['d']['clicks'].compareTo(docA.data()['d']['clicks']));
    // }
    if (querySnapshot.docs.length == 0) {
      moreEventsAvailable = false;
    }
    loadingAdditionalEvents = false;
    setState(() {});
  }

  getAdditionalPosts() async {
    if (isLoading || !morePostsAvailable || loadingAdditionalPosts) {
      return;
    }
    loadingAdditionalPosts = true;
    setState(() {});
    Query query;
    if (areaCodeFilter.isEmpty) {
      query = postsRef
          .where('postDateTimeInMilliseconds', isGreaterThan: dateTimeInMilliseconds1MonthAgo)
          .orderBy('postDateTimeInMilliseconds', descending: true)
          .startAfterDocument(lastPostDocSnap)
          .limit(resultsPerPage);
    } else {
      query = postsRef
          .where('nearbyZipcodes', arrayContains: areaCodeFilter)
          .where('postDateTimeInMilliseconds', isGreaterThan: dateTimeInMilliseconds1MonthAgo)
          .orderBy('postDateTimeInMilliseconds', descending: true)
          .startAfterDocument(lastPostDocSnap)
          .limit(resultsPerPage);
    }
    QuerySnapshot querySnapshot = await query.get().catchError((e) {});
    lastPostDocSnap = querySnapshot.docs[querySnapshot.docs.length - 1];
    postResults.addAll(querySnapshot.docs);
    if (tagFilter.isNotEmpty) {
      postResults.removeWhere((doc) => !doc.data()['tags'].contains(tagFilter));
    }
    if (sortBy == "Most Popular") {
      postResults.sort((docA, docB) => docB.data()['commentCount'].compareTo(docA.data()['commentCount']));
    }
    if (querySnapshot.docs.length == 0) {
      morePostsAvailable = false;
    }
    loadingAdditionalPosts = false;
    setState(() {});
  }

  getAdditionalFollowing() async {
    if (isLoading || !moreFollowingAvailable || loadingAdditionalFollowing) {
      return;
    }
    loadingAdditionalFollowing = true;
    setState(() {});
    Query query = postsRef
        .where('followers', arrayContains: widget.currentUser.uid)
        .where('postDateTimeInMilliseconds', isGreaterThan: dateTimeInMilliseconds1MonthAgo)
        .orderBy('postDateTimeInMilliseconds', descending: true)
        .startAfterDocument(lastFollowingDocSnap)
        .limit(resultsPerPage);

    QuerySnapshot querySnapshot = await query.get().catchError((e) {});
    lastFollowingDocSnap = querySnapshot.docs[querySnapshot.docs.length - 1];
    followingResults.addAll(querySnapshot.docs);
    if (tagFilter.isNotEmpty) {
      followingResults.removeWhere((doc) => !doc.data()['tags'].contains(tagFilter));
    }
    if (sortBy == "Most Popular") {
      followingResults.sort((docA, docB) => docB.data()['commentCount'].compareTo(docA.data()['commentCount']));
    }
    if (querySnapshot.docs.length == 0) {
      moreFollowingAvailable = false;
    }
    loadingAdditionalFollowing = false;
    setState(() {});
  }

  getAdditionalRecommended() async {
    // if (isLoading || !moreRecommendedAvailable || loadingAdditionalRecommended) {
    //   return;
    // }
    // loadingAdditionalRecommended = true;
    // setState(() {});
    // Query query;
    // if (tagFilter == "None" && !sortByPopularity) {
    //   query = postsRef
    //       .where('d.nearbyZipcodes', arrayContains: areaCodeFilter)
    //       .where('tags', arrayContainsAny: widget.currentUser.tags)
    //       .orderBy('postDateTimeInMilliseconds', descending: true)
    //       .startAfterDocument(lastRecommendedDocSnap)
    //       .limit(resultsPerPage);
    // } else if (tagFilter != "None" && !sortByPopularity) {
    //   query = postsRef
    //       .where('nearbyZipcodes', arrayContains: areaCodeFilter)
    //       .where('tags', arrayContainsAny: widget.currentUser.tags)
    //       .where('tags', arrayContains: tagFilter)
    //       .orderBy('postDateTimeInMilliseconds', descending: true)
    //       .startAfterDocument(lastRecommendedDocSnap)
    //       .limit(resultsPerPage);
    // } else if (tagFilter == "None" && sortByPopularity) {
    //   query = postsRef
    //       .where('nearbyZipcodes', arrayContains: areaCodeFilter)
    //       .where('tags', arrayContainsAny: widget.currentUser.tags)
    //       .startAfterDocument(lastRecommendedDocSnap)
    //       .orderBy('commentCount', descending: true)
    //       .limit(resultsPerPage);
    // } else {
    //   query = postsRef
    //       .where('nearbyZipcodes', arrayContains: areaCodeFilter)
    //       .where('tags', arrayContainsAny: widget.currentUser.tags)
    //       .where('tags', arrayContains: tagFilter)
    //       .orderBy('commentCount', descending: true)
    //       .startAfterDocument(lastRecommendedDocSnap)
    //       .limit(resultsPerPage);
    // }
    // QuerySnapshot querySnapshot = await query.get().catchError((e) {});
    // lastRecommendedDocSnap = querySnapshot.docs[querySnapshot.docs.length - 1];
    // recommendedResults.addAll(querySnapshot.docs);
    // if (querySnapshot.docs.length == 0) {
    //   moreRecommendedAvailable = false;
    // }
    // loadingAdditionalRecommended = false;
    // setState(() {});
  }

  setNewLocation() async {
    Navigator.of(context).pop();
    Prediction p = await PlacesAutocomplete.show(
      context: context,
      apiKey: Strings.googleAPIKEY,
      onError: (res) {
        //print(res.errorMessage);
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
    postResults = [];
    eventResults = [];
    followingResults = [];
    // recommendedResults = [];
    recordedStreamResults = [];
    getRecordedStreams();
    getEvents();
    getFollowingPosts();
    // getRecommendedPosts();
    getPosts();
  }

  Future<void> refreshFromPreferences() async {
    isLoading = true;
    setState(() {});
    refreshData();
  }

  showPreferenceDialog() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 64.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        context: context,
                        text: "Preferences",
                        textColor: Colors.black,
                        textAlign: TextAlign.left,
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          FontAwesomeIcons.times,
                          color: Colors.black38,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  CustomText(
                    context: context,
                    text: "Sort By:",
                    textColor: Colors.black,
                    textAlign: TextAlign.left,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: 4.0),
                  TextFieldContainer(
                    height: 32,
                    child: DropdownButton(
                        isExpanded: true,
                        underline: Container(),
                        value: sortBy,
                        items: sortByList.map((String val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            sortBy = val;
                          });
                          refreshFromPreferences();
                        }),
                  ),
                  SizedBox(height: 32.0),
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
                      height: 32.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomText(
                            context: context,
                            text: areaName.isEmpty ? "Everywhere" : "$areaName",
                            textColor: Colors.black,
                            textAlign: TextAlign.left,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12.0),
                  GestureDetector(
                    onTap: () {
                      areaName = "";
                      areaCodeFilter = "";
                      setState(() {});
                      refreshFromPreferences();
                    },
                    child: Text(
                      'Clear Location Filter',
                      style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 32.0),
                  CustomText(
                    context: context,
                    text: "Tag: $tagFilter",
                    textColor: Colors.black,
                    textAlign: TextAlign.left,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: 4.0),
                  TextFieldContainer(
                    height: 35,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 8,
                      ),
                      child: TypeAheadField(
                        hideOnEmpty: true,
                        hideOnLoading: true,
                        direction: AxisDirection.down,
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: tagTextController,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            hintText: "Search for Tag",
                            border: InputBorder.none,
                          ),
                          autofocus: false,
                        ),
                        suggestionsCallback: (searchTerm) async {
                          return await AlgoliaSearch().queryTags(searchTerm);
                        },
                        itemBuilder: (context, tag) {
                          return ListTile(
                            title: Text(
                              tag,
                              style: TextStyle(color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.w700),
                            ),
                          );
                        },
                        onSuggestionSelected: (val) {
                          tagFilter = val;
                          tagTextController.clear();
                          refreshFromPreferences();
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 12.0),
                  GestureDetector(
                    onTap: () {
                      tagFilter = "";
                      setState(() {});
                      refreshFromPreferences();
                    },
                    child: Text(
                      'Clear Tag Filter',
                      style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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

  Widget listPosts(String postType) {
    return LiquidPullToRefresh(
      color: CustomColors.webblenRed,
      onRefresh: refreshData,
      child: ListView.builder(
        controller: null,
        physics: AlwaysScrollableScrollPhysics(),
        key: UniqueKey(),
        shrinkWrap: true,
        padding: EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
        ),
        itemCount: postType == "following"
            ? followingResults.length
            : postType == "recommended"
                ? recommendedResults.length
                : postResults.length,
        itemBuilder: (context, index) {
          WebblenPost post = WebblenPost.fromMap(Map<String, dynamic>.from(postType == "following"
              ? followingResults[index].data()
              : postType == "recommended"
                  ? recommendedResults[index].data()
                  : postResults[index].data()));
          double num = index / 15;
          if (num == num.roundToDouble() && num != 0) {
            return Padding(
              padding: postType == "following"
                  ? EdgeInsets.only(bottom: followingResults.length - 1 == index ? 16.0 : 0)
                  : postType == "recommended"
                      ? EdgeInsets.only(bottom: recommendedResults.length - 1 == index ? 16.0 : 0)
                      : EdgeInsets.only(bottom: postResults.length - 1 == index ? 16.0 : 0),
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
                    post.imageURL == null
                        ? PostTextBlock(
                            currentUID: widget.currentUser.uid,
                            post: post,
                            viewUser: () => transitionToUserPage(post.authorID),
                            //shareEvent: () => Share.share("https://app.webblen.io/#/post?id=${post.id}"),
                            viewPost: () => PageTransitionService(context: context, postID: post.id).transitionToPostViewPage(),
                            postOptions: () => postOptionsDialog(post.id, post.authorID),
                          )
                        : PostImgBlock(
                            currentUID: widget.currentUser.uid,
                            post: post,
                            viewUser: () => transitionToUserPage(post.authorID),
                            //shareEvent: () => Share.share("https://app.webblen.io/#/post?id=${post.id}"),
                            viewPost: () => PageTransitionService(context: context, postID: post.id).transitionToPostViewPage(),
                            postOptions: () => postOptionsDialog(post.id, post.authorID),
                          ),
                  ],
                ),
              ),
            );
          } else {
            return index == 0
                ? Padding(
                    padding: postType == "following"
                        ? EdgeInsets.only(bottom: followingResults.length - 1 == index ? 16.0 : 0)
                        : postType == "recommended"
                            ? EdgeInsets.only(bottom: recommendedResults.length - 1 == index ? 16.0 : 0)
                            : EdgeInsets.only(bottom: postResults.length - 1 == index ? 16.0 : 0),
                    child: Container(
                      child: Column(
                        children: [
                          recordedStreamResults.isNotEmpty ? listRecordedStreams() : Container(),
                          SizedBox(height: 8.0),
                          post.imageURL == null
                              ? PostTextBlock(
                                  currentUID: widget.currentUser.uid,
                                  post: post,
                                  viewUser: () => transitionToUserPage(post.authorID),
                                  //shareEvent: () => Share.share("https://app.webblen.io/#/post?id=${post.id}"),
                                  viewPost: () => PageTransitionService(context: context, postID: post.id).transitionToPostViewPage(),
                                  postOptions: () => postOptionsDialog(post.id, post.authorID),
                                )
                              : PostImgBlock(
                                  currentUID: widget.currentUser.uid,
                                  post: post,
                                  viewUser: () => transitionToUserPage(post.authorID),
                                  //shareEvent: () => Share.share("https://app.webblen.io/#/post?id=${post.id}"),
                                  viewPost: () => PageTransitionService(context: context, postID: post.id).transitionToPostViewPage(),
                                  postOptions: () => postOptionsDialog(post.id, post.authorID),
                                ),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: postType == "following"
                        ? EdgeInsets.only(bottom: followingResults.length - 1 == index ? 16.0 : 0)
                        : postType == "recommended"
                            ? EdgeInsets.only(bottom: recommendedResults.length - 1 == index ? 16.0 : 0)
                            : EdgeInsets.only(bottom: postResults.length - 1 == index ? 16.0 : 0),
                    child: post.imageURL == null
                        ? PostTextBlock(
                            currentUID: widget.currentUser.uid,
                            post: post,
                            viewUser: () => transitionToUserPage(post.authorID),
                            //shareEvent: () => Share.share("https://app.webblen.io/#/post?id=${post.id}"),
                            viewPost: () =>
                                PageTransitionService(context: context, currentUser: widget.currentUser, postID: post.id).transitionToPostViewPage(),
                            postOptions: () => postOptionsDialog(post.id, post.authorID),
                          )
                        : PostImgBlock(
                            currentUID: widget.currentUser.uid,
                            post: post,
                            viewUser: () => transitionToUserPage(post.authorID),
                            //shareEvent: () => Share.share("https://app.webblen.io/#/post?id=${post.id}"),
                            viewPost: () =>
                                PageTransitionService(context: context, currentUser: widget.currentUser, postID: post.id).transitionToPostViewPage(),
                            postOptions: () => postOptionsDialog(post.id, post.authorID),
                          ),
                  );
          }
        },
      ),
    );
  }

  Widget listEvents() {
    return LiquidPullToRefresh(
      color: CustomColors.webblenRed,
      onRefresh: refreshData,
      child: ListView.builder(
        controller: eventsScrollController,
        physics: AlwaysScrollableScrollPhysics(),
        key: UniqueKey(),
        shrinkWrap: true,
        padding: EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
        ),
        itemCount: eventResults.length,
        itemBuilder: (context, index) {
          WebblenEvent event = WebblenEvent.fromMap(Map<String, dynamic>.from(eventResults[index].data()['d']));
          return Padding(
            padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: eventResults.length - 1 == index ? 16.0 : 0),
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
      ),
    );
  }

  showNewContentDialog() async {
    String action = await showModalActionSheet(context: context, message: "What Do You Have for $areaName?", actions: [
      SheetAction(label: "Create Post", key: 'post'),
      SheetAction(label: "Create Stream", key: 'stream'),
      SheetAction(label: "Create Event", key: 'event'),
    ]);
    if (action == 'post') {
      PageTransitionService(context: context).transitionToCreatePostPage();
    } else if (action == 'stream') {
      PageTransitionService(context: context, isStream: true).transitionToCreateEventPage();
    } else if (action == 'event') {
      PageTransitionService(context: context, isStream: false).transitionToCreateEventPage();
    }
  }

  postOptionsDialog(String postID, String postAuthorID) async {
    if (postAuthorID == widget.currentUser.uid) {
      String action = await showModalActionSheet(
        context: context,
        actions: [
          SheetAction(label: "Edit Post", key: 'editPost'),
          SheetAction(label: "Share", key: 'sharePost'),
          SheetAction(label: "Delete Post", key: 'deletePost', isDestructiveAction: true),
        ],
      );
      if (action == 'editPost') {
        PageTransitionService(context: context, postID: postID).transitionToCreatePostPage();
      } else if (action == 'sharePost') {
        PageTransitionService(context: context, isStream: true).transitionToCreatePostPage();
      } else if (action == 'deletePost') {
        OkCancelResult res = await showOkCancelAlertDialog(
          context: context,
          message: "Delete This Post?",
          okLabel: "Delete",
          cancelLabel: "Cancel",
          isDestructiveAction: true,
        );
        if (res == OkCancelResult.ok) {
          PostDataService().deletePost(postID);
        }
      }
    } else {
      String action = await showModalActionSheet(
        context: context,
        actions: [
          SheetAction(label: "Share", key: 'share'),
          SheetAction(label: "Report", key: 'report', isDestructiveAction: true),
        ],
      );
      if (action == 'share') {
        PageTransitionService(context: context).transitionToCreatePostPage();
      } else if (action == 'report') {
        PageTransitionService(context: context, isStream: true).transitionToCreatePostPage();
      }
    }
  }

  transitionToUserPage(String uid) async {
    ShowAlertDialogService().showLoadingDialog(context);
    WebblenUser user = await WebblenUserData().getUserByID(uid);
    Navigator.of(context).pop();
    PageTransitionService(
      context: context,
      currentUser: widget.currentUser,
      webblenUser: user,
    ).transitionToUserPage();
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
      length: 3,
      vsync: this,
    );

    postsScrollController = ScrollController();
    eventsScrollController = ScrollController();
    followingScrollController = ScrollController();
    // recommendedScrollController = ScrollController();

    postsScrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * postsScrollController.position.maxScrollExtent;
      if (postsScrollController.position.pixels > triggerFetchMoreSize) {
        getAdditionalPosts();
      }
    });
    eventsScrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * eventsScrollController.position.maxScrollExtent;
      if (eventsScrollController.position.pixels > triggerFetchMoreSize) {
        getAdditionalEvents();
      }
    });
    followingScrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * followingScrollController.position.maxScrollExtent;
      if (followingScrollController.position.pixels > triggerFetchMoreSize) {
        getAdditionalFollowing();
      }
    });
    // recommendedScrollController.addListener(() {
    //   double triggerFetchMoreSize = 0.9 * recommendedScrollController.position.maxScrollExtent;
    //   if (recommendedScrollController.position.pixels > triggerFetchMoreSize) {
    //     getAdditionalRecommended();
    //   }
    // });
    areaName = widget.areaName;
    setState(() {});
    LocationService().getZipFromLatLon(widget.currentLat, widget.currentLon).then((res) {
      areaCodeFilter = res;
      getRecordedStreams();
      getPosts();
      getEvents();
      getFollowingPosts();
      //getRecommendedPosts();
    });
  }

  @override
  void dispose() {
    super.dispose();
    eventsScrollController.dispose();
    postsScrollController.dispose();
    followingScrollController.dispose();
    // recommendedScrollController.dispose();
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
              right: 16,
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
                        child: areaName.isEmpty
                            ? Fonts().textW700(
                                "Everywhere",
                                25,
                                Colors.black,
                                TextAlign.left,
                              )
                            : areaName.length <= 6
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
                              onTap: () => showPreferenceDialog(),
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
                              onTap: () => showNewContentDialog(),
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
            height: 30,
            padding: EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TabBar(
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
                            "Following",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    // Tab(
                    //   child: Container(
                    //     height: 30,
                    //     width: 110,
                    //     decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(10),
                    //     ),
                    //     child: Align(
                    //       alignment: Alignment.center,
                    //       child: Text(
                    //         "Recommended",
                    //         style: TextStyle(fontWeight: FontWeight.bold),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
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
                    //LIVE EVENTS
                    Container(
                      key: PageStorageKey('key0'),
                      color: Colors.white,
                      child: isLoading
                          ? LoadingScreen(
                              context: context,
                              loadingDescription: 'Loading Posts...',
                            )
                          : postResults.isEmpty && recordedStreamResults.isEmpty
                              ? LiquidPullToRefresh(
                                  color: CustomColors.webblenRed,
                                  onRefresh: refreshData,
                                  child: Center(
                                    child: ListView(
                                      shrinkWrap: true,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                                          child: Image.asset(
                                            'assets/images/balloon_person.png',
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
                                                "Looks Like Nobody Has Started\nSetting the Culture of This Area...",
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
                                              onTap: () => showNewContentDialog(),
                                              child: Text(
                                                "Be the First and Get 10.00 WBLN",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, color: CustomColors.electronBlue),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 100.0),
                                      ],
                                    ),
                                  ),
                                )
                              : recordedStreamResults.isNotEmpty && postResults.isEmpty
                                  ? LiquidPullToRefresh(
                                      color: CustomColors.webblenRed,
                                      onRefresh: refreshData,
                                      child: Center(
                                        child: ListView(
                                          shrinkWrap: true,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                                              child: Image.asset(
                                                'assets/images/balloon_person.png',
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
                                                    "Looks Like Nobody Has Started\nSetting the Culture of This Area...",
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
                                                  onTap: () => showNewContentDialog(),
                                                  child: Text(
                                                    "Be the First and Get 10.00 WBLN",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, color: CustomColors.electronBlue),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 100.0),
                                          ],
                                        ),
                                      ),
                                    )
                                  : listPosts(""),
                    ),
                    //EVENTS
                    Container(
                      key: PageStorageKey('key1'),
                      color: Colors.white,
                      child: isLoading
                          ? LoadingScreen(
                              context: context,
                              loadingDescription: 'Loading Events...',
                            )
                          : eventResults.isEmpty
                              ? LiquidPullToRefresh(
                                  color: CustomColors.webblenRed,
                                  onRefresh: refreshData,
                                  child: Center(
                                    child: ListView(
                                      shrinkWrap: true,
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
                                              onTap: () => showPreferenceDialog(),
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
                                  ),
                                )
                              : listEvents(),
                    ),
                    //Following
                    Container(
                      key: PageStorageKey('key2'),
                      color: Colors.white,
                      child: isLoading
                          ? LoadingScreen(
                              context: context,
                              loadingDescription: 'Loading Posts...',
                            )
                          : followingResults.isEmpty
                              ? LiquidPullToRefresh(
                                  color: CustomColors.webblenRed,
                                  onRefresh: refreshData,
                                  child: Center(
                                    child: ListView(
                                      shrinkWrap: true,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                                          child: Image.asset(
                                            'assets/images/add_users.png',
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
                                                "No One Your Following Has Posted Anything Recently",
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
                                              onTap: () => PageTransitionService(context: context).transitionToFollowSugestionsPage(),
                                              child: Text(
                                                "View Follow Suggestions",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, color: CustomColors.electronBlue),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 100.0),
                                      ],
                                    ),
                                  ),
                                )
                              : listPosts('following'),
                    ),
                    //RECOMMENDED
                    // Container(
                    //   key: PageStorageKey('key3'),
                    //   color: Colors.white,
                    //   child: isLoading
                    //       ? LoadingScreen(
                    //           context: context,
                    //           loadingDescription: 'Loading Posts...',
                    //         )
                    //       : recommendedResults.isEmpty
                    //           ? LiquidPullToRefresh(
                    //               color: CustomColors.webblenRed,
                    //               onRefresh: refreshData,
                    //               child: Center(
                    //                 child: ListView(
                    //                   shrinkWrap: true,
                    //                   children: <Widget>[
                    //                     Padding(
                    //                       padding: EdgeInsets.symmetric(horizontal: 16.0),
                    //                       child: Image.asset(
                    //                         'assets/images/analytics.png',
                    //                         height: 200,
                    //                         fit: BoxFit.contain,
                    //                         filterQuality: FilterQuality.medium,
                    //                       ),
                    //                     ),
                    //                     Row(
                    //                       mainAxisAlignment: MainAxisAlignment.center,
                    //                       children: <Widget>[
                    //                         Container(
                    //                           constraints: BoxConstraints(
                    //                             maxWidth: MediaQuery.of(context).size.width - 16,
                    //                           ),
                    //                           child: Text(
                    //                             "We Couldn't Find Any People or Events\n that Would Interest You\n\n Check Back Here Later!",
                    //                             textAlign: TextAlign.center,
                    //                             style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
                    //                           ),
                    //                         )
                    //                       ],
                    //                     ),
                    //                     SizedBox(height: 8.0),
                    //                     Row(
                    //                       mainAxisAlignment: MainAxisAlignment.center,
                    //                       children: <Widget>[
                    //                         GestureDetector(
                    //                           onTap: () => PageTransitionService(context: context).transitionToInterestsPage(),
                    //                           child: Text(
                    //                             "Update Interests",
                    //                             textAlign: TextAlign.center,
                    //                             style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, color: CustomColors.electronBlue),
                    //                           ),
                    //                         ),
                    //                       ],
                    //                     ),
                    //                     SizedBox(height: 100.0),
                    //                   ],
                    //                 ),
                    //               ),
                    //             )
                    //           : listPosts('recommended'),
                    // ),
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
