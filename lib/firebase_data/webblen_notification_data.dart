import 'package:flutter/material.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'community_data.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:webblen/models/webblen_notification.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:math';
import 'user_data.dart';

class WebblenNotificationDataService {

  final CollectionReference notifRef = Firestore.instance.collection("user_notifications");
  final StorageReference storageReference = FirebaseStorage.instance.ref();


  Future<Null> updateNotificationStatus(String notifKey) async {
    notifRef.document(notifKey).updateData(({'notificationSeen': true}));
  }

  Future<Null> deleteNotification(String notifKey) async {
    notifRef.document(notifKey).delete();
  }

  Future<List<WebblenNotification>> getUserNotifications(String uid) async {
    List<WebblenNotification> notifs = [];
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'getUserNotifications');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'uid': uid});
    if (result.data != null){
      List query =  List.from(result.data);
      query.forEach((resultMap){
        Map<String, dynamic> notifMap =  Map<String, dynamic>.from(resultMap);
        WebblenNotification notif = WebblenNotification.fromMap(notifMap);
        notifs.add(notif);
      });
    }
    return notifs;
  }

  performNotifcationAction(BuildContext context, String notifType, String notifData, WebblenUser currentUser) async {
    if (notifData == "notification"){
      PageTransitionService(context: context, currentUser: currentUser).transitionToNotificationsPage();
    } else if (notifData == "deposit"){
      PageTransitionService(context: context, currentUser: currentUser).transitionToWalletPage();
    } else if (notifData == "newPost" || notifData == "newPostComment"){
      CommunityDataService().getPost(notifData).then((newsPost){
        if (newsPost != null){
          PageTransitionService(context: context, newsPost: newsPost).transitionToPostCommentsPage();
        }
      });
    } else if (notifData == "newEvent"){
      List<String> comData = notifData.split(".");
      String comAreaName = comData[0];
      String comName = comData[1];
      CommunityDataService().getCommunityByName(comAreaName, comName).then((com){
        if (com != null){
          PageTransitionService(context: context, community: com, currentUser: currentUser).transitionToCommunityProfilePage();
        }
      });
    } else if (notifData == "newMessage"){
      PageTransitionService(context: context, currentUser: currentUser).transitionToMessagesPage();
    }
  }

  //Community Invitations
  Future<bool> checkIfComInviteExists(String areaName, String comName, String receivingUid) async {
    bool exists = false;
    String modifiedComName = comName.contains("#") ? comName : "#$comName";
    String comNotifData = '$areaName.$modifiedComName';
    await notifRef
        .where('notificationData', isEqualTo: comNotifData)
        .where('uid', isEqualTo: receivingUid)
        .where('notificationType', isEqualTo: 'invite')
        .getDocuments().then((result){
          if (result.documents != null && result.documents.length > 0){
            exists = true;
          }
    });
    return exists;
  }

  Future<String> sendCommunityInviteNotif(String senderUid, String areaName, String comName, String receivingUid, String notifDescription) async {
    String status = "";
    String modifiedComName = comName.contains("#") ? comName : "#$comName";
    String comNotifData = '$areaName.$modifiedComName';
    String notifKey = Random().nextInt(999999999).toString();
    String messageToken = await UserDataService().findUserMesseageTokenByID(receivingUid);
    WebblenNotification notification = WebblenNotification(
        notificationData: comNotifData,
        notificationDescription: notifDescription,
        notificationExpDate: DateTime.now().add(Duration(days: 14)).millisecondsSinceEpoch,
        notificationTitle: "",
        notificationExpirationDate: DateTime.now().add(Duration(days: 14)).millisecondsSinceEpoch.toString(),
        notificationKey: notifKey,
        notificationSeen: false,
        notificationSender: senderUid,
        notificationType: "invite",
        sponsoredNotification: false,
        uid: receivingUid,
        messageToken: messageToken
    );

    notifRef.document(notifKey).setData(notification.toMap()).whenComplete((){
    }).catchError((e) {
      status = e.details;
    });
    return status;
  }

  Future<bool> acceptCommunityInvite(String areaName, String comName, String uid, String notifKey) async {
    bool success = false;
    print(areaName);
    print(comName);
    print(uid);
    print(notifKey);
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'acceptCommunityInvite');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{
      'areaName': areaName,
      'comName': comName,
      'uid': uid,
      'notifKey': notifKey
    });
    if (result.data != null){
      success = result.data;
    }
    return success;
  }

  //Friend Requests
  Future<bool> checkIfFriendRequestExists(String senderUID, String receivingUid) async {
    bool exists = false;
    await notifRef
        .where('notificationData', isEqualTo: senderUID)
        .where('uid', isEqualTo: receivingUid)
        .getDocuments().then((result){
      if (result.documents != null && result.documents.length > 0){
        exists = true;
      }
    });
    return exists;
  }

  Future<String> sendFriendRequest(String uid, String peerUID, String username) async {
    String error = "";
    String notifKey = Random().nextInt(999999999).toString();
    String messageToken = await UserDataService().findUserMesseageTokenByID(peerUID);
    WebblenNotification notification = WebblenNotification(
      messageToken: messageToken,
      notificationData: uid,
      notificationTitle: "",
      notificationExpDate: DateTime.now().add(Duration(days: 14)).millisecondsSinceEpoch,
      notificationDescription: "@$username wants to be your friend",
      notificationExpirationDate: DateTime.now().add(Duration(days: 14)).millisecondsSinceEpoch.toString(),
      notificationKey: notifKey,
      notificationSeen: false,
      notificationSender: username,
      notificationType: "friendRequest",
      sponsoredNotification: false,
      uid: peerUID,
    );
    notifRef.document(notifKey).setData(notification.toMap()).whenComplete((){
    }).catchError((e) {
      error = e.details;
    });
    return error;
  }

  Future<bool> acceptFriendRequest(String uid, String friendUid, String notifKey) async {
    bool success = false;
    String key = notifKey;
    if (notifKey == null){
      notifKey = "";
    }
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'acceptFriendRequest');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{
      'receiverUID': uid,
      'requesterUID': friendUid,
      'notifKey': key
    });
    if (result.data != null){
      success = result.data;
    }
    return success;
  }

  Future<bool> denyFriendRequest(String uid, String friendUid, String notifKey) async {
    bool success = false;
    String key = notifKey;
    if (notifKey == null){
      notifKey = "";
    }
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'denyFriendRequest');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{
      'receiverUID': uid,
      'requesterUID': friendUid,
      'notifKey': key
    });
    if (result.data != null){
      success = result.data;
    }
    return success;
  }

  //Posts
  Future<Null> deletePostNotifications(String postTitle, String areaName, String comName) async {
    String modifiedComName = comName.contains("#") ? comName : "#$comName";
    String comNotifData = '$areaName.$modifiedComName';
    await notifRef.where('notificationDescription', isEqualTo: postTitle)
        .where('notificationData', isEqualTo: comNotifData).getDocuments().then((query){
          if (query.documents != null && query.documents.length > 0){
            query.documents.forEach((doc){
              notifRef.document(doc.documentID).delete();
            });
          }
    });
  }




}