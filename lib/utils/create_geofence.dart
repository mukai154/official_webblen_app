//import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
//import 'package:webblen/models/event_post.dart';
//import 'create_notification.dart';
//
//class CreateGeoFence {
//
//  intializedBackgroundLocation(){
//    bg.Config params = new bg.Config(
//        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
//        distanceFilter: 10.0,
//        stopOnTerminate: false,
//        startOnBoot: true,
//        url: 'http://my.server.com',
//        params: {
//          "user_id": 123
//        },
//        headers: {
//          "my-auth-token":"secret-key"
//        }
//    );
//
//    bg.BackgroundGeolocation.ready(params).then((bg.State state) {
//      print('[ready] BackgroundGeolocation is configured and ready to use');
//      bg.BackgroundGeolocation.start();
//    });
//  }
//
//  createGeoFences(List<EventPost> eventPosts){
//    List<bg.Geofence> geoFences = [];
//    eventPosts.forEach((event){
//      bg.Geofence geofence = bg.Geofence(
//        identifier: event.eventKey,
//        radius: 10,
//        latitude: event.lat,
//        longitude: event.lon,
//        notifyOnDwell: true,
//        loiteringDelay: 20000,
//      );
//      geoFences.add(geofence);
//    });
//    //bg.BackgroundGeolocation.addGeofences(geoFences.toList());
//  }
//
//  onGeoFenceLoiter(bg.Geofence geoFence){
//    CreateNotification().createImmediateNotification(
//        "Event Found!",
//        "Check In to Earn Webblen!",
//        'test'//widget.eventPost.eventKey
//    );
//  }
//
//  getNumberOfFences(){
//    bg.BackgroundGeolocation.geofences.then((fence){
//      print(fence.length);
//    });
//  }
//
//}