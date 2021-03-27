import 'package:injectable/injectable.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/ui/views/base/webblen_base_view_model.dart';
import 'package:webblen/ui/views/search/search_view.dart';

@singleton
class RecentSearchViewModel extends BaseViewModel {
  NavigationService _navigationService = locator<NavigationService>();
  WebblenBaseViewModel webblenBaseViewModel = locator<WebblenBaseViewModel>();

  ///DATA RESULTS
  List recentSearchTerms = [];
  String uid;

  showAddContentOptions() async {
    webblenBaseViewModel.showAddContentOptions();
  }

  researchTerm(String term) {
    _navigationService.navigateWithTransition(SearchView(term: term), transition: 'fade', opaque: true);
  }

  navigateToSearchView() {
    _navigationService.navigateWithTransition(SearchView(), transition: 'fade', opaque: true);
  }
}
