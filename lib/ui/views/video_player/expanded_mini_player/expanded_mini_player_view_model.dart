import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/enums/bottom_sheet_type.dart';
import 'package:webblen/models/webblen_comment.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/models/webblen_notification.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/bottom_sheets/custom_bottom_sheets_service.dart';
import 'package:webblen/services/dynamic_links/dynamic_link_service.dart';
import 'package:webblen/services/firestore/data/comment_data_service.dart';
import 'package:webblen/services/firestore/data/live_stream_data_service.dart';
import 'package:webblen/services/firestore/data/notification_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/reactive/mini_video_player/reactive_mini_video_player_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/services/share/share_service.dart';
import 'package:webblen/ui/widgets/mini_video_player/mini_video_player_view_model.dart';
import 'package:webblen/utils/custom_string_methods.dart';

class ExpandedMiniPlayerViewModel extends BaseViewModel {
  CustomNavigationService _customNavigationService = locator<CustomNavigationService>();
  CustomBottomSheetService _customBottomSheetService = locator<CustomBottomSheetService>();
  BottomSheetService _bottomSheetService = locator<BottomSheetService>();
  UserDataService _userDataService = locator<UserDataService>();
  LiveStreamDataService _liveStreamDataService = locator<LiveStreamDataService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  ReactiveMiniVideoPlayerService _reactiveMiniVideoPlayerService = locator<ReactiveMiniVideoPlayerService>();
  MiniVideoPlayerViewModel miniVideoPlayerViewModel = locator<MiniVideoPlayerViewModel>();
  NotificationDataService _notificationDataService = locator<NotificationDataService>();
  CommentDataService _commentDataService = locator<CommentDataService>();
  DynamicLinkService _dynamicLinkService = locator<DynamicLinkService>();
  ShareService _shareService = locator<ShareService>();

  ///HELPERS
  FocusNode focusNode = FocusNode();
  ScrollController scrollController = ScrollController();
  TextEditingController commentTextController = TextEditingController();
  double scrollControllerPosition = 0.0;
  PageStorageKey commentStorageKey = PageStorageKey('initial');

  ///DATA RESULTS
  bool loadingAdditionalComments = false;
  bool moreCommentsAvailable = true;
  List<DocumentSnapshot> commentResults = [];
  int resultsLimit = 10;

  ///DATA
  bool isReplying = false;
  bool refreshingComments = true;
  WebblenComment? commentToReplyTo;

  ///USER DATA
  WebblenUser get user => _reactiveUserService.user;

  ///STREAM HOST
  WebblenUser? host;
  bool isHost = false;

  ///VIDEO
  WebblenLiveStream get stream => _reactiveMiniVideoPlayerService.selectedStream;
  String get creatorUsername => _reactiveMiniVideoPlayerService.selectedStreamCreator;
  bool savedStream = false;
  bool clickedOnStream = false;
  List savedBy = [];
  List clickedBy = [];
  bool showVideoInfo = false;
  bool isLandscape = false;

  bool hasSocialAccounts = false;

  ///INITIALIZE
  initialize() async {
    setBusy(true);

    //check if user saved content
    if (stream.savedBy != null) {
      if (stream.savedBy!.contains(user.id)) {
        savedStream = true;
      }
      savedBy = stream.savedBy!;
    }

    //check if user clicked content
    if (stream.clickedBy != null) {
      if (stream.clickedBy!.contains(user.id)) {
        clickedOnStream = true;
      }
      clickedBy = stream.clickedBy!;
    }

    //check if stream has social accounts
    if ((stream.fbUsername != null && stream.fbUsername!.isNotEmpty) ||
        (stream.instaUsername != null && stream.instaUsername!.isNotEmpty) ||
        (stream.twitterUsername != null && stream.twitterUsername!.isNotEmpty) ||
        (stream.website != null && stream.website!.isNotEmpty)) {
      hasSocialAccounts = true;
    }

    //get author info
    host = await _userDataService.getWebblenUserByID(stream.hostID);

    if (user.id == stream.hostID) {
      isHost = true;
    }

    ///SET SCROLL CONTROLLER
    scrollController.addListener(() {
      double triggerFetchMoreSize = 0.7 * scrollController.position.maxScrollExtent;
      if (scrollController.position.pixels > triggerFetchMoreSize) {
        if (commentResults.isNotEmpty) {
          loadAdditionalComments();
        }
      }
    });
    await loadComments();

    notifyListeners();
    setBusy(false);
  }

  saveUnsaveStream() async {
    if (savedStream) {
      savedStream = false;
      savedBy.remove(user.id);
    } else {
      savedStream = true;
      savedBy.add(user.id);
      WebblenNotification notification = WebblenNotification().generateContentSavedNotification(
        receiverUID: stream.hostID!,
        senderUID: user.id!,
        username: user.username!,
        content: stream,
      );
      _notificationDataService.sendNotification(notif: notification);
    }
    HapticFeedback.lightImpact();
    notifyListeners();
    await _liveStreamDataService.saveUnsaveStream(uid: user.id!, streamID: stream.id!, savedStream: savedStream);
  }

  shareVideo() async {
    HapticFeedback.selectionClick();
    String? url = await _dynamicLinkService.createVideoLink(authorUsername: host!.username!, stream: stream);
    _shareService.shareLink(url);
  }

  reportVideo() async {
    await _liveStreamDataService.reportStream(streamID: stream.id!, reporterID: user.id!);
  }

  toggleShowVideoInfo() {
    if (showVideoInfo) {
      showVideoInfo = false;
    } else {
      showVideoInfo = true;
    }
    notifyListeners();
  }

  toggleLandscapeMode() {
    _customNavigationService.navigateToExpandedLandscapeMiniPlayer(stream.id!);
  }

