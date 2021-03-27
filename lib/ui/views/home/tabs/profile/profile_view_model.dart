import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/app/router.gr.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/dynamic_links/dynamic_link_service.dart';
import 'package:webblen/services/firestore/data/event_data_service.dart';
import 'package:webblen/services/firestore/data/live_stream_data_service.dart';
import 'package:webblen/services/firestore/data/post_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/share/share_service.dart';
import 'package:webblen/ui/views/base/webblen_base_view_model.dart';
import 'package:webblen/utils/url_handler.dart';

@singleton
class ProfileViewModel extends BaseViewModel {
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

  ///UI HELPERS
  ScrollController scrollController = ScrollController();

  ///POST DATA
  List<DocumentSnapshot> postResults = [];
  DocumentSnapshot lastPostDocSnap;

  bool loadingAdditionalPosts = false;
  bool morePostsAvailable = true;
  bool reloadingPosts = false;

  ///EVENT DATA
  List<DocumentSnapshot> eventResults = [];
  DocumentSnapshot lastEventDocSnap;

  bool reloadingEvents = false;
  bool loadingAdditionalEvents = false;
  bool moreEventsAvailable = true;

  ///STREAM DATA
  List<DocumentSnapshot> streamResults = [];
  DocumentSnapshot lastStreamDocSnap;

  bool reloadingStreams = false;
  bool loadingAdditionalStreams = false;
  bool moreStreamsAvailable = true;

  int resultsLimit = 20;

  ///INITIALIZE
  initialize({BuildContext context, TabController tabController}) async {
    //set busy status
    setBusy(true);

    //get current user
    notifyListeners();

    //load additional data on scroll
    scrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * scrollController.position.maxScrollExtent;
      if (scrollController.position.pixels > triggerFetchMoreSize) {
        if (tabController.index == 0 && postResults.length > 2) {
          loadAdditionalPosts();
        } else if (tabController.index == 1 && streamResults.length > 2) {
          loadAdditionalStreams();
        } else if (tabController.index == 2 && eventResults.length > 2) {
          loadAdditionalEvents();
        }
      }
    });
    notifyListeners();

    //load profile data
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

  ///REFRESH DATA
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

  Future<void> refreshPosts() async {
    await loadPosts();
    notifyListeners();
  }

  ///POST DATA
  loadPosts() async {
    //load posts with params
    postResults = await _postDataService.loadPostsByUserID(id: webblenBaseViewModel.uid, resultsLimit: resultsLimit);
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
    List<DocumentSnapshot> newResults = await _postDataService.loadAdditionalPostsByUserID(
      lastDocSnap: postResults[postResults.length - 1],
      id: webblenBaseViewModel.uid,
      resultsLimit: resultsLimit,
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
    reloadingStreams = true;

    //clear previous stream data
    streamResults = [];
    notifyListeners();

    //load streams
    await loadStreams();
  }

  loadStreams() async {
    //load streams with params
    streamResults = await _liveStreamDataService.loadStreamsByUserID(
      id: webblenBaseViewModel.uid,
      resultsLimit: resultsLimit,
    );

    //set loading streams status
    reloadingStreams = false;
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
    List<DocumentSnapshot> newResults = await _liveStreamDataService.loadAdditionalStreamsByUserID(
      id: webblenBaseViewModel.uid,
      lastDocSnap: streamResults[streamResults.length - 1],
      resultsLimit: resultsLimit,
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
    reloadingEvents = true;

    //clear previous post data
    eventResults = [];
    notifyListeners();

    //load posts
    await loadEvents();
  }

  loadEvents() async {
    //load events with params
    eventResults = await _eventDataService.loadEventsByUserID(
      id: webblenBaseViewModel.uid,
      resultsLimit: resultsLimit,
    );

    //set loading events status
    reloadingEvents = false;
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
    List<DocumentSnapshot> newResults = await _eventDataService.loadAdditionalEventsByUserID(
      lastDocSnap: postResults[postResults.length - 1],
      id: webblenBaseViewModel.uid,
      resultsLimit: resultsLimit,
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

  ///OTHER
  openWebsite() {
    UrlHandler().launchInWebViewOrVC(webblenBaseViewModel.user.website);
  }

  ///BOTTOM SHEETS
  showUserOptions() async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      barrierDismissible: true,
      variant: BottomSheetType.currentUserOptions,
    );
    if (sheetResponse != null) {
      String res = sheetResponse.responseData;
      if (res == "saved") {
        //saved
      } else if (res == "edit profile") {
        //edit profile
        navigateToEditProfileView();
      } else if (res == "share profile") {
        //share profile
        String url = await _dynamicLinkService.createProfileLink(user: webblenBaseViewModel.user);
        _shareService.shareLink(url);
      } else if (res == "settings") {
        navigateToSettingsView();
      }
      notifyListeners();
    }
  }

  //bottom sheet for new post, stream, or event
  showAddContentOptions() async {
    webblenBaseViewModel.showAddContentOptions();
  }

  //show content options
  showContentOptions({@required dynamic content}) async {
    print(content);
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

  ///NAVIGATION
  navigateToEditProfileView() {
    _navigationService.navigateTo(Routes.EditProfileViewRoute, arguments: {'id': webblenBaseViewModel.uid});
  }

  navigateToUserFollowersView() {
    _navigationService.navigateTo(Routes.UserFollowersViewRoute);
  }

  navigateToUserFollowingView() {
    _navigationService.navigateTo(Routes.UserFollowingViewRoute);
  }

  navigateToSettingsView() {
    _navigationService.navigateTo(Routes.SettingsViewRoute);
  }
}
