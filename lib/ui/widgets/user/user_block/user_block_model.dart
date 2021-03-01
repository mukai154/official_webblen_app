import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/services/auth/auth_service.dart';

class UserBlockModel extends BaseViewModel {
  AuthService _authService = locator<AuthService>();
  NavigationService _navigationService = locator<NavigationService>();

  bool isFollowingUser = false;

  initialize(List followers) async {
    String uid = await _authService.getCurrentUserID();
    if (followers.contains(uid)) {
      isFollowingUser = true;
    }
    notifyListeners();
  }

  ///NAVIGATION
  navigateToUserView(String uid) {
    // _navigationService.navigateTo(Routes.UserViewRoute, arguments: {'uid': uid});
  }
}