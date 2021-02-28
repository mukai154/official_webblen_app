import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/app/router.gr.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/dynamic_links/dynamic_link_service.dart';
import 'package:webblen/services/firestore/data/post_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/share/share_service.dart';

class PostImgBlockViewModel extends BaseViewModel {
  AuthService _authService = locator<AuthService>();
  NavigationService _navigationService = locator<NavigationService>();
  BottomSheetService _bottomSheetService = locator<BottomSheetService>();
  PostDataService _postDataService = locator<PostDataService>();
  UserDataService _userDataService = locator<UserDataService>();
  SnackbarService _snackbarService = locator<SnackbarService>();
  DynamicLinkService _dynamicLinkService = locator<DynamicLinkService>();
  ShareService _shareService = locator<ShareService>();

  bool savedPost = false;
  String authorImageURL = "https://icon2.cleanpng.com/20180228/hdq/kisspng-circle-angle-material-gray-circle-pattern-5a9716f391f119.9417320315198512515978.jpg";
  String authorUsername = "";

  initialize({String currentUID, String postID, String postAuthorID}) async {
    setBusy(true);

    savedPost = await _postDataService.checkIfPostSaved(userID: currentUID, postID: postID);
    //Get Post Author Data
    _userDataService.getWebblenUserByID(postAuthorID).then((res) {
      if (res is String) {
        //print(String);
      } else {
        authorImageURL = res.profilePicURL;
        authorUsername = res.username;
      }
      notifyListeners();
      setBusy(false);
    });
  }

  saveUnsavePost({String currentUID, String postID}) async {
    if (savedPost) {
      savedPost = false;
    } else {
      savedPost = true;
    }
    HapticFeedback.lightImpact();
    notifyListeners();
    await _postDataService.saveUnsavePost(userID: currentUID, postID: postID, savedPost: savedPost);
  }

  ///NAVIGATION
  navigateToPostView(String id) async {
    String res = await _navigationService.navigateTo(Routes.PostViewRoute, arguments: {'id': id});
    if (res == "post no longer exists") {
      _snackbarService.showSnackbar(
        title: 'Uh Oh...',
        message: "This post no longer exists",
        duration: Duration(seconds: 5),
      );
    }
  }

  navigateToUserView(String id) {
    _navigationService.navigateTo(Routes.UserProfileView, arguments: {'id': id});
  }
}
