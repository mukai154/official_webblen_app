import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class CreateNotification {

  intializeNotificationSettings(){
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();

    var initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {

  }

  createImmediateNotification(String notifTitle, String notifBody, String payload) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await FlutterLocalNotificationsPlugin().show(0, notifTitle, notifBody, platformChannelSpecifics, payload: 'item id 2');
  }

  createTimedNotification(int notifID, int triggerDateInMilliseconds, String notifTitle, String notifBody, String payload) async {
    DateTime scheduledNotificationDateTime = DateTime.fromMillisecondsSinceEpoch(triggerDateInMilliseconds);
    print(scheduledNotificationDateTime);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(payload, notifTitle, notifBody);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await FlutterLocalNotificationsPlugin().schedule(notifID, notifTitle, notifBody, scheduledNotificationDateTime, platformChannelSpecifics);
  }

  deleteTimedNotification(int notifID) async{
    await FlutterLocalNotificationsPlugin().cancel(notifID);
  }
}