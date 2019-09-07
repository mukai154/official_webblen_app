import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:webblen/models/event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/firebase_data/community_data.dart';
import 'package:cloud_functions/cloud_functions.dart';


class EventDataService{

  Geoflutterfire geo = Geoflutterfire();
  final CollectionReference pastEventsRef = Firestore.instance.collection("past_events");
  final CollectionReference upcomingEventsRef = Firestore.instance.collection("upcoming_events");
  final CollectionReference recurringEventRef = Firestore.instance.collection("recurring_events");
  final CollectionReference userRef = Firestore.instance.collection("users");
  final StorageReference storageReference = FirebaseStorage.instance.ref();


  getAttendanceMultiplier(int attendanceCount){
    double multiplier = 0.75;
    if (attendanceCount > 5 && attendanceCount <= 10){
      multiplier = 0.85;
    } else if (attendanceCount > 10 && attendanceCount <= 20){
      multiplier = 1.00;
    } else if (attendanceCount > 20 && attendanceCount <= 100){
      multiplier = 1.25;
    } else if (attendanceCount > 100 && attendanceCount <= 500){
      multiplier = 1.75;
    } else if (attendanceCount > 500 && attendanceCount <= 1000){
      multiplier = 2.00;
    } else if (attendanceCount > 1000 && attendanceCount <= 2000){
      multiplier = 2.15;
    } else if (attendanceCount > 2000){
      multiplier = 2.5;
    }
    return multiplier;
  }

  //***CREATE
  Future<String> uploadEvent(File eventImage, Event event, double lat, double lon) async {
    String error = '';
    final String eventKey = "${Random().nextInt(999999999)}";
    String fileName = "$eventKey.jpg";
    String downloadUrl = await setEventImage(eventImage, fileName);
    event.imageURL = downloadUrl;
    event.eventKey = eventKey;
    GeoFirePoint geoFirePoint = geo.point(latitude: lat, longitude: lon);
    event.location = geo.point(latitude: lat, longitude: lon).data;
    await upcomingEventsRef.document(eventKey).setData({'d': event.toMap(), 'g': geoFirePoint.hash, 'l': geoFirePoint.geoPoint}).whenComplete((){
      if (!event.flashEvent) CommunityDataService().updateCommunityEventActivity(event.tags, event.communityAreaName, event.communityName);
    }).catchError((e) {
      error = e.toString();
    });
    return error;
  }

  Future<String> uploadRecurringEvent(File eventImage, RecurringEvent event, double lat, double lon) async {
    String error = '';
    GeoFirePoint eventLoc = geo.point(latitude: lat, longitude: lon);
    final String eventKey = "${Random().nextInt(999999999)}";
    String fileName = "$eventKey.jpg";
    String downloadUrl = await setEventImage(eventImage, fileName);
    event.imageURL = downloadUrl;
    event.eventKey = eventKey;
    event.location = eventLoc.data;
    await recurringEventRef.document(eventKey).setData(event.toMap()).whenComplete(() {
      CommunityDataService().updateCommunityEventActivity(event.tags, event.areaName, event.comName);
    }).catchError((e) {
      error = e.toString();
    });
    return error;
  }

  Future<String> setEventImage(File eventImage, String fileName) async {
    StorageReference ref = storageReference.child("events").child(fileName);
    StorageUploadTask uploadTask = ref.putFile(eventImage);
    String downloadUrl = await (await uploadTask.onComplete).ref.getDownloadURL() as String;
    return downloadUrl;
  }

  //***READ
  Future<bool> checkIfEventExists(String eventType, String eventID) async {
    bool eventExists = false;
    if (eventType == 'upcoming'){
      await upcomingEventsRef.document(eventID).get().then((result){
        if (result.exists){
          eventExists = true;
        }
      });
    } else if (eventType == 'past'){
      await pastEventsRef.document(eventID).get().then((result){
        if (result.exists){
          eventExists = true;
        }
      });
    } else if (eventType == 'recurring'){
      await recurringEventRef.document(eventID).get().then((result){
        if (result.exists){
          eventExists = true;
        }
      });
    }
    return eventExists;
  }

