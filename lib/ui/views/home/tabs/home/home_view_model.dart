import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/dynamic_links/dynamic_link_service.dart';
import 'package:webblen/services/firestore/data/event_data_service.dart';
import 'package:webblen/services/firestore/data/live_stream_data_service.dart';
import 'package:webblen/services/firestore/data/platform_data_service.dart';
import 'package:webblen/services/firestore/data/post_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/share/share_service.dart';
import 'package:webblen/ui/views/base/webblen_base_view_model.dart';

@singleton
class HomeViewModel extends BaseViewModel {
  ///SERVICES
  PlatformDataService _platformDataService = locator<PlatformDataService>();
  AuthService _authService = locator<AuthService>();
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  UserDataService _userDataService = locator<UserDataService>();
  BottomSheetService _bottomSheetService = locator<BottomSheetService>();
  SnackbarService _snackbarService = locator<SnackbarService>();
  DynamicLinkService _dynamicLinkService = locator<DynamicLinkService>();
  PostDataService _postDataService = locator<PostDataService>();
  LiveStreamDataService _liveStreamDataService = locator<LiveStreamDataService>();
  EventDataService _eventDataService = locator<EventDataService>();
  ShareService _shareService = locator<ShareService>();
  WebblenBaseViewModel webblenBaseViewModel = locator<WebblenBaseViewModel>();

  ///HELPERS
  ScrollController scrollController = ScrollController();

  ///CURRENT USER
  WebblenUser user;

  ///FILTERS
  String cityName;
  String areaCode;
  String sortBy = "Latest";
  String tagFilter = "";

  ///FOR YOU DATA
  List<dynamic> forYouResults = [];
  bool loadingForYou = true;
  bool loadingAdditionalForYou = false;
  bool moreForYouAvailable = true;

  ///POST DATA
  List<DocumentSnapshot> postResults = [];
  DocumentSnapshot lastPostDocSnap;

  bool loadingPosts = true;
  bool loadingAdditionalPosts = false;
  bool morePostsAvailable = true;

  ///EVENT DATA
  List<DocumentSnapshot> eventResults = [];
  DocumentSnapshot lastEventDocSnap;

  bool loadingEvents = true;
  bool loadingAdditionalEvents = false;
  bool moreEventsAvailable = true;

  ///STREAM DATA
  List<DocumentSnapshot> streamResults = [];
  DocumentSnapshot lastStreamDocSnap;

  bool loadingStreams = false;
  bool loadingAdditionalStreams = false;
  bool moreStreamsAvailable = true;

  int resultsLimit = 30;

  ///PROMOS
  double postPromo;
  double streamPromo;
  double eventPromo;

