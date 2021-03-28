import 'package:flutter/material.dart';

class WebblenUserPreferences {
  String id;
  bool notifyNewFollowers;
  bool notifyMentions;
  bool notifyEvents;
  bool notifyPosts;
  bool notifyStreams;
  bool notifyContentSaves;
  bool notifyContentComments;
  bool notifyAvailableCheckIns;
  bool displayCreateEventActivity;
  bool displayCheckInEventActivity;
  bool displayCreateLiveStreamActivity;
  bool displayCheckInLiveStreamActivity;
  bool displayCreatePostActivity;
  bool displayCommentPostActivity;

  WebblenUserPreferences({
    this.id,
    this.notifyNewFollowers,
    this.notifyMentions,
    this.notifyEvents,
    this.notifyPosts,
    this.notifyStreams,
    this.notifyContentSaves,
    this.notifyContentComments,
    this.notifyAvailableCheckIns,
    this.displayCreateEventActivity,
    this.displayCheckInEventActivity,
    this.displayCreateLiveStreamActivity,
    this.displayCheckInLiveStreamActivity,
    this.displayCreatePostActivity,
    this.displayCommentPostActivity,
  });

  WebblenUserPreferences.fromMap(Map<String, dynamic> data)
      : this(
          id: data['id'],
          notifyNewFollowers: data['notifyNewFollowers'],
          notifyMentions: data['notifyMentions'],
          notifyEvents: data['notifyEvents'],
          notifyPosts: data['notifyPosts'],
          notifyStreams: data['notifyStreams'],
          notifyContentSaves: data['notifyContentSaves'],
          notifyContentComments: data['notifyContentComments'],
          notifyAvailableCheckIns: data['notifyAvailableCheckIns'],
          displayCreateEventActivity: data['displayCreateEventActivity'],
          displayCheckInEventActivity: data['displayCheckInEventActivity'],
          displayCreateLiveStreamActivity: data['displayCreateLiveStreamActivity'],
          displayCheckInLiveStreamActivity: data['displayCheckInLiveStreamActivity'],
          displayCreatePostActivity: data['displayCreatePostActivity'],
          displayCommentPostActivity: data['displayCommentPostActivity'],
        );

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'notifyNewFollowers': this.notifyNewFollowers,
        'notifyMentions': this.notifyMentions,
        'notifyEvents': this.notifyEvents,
        'notifyPosts': this.notifyPosts,
        'notifyStreams': this.notifyStreams,
        'notifyContentSaves': this.notifyContentSaves,
        'notifyContentComments': this.notifyContentComments,
        'notifyAvailableCheckIns': this.notifyAvailableCheckIns,
        'displayCreateEventActivity': this.displayCreateEventActivity,
        'displayCheckInEventActivity': this.displayCheckInEventActivity,
        'displayCreateLiveStreamActivity': this.displayCreateLiveStreamActivity,
        'displayCheckInLiveStreamActivity': this.displayCheckInLiveStreamActivity,
        'displayCreatePostActivity': this.displayCreatePostActivity,
        'displayCommentPostActivity': this.displayCommentPostActivity,
      };

  WebblenUserPreferences generateNewPreferences({@required String id}) {
    WebblenUserPreferences preferences = WebblenUserPreferences(
      id: id,
      notifyNewFollowers: true,
      notifyMentions: true,
      notifyEvents: true,
      notifyPosts: true,
      notifyStreams: true,
      notifyContentSaves: true,
      notifyContentComments: true,
      notifyAvailableCheckIns: true,
      displayCreateEventActivity: true,
      displayCheckInEventActivity: true,
      displayCreateLiveStreamActivity: true,
      displayCheckInLiveStreamActivity: true,
      displayCreatePostActivity: true,
      displayCommentPostActivity: true,
    );

    return preferences;
  }
//
// //Webblen Received Notification
// WebblenNotification generateWebblenReceivedNotification({
//   @required String postID,
//   @required String receiverUID,
//   @required String senderUID,
//   @required String senderUsername,
//   @required String amountReceived,
// }) {
//   WebblenNotification notif = WebblenNotification(
//     receiverUID: receiverUID,
//     senderUID: senderUID,
//     type: NotificationType.webblenReceived,
//     header: '$senderUsername sent you WBLN',
//     subHeader: '$amountReceived WBLN has been deposited in your wallet',
//     additionalData: {'postID': postID},
//     timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
//     expDateInMilliseconds: DateTime.now().millisecondsSinceEpoch + 7884000000, //Expiration Date Set 3 Months from Now
//     read: false,
//   );
//   return notif;
// }
}
