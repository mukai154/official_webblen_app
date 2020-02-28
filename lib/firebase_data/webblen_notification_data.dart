import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:random_string/random_string.dart';
import 'package:webblen/models/webblen_notification.dart';
import 'user_data.dart';

class WebblenNotificationDataService {
  final CollectionReference notifRef =
      Firestore.instance.collection("user_notifications");
  final StorageReference storageReference = FirebaseStorage.instance.ref();

  //GENERAL
  Future<Null> updateNotificationStatus(String notifKey) async {
    notifRef.document(notifKey).updateData(({'notificationSeen': true}));
  }

  Future<Null> deleteNotification(String notifKey) async {
    notifRef.document(notifKey).delete();
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
  Future<String> shareEventWithFriend(String receivingUID, String senderUID,
      String senderName, String eventKey, String eventTitle) async {
    String error;
    String notifDescription;
    String notifKey = randomAlphaNumeric(10);
    int ranNum = Random().nextInt(5);
    if (ranNum == 0) {
      notifDescription =
          "@$senderName thinks this is something you should checkout 👀";
    } else if (ranNum == 1) {
      notifDescription = "@$senderName shared an event with you!";
    } else if (ranNum == 2) {
      notifDescription =
          "@$senderName knows this event would be 10x better if you came";
    } else if (ranNum == 3) {
      notifDescription = "@$senderName would love if you came here️";
    } else if (ranNum == 4) {
      notifDescription = "@$senderName doesn't want you to miss this...";
    } else {
      notifDescription =
          "@$senderName thinks this is something worth looking into";
    }
    WebblenNotification notification = WebblenNotification(
      notificationData: eventKey,
      notificationDescription: notifDescription,
      notificationExpDate: DateTime.now()
          .add(
            Duration(
              days: 14,
            ),
          )
          .millisecondsSinceEpoch,
      notificationTitle: eventTitle,
      notificationExpirationDate: DateTime.now()
          .add(
            Duration(
              days: 14,
            ),
          )
          .millisecondsSinceEpoch
          .toString(),
      notificationKey: notifKey,
      notificationSeen: false,
      notificationSender: senderName,
      notificationType: "eventShare",
      sponsoredNotification: false,
      uid: receivingUID,
      messageToken: "",
    );
    notifRef
        .document(notifKey)
        .setData(notification.toMap())
        .whenComplete(() {})
        .catchError((e) {
      error = e.details;
    });
    return error;
  }

  //Community Invitations
  Future<bool> checkIfComInviteExists(
      String areaName, String comName, String receivingUid) async {
    bool exists = false;
    String modifiedComName = comName.contains("#") ? comName : "#$comName";
    String comNotifData = '$areaName.$modifiedComName';
    await notifRef
        .where(
          'notificationData',
          isEqualTo: comNotifData,
        )
        .where(
          'uid',
          isEqualTo: receivingUid,
        )
        .where(
          'notificationType',
          isEqualTo: 'invite',
        )
        .getDocuments()
        .then((result) {
      if (result.documents != null && result.documents.length > 0) {
        exists = true;
      }
    });
    return exists;
  }

  Future<String> sendCommunityInviteNotif(String senderUid, String areaName,
      String comName, String receivingUid, String notifDescription) async {
    String status = "";
    String modifiedComName = comName.contains("#") ? comName : "#$comName";
    String comNotifData = '$areaName.$modifiedComName';
    String notifKey = Random().nextInt(999999999).toString();
    String messageToken =
        await UserDataService().findUserMesseageTokenByID(receivingUid);
    WebblenNotification notification = WebblenNotification(
      notificationData: comNotifData,
      notificationDescription: notifDescription,
      notificationExpDate: DateTime.now()
          .add(
            Duration(
              days: 14,
            ),
          )
          .millisecondsSinceEpoch,
      notificationTitle: "",
      notificationExpirationDate: DateTime.now()
          .add(
            Duration(
              days: 14,
            ),
          )
          .millisecondsSinceEpoch
          .toString(),
      notificationKey: notifKey,
      notificationSeen: false,
      notificationSender: senderUid,
      notificationType: "invite",
      sponsoredNotification: false,
      uid: receivingUid,
      messageToken: messageToken,
    );

    notifRef
        .document(notifKey)
        .setData(notification.toMap())
        .whenComplete(() {})
        .catchError((e) {
      status = e.details;
    });
    return status;
  }

  Future<bool> acceptCommunityInvite(
      String areaName, String comName, String uid, String notifKey) async {
    bool success = false;
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'acceptCommunityInvite',
    );
    final HttpsCallableResult result = await callable.call(<String, dynamic>{
      'areaName': areaName,
      'comName': comName,
      'uid': uid,
      'notifKey': notifKey,
    });
    if (result.data != null) {
      success = result.data;
    }
    return success;
  }

