import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/bottom_sheets/custom_bottom_sheets_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';

class ListRecentlySearchedTermsModel extends ReactiveViewModel {
  CustomNavigationService customNavigationService = locator<CustomNavigationService>();
  CustomBottomSheetService customBottomSheetService = locator<CustomBottomSheetService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();

  ///HELPERS
  ScrollController scrollController = ScrollController();
  String listKey = "initial-search-results-key";

  ///USER DATA
  WebblenUser get user => _reactiveUserService.user;

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_reactiveUserService];

  navigateToSearchWithTerm(String term) async {
    customNavigationService.navigateToSearchViewWithTerm(term);
  }
}
