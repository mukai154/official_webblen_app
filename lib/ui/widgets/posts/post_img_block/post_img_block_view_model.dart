import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_notification.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/firestore/data/notification_data_service.dart';
import 'package:webblen/services/firestore/data/post_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';

class PostImgBlockViewModel extends BaseViewModel {
  PostDataService _postDataService = locator<PostDataService>();
  UserDataService _userDataService = locator<UserDataService>();
  CustomNavigationService customNavigationService = locator<CustomNavigationService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  NotificationDataService _notificationDataService = locator<NotificationDataService>();

  ///USER DATA
  WebblenUser get user => _reactiveUserService.user;

  ///POST DATA
  bool savedPost = false;
  List savedBy = [];
  String? authorImageURL =
      "https://icon2.cleanpng.com/20180228/hdq/kisspng-circle-angle-material-gray-circle-pattern-5a9716f391f119.9417320315198512515978.jpg";
  String? authorUsername = "";

  initialize({required WebblenPost post}) async {
    setBusy(true);

    if (post.savedBy != null) {
      if (post.savedBy!.contains(user.id)) {
        savedPost = true;
      }
      savedBy = post.savedBy!;
    } else {
      savedBy = [];
    }

    //Get Post Author Data
    WebblenUser author = await _userDataService.getWebblenUserByID(post.authorID);

    if (author.isValid()) {
      authorImageURL = author.profilePicURL;
      authorUsername = author.username;
    }
    notifyListeners();
    setBusy(false);
  }

  saveUnsavePost({required WebblenPost post}) async {
    if (savedPost) {
      savedPost = false;
      savedBy.remove(user.id);
    } else {
      savedPost = true;
      WebblenNotification notification = WebblenNotification().generateContentSavedNotification(
        receiverUID: post.authorID!,
        senderUID: user.id!,
        username: user.username!,
        content: post,
      );
      _notificationDataService.sendNotification(notif: notification);
    }
    HapticFeedback.lightImpact();
    notifyListeners();
    await _postDataService.saveUnsavePost(userID: user.id, postID: post.id!, savedPost: savedPost);
  }
}
