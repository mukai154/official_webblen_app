import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/services/bottom_sheets/custom_bottom_sheets_service.dart';
import 'package:webblen/services/firestore/data/event_data_service.dart';
import 'package:webblen/services/firestore/data/live_stream_data_service.dart';
import 'package:webblen/services/firestore/data/post_data_service.dart';
import 'package:webblen/services/reactive/content_filter/reactive_content_filter_service.dart';
import 'package:webblen/ui/widgets/events/event_block/event_block_view.dart';
import 'package:webblen/ui/widgets/live_streams/live_stream_block/live_stream_block_view.dart';
import 'package:webblen/ui/widgets/posts/post_img_block/post_img_block_view.dart';
import 'package:webblen/ui/widgets/posts/post_text_block/post_text_block_view.dart';
import 'package:webblen/utils/custom_string_methods.dart';

class ListDiscoverContentModel extends ReactiveViewModel {
  PostDataService _postDataService = locator<PostDataService>();
  LiveStreamDataService _liveStreamDataService = locator<LiveStreamDataService>();
  EventDataService _eventDataService = locator<EventDataService>();
  CustomBottomSheetService customBottomSheetService = locator<CustomBottomSheetService>();
  ReactiveContentFilterService _reactiveContentFilterService = locator<ReactiveContentFilterService>();

  ///HELPERS
  ScrollController scrollController = ScrollController();
  String listKey = "initial-home-content-key";

  ///FILTER DATA
  String listAreaCode = "";
  String listTagFilter = "";
  String listSortByFilter = "Latest";

  String get cityName => _reactiveContentFilterService.cityName;
  String get areaCode => _reactiveContentFilterService.areaCode;
  String get tagFilter => _reactiveContentFilterService.tagFilter;
  String get sortByFilter => _reactiveContentFilterService.sortByFilter;

  ///DATA
  List<DocumentSnapshot> dataResults = [];
  List<DocumentSnapshot> postResults = [];
  List<DocumentSnapshot> streamResults = [];
  List<DocumentSnapshot> eventResults = [];
  DocumentSnapshot? lastPostDoc;
  DocumentSnapshot? lastStreamDoc;
  DocumentSnapshot? lastEventDoc;

  bool loadingAdditionalPosts = false;
  bool morePostsAvailable = true;

  bool loadingAdditionalStreams = false;
  bool moreStreamsAvailable = true;

  bool loadingAdditionalEvents = false;
  bool moreEventsAvailable = true;

  bool loadingAdditionalData = false;
  bool moreDataAvailable = true;