  ///LOAD COMMENTS
  Future<void> refreshComments() async {
    await loadComments();
    resetPageStorageKey();
  }

  loadComments() async {
    commentResults = await _commentDataService.loadVideoComments(streamID: stream.id, resultsLimit: resultsLimit);
    refreshingComments = false;
    notifyListeners();
  }

  loadAdditionalComments() async {
    if (loadingAdditionalComments || !moreCommentsAvailable) {
      return;
    }
    loadingAdditionalComments = true;
    notifyListeners();
    List<DocumentSnapshot> newResults = await _commentDataService.loadAdditionalVideoComments(
      lastDocSnap: commentResults[commentResults.length - 1],
      resultsLimit: resultsLimit,
      streamID: stream.id,
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
  toggleReply(FocusNode focusNode, WebblenComment comment) {
    isReplying = true;
    commentToReplyTo = comment;
    focusNode.requestFocus();
  }

  submitComment({BuildContext? context, required Map<String, dynamic> commentData}) async {
    isReplying = false;
    String text = commentData['comment'].trim();
    if (text.isNotEmpty) {
      WebblenComment comment = WebblenComment(
        streamID: stream.id,
        senderUID: user.id!,
        username: user.username,
        message: text,
        isReply: false,
        replies: [],
        replyCount: 0,
        timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
      );

      //send comment & notification
      _commentDataService.sendVideoComment(stream.id, stream.hostID, comment).then((err) {
        if (err == null && (user.id! != stream.hostID)) {
          sendCommentNotification(text);

          //send notification to mentioned users
          if (commentData['mentionedUsers'].isNotEmpty) {
            List<WebblenUser> users = commentData['mentionedUsers'];
            users.forEach((user) {
              sendCommentMentionNotification(user.id, text);
            });
          }
        }
      });

      clearState(context);
    }
    refreshComments();
  }

  replyToComment({BuildContext? context, required Map<String, dynamic> commentData}) async {
    String text = commentData['comment'].trim();
    if (text.isNotEmpty) {
      WebblenComment comment = WebblenComment(
        streamID: stream.id,
        senderUID: user.id!,
        username: user.username,
        message: text,
        isReply: true,
        replies: [],
        replyCount: 0,
        replyReceiverUsername: commentToReplyTo!.username,
        originalReplyCommentID: commentToReplyTo!.timePostedInMilliseconds.toString(),
        timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
      );

      //send reply
      await _commentDataService
          .replyToVideoComment(
        stream.id,
        commentToReplyTo!.senderUID,
        commentToReplyTo!.timePostedInMilliseconds.toString(),
        comment,
      )
          .then((err) {
        if (err != null && (user.id! != stream.hostID)) {
          //send reply notification
          sendCommentReplyNotification(commentToReplyTo!.senderUID, text);

          //send notification to mentioned users
          if (commentData['mentionedUsers'].isNotEmpty) {
            List<WebblenUser> users = commentData['mentionedUsers'];
            users.forEach((user) {
              sendCommentMentionNotification(user.id, text);
            });
          }
        }
      });
    }

    //clear textfield and refresh comments
    clearState(context);
    refreshComments();
  }

  deleteComment({BuildContext? context, required WebblenComment comment}) async {
    isReplying = false;
    if (comment.isReply!) {
      await CommentDataService().deleteVideoCommentReply(stream.id, comment);
    } else {
      await CommentDataService().deleteVideoComment(stream.id, comment);
    }
    clearState(context);
    if (comment.isReply!) {
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

  clearState(BuildContext? context) {
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
    WebblenNotification notification = WebblenNotification().generateVideoCommentNotification(
      streamID: stream.id,
      receiverUID: stream.hostID,
      senderUID: user.id!,
      commenterUsername: "@${user.username}",
      comment: comment,
    );
    _notificationDataService.sendNotification(notif: notification);
  }

  sendCommentReplyNotification(String? receiverUID, String comment) {
    WebblenNotification notification = WebblenNotification().generateVideoCommentNotification(
      streamID: stream.id,
      receiverUID: stream.hostID,
      senderUID: user.id!,
      commenterUsername: "@${user.username}",
      comment: comment,
    );
    _notificationDataService.sendNotification(notif: notification);
  }

  sendCommentMentionNotification(String? receiverUID, String comment) {
    WebblenNotification notification = WebblenNotification().generateWebblenVideoCommentMentionNotification(
      streamID: stream.id,
      receiverUID: receiverUID,
      senderUID: user.id!,
      commenterUsername: "@${user.username}",
      comment: comment,
    );
    _notificationDataService.sendNotification(notif: notification);
  }

  ///DIALOGS & BOTTOM SHEETS
  showContentOptions() async {
    var actionPerformed = await _customBottomSheetService.showContentOptions(content: stream);
    if (actionPerformed == "deleted content") {
      miniVideoPlayerViewModel.shrinkMiniPlayer();
      miniVideoPlayerViewModel.dismissMiniPlayer();
    }
  }

  showDeleteCommentConfirmation({BuildContext? context, WebblenComment? comment}) async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      title: "Delete Comment",
      description: "Are You Sure You Want to Delete this Comment?",
      mainButtonTitle: "Delete",
      secondaryButtonTitle: "Cancel",
      barrierDismissible: true,
      variant: BottomSheetType.destructiveConfirmation,
    );
    if (sheetResponse != null) {
      String? res = sheetResponse.responseData;
      if (res == "confirmed") {
        deleteComment(context: context, comment: comment!);
      }
    }
  }

  ///NAVIGATION
  navigateToUserView(String id) {
    _customNavigationService.navigateToUserView(id);
  }
}