  Future<List<Event>> getEventsFromFollowedCommunities(String uid) async {
    List<Event> events = [];
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'getEventsFromFollowedCommunities');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'uid': uid});
    if (result.data != null){
      List query =  List.from(result.data);
      query.forEach((resultMap){
        Map<String, dynamic> evMap =  Map<String, dynamic>.from(resultMap);
        Event event = Event.fromMap(evMap);
        events.add(event);
      });
    }
    return events;
  }

  Future<List<WebblenUser>> getEventAttendees(String eventID) async {
    List<WebblenUser> users = [];
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'getEventAttendees');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'eventID': eventID});
    if (result.data != null){
      List query =  List.from(result.data);
      query.forEach((resultMap){
        Map<String, dynamic> userMap =  Map<String, dynamic>.from(resultMap);
        WebblenUser user = WebblenUser.fromMap(userMap);
        users.add(user);
      });
    }
    return users;
  }

  Future<List<Event>> getEventsNearLocation(double lat, double lon, bool forCheckIn) async {
    List<Event> events = [];
    final HttpsCallable callable = forCheckIn
        ? CloudFunctions.instance.getHttpsCallable(functionName: 'getEventsForCheckIn')
        : CloudFunctions.instance.getHttpsCallable(functionName: 'getEventsNearLocation');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'lat': lat, 'lon': lon});
    if (result.data != null){
      List query =  List.from(result.data);
      query.forEach((resultMap){
        Map<String, dynamic> eventMap =  Map<String, dynamic>.from(resultMap);
        Event event = Event.fromMap(eventMap);
        events.add(event);
      });
    }
    return events;
  }

  Future<List<Event>> getUserEventHistory(String uid) async {
    List<Event> events = [];
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'getUserEventHistory');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'uid': uid});
    if (result.data != null){
      List query =  List.from(result.data);
      query.forEach((resultMap){
        Map<String, dynamic> evMap =  Map<String, dynamic>.from(resultMap);
        Event event = Event.fromMap(evMap);
        events.add(event);
      });
    }
    return events;
  }

  Future<List<Event>> getExclusiveWebblenEvents() async {
    List<Event> events = [];
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'getExclusiveWebblenEvents');
    final HttpsCallableResult result = await callable.call();
    if (result.data != null){
      List query =  List.from(result.data);
      query.forEach((resultMap){
        Map<String, dynamic> evMap =  Map<String, dynamic>.from(resultMap);
        Event event = Event.fromMap(evMap);
        events.add(event);
      });
    }
    return events;
  }

  Future<bool> areCheckInsAvailable(double lat, double lon) async {
    bool checkInAvailable = false;
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'areCheckInsAvailable');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'lat': lat, 'lon': lon});
    if (result.data != null){
      checkInAvailable = result.data;
    }
    return checkInAvailable;
  }

  Future<List<Event>> searchForEventByName(String searchTerm, String areaName) async {
    List<Event> events = [];
    QuerySnapshot querySnapshot = await upcomingEventsRef.where("d.title", isEqualTo: searchTerm).getDocuments();
    if (querySnapshot.documents.isNotEmpty){
      querySnapshot.documents.forEach((docSnap){
        Event event = Event.fromMap(docSnap.data);
        events.add(event);
      });
    }
    return events;
  }

  Future<List<Event>> searchForEventByTag(String searchTerm, String areaName) async {
    List<Event> events = [];
    QuerySnapshot querySnapshot = await upcomingEventsRef.where("d.tags", arrayContains: searchTerm).getDocuments();
    if (querySnapshot.documents.isNotEmpty){
      querySnapshot.documents.forEach((docSnap){
        Event event = Event.fromMap(docSnap.data);
        events.add(event);
      });
    }
    return events;
  }

  //**UPDATE
  Future<String> updateEvent(Event event) async {
    String status = "";
    upcomingEventsRef.document(event.eventKey).setData(event.toMap()).whenComplete((){
    }).catchError((e) {
      status = e.details;
    });
    return status;
  }


  Future<Null> updateEventViews(String eventID) async {
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'updateEventViews');
    await callable.call(<String, dynamic>{'eventID': eventID});
  }


  Future<Null> addEventDataField(String dataName, dynamic data) async {
    QuerySnapshot querySnapshot = await upcomingEventsRef.getDocuments();
    querySnapshot.documents.forEach((doc){
      upcomingEventsRef.document(doc.documentID).updateData({"$dataName": data}).whenComplete(() {
      }).catchError((e) {
      });
    });
  }

  Future<Null> addRecEventDataField(String dataName, dynamic data) async {
    QuerySnapshot querySnapshot = await recurringEventRef.getDocuments();
    querySnapshot.documents.forEach((doc){
      recurringEventRef.document(doc.documentID).updateData({"$dataName": data}).whenComplete(() {
      }).catchError((e) {
      });
    });
  }

  Future<Event> checkInAndUpdateEventPayout(String eventID, String uid, double userAP) async {
    Event event;
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'checkInAndUpdateEventPayout');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'eventID': eventID, 'uid': uid, 'userAP': userAP});
    if (result.data != null){
        Map<String, dynamic> eventMap =  Map<String, dynamic>.from(result.data);
        event = Event.fromMap(eventMap);
    }
    return event;
  }

  Future<Event> checkoutAndUpdateEventPayout(String eventID, String uid) async {
    Event event;
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'checkoutAndUpdateEventPayout');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'eventID': eventID, 'uid': uid});
    if (result.data != null){
      Map<String, dynamic> eventMap =  Map<String, dynamic>.from(result.data);
      event = Event.fromMap(eventMap);
    }
    return event;
  }


  //***DELETE
  Future<String> deleteEvent(String eventID) async {
    String error = "";
    await upcomingEventsRef.document(eventID).get().then((doc) async {
      if (doc.exists){
       await upcomingEventsRef.document(eventID).delete();
      } else {
        await pastEventsRef.document(eventID).delete();
      }
    });
    return error;
  }

  Future<String> deleteRecurringEvent(String eventID) async {
    String error = "";
    await recurringEventRef.document(eventID).delete().whenComplete((){
    }).catchError((e) {
      error = e.toString();
    });
    return error;
  }

}