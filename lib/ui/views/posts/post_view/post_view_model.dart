import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/app/router.gr.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/models/webblen_notification.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/models/webblen_post_comment.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/auth/auth_service.dart';
import 'package:webblen/services/dynamic_links/dynamic_link_service.dart';
import 'package:webblen/services/firestore/data/comment_data_service.dart';
import 'package:webblen/services/firestore/data/notification_data_service.dart';
import 'package:webblen/services/firestore/data/post_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/share/share_service.dart';
import 'package:webblen/utils/random_string_generator.dart';

class PostViewModel extends BaseViewModel {
  AuthService _authService = locator<AuthService>();
  DialogService _dialogService = locator<DialogService>();
  NavigationService _navigationService = locator<NavigationService>();
  BottomSheetService _bottomSheetService = locator<BottomSheetService>();
  UserDataService _userDataService = locator<UserDataService>();
  PostDataService _postDataService = locator<PostDataService>();
  CommentDataService _commentDataService = locator<CommentDataService>();
  NotificationDataService _notificationDataService = locator<NotificationDataService>();
  DynamicLinkService _dynamicLinkService = locator<DynamicLinkService>();
  ShareService _shareService = locator<ShareService>();

  ///HELPERS
  ScrollController postScrollController = ScrollController();
  TextEditingController commentTextController = TextEditingController();
  double postScrollPosition = 0.0;
  PageStorageKey commentStorageKey = PageStorageKey('initial');

  ///DATA RESULTS
  bool loadingAdditionalComments = false;
  bool moreCommentsAvailable = true;
  List<DocumentSnapshot> commentResults = [];
  int resultsLimit = 10;

  ///DATA
  WebblenUser currentUser;
  WebblenUser author;
  WebblenPost post;
  bool isAuthor = false;
  bool isReplying = false;
  bool refreshingComments = true;
  WebblenPostComment commentToReplyTo;

  ///INITIALIZE
  initialize(BuildContext context) async {
    setBusy(true);
    String uid = await _authService.getCurrentUserID();
    currentUser = await _userDataService.getWebblenUserByID(uid);

    Map<String, dynamic> args = RouteData.of(context).arguments;
    String postID = args['postID'] ?? "";

    var res = await _postDataService.getPostByID(postID);
    if (res == null) {
      _navigationService.back(result: 'post no longer exists');
      return;
    } else {
      post = res;
    }
    author = await _userDataService.getWebblenUserByID(post.authorID);

    if (currentUser.id == post.authorID) {
      isAuthor = true;
    }

    ///SET SCROLL CONTROLLER
    postScrollController.addListener(() {
      double triggerFetchMoreSize = 0.7 * postScrollController.position.maxScrollExtent;
      if (postScrollController.position.pixels > triggerFetchMoreSize) {
        try {
          loadAdditionalComments();
        } catch (e) {}
      }
    });
    await loadComments();
    notifyListeners();
    setBusy(false);
  }

  ///LOAD COMMENTS
  Future<void> refreshComments() async {
    await loadComments();
    resetPageStorageKey();
  }

  loadComments() async {
    commentResults = await _commentDataService.loadComments(postID: post.id, resultsLimit: resultsLimit);
    refreshingComments = false;
    notifyListeners();
  }

  loadAdditionalComments() async {
    if (loadingAdditionalComments || !moreCommentsAvailable) {
      return;
    }
    loadingAdditionalComments = true;
    notifyListeners();
    List<DocumentSnapshot> newResults = await _commentDataService.loadAdditionalComments(
      lastDocSnap: commentResults[commentResults.length - 1],
      resultsLimit: resultsLimit,
      postID: post.id,
    );
    if (newResults.length == 0) {
      moreCommentsAvailable = false;
    } else {
      commentResults.addAll(newResults);
    }
    loadingAdditionalComments = false;
    notifyListeners();
  }

  ///COMMENTING
  toggleReply(FocusNode focusNode, WebblenPostComment comment) {
    isReplying = true;
    commentToReplyTo = comment;
    focusNode.requestFocus();
  }

  submitComment({BuildContext context, String commentVal}) async {
    isReplying = false;
    String text = commentVal.trim();
    if (text.isNotEmpty) {
      WebblenPostComment comment = WebblenPostComment(
        postID: post.id,
        senderUID: currentUser.id,
        username: currentUser.username,
        message: text,
        isReply: false,
        replies: [],
        replyCount: 0,
        timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
      );
      await _commentDataService.sendComment(post.id, post.authorID, comment);
      sendCommentNotification(text);
      clearState(context);
    }
    refreshComments();
  }

