import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/app/router.gr.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/dynamic_links/dynamic_link_service.dart';
import 'package:webblen/services/firestore/data/post_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/share/share_service.dart';

class PostImgBlockModel extends BaseViewModel {
  AuthService _authService = locator<AuthService>();
  NavigationService _navigationService = locator<NavigationService>();
  BottomSheetService _bottomSheetService = locator<BottomSheetService>();
  PostDataService _postDataService = locator<PostDataService>();
  UserDataService _userDataService = locator<UserDataService>();
  DynamicLinkService _dynamicLinkService = locator<DynamicLinkService>();
  ShareService _shareService = locator<ShareService>();

  bool isAuthor = false;
  String authorImageURL = "https://icon2.cleanpng.com/20180228/hdq/kisspng-circle-angle-material-gray-circle-pattern-5a9716f391f119.9417320315198512515978.jpg";
  String authorUsername = "";

  initialize(String postAuthorID) async {
    setBusy(true);

    //Check if Current User is Author
    String currentUID = await _authService.getCurrentUserID();
    if (postAuthorID == currentUID) {
      isAuthor = true;
    }

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

  showOptions({WebblenPost post, VoidCallback refreshAction}) async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      barrierDismissible: true,
      variant: isAuthor ? BottomSheetType.postAuthorOptions : BottomSheetType.postOptions,
    );
    if (sheetResponse != null) {
      String res = sheetResponse.responseData;
      if (res == "edit") {
        // String data = await _navigationService.navigateTo(Routes.CreateForumPostViewRoute, arguments: {
        //   'postID': post.id,
        // });
        // if (data != null && data == 'newPostCreated') {
        //   refreshAction();
        // }
      } else if (res == "share") {
        //share post link
        String url = await _dynamicLinkService.createPostLink(postAuthorUsername: authorUsername, post: post);
        _shareService.shareLink(url);
      } else if (res == "report") {
        //report post
        String currentUID = await _authService.getCurrentUserID();
        _postDataService.reportPost(postID: post.id, reporterID: currentUID);
      } else if (res == "delete") {
        //delete
      }
      notifyListeners();
    }
  }

  ///NAVIGATION
  navigateToPostView(String postID) {
    _navigationService.navigateTo(Routes.PostViewRoute, arguments: {'postID': postID});
  }

  navigateToUserView(String uid) {
    //_navigationService.navigateTo(Routes.UserViewRoute, arguments: {'uid': uid});
  }
}
