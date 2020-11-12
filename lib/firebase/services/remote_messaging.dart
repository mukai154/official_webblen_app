import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/utils/create_notification.dart';

class FirebaseMessagingService {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final CollectionReference notificationRef = FirebaseFirestore.instance.collection("user_notifications");

//** FIREBASE MESSAGING  */
  configFirebaseMessaging(BuildContext context) {
    String messageTitle;
    String messageBody;
    String messageType;
    String messageData;

    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        //_showItemDialog(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        //_navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        //_navigateToItemDetail(message);
      },
    );

    firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
        sound: false,
        alert: true,
        badge: true,
      ),
    );
    firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings iosSetting) {
      //print('ios settings registered');
    });
  }

  updateFirebaseMessageToken(String uid) {
    CreateNotification().initializeNotificationSettings();
    firebaseMessaging.getToken().then((token) {
      WebblenUserData().setUserCloudMessageToken(
        uid,
        token,
      );
    });
  }
}
