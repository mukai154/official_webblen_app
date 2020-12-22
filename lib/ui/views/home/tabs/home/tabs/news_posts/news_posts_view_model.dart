import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';

@singleton
class NewsPostsViewModel extends BaseViewModel {
  // DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  SnackbarService _snackbarService = locator<SnackbarService>();
  CollectionReference postsRef = FirebaseFirestore.instance.collection("posts");

  String authorImageURL;
  String authorUsername;
  int dateTimeInMilliseconds1MonthAgo = DateTime.now().millisecondsSinceEpoch - 2628000000;
  ScrollController postsScrollController = ScrollController();

  List<DocumentSnapshot> postResults = [];
  DocumentSnapshot lastPostDocSnap;

  bool loadingAdditionalPosts = false;
  bool morePostsAvailable = true;

  int resultsLimit = 20;

  initialize() async {
    setBusy(true);
    postsScrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * postsScrollController.position.maxScrollExtent;
      if (postsScrollController.position.pixels > triggerFetchMoreSize) {
        loadAdditionalPosts();
      }
    });
    notifyListeners();
    await loadPosts();
    setBusy(false);
  }

  Future<void> refreshData() async {
    postResults = [];
    notifyListeners();
    await loadPosts();
  }

  loadPosts() async {
    Query query;
    // if (areaCodeFilter.isEmpty) {
    query = postsRef
        .where('postDateTimeInMilliseconds', isGreaterThan: dateTimeInMilliseconds1MonthAgo)
        .orderBy('postDateTimeInMilliseconds', descending: true)
        .limit(resultsLimit);
    // } else {
    //   query = postsRef
    //       .where('nearbyZipcodes', arrayContains: areaCodeFilter)
    //       .where('postDateTimeInMilliseconds', isGreaterThan: dateTimeInMilliseconds1MonthAgo)
    //       .orderBy('postDateTimeInMilliseconds', descending: true)
    //       .limit(resultsPerPage);
    // }
    QuerySnapshot snapshot = await query.get().catchError((e) {
      print(e);
      _snackbarService.showSnackbar(
        title: 'Error',
        message: e.message,
        duration: Duration(seconds: 5),
      );
    });

    if (snapshot.docs.isNotEmpty) {
      lastPostDocSnap = snapshot.docs[snapshot.docs.length - 1];
      postResults = snapshot.docs;
      // if (tagFilter.isNotEmpty) {
      //   postResults.removeWhere((doc) => !doc.data()['tags'].contains(tagFilter));
      // }
      // if (sortBy == "Latest") {
      //   postResults.sort((docA, docB) => docB.data()['postDateTimeInMilliseconds'].compareTo(docA.data()['postDateTimeInMilliseconds']));
      // } else {
      //   postResults.sort((docA, docB) => docB.data()['commentCount'].compareTo(docA.data()['commentCount']));
      // }
    }
    notifyListeners();
  }

  loadAdditionalPosts() async {
    if (loadingAdditionalPosts || !morePostsAvailable) {
      return;
    }
    loadingAdditionalPosts = true;
    notifyListeners();
    Query query;
    // if (areaCodeFilter.isEmpty) {
    query = postsRef
        .where('postDateTimeInMilliseconds', isGreaterThan: dateTimeInMilliseconds1MonthAgo)
        .orderBy('postDateTimeInMilliseconds', descending: true)
        .startAfterDocument(lastPostDocSnap)
        .limit(resultsLimit);
    // } else {
    //   query = postsRef
    //       .where('nearbyZipcodes', arrayContains: areaCodeFilter)
    //       .where('postDateTimeInMilliseconds', isGreaterThan: dateTimeInMilliseconds1MonthAgo)
    //       .orderBy('postDateTimeInMilliseconds', descending: true)
    //       .startAfterDocument(lastPostDocSnap)
    //       .limit(resultsPerPage);
    // }
    QuerySnapshot querySnapshot = await query.get().catchError((e) {
      print(e);
      _snackbarService.showSnackbar(
        title: 'Error',
        message: e.message,
        duration: Duration(seconds: 5),
      );
    });
    if (querySnapshot.docs.isNotEmpty) {
      lastPostDocSnap = querySnapshot.docs[querySnapshot.docs.length - 1];
    }
    postResults.addAll(querySnapshot.docs);
    // if (tagFilter.isNotEmpty) {
    //   postResults.removeWhere((doc) => !doc.data()['tags'].contains(tagFilter));
    // }
    // if (sortBy == "Most Popular") {
    //   postResults.sort((docA, docB) => docB.data()['commentCount'].compareTo(docA.data()['commentCount']));
    // }
    // if (querySnapshot.docs.length == 0) {
    //   morePostsAvailable = false;
    // }
    loadingAdditionalPosts = false;
    notifyListeners();
  }

  ///NAVIGATION
// replaceWithPage() {
//   _navigationService.replaceWith(PageRouteName);
// }
//
//   navigateToCreateCauseView() {
//     _navigationService.navigateTo(Routes.CreateCauseViewRoute);
//   }

}
