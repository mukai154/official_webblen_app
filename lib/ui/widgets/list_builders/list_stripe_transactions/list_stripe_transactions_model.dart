import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/bottom_sheets/custom_bottom_sheets_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/services/stripe/stripe_connect_account_service.dart';
import 'package:webblen/utils/custom_string_methods.dart';

class ListStripeTransactionsModel extends ReactiveViewModel {
  StripeConnectAccountService _stripeConnectAccountService = locator<StripeConnectAccountService>();
  CustomBottomSheetService customBottomSheetService = locator<CustomBottomSheetService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();

  ///HELPERS
  ScrollController scrollController = ScrollController();
  String listKey = "initial-stripe-transactions-key";

  ///USER DATA
  WebblenUser get user => _reactiveUserService.user;

  ///DATA
  List<DocumentSnapshot> dataResults = [];

  bool loadingAdditionalData = false;
  bool moreDataAvailable = true;

  int resultsLimit = 10;

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_reactiveUserService];

  initialize() async {
    await loadData();
  }

  Future<void> refreshData() async {
    scrollController.jumpTo(scrollController.position.minScrollExtent);

    //clear previous data
    dataResults = [];
    loadingAdditionalData = false;
    moreDataAvailable = true;

    notifyListeners();
    //load all data
    await loadData();
  }

  loadData() async {
    setBusy(true);

    //load data with params
    dataResults = await _stripeConnectAccountService.loadStripeTransactions(
      id: user.id,
      resultsLimit: resultsLimit,
    );

    notifyListeners();

    setBusy(false);
  }

  loadAdditionalData() async {
    //check if already loading data or no more data available
    if (loadingAdditionalData || !moreDataAvailable) {
      return;
    }

    //set loading additional data status
    loadingAdditionalData = true;
    notifyListeners();

    //load additional posts
    List<DocumentSnapshot> newResults = await _stripeConnectAccountService.loadAdditionalTransactions(
      id: user.id,
      lastDocSnap: dataResults[dataResults.length - 1],
      resultsLimit: resultsLimit,
    );

    //notify if no more posts available
    if (newResults.length == 0) {
      moreDataAvailable = false;
    } else {
      dataResults.addAll(newResults);
    }

    //set loading additional posts status
    loadingAdditionalData = false;
    notifyListeners();
  }

  showContentOptions(dynamic content) async {
    String val = await customBottomSheetService.showContentOptions(content: content);
    if (val == "deleted content") {
      dataResults.removeWhere((doc) => doc.id == content.id);
      listKey = getRandomString(5);
      notifyListeners();
    }
  }
}
