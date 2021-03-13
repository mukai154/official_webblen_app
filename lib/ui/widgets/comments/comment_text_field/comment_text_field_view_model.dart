import 'package:stacked/stacked.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';

class CommentTextFieldViewModel extends BaseViewModel {
  AuthService _authService = locator<AuthService>();
  UserDataService _userDataService = locator<UserDataService>();

  String errorDetails;
  String currentUserProfilePicURL;
  String currentUsername;

  initialize() async {
    setBusy(true);
    String uid = await _authService.getCurrentUserID();
    WebblenUser user = await _userDataService.getWebblenUserByID(uid);
    if (user == null) {
      return;
    }
    currentUsername = user.username;
    currentUserProfilePicURL = user.profilePicURL;
    notifyListeners();
    setBusy(false);
  }
}
