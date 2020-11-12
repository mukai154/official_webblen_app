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
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'getUserNotifications',
    );
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

  //EVENTS
  // Future<String> shareEventWithFriend(String receivingUID, String senderUID, String senderName, String eventKey, String eventTitle) async {
  //   String error;
  //   String notifDescription;
  //   String notifKey = randomAlphaNumeric(10);
  //   int ranNum = Random().nextInt(5);
  //   if (ranNum == 0) {
  //     notifDescription = "@$senderName thinks this is something you should checkout 👀";
  //   } else if (ranNum == 1) {
  //     notifDescription = "@$senderName shared an event with you!";
  //   } else if (ranNum == 2) {
  //     notifDescription = "@$senderName knows this event would be 10x better if you came";
  //   } else if (ranNum == 3) {
  //     notifDescription = "@$senderName would love if you came here️";
  //   } else if (ranNum == 4) {
  //     notifDescription = "@$senderName doesn't want you to miss this...";
  //   } else {
  //     notifDescription = "@$senderName thinks this is something worth looking into";
  //   }
  //   WebblenNotification notification = WebblenNotification(
  //     notificationData: eventKey,
  //     notificationDescription: notifDescription,
  //     notificationExpDate: DateTime.now()
  //         .add(
  //           Duration(
  //             days: 14,
  //           ),
  //         )
  //         .millisecondsSinceEpoch,
  //     notificationTitle: eventTitle,
  //     notificationExpirationDate: DateTime.now()
  //         .add(
  //           Duration(
  //             days: 14,
  //           ),
  //         )
  //         .millisecondsSinceEpoch
  //         .toString(),
  //     notificationKey: notifKey,
  //     notificationSeen: false,
  //     notificationSender: senderName,
  //     notificationType: "eventShare",
  //     sponsoredNotification: false,
  //     uid: receivingUID,
  //     messageToken: "",
  //   );
  //   notifRef.document(notifKey).setData(notification.toMap()).whenComplete(() {}).catchError((e) {
  //     error = e.details;
  //   });
  //   return error;
  // }

}
