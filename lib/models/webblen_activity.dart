import 'package:flutter/cupertino.dart';
import 'package:webblen/utils/custom_string_methods.dart';

class WebblenActivity {
  String id;
  String uid;
  String contentID;
  String type;
  String header;
  String subHeader;
  dynamic additionalData;
  int timePostedInMilliseconds;
  List associatedTags;
  bool isPublic;

  WebblenActivity({
    this.id,
    this.uid,
    this.contentID,
    this.type,
    this.header,
    this.subHeader,
    this.additionalData,
    this.timePostedInMilliseconds,
    this.associatedTags,
    this.isPublic,
  });

  WebblenActivity.fromMap(Map<String, dynamic> data)
      : this(
          id: data['id'],
          uid: data['uid'],
          contentID: data['contentID'],
          type: data['type'],
          header: data['header'],
          subHeader: data['subHeader'],
          additionalData: data['additionalData'],
          timePostedInMilliseconds: data['timePostedInMilliseconds'],
          associatedTags: data['associatedTags'],
          isPublic: data['isPublic'],
        );

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'uid': this.uid,
        'contentID': this.contentID,
        'type': this.type,
        'header': this.header,
        'subHeader': this.subHeader,
        'additionalData': this.additionalData,
        'timePostedInMilliseconds': this.timePostedInMilliseconds,
        'associatedTags': this.associatedTags,
        'isPublic': this.isPublic,
      };

  WebblenActivity generateCreatePostActivity(
      {@required String uid, @required String username, @required String contentID, @required List associatedTags, @required bool isPublic}) {
    String id = getRandomString(30);

    WebblenActivity activity = WebblenActivity(
      id: id,
      uid: uid,
      contentID: contentID,
      type: 'post',
      header: '@$username created a new post',
      subHeader: null,
      additionalData: null,
      associatedTags: associatedTags,
      isPublic: isPublic,
      timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
    );

    return activity;
  }

  WebblenActivity generatePostCommentActivity(
      {@required String uid,
      @required String username,
      @required String contentID,
      @required List associatedTags,
      @required bool isPublic,
      @required String commentID}) {
    String id = getRandomString(30);

    WebblenActivity activity = WebblenActivity(
      id: id,
      uid: uid,
      contentID: contentID,
      type: 'post',
      header: '@$username commented on a post',
      subHeader: null,
      additionalData: commentID,
      associatedTags: associatedTags,
      isPublic: isPublic,
      timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
    );

    return activity;
  }

  WebblenActivity generateCreateStreamActivity(
      {@required String uid, @required String username, @required String contentID, @required List associatedTags, @required bool isPublic}) {
    String id = getRandomString(30);

    WebblenActivity activity = WebblenActivity(
      id: id,
      uid: uid,
      contentID: contentID,
      type: 'stream',
      header: '@$username scheduled a new stream',
      subHeader: null,
      additionalData: null,
      associatedTags: associatedTags,
      isPublic: isPublic,
    );

    return activity;
  }

  WebblenActivity generateCheckIntoStreamActivity(
      {@required String uid, @required String username, @required String contentID, @required List associatedTags, @required bool isPublic}) {
    String id = getRandomString(30);

    WebblenActivity activity = WebblenActivity(
      id: id,
      uid: uid,
      contentID: contentID,
      type: 'stream',
      header: '@$username checked into a livestream',
      subHeader: null,
      additionalData: null,
      associatedTags: associatedTags,
      isPublic: isPublic,
    );

    return activity;
  }

  WebblenActivity generateNewEventActivity(
      {@required String uid, @required String username, @required String contentID, @required List associatedTags, @required bool isPublic}) {
    String id = getRandomString(30);

    WebblenActivity activity = WebblenActivity(
      id: id,
      uid: uid,
      contentID: contentID,
      type: 'event',
      header: '@$username scheduled a new event',
      subHeader: null,
      additionalData: null,
      associatedTags: associatedTags,
      isPublic: isPublic,
    );

    return activity;
  }

  WebblenActivity generateCheckIntoEventActivity(
      {@required String uid, @required String username, @required String contentID, @required List associatedTags, @required bool isPublic}) {
    String id = getRandomString(30);

    WebblenActivity activity = WebblenActivity(
      id: id,
      uid: uid,
      contentID: contentID,
      type: 'event',
      header: '@$username checked into an event',
      subHeader: null,
      additionalData: null,
      associatedTags: associatedTags,
      isPublic: isPublic,
    );

    return activity;
  }
}
