// import 'package:flutter/cupertino.dart';
// // import 'package:stacked/stacked.dart';
// import 'package:webblen/app/app.locator.dart';// import 'package:webblen/services/firestore/data/for_you_event_data_service.dart';
// import 'package:webblen/services/firestore/data/for_you_post_data_service.dart';
// import 'package:webblen/ui/views/base/webblen_base_view_model.dart';
//
// @lazySingleton
// class ListContentForYouModel extends BaseViewModel {
//   ForYouPostDataService _forYouPostDataService = locator<ForYouPostDataService>();
//   ForYouEventDataService _forYouEventDataService = locator<ForYouEventDataService>();
//   WebblenBaseViewModel webblenBaseViewModel = locator<WebblenBaseViewModel>();
//
//   ///HELPERS
//   ScrollController scrollController = ScrollController();
//
//   ///FILTER DATA
//   String cityName;
//   String areaCode;
//   String contentTagFilter;
//   String contentSortBy;
//
//   ///DATA
//   List<Map<String, dynamic>> dataResults = [];
//
//   bool loadingAdditionalData = false;
//   bool moreDataAvailable = true;
//
//   Map<String, dynamic> lastPost;
//   Map<String, dynamic> lastEvent;
//
//   int resultsLimit = 5;
//
//   initialize() async {
//     // load additional data on scroll
//     scrollController.addListener(() {
//       double triggerFetchMoreSize = 0.9 * scrollController.position.maxScrollExtent;
//       if (scrollController.position.pixels > triggerFetchMoreSize) {
//         loadAdditionalData();
//       }
//     });
//
//     // listener for changed filter
//     webblenBaseViewModel.addListener(() {
//       bool filterChanged = false;
//       if (cityName != webblenBaseViewModel.cityName) {
//         filterChanged = true;
//         cityName = webblenBaseViewModel.cityName;
//       }
//       if (areaCode != webblenBaseViewModel.areaCode) {
//         filterChanged = true;
//         areaCode = webblenBaseViewModel.areaCode;
//       }
//       if (contentTagFilter != webblenBaseViewModel.contentTagFilter) {
//         filterChanged = true;
//         contentTagFilter = webblenBaseViewModel.contentTagFilter;
//       }
//       if (contentSortBy != webblenBaseViewModel.contentSortBy) {
//         filterChanged = true;
//         contentSortBy = webblenBaseViewModel.contentSortBy;
//       }
//       if (filterChanged) {
//         refreshData();
//       }
//     });
//
//     await loadData();
//   }
//
//   Future<void> refreshData() async {
//     scrollController.jumpTo(scrollController.position.minScrollExtent);
//
//     //clear previous data
//     dataResults = [];
//     loadingAdditionalData = false;
//     moreDataAvailable = true;
//
//     notifyListeners();
//     //load all data
//     await loadData();
//   }
//
//   loadData() async {
//     setBusy(true);
//     List<Map<String, dynamic>> additionalData;
//
//     //load data with params
//     dataResults = await _forYouPostDataService.loadSuggestedPosts(
//       areaCode: webblenBaseViewModel.areaCode,
//       resultsLimit: resultsLimit,
//       tagFilter: webblenBaseViewModel.contentTagFilter,
//       sortBy: webblenBaseViewModel.contentSortBy,
//     );
//
//     //load following posts
//     additionalData = await _forYouPostDataService.loadFollowingPosts(
//       id: webblenBaseViewModel.uid,
//       resultsLimit: resultsLimit,
//     );
//
//     dataResults.addAll(additionalData);
//
//     //load events
//     additionalData = await _forYouEventDataService.loadSuggestedEvents(
//       areaCode: webblenBaseViewModel.areaCode,
//       resultsLimit: resultsLimit,
//       tagFilter: webblenBaseViewModel.contentTagFilter,
//       sortBy: webblenBaseViewModel.contentSortBy,
//     );
//
//     dataResults.addAll(additionalData);
//
//     //load following events
//     additionalData = await _forYouEventDataService.loadFollowingEvents(
//       id: webblenBaseViewModel.uid,
//       resultsLimit: resultsLimit,
//     );
//     notifyListeners();
//
//     setBusy(false);
//   }
//
//   loadAdditionalData() async {
//     // //check if already loading data or no more data available
//     // if (loadingAdditionalData || !moreDataAvailable) {
//     //   return;
//     // }
//     //
//     // //set loading additional data status
//     // loadingAdditionalData = true;
//     // notifyListeners();
//     //
//     // //load additional posts
//     // List<DocumentSnapshot> newResults = await _postDataService.loadAdditionalPosts(
//     //   lastDocSnap: dataResults[dataResults.length - 1],
//     //   areaCode: webblenBaseViewModel.areaCode,
//     //   resultsLimit: resultsLimit,
//     //   tagFilter: webblenBaseViewModel.contentTagFilter,
//     //   sortBy: webblenBaseViewModel.contentSortBy,
//     // );
//     //
//     // //notify if no more posts available
//     // if (newResults.length == 0) {
//     //   moreDataAvailable = false;
//     // } else {
//     //   dataResults.addAll(newResults);
//     // }
//     //
//     // //set loading additional posts status
//     // loadingAdditionalData = false;
//     // notifyListeners();
//   }
// }
