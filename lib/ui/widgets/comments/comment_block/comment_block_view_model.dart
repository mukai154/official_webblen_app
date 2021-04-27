import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/ui/views/base/webblen_base_view_model.dart';

class CommentBlockViewModel extends BaseViewModel {
  AuthService? _authService = locator<AuthService>();
  DialogService? _dialogService = locator<DialogService>();
  NavigationService? _navigationService = locator<NavigationService>();
  UserDataService? _userDataService = locator<UserDataService>();
  WebblenBaseViewModel? webblenBaseViewModel = locator<WebblenBaseViewModel>();

  ///ERROR STATUS
  bool errorLoadingData = false;

  ///DATA
  bool isAuthor = false;
  String? authorUID;
  String? username;
  String? authorProfilePicURL;

  ///VIEW STATUS
  bool showingReplies = false;

  ///Loading User
  bool loadingUser = false;

  ///INITIALIZE
  initialize(String? uid) async {
    //set busy status
    setBusy(true);

    //get comment author data
    var res = await _userDataService!.getWebblenUserByID(uid);

    if (res is String) {
      errorLoadingData = true;
    } else {
      //set author data
      authorUID = res!.id;
      username = res.username;
      authorProfilePicURL = res.profilePicURL;

      //check if author is current user
      if (authorUID == webblenBaseViewModel!.uid) {
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

  navigateToMentionedUser(String username) async {
    if (!loadingUser) {
      loadingUser = true;
      notifyListeners();
      WebblenUser user = await (_userDataService!.getWebblenUserByUsername(username) as FutureOr<WebblenUser>);
      loadingUser = false;
      notifyListeners();
      navigateToUserPage(user.id);
    }
  }

  ///NAVIGATION
  navigateToUserPage(String? id) {
    //_navigationService.navigateTo(Routes.UserProfileView, arguments: {'id': id});
  }
//
// navigateToPage() {
//   _navigationService.navigateTo(PageRouteName);
// }
}
