import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';

class SuggestAccountsViewModel extends BaseViewModel {
  AuthService? _authService = locator<AuthService>();
  DialogService? _dialogService = locator<DialogService>();
  NavigationService? _navigationService = locator<NavigationService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  CustomNavigationService customNavigationService = locator<CustomNavigationService>();
  UserDataService _userDataService = locator<UserDataService>();
  LocationService _locationService = locator<LocationService>();
  CustomDialogService _customDialogService = locator<CustomDialogService>();

  WebblenUser get user => _reactiveUserService.user;
  List tags = [];
  List<WebblenUser> suggestedUsers = [];
  List newFollows = [];
  bool isLoading = true;
  bool hasLocation = false;

  initialize() async {
    setBusy(true);
    String? zip = await _locationService.getCurrentZipcode();
    if (zip != null) {
      suggestedUsers = await _userDataService.getFollowerSuggestions(user.id!, zip);
    } else {
      _customDialogService.showErrorDialog(description: "There was an issue loading suggested users");
    }
    notifyListeners();
    setBusy(false);
  }

  followUser(String id) async {
    List userFollowing = user.following ?? [];
    if (userFollowing.contains(id) && !newFollows.contains(id)) {
      newFollows.add(id);
      notifyListeners();
    }
    if (newFollows.contains(id)) {
      return;
    }
    _userDataService.followUser(user.id, id);
    newFollows.add(id);
    notifyListeners();
  }

  unfollowUser(String id) async {
    if (newFollows.contains(id)) {
      _userDataService.unFollowUser(user.id, id);
      newFollows.remove(id);
      notifyListeners();
    }
  }

  completeOnboarding() {}

  ///NAVIGATION
// replaceWithPage() {
//   _navigationService.replaceWith(PageRouteName);
// }
//
// navigateToPage() {
//   _navigationService.navigateTo(PageRouteName);
// }
}