  int resultsLimit = 10;
  int contentCount = 0;

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_reactiveContentFilterService];

  initialize() async {
    setBusy(true);
    // get content filter
    syncContentFilter();

    notifyListeners();

    _reactiveContentFilterService.addListener(() {
      if (areaCode != listAreaCode || listTagFilter != tagFilter || listSortByFilter != sortByFilter) {
        syncContentFilter();
        refreshData();
      }
    });

    await loadData();
  }

  syncContentFilter() {
    listAreaCode = areaCode;
    listTagFilter = listTagFilter;
    listSortByFilter = sortByFilter;
    notifyListeners();
  }

  Future<void> refreshData() async {
    //clear previous data
    dataResults = [];
    postResults = [];
    streamResults = [];
    eventResults = [];

    loadingAdditionalPosts = false;
    morePostsAvailable = true;

    loadingAdditionalStreams = false;
    moreStreamsAvailable = true;

    loadingAdditionalEvents = false;
    moreEventsAvailable = true;

    loadingAdditionalData = false;
    moreDataAvailable = true;

    notifyListeners();
    //load all data
    await loadData();
  }

  loadData() async {
    setBusy(true);

    //load data with params
    postResults = await _postDataService.loadPosts(
      areaCode: areaCode,
      resultsLimit: resultsLimit,
      sortBy: sortByFilter,
      tagFilter: tagFilter,
    );

    streamResults = await _liveStreamDataService.loadStreams(
      areaCode: areaCode,
      resultsLimit: resultsLimit,
      sortBy: sortByFilter,
      tagFilter: tagFilter,
    );

    eventResults = await _eventDataService.loadEvents(
      areaCode: areaCode,
      resultsLimit: resultsLimit,
      sortBy: sortByFilter,
      tagFilter: tagFilter,
    );

    notifyListeners();
    sortDataResults();

    loadingAdditionalData = false;

    notifyListeners();
    setBusy(false);
  }

  loadAdditionalData() async {
    if (loadingAdditionalData) {
      return;
    }

    loadingAdditionalData = true;
    notifyListeners();

    if (!loadingAdditionalPosts && morePostsAvailable) {
      await loadAdditionalPosts();
    }
    if (!loadingAdditionalStreams && moreStreamsAvailable) {
      await loadAdditionalStreams();
    }
    if (!loadingAdditionalEvents && moreEventsAvailable) {
      await loadAdditionalEvents();
    }

    if (!morePostsAvailable && !moreStreamsAvailable && !moreEventsAvailable) {
      moreDataAvailable = false;
    }

    sortDataResults();

    loadingAdditionalData = false;
    notifyListeners();
  }

  loadAdditionalPosts() async {
    List<DocumentSnapshot> results = [];

    //set loading additional data status
    loadingAdditionalPosts = true;
    notifyListeners();

    //load additional posts
    if (lastPostDoc != null) {
      results = await _postDataService.loadAdditionalPosts(
        lastDocSnap: lastPostDoc!,
        areaCode: areaCode,
        resultsLimit: resultsLimit,
        sortBy: sortByFilter,
        tagFilter: tagFilter,
      );

      if (results.isNotEmpty) {
        postResults.addAll(results);
      }

      //notify if no more data available
      if (results.length == 0 || results.length < 10) {
        morePostsAvailable = false;
      }
    }

    //set loading additional data status
    loadingAdditionalPosts = false;
    notifyListeners();
  }

  loadAdditionalStreams() async {
    List<DocumentSnapshot> results = [];

    //set loading additional data status
    loadingAdditionalStreams = true;
    notifyListeners();

    //load additional data
    if (lastStreamDoc != null) {
      results = await _liveStreamDataService.loadAdditionalStreams(
        lastDocSnap: lastStreamDoc!,
        areaCode: areaCode,
        resultsLimit: resultsLimit,
        tagFilter: tagFilter,
        sortBy: sortByFilter,
      );

      if (results.isNotEmpty) {
        streamResults.addAll(results);
      }

      //notify if no more data available
      if (results.length == 0 || results.length < 10) {
        moreStreamsAvailable = false;
      }
    }
    //set loading additional streams status
    loadingAdditionalStreams = false;
    notifyListeners();
  }

  loadAdditionalEvents() async {
    List<DocumentSnapshot> results = [];

    //set loading additional data status
    loadingAdditionalEvents = true;
    notifyListeners();

    //load additional data
    if (lastEventDoc != null) {
      results = await _eventDataService.loadAdditionalEvents(
        lastDocSnap: lastEventDoc!,
        areaCode: areaCode,
        resultsLimit: resultsLimit,
        sortBy: sortByFilter,
        tagFilter: tagFilter,
      );

      if (results.isNotEmpty) {
        eventResults.addAll(results);
      }

      //notify if no more data available
      if (results.length == 0 || results.length < 10) {
        moreEventsAvailable = false;
      }
    }
    //set loading additional events status
    loadingAdditionalEvents = false;
    notifyListeners();
  }

  sortDataResults() {
    int contentCount = postResults.length + streamResults.length + eventResults.length;

    for (int i = contentCount; i >= 1; i--) {
      DocumentSnapshot? doc;
      //get streams every 3rd content piece if possible
      if (i % 3 == 0) {
        doc = getStream();
      } else if (i % 8 == 0) {
        doc = getEvent();
      }

      if (doc == null) {
        doc = getPost();
      }

      if (doc == null) {
        //load from streams and events if no more posts
        if (streamResults.length > 0 && eventResults.length > 0) {
          if ((streamResults[0].data() as Map<String, dynamic>)['startDateTimeInMilliseconds'] <
              (eventResults[0].data() as Map<String, dynamic>)['startDateTimeInMilliseconds']) {
            doc = getStream();
          } else {
            doc = getEvent();
          }
        } else if (streamResults.length > 0) {
          doc = getStream();
        } else if (eventResults.length > 0) {
          doc = getEvent();
        }
      }

      if (doc != null) {
        //print(doc.data());
        dataResults.add(doc);
      }
    }

    notifyListeners();
  }

  DocumentSnapshot? getPost() {
    DocumentSnapshot? doc;
    doc = postResults.length > 0 ? postResults.removeAt(0) : null;
    if (doc != null) {
      if (postResults.isEmpty && morePostsAvailable) {
        lastPostDoc = doc;
        notifyListeners();
      }
    }
    return doc;
  }

  Widget getPostWidget(Map<String, dynamic> data) {
    WebblenPost post = WebblenPost.fromMap(data);
    return post.imageURL == null
        ? PostTextBlockView(
            post: post,
            showPostOptions: (post) => showContentOptions(post),
          )
        : PostImgBlockView(
            post: post,
            showPostOptions: (post) => showContentOptions(post),
          );
  }

  DocumentSnapshot? getStream() {
    DocumentSnapshot? doc;
    doc = streamResults.length > 0 ? streamResults.removeAt(0) : null;
    if (doc != null) {
      if (streamResults.isEmpty && moreStreamsAvailable) {
        lastStreamDoc = doc;
        notifyListeners();
      }
    }
    return doc;
  }

  Widget getStreamWidget(Map<String, dynamic> data) {
    WebblenLiveStream stream = WebblenLiveStream.fromMap(data);
    return LiveStreamBlockView(
      stream: stream,
      showStreamOptions: (stream) => showContentOptions(stream),
    );
  }

  DocumentSnapshot? getEvent() {
    DocumentSnapshot? doc;
    doc = eventResults.length > 0 ? eventResults.removeAt(0) : null;
    if (doc != null) {
      if (eventResults.isEmpty && moreEventsAvailable) {
        lastEventDoc = doc;
        notifyListeners();
      }
    }
    return doc;
  }

  Widget getEventWidget(Map<String, dynamic> data) {
    WebblenEvent event = WebblenEvent.fromMap(data);
    return EventBlockView(
      event: event,
      showEventOptions: (event) => showContentOptions(event),
    );
  }

  showContentOptions(dynamic content) async {
    String? val = await customBottomSheetService.showContentOptions(content: content);
    if (val == "deleted content") {
      dataResults.removeWhere((doc) => doc.id == content.id);
      listKey = getRandomString(5);
      notifyListeners();
    }
  }
}
