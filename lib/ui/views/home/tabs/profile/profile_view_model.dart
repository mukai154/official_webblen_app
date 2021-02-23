import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/app/router.gr.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';

@singleton
class ProfileViewModel extends BaseViewModel {
  AuthService _authService = locator<AuthService>();
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  UserDataService _userDataService = locator<UserDataService>();
  BottomSheetService _bottomSheetService = locator<BottomSheetService>();
  SnackbarService _snackbarService = locator<SnackbarService>();
  CollectionReference postsRef = FirebaseFirestore.instance.collection("posts");

  ScrollController scrollController = ScrollController();

  List<DocumentSnapshot> postResults = [];
  DocumentSnapshot lastPostDocSnap;

  bool loadingAdditionalPosts = false;
  bool morePostsAvailable = true;

  int resultsLimit = 20;

  WebblenUser user;

  initialize(TabController tabController, WebblenUser currentUser) async {
    //set busy status
    setBusy(true);

    //get current user
    user = currentUser;
    notifyListeners();

    //load additional data on scroll
    scrollController.addListener(() {
      double triggerFetchMoreSize = 0.9 * scrollController.position.maxScrollExtent;
      if (scrollController.position.pixels > triggerFetchMoreSize) {
        if (tabController.index == 0) {
          loadAdditionalPosts();
        }
      }
    });
    notifyListeners();

    //load profile data
    await loadData();
    setBusy(false);
  }

  loadData() async {
    await loadPosts();
  }

  Future<void> refreshPosts() async {
    postResults = [];
    notifyListeners();
    await loadPosts();
  }

  ///Load Data
  loadPosts() async {
    Query query;
    // if (areaCodeFilter.isEmpty) {
    query = postsRef.where('authorID', isEqualTo: user.id).orderBy('postDateTimeInMilliseconds', descending: true).limit(resultsLimit);
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
        .where('authorID', isEqualTo: user.id)
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

  ///SHOW OPTIONS
  showOptions() async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      barrierDismissible: true,
      variant: BottomSheetType.currentUserOptions,
    );
    if (sheetResponse != null) {
      String res = sheetResponse.responseData;
      if (res == "edit profile") {
        //edit profile
      } else if (res == "saved") {
        //saved
      } else if (res == "settings") {
        navigateToSettingsPage();
      }
      notifyListeners();
    }
  }

  ///NAVIGATION
// replaceWithPage() {
//   _navigationService.replaceWith(PageRouteName);
// }
//
  navigateToSettingsPage() {
    _navigationService.navigateTo(Routes.SettingsViewRoute);
  }
}
