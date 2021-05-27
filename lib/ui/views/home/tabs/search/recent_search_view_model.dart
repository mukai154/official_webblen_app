import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/bottom_sheets/custom_bottom_sheets_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/ui/views/search/search_view.dart';

class RecentSearchViewModel extends BaseViewModel {
  NavigationService? _navigationService = locator<NavigationService>();
  CustomBottomSheetService customBottomSheetService = locator<CustomBottomSheetService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();

  ///USER DATA
  WebblenUser get user => _reactiveUserService.user;

  ///DATA RESULTS
  List recentSearchTerms = [];
  String? uid;

  researchTerm(String term) {
    _navigationService!.navigateWithTransition(SearchView(term: term), transition: 'fade', opaque: true);
  }

  navigateToSearchView() {
    _navigationService!.navigateWithTransition(SearchView(), transition: 'fade', opaque: true);
  }
}
