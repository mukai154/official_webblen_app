import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'dart:math';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_notification_services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:webblen/models/event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/firebase_data/community_data.dart';
import 'package:cloud_functions/cloud_functions.dart';

class EventDataService{
  Geoflutterfire geo = Geoflutterfire();
  final CollectionReference eventRef = Firestore.instance.collection("events");
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

  Future<String> uploadEvent(File eventImage, Event event, double lat, double lon) async {
    String error = '';
    GeoFirePoint eventLoc = geo.point(latitude: lat, longitude: lon);
    final String eventKey = "${Random().nextInt(999999999)}";
    String fileName = "$eventKey.jpg";
    String downloadUrl = await setEventImage(eventImage, fileName);
    event.imageURL = downloadUrl;
    event.eventKey = eventKey;
    event.location = eventLoc.data;
    await eventRef.document(eventKey).setData(event.toMap()).whenComplete(() {
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

  Future<String> updateEvent(Event event) async {
    String status = "";
    eventRef.document(event.eventKey).setData(event.toMap()).whenComplete((){
    }).catchError((e) {
      status = e.details;
    });
    return status;
  }


  Future<String> setEventImage(File eventImage, String fileName) async {
    StorageReference ref = storageReference.child("events").child(fileName);
    StorageUploadTask uploadTask = ref.putFile(eventImage);
    String downloadUrl = await (await uploadTask.onComplete).ref.getDownloadURL() as String;
    return downloadUrl;
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

  Future<Event> findEventByKey(String eventKey) async {
    Event event;
    DocumentSnapshot eventDoc = await eventRef.document(eventKey).get();
    if (eventDoc.exists){
      event = Event.fromMap(eventDoc.data);
    }
    return event;
  }

  Future<List<Event>> findSpecialEventsNearLocation(double lat, double lon) async {
    List<Event> nearbyEvents = [];
    GeoFirePoint center = geo.point(latitude: lat, longitude: lon);
    List<DocumentSnapshot> docSnaphots = await geo.collection(collectionRef: eventRef).within(center: center, radius: 20, field: 'location').first;

    docSnaphots.forEach((doc){
      if (doc.data['recurring'] == 'none' && doc.data['startDateInMilliseconds'] != null){
        Event event = Event.fromMap(doc.data);
        nearbyEvents.add(event);
      }
    });

    return nearbyEvents;
  }

  Future<String> saveEvent(String eventKey, String uid) async {
    String error = "";
    DocumentSnapshot userDoc = await userRef.document(uid).get();
    List savedEvents = userDoc['savedEvents'];
    savedEvents = savedEvents.toList(growable: true);
    savedEvents.add(eventKey);
    userRef.document(uid).updateData({"savedEvents": savedEvents}).whenComplete((){
    }).catchError((e) {
      error = e.details;
    });
    return error;
  }

  Future<String> updateEventPayOut(String uid, String eventID) async {
    String status = "";
    double eventPayout;
    double attendanceMultiplier;
    DocumentSnapshot eventSnapshot = await eventRef.document(eventID).get();
    List attendees = eventSnapshot.data["attendees"];
    int attendanceCount = attendees.length;
    attendanceMultiplier = getAttendanceMultiplier(attendanceCount);
    DocumentSnapshot userSnapshot = await userRef.document(uid).get();
    double userImpact = userSnapshot.data["impactPoints"].toDouble();
    eventPayout = (attendanceCount * attendanceMultiplier) + (userImpact * 0.05);
    eventRef.document(eventID).updateData({"eventPayout": eventPayout}).whenComplete((){
    }).catchError((e) {
      status = e.details;
    });
    return status;
  }


  Future<int> updateEventViews(String eventID) async {
    DocumentSnapshot documentSnapshot = await eventRef.document(eventID).get();
    int viewCount = documentSnapshot.data["views"];
    viewCount += 1;
    eventRef.document(eventID).updateData({"views": viewCount}).whenComplete((){
    }).catchError((e) {
      return 10;
    });
    return viewCount;
  }

  Future<int> updateEstimatedTurnout(String eventID) async {
    int returnVal = 0;
    DocumentSnapshot documentSnapshot = await eventRef.document(eventID).get();
    int viewCount = documentSnapshot.data["views"];
    int currentTurnout = documentSnapshot.data["estimatedTurnout"];
    viewCount += 1;
    double estimatedCalculation = viewCount / 3;
    int randNum = Random().nextInt(10);
    int estimatedTurnout = estimatedCalculation.round();
    if (randNum <= 3 && currentTurnout < estimatedTurnout){
      eventRef.document(eventID).updateData({"estimatedTurnout": estimatedTurnout, "views": viewCount}).whenComplete((){
        returnVal = estimatedTurnout;
      }).catchError((e) {
        returnVal = 10;
      });
    } else {
      eventRef.document(eventID).updateData({ "views": viewCount}).whenComplete((){
        returnVal = estimatedTurnout;
      }).catchError((e) {
        returnVal = 10;
      });
    }
    return returnVal;
  }

  Future<Null> addEventDataField(String dataName, dynamic data) async {
    QuerySnapshot querySnapshot = await eventRef.getDocuments();
    querySnapshot.documents.forEach((doc){
      eventRef.document(doc.documentID).updateData({"$dataName": data}).whenComplete(() {
      }).catchError((e) {
      });
    });
  }


  Future<Null> distributePoints(Event event) async {
    if (event.attendees != null){
      event.attendees.forEach((attendeeUID){
        UserDataService().updateEventPoints(attendeeUID, event.eventPayout).then((error){
        });
      });
      eventRef.document(event.eventKey).updateData({"pointsDistributedToUsers": true}).whenComplete((){
        //return error;
      }).catchError((e) {
        //return error;
      });
    }
  }

  Future<String> receiveEventPoints(List eventKeys) async {
    String error = "";
    DateTime currentDateTime = DateTime.now();
    if (eventKeys != null){
      eventKeys.forEach((key) async {
        QuerySnapshot eventDocs = await eventRef
            .where('eventKey', isEqualTo: key)
            .where('pointsDistributedToUsers', isEqualTo: false)
            .getDocuments();
        if (eventDocs != null && eventDocs.documents.isNotEmpty){
          eventDocs.documents.forEach((eventDoc){
            Event event = Event.fromMap(eventDoc.data);
            DateTime eventEnd = DateTime.fromMillisecondsSinceEpoch(event.endDateInMilliseconds);
            if (!event.pointsDistributedToUsers && currentDateTime.isAfter(eventEnd)){
              double points = event.eventPayout;
              if (event.attendees != null){
                event.attendees.forEach((uid) async {
                  DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
                  double userImpact = documentSnapshot.data["impactPoints"] * 1.00;
                  double userPoints = documentSnapshot.data["eventPoints"] * 1.00;
                  double rewardAmount = (userImpact * 0.05) * (points * 0.8);
                  userPoints += rewardAmount;
                  userRef.document(uid).updateData({"eventPoints": userPoints}).whenComplete((){
                  }).catchError((e) {
                    error = 'error receiving points';
                  });
                });
              }
              eventRef.document(event.eventKey).updateData({"pointsDistributedToUsers": true}).whenComplete((){
              }).catchError((e) {
                error = 'error receiving points';
              });
            }
          });
        }
      });
    }
    return error;
  }

  Future<String> deleteEvent(String eventID) async {
    String error = "";
    await eventRef.document(eventID).delete().whenComplete((){
    }).catchError((e) {
      error = e.toString();
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

  Future<List<Event>> searchForEventByName(String searchTerm, String areaName) async {
    List<Event> events = [];
    QuerySnapshot querySnapshot = await eventRef.where("title", isEqualTo: searchTerm).getDocuments();
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
    QuerySnapshot querySnapshot = await eventRef.where("tags", arrayContains: searchTerm).getDocuments();
    if (querySnapshot.documents.isNotEmpty){
      querySnapshot.documents.forEach((docSnap){
        Event event = Event.fromMap(docSnap.data);
        events.add(event);
      });
    }
    return events;
  }

}