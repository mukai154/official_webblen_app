import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/firestore/data/post_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';

class PostImgBlockViewModel extends BaseViewModel {
  PostDataService _postDataService = locator<PostDataService>();
  UserDataService _userDataService = locator<UserDataService>();
  CustomNavigationService customNavigationService = locator<CustomNavigationService>();

  bool savedPost = false;
  String? authorImageURL =
      "https://icon2.cleanpng.com/20180228/hdq/kisspng-circle-angle-material-gray-circle-pattern-5a9716f391f119.9417320315198512515978.jpg";
  String? authorUsername = "";

  initialize({String? currentUID, String? postID, String? postAuthorID}) async {
    setBusy(true);

    savedPost = await _postDataService.checkIfPostSaved(userID: currentUID, postID: postID);

    //Get Post Author Data
    WebblenUser user = await _userDataService.getWebblenUserByID(postAuthorID);

    if (user.isValid()) {
      authorImageURL = user.profilePicURL;
      authorUsername = user.username;
    }
    notifyListeners();
    setBusy(false);
  }

  saveUnsavePost({String? currentUID, String? postID}) async {
    if (savedPost) {
      savedPost = false;
    } else {
      savedPost = true;
    }
    HapticFeedback.lightImpact();
    notifyListeners();
    await _postDataService.saveUnsavePost(userID: currentUID, postID: postID, savedPost: savedPost);
  }
}
