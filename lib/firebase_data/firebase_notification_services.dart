import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:webblen/widgets_common/common_flushbar.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/models/webblen_notification.dart';
import 'dart:math';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/utils/create_notification.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/firebase_data/community_data.dart';

class FirebaseNotificationsService {

final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
final CollectionReference notificationRef = Firestore.instance.collection("user_notifications");

//** FIREBASE MESSAGING  */
  configFirebaseMessaging(BuildContext context, WebblenUser currentUser){
    String messageTitle;
    String messageBody;
    String messageType;
    String messageData;

    firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> message){
        messageType = message['TYPE'];
        messageData = message['DATA'];
        print('onLaunch');
        performNotifcationAction(context, messageType, messageData, currentUser);
      },
      onMessage: (Map<String, dynamic> message){
        messageTitle = message['aps']['alert']['title'];
        messageBody = message['aps']['alert']['body'];
        messageType = message['TYPE'];
        messageData = message['DATA'];
        print('onMessage');
        AlertFlushbar(headerText: messageTitle, bodyText: messageBody, notificationType: messageType).showNotificationFlushBar(context);
      },
      onResume: (Map<String, dynamic> message){
        messageTitle = message['aps']['alert']['title'];
        messageBody = message['aps']['alert']['body'];
        messageType = message['TYPE'];
        messageData = message['DATA'];
        print('onReceived');
        AlertFlushbar(headerText: messageTitle, bodyText: messageBody, notificationType: messageType).showNotificationFlushBar(context);
      },

    );
    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: false,
            alert: true,
            badge: true
        )
    );
    firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings iosSetting){
      //print('ios settings registered');
    });
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
      CommunityDataService().getCommunity(comAreaName, comName).then((com){
        if (com != null){
          PageTransitionService(context: context, community: com, currentUser: currentUser).transitionToCommunityProfilePage();
        }
      });
    } else if (notifData == "newMessage"){
      PageTransitionService(context: context, currentUser: currentUser).transitionToMessagesPage();
    }
  }

  updateFirebaseMessageToken(String uid){
    CreateNotification().intializeNotificationSettings();
    firebaseMessaging.getToken().then((token){
      UserDataService().setUserCloudMessageToken(uid, token);
    });
    //firebaseMessaging.o
  }

