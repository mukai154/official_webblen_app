//import 'dart:math';
//
//import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
//import 'package:webblen/firebase_data/event_data.dart';
//import 'package:webblen/firebase_data/user_data.dart';
//import 'package:webblen/services_general/services_location.dart';
//import 'package:webblen/utils/create_notification.dart';
//
//class GeoFencing {
//  initializeGeoFencing() {
//    bg.BackgroundGeolocation.ready(bg.Config(
//      //url: 'http://your.server.com/geofences',
//      autoSync: true,
//      startOnBoot: true,
//      stopOnTerminate: false,
//      reset: false,
//    )).then((bg.State state) {
//      bg.BackgroundGeolocation.startGeofences();
//    });
//  }
//
//  bg.Geofence createGeoFence(String eventID, double lat, lon) {
//    print('generating geofence...');
//    bg.Geofence geoFence = bg.Geofence(
//      identifier: eventID,
//      radius: 50,
//      latitude: lat,
//      longitude: lon,
//      notifyOnEntry: true,
//    );
//    return geoFence;
//  }
//
//  addGeoFences(List<bg.Geofence> geoFences) {
//    bg.BackgroundGeolocation.addGeofences(geoFences).then((didAddGeoFences) {
//      // print('added geofences');
//    }).catchError((error) {
//      // print('failed to add geofences: $error');
//    });
//  }
//
//  removeAllGeoFences() {
//    bg.BackgroundGeolocation.removeGeofences().then((bool success) {
//      //  print('[removeGeofences] all geofences have been destroyed');
//    });
//  }
//
//  listenForGeoFences(String uid) async {
//    bg.BackgroundGeolocation.onGeofence((bg.GeofenceEvent event) async {
//      int ranNum = Random().nextInt(5);
//      int index1 = event.identifier.indexOf(":");
//      int index2 = event.identifier.indexOf("-");
//      int index3 = event.identifier.indexOf(".");
//      String eventTitle = event.identifier.substring(index1 + 1, index2);
//      int eventStartDateInMilliseconds = int.parse(event.identifier.substring(index2 + 1, index3));
//      int eventEndDateInMilliseconds = int.parse(event.identifier.substring(index3 + 1));
//      int currentDateInMilliseconds = DateTime.now().millisecondsSinceEpoch;
//      int timeUntilEventInMilliseconds = eventStartDateInMilliseconds - currentDateInMilliseconds;
//      //int lastNotifTime = await UserDataService().getLastNotifTime(uid);
//      //if (currentDateInMilliseconds - lastNotifTime > 1800000){
//      if (timeUntilEventInMilliseconds <= 1800000 && timeUntilEventInMilliseconds > 0) {
//        if (ranNum == 1) {
//          CreateNotification()
//              .createImmediateNotification("There's an event happening soon nearby", 'You Might Not Want to Miss This One 😶', event.identifier);
//        } else if (ranNum == 2) {
//          CreateNotification()
//              .createImmediateNotification("Oh Snap! We Found Something You Might Be Interested in Attending", 'Check It Out Now 🎉', event.identifier);
//        } else if (ranNum == 3) {
//          CreateNotification().createImmediateNotification("$eventTitle Will Be Happnening Soon!", 'Hope to See You There 🙌', event.identifier);
//        } else if (ranNum == 4) {
//          CreateNotification().createImmediateNotification("There's something happening around here... 🤔", 'Find Out What it Is ', event.identifier);
//        } else {
//          CreateNotification().createImmediateNotification("If you are a fan of meeting new people...", 'Come to $eventTitle', event.identifier);
//        }
//      } else if (currentDateInMilliseconds >= eventStartDateInMilliseconds && currentDateInMilliseconds <= eventEndDateInMilliseconds) {
//        if (ranNum == 1) {
//          CreateNotification().createImmediateNotification("$eventTitle is happening nearby!", 'Check In to Earn Webblen 💸', event.identifier);
//        } else if (ranNum == 2) {
//          CreateNotification().createImmediateNotification("Want Some Webblen?", 'Then Why Not Check In at this Event? 🙃‍', event.identifier);
//        } else if (ranNum == 3) {
//          CreateNotification().createImmediateNotification("Check in Found!", 'Earn Some Webblen for Being Here‍', event.identifier);
//        } else if (ranNum == 4) {
//          CreateNotification().createImmediateNotification("Fun Fact!", "If You Check In Here, You'll Earn Webblen 💸", event.identifier);
//        } else {
//          CreateNotification().createImmediateNotification("How Nice of You to Show Up 😄", 'Get Some Webblen For Your Time‍', event.identifier);
//        }
//        bg.BackgroundGeolocation.removeGeofence(event.identifier);
//      }
//      UserDataService().updateNotifTime(uid);
//      // }
//    });
//  }
//
//  addAndCreateGeoFencesFromEvents(double lat, double lon, String uid) {
//    initializeGeoFencing();
//    //removeAllGeoFences();
//    EventDataService().getEventsNearLocation(lat, lon, false).then((events) {
//      //print(events.length);
//      events.forEach((event) {
//        String geoIdentifier =
//            event.eventKey + ":" + event.title + "-" + event.startDateInMilliseconds.toString() + "." + event.endDateInMilliseconds.toString();
//        double lat = LocationService().getLatFromGeopoint(event.location['geopoint']);
//        double lon = LocationService().getLonFromGeopoint(event.location['geopoint']);
//        bg.Geofence geoFence = createGeoFence(geoIdentifier, lat, lon);
//        bg.BackgroundGeolocation.addGeofence(geoFence).then((didAddGeoFence) {
//          //print('geofence made for event: ${event.title}');
//        }).catchError((error) {
//          //print('failed to add geofences: $error');
//        });
//      });
//      listenForGeoFences(uid);
//    });
//  }
//}
