import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:webblen/models/webblen_notification.dart';

class WebblenNotificationDataService {
  final CollectionReference notifRef = Firestore.instance.collection("user_notifications");

  //GENERAL
  Future<Null> updateNotificationStatus(String notifKey) async {
    notifRef.doc(notifKey).update(({'notificationSeen': true}));
  }

  Future<Null> deleteNotification(String notifKey) async {
    notifRef.doc(notifKey).delete();
  }

  Future<List<WebblenNotification>> getUserNotifications(String uid) async {
    List<WebblenNotification> notifs = [];
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('getUserNotifications');
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'uid': uid,
      },
    );
    if (result.data != null) {
      List query = List.from(result.data);
      query.forEach((resultMap) {
        Map<String, dynamic> notifMap = Map<String, dynamic>.from(resultMap);
        WebblenNotification notif = WebblenNotification.fromMap(notifMap);
        notifs.add(notif);
      });
    }
    return notifs;
  }

  sendPostCommentNotification(String postID, String postAuthorID, String commenterID, String commentBody) async {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendPostCommentNotification');
    await callable.call(
      <String, dynamic>{
        'postID': postID,
        'postAuthorID': postAuthorID,
        'commenterID': commenterID,
        'commentBody': commentBody,
      },
    );
  }

  sendPostCommentReplyNotification(String postID, String originalCommenterID, String originalCommentID, String commenterID, String commentBody) async {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendPostCommentReplyNotification');
    await callable.call(
      <String, dynamic>{
        'postID': postID,
        'originalCommentID': originalCommentID,
        'originalCommenterID': originalCommenterID,
        'commenterID': commenterID,
        'commentBody': commentBody,
      },
    );
  }
}
