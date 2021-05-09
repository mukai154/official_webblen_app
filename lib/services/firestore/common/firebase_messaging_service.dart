import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';

import '../../../main.dart';

class FirebaseMessagingService {
  Future<String?> getDeviceToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    return token;
  }

  Future<void> setDeviceMessagingToken(String? uid) async {
    String? token = await getDeviceToken().catchError((e) {
      print(e);
    });
    if (token != null) {
      UserDataService _userDataService = locator<UserDataService>();
      await _userDataService.updateUserDeviceToken(id: uid, messageToken: token);
    }
  }

  configureFirebaseMessagingListener() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(message);
      int hash = message.notification.hashCode;
      String? title = message.notification?.title;
      String? body = message.notification?.body;
      int badgeCount = int.parse(message.data['badgeCount']);

      AndroidNotification? android = message.notification?.android;
      if (android != null) {
        flutterLocalNotificationsPlugin.show(
          hash,
          title,
          body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
              icon: 'launch_background',
            ),
          ),
        );
      } else {
        flutterLocalNotificationsPlugin.show(
          hash,
          title,
          body,
          NotificationDetails(
            iOS: IOSNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              badgeNumber: badgeCount,
            ),
          ),
        );
      }
    }).onError((e) {
      print(e);
    });
  }
}