  openFilter() async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      barrierDismissible: true,
      variant: BottomSheetType.homeFilter,
      takesInput: true,
      customData: {
        'currentCityName': cityName,
        'currentAreaCode': areaCode,
        'currentSortBy': sortBy,
        'currentTagFilter': tagFilter,
      },
    );
    if (sheetResponse != null && sheetResponse.responseData != null) {
      cityName = sheetResponse.responseData['cityName'];
      areaCode = sheetResponse.responseData['areaCode'];
      sortBy = sheetResponse.responseData['sortBy'];
      tagFilter = sheetResponse.responseData['tagFilter'];
      notifyListeners();
      refreshData();
    }
  }

  ///INITIALIZE
  initialize({TabController tabController}) async {
    //get location data
    cityName = webblenBaseViewModel.initialCityName;
    areaCode = webblenBaseViewModel.initialAreaCode;

    //load content promos (if any exists)
    postPromo = await _platformDataService.getPostPromo();
    streamPromo = await _platformDataService.getStreamPromo();
    eventPromo = await _platformDataService.getEventPromo();

    //load additional content on scroll
    scrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * scrollController.position.maxScrollExtent;
      if (scrollController.position.pixels > triggerFetchMoreSize) {
        if (tabController.index == 1) {
          loadAdditionalPosts();
        } else if (tabController.index == 2) {
          loadAdditionalStreams();
        } else if (tabController.index == 3) {
          loadAdditionalEvents();
        }
      }
    });
    notifyListeners();
    //load content data
    await loadData();
    setBusy(false);
  }

  ///LOAD ALL DATA
  loadData() async {
    await loadPosts();
    await loadStreams();
    await loadEvents();
    //await loadForYouContent();
  }

  ///REFRESH ALL DATA
  Future<void> refreshData() async {
    //set busy status
    setBusy(true);

    //clear previous data
    postResults = [];
    streamResults = [];
    eventResults = [];
    //forYouResults = [];

    //load all data
    await loadData();
    notifyListeners();

    //set busy status
    setBusy(false);
  }

  ///POST DATA
  Future<void> refreshPosts() async {
    //set loading posts status
    loadingPosts = true;

    //clear previous post data
    postResults = [];
    notifyListeners();

    //load posts
    await loadPosts();
  }

  loadPosts() async {
    //load posts with params
    postResults = await _postDataService.loadPosts(
      areaCode: areaCode,
      resultsLimit: resultsLimit,
      tagFilter: tagFilter,
      sortBy: sortBy,
    );

    //set loading posts status
    loadingPosts = false;
    notifyListeners();
  }

  loadAdditionalPosts() async {
    //check if already loading posts or no more posts available
    if (loadingAdditionalPosts || !morePostsAvailable) {
      return;
    }

    //set loading additional posts status
    loadingAdditionalPosts = true;
    notifyListeners();

    //load additional posts
    List<DocumentSnapshot> newResults = await _postDataService.loadAdditionalPosts(
      lastDocSnap: postResults[postResults.length - 1],
      areaCode: areaCode,
      resultsLimit: resultsLimit,
      tagFilter: tagFilter,
      sortBy: sortBy,
    );

    //notify if no more posts available
    if (newResults.length == 0) {
      morePostsAvailable = false;
    } else {
      postResults.addAll(newResults);
    }

    //set loading additional posts status
    loadingAdditionalPosts = false;
    notifyListeners();
  }

  ///STREAM DATA
  Future<void> refreshStreams() async {
    //set loading streams status
    loadingStreams = true;

    //clear previous stream data
    streamResults = [];
    notifyListeners();

    //load streams
    await loadStreams();
  }

  loadStreams() async {
    //load events with params
    streamResults = await _liveStreamDataService.loadStreams(
      areaCode: areaCode,
      resultsLimit: resultsLimit,
      tagFilter: tagFilter,
      sortBy: sortBy,
    );

    //set loading events status
    loadingStreams = false;
    notifyListeners();
  }

  loadAdditionalStreams() async {
    //check if already loading streams or no more streams available
    if (loadingAdditionalStreams || !moreStreamsAvailable) {
      return;
    }

    //set loading additional streams status
    loadingAdditionalStreams = true;
    notifyListeners();

    //load additional streams
    List<DocumentSnapshot> newResults = await _liveStreamDataService.loadAdditionalStreams(
      lastDocSnap: streamResults[streamResults.length - 1],
      areaCode: areaCode,
      resultsLimit: resultsLimit,
      tagFilter: tagFilter,
      sortBy: sortBy,
    );

    //notify if no more streams available
    if (newResults.length == 0) {
      moreStreamsAvailable = false;
    } else {
      streamResults.addAll(newResults);
    }

    //set loading additional streams status
    loadingAdditionalStreams = false;
    notifyListeners();
  }

  ///EVENT DATA
  Future<void> refreshEvents() async {
    //set loading posts status
    loadingEvents = true;

    //clear previous post data
    eventResults = [];
    notifyListeners();

    //load posts
    await loadEvents();
  }

  loadEvents() async {
    //load events with params
    eventResults = await _eventDataService.loadEvents(
      areaCode: areaCode,
      resultsLimit: resultsLimit,
      tagFilter: tagFilter,
      sortBy: sortBy,
    );

    //set loading events status
    loadingEvents = false;
    notifyListeners();
  }

  loadAdditionalEvents() async {
    //check if already loading events or no more events available
    if (loadingAdditionalEvents || !moreEventsAvailable) {
      return;
    }

    //set loading additional events status
    loadingAdditionalEvents = true;
    notifyListeners();

    //load additional events
    List<DocumentSnapshot> newResults = await _eventDataService.loadAdditionalEvents(
      lastDocSnap: eventResults[eventResults.length - 1],
      areaCode: areaCode,
      resultsLimit: resultsLimit,
      tagFilter: tagFilter,
      sortBy: sortBy,
    );

    //notify if no more events available
    if (newResults.length == 0) {
      moreEventsAvailable = false;
    } else {
      eventResults.addAll(newResults);
    }

    //set loading additional events status
    loadingAdditionalEvents = false;
    notifyListeners();
  }

  ///PROMO
  createPostWithPromo() {
    webblenBaseViewModel.createPostWithPromo(promo: postPromo);
  }

  createEventWithPromo() {
    webblenBaseViewModel.createEventWithPromo(promo: eventPromo);
  }

  createStreamWithPromo() {
    webblenBaseViewModel.createStreamWithPromo(promo: streamPromo);
  }

  ///BOTTOM SHEETS
  //bottom sheet for new post, stream, or event
  showAddContentOptions() async {
    webblenBaseViewModel.showAddContentOptions();
  }

  //show content options
  showContentOptions({@required dynamic content}) async {
    var actionPerformed = await webblenBaseViewModel.showContentOptions(content: content);
    if (actionPerformed == "deleted content") {
      if (content is WebblenPost) {
        //deleted post
        postResults.removeWhere((doc) => doc.id == content.id);
        notifyListeners();
      } else if (content is WebblenEvent) {
        //deleted event
        eventResults.removeWhere((doc) => doc.id == content.id);
        notifyListeners();
      } else if (content is WebblenLiveStream) {
        //deleted stream
        streamResults.removeWhere((doc) => doc.id == content.id);
        notifyListeners();
      }
    }
  }
}