//** NOTIFICATIONS  */
Future<String> createFriendRequestNotification(String uid, String peerUID, String peerUsername, String peerPicUrl) async {
    String status = "";
    String notifKey = Random().nextInt(999999999).toString();
    String messageToken = await UserDataService().findUserMesseageTokenByID(peerUID);
    WebblenNotification notification = WebblenNotification(
      messageToken: messageToken,
      notificationData: peerUID,
      notificationTitle: "",
      notificationExpDate: DateTime.now().add(Duration(days: 14)).millisecondsSinceEpoch,
      notificationDescription: "@$peerUsername wants to be your friend",
      notificationExpirationDate: DateTime.now().add(Duration(days: 14)).millisecondsSinceEpoch.toString(),
      notificationKey: notifKey,
      notificationPicData: peerPicUrl,
      notificationSeen: false,
      notificationSender: peerUsername,
      notificationType: "friendRequest",
      sponsoredNotification: false,
      uid: uid,
    );

    notificationRef.document(notifKey).setData(notification.toMap()).whenComplete((){
    }).catchError((e) {
      status = e.details;
    });
    return status;
  }

  Future<String> createCommunityDisbandedNotification(String notifData, String receivingUid, String notifDescription) async {
    String status = "";
    String notifKey = Random().nextInt(999999999).toString();
    String messageToken = await UserDataService().findUserMesseageTokenByID(receivingUid);
    WebblenNotification notification = WebblenNotification(
        notificationData: null,
        notificationDescription: notifDescription,
        notificationTitle: notifDescription,
        notificationExpDate: DateTime.now().add(Duration(days: 14)).millisecondsSinceEpoch,
        notificationExpirationDate: DateTime.now().add(Duration(days: 14)).millisecondsSinceEpoch.toString(),
        notificationKey: notifKey,
        notificationPicData: null,
        notificationSeen: false,
        notificationSender: null,
        notificationType: "communityDisbanded",
        sponsoredNotification: false,
        uid: receivingUid,
        messageToken: messageToken
    );

    notificationRef.document(notifKey).setData(notification.toMap()).whenComplete((){
    }).catchError((e) {
      status = e.details;
    });
    return status;
  }

  Future<String> createCommunityActiveNotification(String notifData, String receivingUid, String notifDescription) async {
    String status = "";
    String notifKey = Random().nextInt(999999999).toString();
    String messageToken = await UserDataService().findUserMesseageTokenByID(receivingUid);
    WebblenNotification notification = WebblenNotification(
        notificationData: null,
        notificationDescription: notifDescription,
        notificationTitle: notifDescription,
        notificationExpDate: DateTime.now().add(Duration(days: 14)).millisecondsSinceEpoch,
        notificationExpirationDate: DateTime.now().add(Duration(days: 14)).millisecondsSinceEpoch.toString(),
        notificationKey: notifKey,
        notificationPicData: null,
        notificationSeen: false,
        notificationSender: null,
        notificationType: "communityActivated",
        sponsoredNotification: false,
        uid: receivingUid,
        messageToken: messageToken
    );

    notificationRef.document(notifKey).setData(notification.toMap()).whenComplete((){
    }).catchError((e) {
      status = e.details;
    });
    return status;
  }

  Future<String> createInviteNotification(String senderUid, String notifData, String receivingUid, String notifDescription) async {
    String status = "";
    String notifKey = Random().nextInt(999999999).toString();
    String messageToken = await UserDataService().findUserMesseageTokenByID(receivingUid);
    WebblenNotification notification = WebblenNotification(
      notificationData: notifData,
      notificationDescription: notifDescription,
      notificationExpDate: DateTime.now().add(Duration(days: 14)).millisecondsSinceEpoch,
      notificationTitle: "",
      notificationExpirationDate: DateTime.now().add(Duration(days: 14)).millisecondsSinceEpoch.toString(),
      notificationKey: notifKey,
      notificationPicData: null,
      notificationSeen: false,
      notificationSender: senderUid,
      notificationType: "invite",
      sponsoredNotification: false,
      uid: receivingUid,
      messageToken: messageToken
    );

    notificationRef.document(notifKey).setData(notification.toMap()).whenComplete((){
    }).catchError((e) {
      status = e.details;
    });
    return status;
  }

  Future<String> eventRecommendationNotification(String uid, String eventKey, String eventTitle) async {
    String status = "";
    String notifKey = Random().nextInt(999999999).toString();

    WebblenNotification notification = WebblenNotification(
      notificationData: eventKey,
      notificationDescription: "We Found an event you might like: $eventTitle",
      notificationExpirationDate: DateTime.now().add(Duration(days: 14)).millisecondsSinceEpoch.toString(),
      notificationKey: notifKey,
      notificationPicData: null,
      notificationSeen: false,
      notificationSender: eventKey,
      notificationType: "eventRecommendation",
      sponsoredNotification: false,
      uid: uid,
    );

    notificationRef.document(notifKey).setData(notification.toMap()).whenComplete((){
    }).catchError((e) {
      status = e.details;
    });
    return status;
  }

  Future<String> eventSharedNotification(String uid, String peerUsername, String eventTitle, String peerUID, String eventKey) async {
    String status = "";
    String notifKey = Random().nextInt(999999999).toString();

    WebblenNotification notification = WebblenNotification(
      notificationData: eventKey,
      notificationDescription: "@$peerUsername shared an event with you: $eventTitle",
      notificationExpirationDate: DateTime.now().add(Duration(days: 14)).millisecondsSinceEpoch.toString(),
      notificationKey: notifKey,
      notificationPicData: null,
      notificationSeen: false,
      notificationSender: peerUID,
      notificationType: "eventShare",
      sponsoredNotification: false,
      uid: uid,
    );

    notificationRef.document(notifKey).setData(notification.toMap()).whenComplete((){
    }).catchError((e) {
      status = e.details;
    });
    return status;
  }

  Future<Null> updateNotificationStatus(String notifKey) async {
    notificationRef.document(notifKey).updateData({"notificationSeen": true}).whenComplete(() {
    }).catchError((e) {
    });
  }

  Future<Null> deleteNotification(String notifKey) async {
    notificationRef.document(notifKey).delete();
  }

  Future<Null> deleteNotificationsByPost(String postID) async {
    QuerySnapshot notifQuery = await notificationRef.where('notificationSender', isEqualTo: postID)
        .getDocuments();
    notifQuery.documents.forEach((doc) async {
      await deleteNotification(doc.documentID);
    });
  }
  Future<Null> deleteFriendRequestByID(String currentUID, String peerUID) async {
    QuerySnapshot notifQuery = await notificationRef
        .where('uid', isEqualTo: currentUID)
        .where('notificationData', isEqualTo: peerUID)
        .where('notificationType', isEqualTo: 'friendRequest')
        .getDocuments();

    notifQuery.documents.forEach((notifDoc){
      notificationRef.document(notifDoc.documentID).delete();
    });
  }

  Future<Null> addDataField(String dataName, dynamic data) async {
    QuerySnapshot querySnapshot = await notificationRef.getDocuments();
    querySnapshot.documents.forEach((doc){
      notificationRef.document(doc.documentID).updateData({"$dataName": data}).whenComplete(() {

      }).catchError((e) {

      });
    });
  }

//  Future<Null> createTestNotification() async {
//    WebblenNotification testNotif = WebblenNotification(
//      messageToken: "dkx3Y__zhow:APA91bGe-YnldoRpuidKiom_GEoFVRpwmvsuqpAsYbTzoalRdXtDo9RJa6QgsvFtd4hOh_xutcHb9JkMcrbF-vNJb9zKKYHK7g9t3_s8j4xd9TmVpDnRcvHmGCq_JKZgF1g6OYefAJg4",
//      notificationData: "JYDnjBuv7NN9VjcWlSJFBVWGxYX2",
//      notificationDescription: "You've Been Invited to Join the Community #webblen",
//      notificationExpirationDate: "1557274741714",
//      notificationKey: "572249258",
//      notificationSeen: false,
//      notificationSender: 'dev',
//      sponsoredNotification: false,
//      notificationType: 'invite',
//      uid: 'Dya8eg1EToYMBTiCyAgFekN5J232'
//    );
//
//
//    notificationRef.document(testNotif.notificationKey).setData(testNotif.toMap()).whenComplete(() {
//    }).catchError((e) {
//    });
//  }

}