  //Friend Requests
  Future<bool> checkIfFriendRequestExists(
      String senderUID, String receivingUid) async {
    bool exists = false;
    await notifRef
        .where(
          'notificationData',
          isEqualTo: senderUID,
        )
        .where('uid', isEqualTo: receivingUid)
        .getDocuments()
        .then((result) {
      if (result.documents != null && result.documents.length > 0) {
        exists = true;
      }
    });
    return exists;
  }

  Future<String> sendFriendRequest(
      String uid, String peerUID, String username) async {
    String error = "";
    String notifKey = Random().nextInt(999999999).toString();
    String messageToken =
        await UserDataService().findUserMesseageTokenByID(peerUID);
    WebblenNotification notification = WebblenNotification(
      messageToken: messageToken,
      notificationData: uid,
      notificationTitle: "",
      notificationExpDate: DateTime.now()
          .add(
            Duration(
              days: 14,
            ),
          )
          .millisecondsSinceEpoch,
      notificationDescription: "@$username wants to be your friend",
      notificationExpirationDate: DateTime.now()
          .add(
            Duration(
              days: 14,
            ),
          )
          .millisecondsSinceEpoch
          .toString(),
      notificationKey: notifKey,
      notificationSeen: false,
      notificationSender: username,
      notificationType: "friendRequest",
      sponsoredNotification: false,
      uid: peerUID,
    );
    notifRef
        .document(notifKey)
        .setData(notification.toMap())
        .whenComplete(() {})
        .catchError((e) {
      error = e.details;
    });
    return error;
  }

  Future<bool> acceptFriendRequest(
      String uid, String friendUid, String notifKey) async {
    bool success = false;
    String key = notifKey;
    if (notifKey == null) {
      notifKey = "";
    }
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'acceptFriendRequest',
    );
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'receiverUID': uid,
        'requesterUID': friendUid,
        'notifKey': key,
      },
    );
    if (result.data != null) {
      success = result.data;
    }
    return success;
  }

  Future<bool> denyFriendRequest(
      String uid, String friendUid, String notifKey) async {
    bool success = false;
    String key = notifKey;
    if (notifKey == null) {
      notifKey = "";
    }
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'denyFriendRequest',
    );
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'receiverUID': uid,
        'requesterUID': friendUid,
        'notifKey': key,
      },
    );
    if (result.data != null) {
      success = result.data;
    }
    return success;
  }

  //Posts
  Future<Null> deletePostNotifications(
      String postTitle, String areaName, String comName) async {
    String modifiedComName = comName.contains("#") ? comName : "#$comName";
    String comNotifData = '$areaName.$modifiedComName';
    await notifRef
        .where(
          'notificationDescription',
          isEqualTo: postTitle,
        )
        .where(
          'notificationData',
          isEqualTo: comNotifData,
        )
        .getDocuments()
        .then((query) {
      if (query.documents != null && query.documents.length > 0) {
        query.documents.forEach((doc) {
          notifRef.document(doc.documentID).delete();
        });
      }
    });
  }
}
