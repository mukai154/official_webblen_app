import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';

class CommentBlockViewModel extends BaseViewModel {
  NavigationService _navigationService = locator<NavigationService>();
  UserDataService _userDataService = locator<UserDataService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  CustomNavigationService customNavigationService = locator<CustomNavigationService>();

  ///ERROR STATUS
  bool errorLoadingData = false;

  ///USER DATA
  WebblenUser get user => _reactiveUserService.user;

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
    var res = await _userDataService.getWebblenUserByID(uid);

    if (res is String) {
      errorLoadingData = true;
    } else {
      //set author data
      authorUID = res.id;
      username = res.username;
      authorProfilePicURL = res.profilePicURL;

      //check if author is current user
      if (authorUID == user.id) {
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
      WebblenUser user = await _userDataService.getWebblenUserByUsername(username);
      loadingUser = false;
      notifyListeners();
      if (user.isValid()) {
        customNavigationService.navigateToUserView(user.id!);
      }
    }
  }
}