  replyToComment({BuildContext context, String commentVal}) async {
    String text = commentVal.trim();
    if (text.isNotEmpty) {
      WebblenPostComment comment = WebblenPostComment(
        postID: post.id,
        senderUID: currentUser.id,
        username: currentUser.username,
        message: text,
        isReply: true,
        replies: [],
        replyCount: 0,
        replyReceiverUsername: commentToReplyTo.username,
        originalReplyCommentID: commentToReplyTo.timePostedInMilliseconds.toString(),
        timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
      );
      await _commentDataService.replyToComment(
        post.id,
        commentToReplyTo.senderUID,
        commentToReplyTo.timePostedInMilliseconds.toString(),
        comment,
      );
    }
    sendCommentReplyNotification(commentToReplyTo.senderUID, text);
    clearState(context);
    refreshComments();
  }

  deleteComment({BuildContext context, WebblenPostComment comment}) async {
    isReplying = false;
    if (comment.isReply) {
      await CommentDataService().deleteReply(post.id, comment);
    } else {
      await CommentDataService().deleteComment(post.id, comment);
    }
    clearState(context);
    if (comment.isReply) {
      commentResults = [];
    }
    refreshComments();
  }

  unFocusKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (isReplying) {
      clearState(context);
    }
  }

  clearState(BuildContext context) {
    isReplying = false;
    commentToReplyTo = null;
    commentTextController.clear();
    notifyListeners();
  }

  resetPageStorageKey() {
    String val = getRandomString(10);
    commentStorageKey = PageStorageKey(val);
    notifyListeners();
  }

  ///NOTIFICATIONS
  sendCommentNotification(String comment) {
    WebblenNotification notification = WebblenNotification().generatePostCommentNotification(
      postID: post.id,
      receiverUID: post.authorID,
      senderUID: currentUser.id,
      commenterUsername: "@${currentUser.username}",
      comment: comment,
    );
    _notificationDataService.sendNotification(notif: notification);
  }

  sendCommentReplyNotification(String receiverUID, String comment) {
    WebblenNotification notification = WebblenNotification().generatePostCommentNotification(
      postID: post.id,
      receiverUID: receiverUID,
      senderUID: currentUser.id,
      commenterUsername: "@${currentUser.username}",
      comment: comment,
    );
    _notificationDataService.sendNotification(notif: notification);
  }

  ///DIALOGS & BOTTOM SHEETS
  //show post options
  showPostOptions({BuildContext context, WebblenPost post}) async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      barrierDismissible: true,
      variant: currentUser.id == post.authorID ? BottomSheetType.postAuthorOptions : BottomSheetType.postOptions,
    );
    if (sheetResponse != null) {
      String res = sheetResponse.responseData;
      if (res == "edit") {
        //edit post
        _navigationService.navigateTo(Routes.CreatePostViewRoute, arguments: {
          'postID': post.id,
        });
      } else if (res == "share") {
        //share post link
        String url = await _dynamicLinkService.createPostLink(postAuthorUsername: "@${currentUser.username}", post: post);
        _shareService.shareLink(url);
      } else if (res == "report") {
        //report post
        _postDataService.reportPost(postID: post.id, reporterID: currentUser.id);
      } else if (res == "delete") {
        //delete
        deletePostConfirmation(context: context, post: post);
      }
      notifyListeners();
    }
  }

  //show delete post confirmation
  deletePostConfirmation({BuildContext context, WebblenPost post}) async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      title: "Delete Post",
      description: "Are You Sure You Want to Delete this Post?",
      mainButtonTitle: "Delete Post",
      secondaryButtonTitle: "Cancel",
      barrierDismissible: true,
      variant: BottomSheetType.destructiveConfirmation,
    );
    if (sheetResponse != null) {
      String res = sheetResponse.responseData;
      if (res == "confirmed") {
        _postDataService.deletePost(post: post);
        _navigationService.back();
        notifyListeners();
      }
    }
  }

  //show delete comment confirmation
  showDeleteCommentConfirmation({BuildContext context, WebblenPostComment comment}) async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      title: "Delete Comment",
      description: "Are You Sure You Want to Delete this Comment?",
      mainButtonTitle: "Delete",
      secondaryButtonTitle: "Cancel",
      barrierDismissible: true,
      variant: BottomSheetType.destructiveConfirmation,
    );
    if (sheetResponse != null) {
      String res = sheetResponse.responseData;
      if (res == "confirmed") {
        deleteComment(context: context, comment: comment);
      }
    }
  }

  ///NAVIGATION
  navigateToUserView(String uid) {
    //_navigationService.navigateTo(Routes.UserViewRoute, arguments: {'uid': uid});
  }
// replaceWithPage() {
//   _navigationService.replaceWith(PageRouteName);
// }
//
// navigateToPage() {
//   _navigationService.navigateTo(PageRouteName);
// }
}
