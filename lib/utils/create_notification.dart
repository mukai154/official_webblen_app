import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CreateNotification {
  initializeNotificationSettings() {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
      initializationSettingsAndroid,
      initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: onSelectNotification,
    );
  }

  Future onSelectNotification(String payload) async {}

  createImmediateNotification(
      String notifTitle, String notifBody, String payload) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      'your channel description',
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics,
      iOSPlatformChannelSpecifics,
    );
    await FlutterLocalNotificationsPlugin().show(
      0,
      notifTitle,
      notifBody,
      platformChannelSpecifics,
      payload: 'item id 2',
    );
  }

  createTimedNotification(int notifID, int triggerDateInMilliseconds,
      String notifTitle, String notifBody, String payload) async {
    DateTime scheduledNotificationDateTime =
        DateTime.fromMillisecondsSinceEpoch(triggerDateInMilliseconds);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      payload,
      notifTitle,
      notifBody,
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics,
      iOSPlatformChannelSpecifics,
    );
    await FlutterLocalNotificationsPlugin().schedule(
      notifID,
      notifTitle,
      notifBody,
      scheduledNotificationDateTime,
      platformChannelSpecifics,
    );
  }

  deleteTimedNotification(int notifID) async {
    await FlutterLocalNotificationsPlugin().cancel(notifID);
  }
}
