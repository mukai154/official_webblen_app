import 'package:flutter/material.dart';
import 'package:webblen/enums/notifcation_type.dart';

class WebblenNotification {
  String receiverUID;
  String senderUID;
  NotificationType type;
  String header;
  String subHeader;
  Map<dynamic, dynamic> additionalData;
  int timePostedInMilliseconds;
  int expDateInMilliseconds;
  bool read;

  WebblenNotification({
    this.receiverUID,
    this.senderUID,
    this.type,
    this.header,
    this.subHeader,
    this.additionalData,
    this.timePostedInMilliseconds,
    this.expDateInMilliseconds,
    this.read,
  });

  WebblenNotification.fromMap(Map<String, dynamic> data)
      : this(
          receiverUID: data['receiverUID'],
          senderUID: data['senderUID'],
          type: NotificationTypeConverter.stringToNotificationType(data['type']),
          header: data['header'],
          subHeader: data['subHeader'],
          additionalData: data['additionalData'],
          timePostedInMilliseconds: data['timePostedInMilliseconds'],
          expDateInMilliseconds: data['expDateInMilliseconds'],
          read: data['read'],
        );

  Map<String, dynamic> toMap() => {
        'receiverUID': this.receiverUID,
        'senderUID': this.senderUID,
        'type': NotificationTypeConverter.notificationTypeToString(this.type),
        'header': this.header,
        'subHeader': this.subHeader,
        'additionalData': this.additionalData,
        'timePostedInMilliseconds': this.timePostedInMilliseconds,
        'expDateInMilliseconds': this.expDateInMilliseconds,
        'read': this.read,
      };

  //New Follower Notification
  WebblenNotification generateNewFollowerNotification({
    @required String receiverUID,
    @required String senderUID,
    @required String followerUsername,
  }) {
    WebblenNotification notif = WebblenNotification(
      receiverUID: receiverUID,
      senderUID: senderUID,
      type: NotificationType.newFollower,
      header: 'You have a new follower',
      subHeader: '$followerUsername has started following you',
      additionalData: null,
      timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
      expDateInMilliseconds: DateTime.now().millisecondsSinceEpoch + 7884000000, //Expiration Date Set 3 Months from Now
      read: false,
    );
    return notif;
  }

  //New Post Notification
  WebblenNotification generateNewPostNotification({
    @required String senderUID,
    @required String postAuthorUsername,
    @required String postID,
  }) {
    WebblenNotification notif = WebblenNotification(
      receiverUID: null,
      senderUID: senderUID,
      type: NotificationType.newPost,
      header: '$postAuthorUsername created a new post',
      subHeader: 'Check it out!',
      additionalData: {'postID': postID},
      timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
      expDateInMilliseconds: DateTime.now().millisecondsSinceEpoch + 7884000000, //Expiration Date Set 3 Months from Now
      read: false,
    );
    return notif;
  }

  //New Event Notification
  WebblenNotification generateNewEventNotification({
    @required String senderUID,
    @required String hostUsername,
    @required String eventID,
  }) {
    WebblenNotification notif = WebblenNotification(
      receiverUID: null,
      senderUID: senderUID,
      type: NotificationType.newEvent,
      header: '$hostUsername scheduled a new event',
      subHeader: 'View Details',
      additionalData: {'eventID': eventID},
      timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
      expDateInMilliseconds: DateTime.now().millisecondsSinceEpoch + 7884000000, //Expiration Date Set 3 Months from Now
      read: false,
    );
    return notif;
  }

  //Edited Event Notification
  WebblenNotification generateEditedEventNotification({
    @required String senderUID,
    @required String hostUsername,
    @required String eventID,
  }) {
    WebblenNotification notif = WebblenNotification(
      receiverUID: null,
      senderUID: senderUID,
      type: NotificationType.editedEvent,
      header: '$hostUsername edited an upcoming event',
      subHeader: 'View Changes',
      additionalData: {'eventID': eventID},
      timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
      expDateInMilliseconds: DateTime.now().millisecondsSinceEpoch + 7884000000, //Expiration Date Set 3 Months from Now
      read: false,
    );
    return notif;
  }

