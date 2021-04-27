import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/algolia/algolia_search_service.dart';
import 'package:webblen/ui/views/base/webblen_base_view_model.dart';

class AllSearchResultsViewModel extends BaseViewModel {
  NavigationService? _navigationService = locator<NavigationService>();
  AlgoliaSearchService? _algoliaSearchService = locator<AlgoliaSearchService>();
  WebblenBaseViewModel? webblenBaseViewModel = locator<WebblenBaseViewModel>();

  ///HELPERS
  TextEditingController searchTextController = TextEditingController();
  ScrollController postScrollController = ScrollController();
  ScrollController streamScrollController = ScrollController();
  ScrollController eventScrollController = ScrollController();
  ScrollController userScrollController = ScrollController();

  ///DATA RESULTS
  String? searchTerm;
  List<WebblenPost> postResults = [];
  bool loadingAdditionalPosts = false;
  bool morePostsAvailable = true;
  int postResultsPageNum = 1;

  List<WebblenLiveStream> streamResults = [];
  bool loadingAdditionalStreams = false;
  bool moreStreamsAvailable = true;
  int streamResultsPageNum = 1;

  List<WebblenEvent> eventResults = [];
  bool loadingAdditionalEvents = false;
  bool moreEventsAvailable = true;
  int eventResultsPageNum = 1;

  List<WebblenUser> userResults = [];
  bool loadingAdditionalUsers = false;
  bool moreUsersAvailable = true;
  int userResultsPageNum = 1;

  int resultsLimit = 15;

  initialize(BuildContext context, String? searchTermVal) async {
    searchTerm = searchTermVal;
    searchTextController.text = searchTerm!;
    notifyListeners();
    postScrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * postScrollController.position.maxScrollExtent;
      if (postScrollController.position.pixels > triggerFetchMoreSize) {
        loadAdditionalPosts();
      }
    });
    streamScrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * streamScrollController.position.maxScrollExtent;
      if (streamScrollController.position.pixels > triggerFetchMoreSize) {
        loadAdditionalStreams();
      }
    });
    eventScrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * eventScrollController.position.maxScrollExtent;
      if (eventScrollController.position.pixels > triggerFetchMoreSize) {
        loadAdditionalEvents();
      }
    });
    userScrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * userScrollController.position.maxScrollExtent;
      if (userScrollController.position.pixels > triggerFetchMoreSize) {
        loadAdditionalUsers();
      }
    });
    notifyListeners();
    await loadPosts();
    await loadStreams();
    await loadEvents();
    await loadUsers();
    setBusy(false);
  }

  ///STREAMS
  Future<void> refreshPosts() async {
    postResults = [];
    await loadPosts();
    notifyListeners();
  }

  loadPosts() async {
    postResults = await _algoliaSearchService!.queryPosts(searchTerm: searchTerm, resultsLimit: resultsLimit);
    postResultsPageNum += 1;
    notifyListeners();
  }

  loadAdditionalPosts() async {
    if (loadingAdditionalPosts || !morePostsAvailable) {
      return;
    }
    loadingAdditionalPosts = true;
    notifyListeners();
    List<WebblenPost> newResults = await _algoliaSearchService!.queryAdditionalPosts(
      searchTerm: searchTerm,
      resultsLimit: resultsLimit,
      pageNum: streamResultsPageNum,
    );
    if (newResults.length == 0) {
      morePostsAvailable = false;
    } else {
      postResults.addAll(newResults);
    }

    loadingAdditionalPosts = false;
    notifyListeners();
  }

  ///STREAMS
  Future<void> refreshStreams() async {
    streamResults = [];
    notifyListeners();
    await loadStreams();
  }

  loadStreams() async {
    streamResults = await _algoliaSearchService!.queryStreams(searchTerm: searchTerm, resultsLimit: resultsLimit);
    streamResultsPageNum += 1;
    notifyListeners();
  }

  loadAdditionalStreams() async {
    if (loadingAdditionalStreams || !moreStreamsAvailable) {
      return;
    }
    loadingAdditionalStreams = true;
    notifyListeners();
    List<WebblenLiveStream> newResults = await _algoliaSearchService!.queryAdditionalStreams(
      searchTerm: searchTerm,
      resultsLimit: resultsLimit,
      pageNum: streamResultsPageNum,
    );
    if (newResults.length == 0) {
      moreStreamsAvailable = false;
    } else {
      streamResults.addAll(newResults);
    }
    loadingAdditionalStreams = false;
    notifyListeners();
  }

  ///EVENTS
  Future<void> refreshEvents() async {
    eventResults = [];
    notifyListeners();
    await loadEvents();
  }

  loadEvents() async {
    eventResults = await _algoliaSearchService!.queryEvents(searchTerm: searchTerm, resultsLimit: resultsLimit);
    eventResultsPageNum += 1;
    notifyListeners();
  }

  loadAdditionalEvents() async {
    if (loadingAdditionalEvents || !moreEventsAvailable) {
      return;
    }
    loadingAdditionalEvents = true;
    notifyListeners();
    List<WebblenEvent> newResults = await _algoliaSearchService!.queryAdditionalEvents(
      searchTerm: searchTerm,
      resultsLimit: resultsLimit,
      pageNum: streamResultsPageNum,
    );
    if (newResults.length == 0) {
      moreEventsAvailable = false;
    } else {
      eventResults.addAll(newResults);
    }
    loadingAdditionalStreams = false;
    notifyListeners();
  }

  ///USERS
  Future<void> refreshUsers() async {
    userResults = [];
    notifyListeners();
    await loadUsers();
  }

  loadUsers() async {
    userResults = await _algoliaSearchService!.queryUsers(searchTerm: searchTerm, resultsLimit: resultsLimit);
    userResultsPageNum += 1;
    notifyListeners();
  }

  loadAdditionalUsers() async {
    if (loadingAdditionalUsers || !moreUsersAvailable) {
      return;
    }
    loadingAdditionalUsers = true;
    notifyListeners();
    List<WebblenUser> newResults = await _algoliaSearchService!.queryAdditionalUsers(
      searchTerm: searchTerm,
      resultsLimit: resultsLimit,
      pageNum: userResultsPageNum,
    );
    if (newResults.length == 0) {
      moreUsersAvailable = false;
    } else {
      userResults.addAll(newResults);
      userResultsPageNum += 1;
    }
    loadingAdditionalUsers = false;
    notifyListeners();
  }

  //show content options
  showContentOptions({required dynamic content}) async {
    var actionPerformed = await webblenBaseViewModel!.showContentOptions(content: content);
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
  navigateToPreviousPage() {
    _navigationService!.back();
  }

  navigateToHomePage() {
    _navigationService!.popRepeated(2);
  }
//
// navigateToPage() {
//   _navigationService.navigateTo(PageRouteName);
// }
}
