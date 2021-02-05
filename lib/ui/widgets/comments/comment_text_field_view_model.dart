import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/firestore/user_data_service.dart';

class CommentTextFieldViewModel extends BaseViewModel {
  AuthService _authService = locator<AuthService>();
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  UserDataService _userDataService = locator<UserDataService>();
  SnackbarService _snackbarService = locator<SnackbarService>();

  String errorDetails;
  String currentUserProfilePicURL;
  String currentUsername;

  initialize() async {
    setBusy(true);
    String uid = await _authService.getCurrentUserID();
    var res = await _userDataService.getWebblenUserByID(uid);
    if (res is String) {
      errorDetails = res;
      _snackbarService.showSnackbar(
        title: 'Error',
        message: errorDetails,
        duration: Duration(seconds: 5),
      );
    } else {
      currentUsername = res.username;
      currentUserProfilePicURL = res.profilePicURL;
    }
    notifyListeners();
    setBusy(false);
  }

  ///NAVIGATION
// replaceWithPage() {
//   _navigationService.replaceWith(PageRouteName);
// }
//
// navigateToPage() {
//   _navigationService.navigateTo(PageRouteName);
// }
}