  //Event Is Live Notification
  WebblenNotification generateEventIsLiveNotification({
    @required String senderUID,
    @required String eventTitle,
    @required String eventID,
  }) {
    WebblenNotification notif = WebblenNotification(
      receiverUID: null,
      senderUID: senderUID,
      type: NotificationType.eventIsLive,
      header: '$eventTitle is happening now!',
      subHeader: 'View Event Details',
      additionalData: {'eventID': eventID},
      timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
      expDateInMilliseconds: DateTime.now().millisecondsSinceEpoch + 7884000000, //Expiration Date Set 3 Months from Now
      read: false,
    );
    return notif;
  }

  //New Stream Notification
  WebblenNotification generateNewStreamNotification({
    @required String senderUID,
    @required String hostUsername,
    @required String streamID,
  }) {
    WebblenNotification notif = WebblenNotification(
      receiverUID: null,
      senderUID: senderUID,
      type: NotificationType.newStream,
      header: '$hostUsername scheduled a new stream',
      subHeader: 'View Details',
      additionalData: {'streamID': streamID},
      timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
      expDateInMilliseconds: DateTime.now().millisecondsSinceEpoch + 7884000000, //Expiration Date Set 3 Months from Now
      read: false,
    );
    return notif;
  }

  //Edited Stream Notification
  WebblenNotification generateEditedStreamNotification({
    @required String senderUID,
    @required String hostUsername,
    @required String streamID,
  }) {
    WebblenNotification notif = WebblenNotification(
      receiverUID: null,
      senderUID: senderUID,
      type: NotificationType.newStream,
      header: '$hostUsername edited an upcoming stream',
      subHeader: 'View Changes',
      additionalData: {'streamID': streamID},
      timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
      expDateInMilliseconds: DateTime.now().millisecondsSinceEpoch + 7884000000, //Expiration Date Set 3 Months from Now
      read: false,
    );
    return notif;
  }

  //Stream is Live Notification
  WebblenNotification generateStreamIsLiveNotification({
    @required String senderUID,
    @required String streamTitle,
    @required String streamID,
  }) {
    WebblenNotification notif = WebblenNotification(
      receiverUID: null,
      senderUID: senderUID,
      type: NotificationType.streamIsLive,
      header: '$streamTitle is live!',
      subHeader: "Watch Now",
      additionalData: {'streamID': streamID},
      timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
      expDateInMilliseconds: DateTime.now().millisecondsSinceEpoch + 7884000000, //Expiration Date Set 3 Months from Now
      read: false,
    );
    return notif;
  }

  //Post Comment Notification
  WebblenNotification generatePostCommentNotification({
    @required String postID,
    @required String receiverUID,
    @required String senderUID,
    @required String commenterUsername,
    @required String comment,
  }) {
    WebblenNotification notif = WebblenNotification(
      receiverUID: receiverUID,
      senderUID: senderUID,
      type: NotificationType.postComment,
      header: '$commenterUsername commented on your post',
      subHeader: comment,
      additionalData: {'postID': postID},
      timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
      expDateInMilliseconds: DateTime.now().millisecondsSinceEpoch + 7884000000, //Expiration Date Set 3 Months from Now
      read: false,
    );
    return notif;
  }

  //Post Comment Reply Notification
  WebblenNotification generatePostCommentReplyNotification({
    @required String postID,
    @required String receiverUID,
    @required String senderUID,
    @required String commenterUsername,
    @required String comment,
  }) {
    WebblenNotification notif = WebblenNotification(
      receiverUID: receiverUID,
      senderUID: senderUID,
      type: NotificationType.postCommentReply,
      header: '$commenterUsername replied to your comment',
      subHeader: comment,
      additionalData: {'postID': postID},
      timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
      expDateInMilliseconds: DateTime.now().millisecondsSinceEpoch + 7884000000, //Expiration Date Set 3 Months from Now
      read: false,
    );
    return notif;
  }

  //Webblen Received Notification
  WebblenNotification generateWebblenReceivedNotification({
    @required String postID,
    @required String receiverUID,
    @required String senderUID,
    @required String senderUsername,
    @required String amountReceived,
  }) {
    WebblenNotification notif = WebblenNotification(
      receiverUID: receiverUID,
      senderUID: senderUID,
      type: NotificationType.webblenReceived,
      header: '$senderUsername sent you WBLN',
      subHeader: '$amountReceived WBLN has been deposited in your wallet',
      additionalData: {'postID': postID},
      timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
      expDateInMilliseconds: DateTime.now().millisecondsSinceEpoch + 7884000000, //Expiration Date Set 3 Months from Now
      read: false,
    );
    return notif;
  }
}
