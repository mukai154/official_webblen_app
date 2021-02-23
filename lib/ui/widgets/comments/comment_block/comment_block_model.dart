import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';

class CommentBlockModel extends BaseViewModel {
  AuthService _authService = locator<AuthService>();
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  UserDataService _userDataService = locator<UserDataService>();

  ///ERROR STATUS
  bool errorLoadingData = false;

  ///DATA
  bool isAuthor = false;
  String authorUID;
  String username;
  String authorProfilePicURL;

  ///VIEW STATUS
  bool showingReplies = false;

  ///INITIALIZE
  initialize(String uid) async {
    //set busy status
    setBusy(true);

    //get current user id
    String currentUserID = await _authService.getCurrentUserID();

    //get comment author data
    var res = await _userDataService.getWebblenUserByID(uid);

    if (res is String) {
      errorLoadingData = true;
    } else {
      //set author data
      authorUID = res.id;
      username = res.username;
      authorProfilePicURL = res.profilePicURL;

      //check if author is current user
      if (authorUID == currentUserID) {
        isAuthor = true;
      }
    }
    notifyListeners();
    setBusy(false);
  }

  ///Toggle Replies
  toggleShowReplies() {
    if (showingReplies) {
      showingReplies = false;
    } else {
      showingReplies = true;
    }
    notifyListeners();
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
