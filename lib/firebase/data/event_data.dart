import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:random_string/random_string.dart';
import 'package:webblen/models/event_ticket.dart';
import 'package:webblen/models/ticket_distro.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/location/location_service.dart';

import 'post_data.dart';

class EventDataService {
  final CollectionReference eventsRef = FirebaseFirestore.instance.collection("events");
  final CollectionReference activeStreamRef = FirebaseFirestore.instance.collection("active_streams");
  final CollectionReference ticketsRef = FirebaseFirestore.instance.collection("purchased_tickets");
  final CollectionReference ticketDistroRef = FirebaseFirestore.instance.collection("ticket_distros");
  final CollectionReference recordedStreamRef = FirebaseFirestore.instance.collection("recorded_streams");
  final Reference storageReference = FirebaseStorage.instance.ref();

  //CREATE
  Future<WebblenEvent> uploadEvent(
      WebblenEvent newEvent, String zipPostalCode, File eventImageFile, TicketDistro ticketDistro, bool didEditEvent, List followers) async {
    List nearbyZipcodes = [];

    String newEventID = newEvent.id == null ? randomAlphaNumeric(12) : newEvent.id;
    newEvent.id = newEventID;
    newEvent.webAppLink = 'https://app.webblen.io/#/event?id=${newEvent.id}';
    if (eventImageFile != null) {
      String eventFileName = "${newEvent.id}.jpg";
      String eventImageURL = await uploadEventImage(eventImageFile, eventFileName);
      newEvent.imageURL = eventImageURL;
    }
    if (zipPostalCode != null) {
      List listOfAreaCodes = await LocationService().findNearestZipcodes(zipPostalCode);
      if (listOfAreaCodes != null) {
        nearbyZipcodes = listOfAreaCodes;
      } else {
        nearbyZipcodes.add(zipPostalCode);
      }
      newEvent.nearbyZipcodes = nearbyZipcodes;
    }
    await eventsRef.doc(newEventID).set({'d': newEvent.toMap(), 'g': null, 'l': null});
    PostDataService().createPostFromEvent(newEvent, didEditEvent, followers);
    if (ticketDistro.tickets.isNotEmpty) {
      await uploadEventTickets(newEventID, ticketDistro);
    }

    return newEvent;
  }

  Future<String> uploadEventTickets(String eventID, TicketDistro ticketDistro) async {
    String error;
    await ticketDistroRef.doc(eventID).set(ticketDistro.toMap()).catchError((e) {
      error = e.details;
    });
    return error;
  }

  Future<String> updateScannedTickets(String eventKey, List validTickets, List usedTickets) async {
    String error = "";
    await ticketDistroRef.doc(eventKey).update({
      "validTicketIDs": validTickets,
      "usedTicketIDs": usedTickets,
    }).catchError((e) {
      error = e;
    });
    return error;
  }

  Future<String> setReviewStatus(String eventID, String title, String uid, List nearbyZipcodes, String imageURL, String downloadURL) async {
    String error;
    await recordedStreamRef.doc(eventID + DateTime.now().millisecondsSinceEpoch.toString()).set({
      "eventID": eventID,
      "authorID": uid,
      "title": title,
      "approved": false,
      "expiration": DateTime.now().millisecondsSinceEpoch + 259200000,
      "nearbyZipcodes": nearbyZipcodes,
      "imageURL": imageURL,
      "downloadURL": downloadURL,
      "postedTimeInMilliseconds": DateTime.now().millisecondsSinceEpoch,
      "showAllUsers": false,
      "seenBy": [],
    }).catchError((e) {
      error = e.details;
    });
    return error;
  }

  Future<String> uploadEventImage(File eventImage, String fileName) async {
    Reference ref = storageReference.child("events").child(fileName);
    UploadTask uploadTask = ref.putFile(eventImage);
    String downloadUrl = await (await uploadTask).ref.getDownloadURL();
    return downloadUrl;
  }

  //READ
  Future<List<WebblenEvent>> getEvents({String cityFilter, String stateFilter, String categoryFilter, String typeFilter}) async {
    List<WebblenEvent> events = [];
    QuerySnapshot querySnapshot = await eventsRef.get();
    querySnapshot.docs.forEach((snapshot) {
      WebblenEvent event = WebblenEvent.fromMap(snapshot.data()['d']);
      events.add(event);
    });
    events.sort((eventA, eventB) => eventA.startDateTimeInMilliseconds.compareTo(eventB.startDateTimeInMilliseconds));
    return events;
  }

  Future<WebblenEvent> getEvent(String eventID) async {
    WebblenEvent event;
    await eventsRef.doc(eventID).get().then((res) {
      if (res.exists) {
        event = WebblenEvent.fromMap(res.data()['d']);
      }
    }).catchError((e) {});
    return event;
  }

  Future<List<WebblenUser>> getEventAttendees(String eventID) async {
    List<WebblenUser> users = [];
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'getEventAttendees',
    );
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'eventID': eventID,
      },
    );
    if (result.data != null) {
      List query = List.from(result.data);
      query.forEach((resultMap) {
        Map<String, dynamic> userMap = Map<String, dynamic>.from(resultMap);
        WebblenUser user = WebblenUser.fromMap(userMap);
        users.add(user);
      });
    }
    return users;
  }

  Future<List<WebblenEvent>> getTrendingEvents() async {
    List<WebblenEvent> events = [];
    QuerySnapshot querySnapshot = await eventsRef.orderBy('d.clicks').limit(3).get();
    querySnapshot.docs.forEach((snapshot) {
      WebblenEvent event = WebblenEvent.fromMap(snapshot.data()['d']);
      events.add(event);
    });
    events.sort((eventA, eventB) => eventA.startDateTimeInMilliseconds.compareTo(eventB.startDateTimeInMilliseconds));
    return events;
  }

  Future<TicketDistro> getEventTicketDistro(String eventID) async {
    TicketDistro ticketDistro;
    DocumentSnapshot snapshot = await ticketDistroRef.doc(eventID).get();
    if (snapshot.exists) {
      ticketDistro = TicketDistro.fromMap(snapshot.data());
    }
    return ticketDistro;
  }

  Future<List<EventTicket>> getPurchasedTickets(String uid) async {
    List<EventTicket> eventTickets = [];
    QuerySnapshot snapshot = await ticketsRef.where("purchaserUID", isEqualTo: uid).get();
    snapshot.docs.forEach((doc) {
      EventTicket ticket = EventTicket.fromMap(doc.data());
      eventTickets.add(ticket);
    });
    return eventTickets;
  }

  Future<List<EventTicket>> getPurchasedTicketsFromEvent(String uid, String eventID) async {
    List<EventTicket> eventTickets = [];
    QuerySnapshot snapshot = await ticketsRef.where("purchaserUID", isEqualTo: uid).where("eventID", isEqualTo: eventID).get();
    snapshot.docs.forEach((doc) {
      EventTicket ticket = EventTicket.fromMap(doc.data());
      eventTickets.add(ticket);
    });
    return eventTickets;
  }

//  Future<List<WebblenEvent>> getEventsNearLocation(double lat, double lon) async {
//    print(lat);
//    final geo = Geoflutterfire();
//    int milli = DateTime.now().millisecondsSinceEpoch;
//    var query = Firestore.instance
//        .collection('events')
//        .where("nearbyZipcodes", arrayContains: '58102')
//        .where("d.startDateTimeInMilliseconds", isLessThan: milli)
//        .where("d.endDateTimeInMilliseconds", isGreaterThan: milli);
//
//    var eventGeoRef = geo.collection(collectionRef: query.reference());
//    GeoFirePoint geoPoint = geo.point(latitude: lat, longitude: lon);
//    List events;
//    await eventGeoRef.within(center: geoPoint, radius: 50, field: 'l', strictMode: false).first.then((docs) {
//      print(docs.length);
//    }).catchError((e) {
//      print(e);
//    });
//    return events;
//  }

  Future<List<WebblenEvent>> getEventsNearLocation(double lat, double lon) async {
    final geoFlutterFire = Geoflutterfire();
    GeoFirePoint geoPoint = geoFlutterFire.point(latitude: lat, longitude: lon);
    List<WebblenEvent> events = [];
    int milli = DateTime.now().millisecondsSinceEpoch;
    QuerySnapshot snapshot = await eventsRef
        .where("d.nearbyZipcodes", arrayContains: '58102')
        .where("d.isDigitalEvent", isEqualTo: false)
        .where("d.endDateTimeInMilliseconds", isGreaterThan: milli)
        .get()
        .catchError((e) {});
    snapshot.docs.forEach((doc) {
      WebblenEvent event = WebblenEvent.fromMap(doc.data()['d']);
      if (event.startDateTimeInMilliseconds < milli) {
        double distanceFromPoint = geoPoint.distance(lat: event.lat, lng: event.lon);
        if (distanceFromPoint < 5.0) {
          events.add(event);
        }
      }
    });
    return events;
  }

//  Future<List<WebblenEvent>> getEventsNearLocation(double lat, double lon, bool forCheckIn) async {
//    List<WebblenEvent> events = [];
//    final HttpsCallable callable = forCheckIn
//        ? CloudFunctions.instance.getHttpsCallable(
//            functionName: 'getEventsForCheckIn',
//          )
//        : CloudFunctions.instance.getHttpsCallable(
//            functionName: 'getEventsNearLocation',
//          );
//    final HttpsCallableResult result = await callable.call(
//      <String, dynamic>{
//        'lat': lat,
//        'lon': lon,
//      },
//    );
//    if (result.data != null) {
//      List query = List.from(result.data);
//      query.forEach((resultMap) {
//        Map<String, dynamic> eventMap = Map<String, dynamic>.from(resultMap);
//        WebblenEvent event = WebblenEvent.fromMap(eventMap);
//        events.add(event);
//      });
//    }
//    return events;
//  }

  Future<List<WebblenEvent>> getUserEventHistory(String uid) async {
    List<WebblenEvent> events = [];
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'getUserEventHistory',
    );
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'uid': uid,
      },
    );
    if (result.data != null) {
      List query = List.from(result.data);
      query.forEach((resultMap) {
        Map<String, dynamic> evMap = Map<String, dynamic>.from(resultMap);
        WebblenEvent event = WebblenEvent.fromMap(evMap);
        events.add(event);
      });
    }
    return events;
  }

  Future<bool> areCheckInsAvailable(double lat, double lon) async {
    bool checkInAvailable = false;
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'areCheckInsAvailable',
    );
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'lat': lat,
        'lon': lon,
      },
    );
    if (result.data != null) {
      checkInAvailable = result.data;
    }
    return checkInAvailable;
  }

  Future<WebblenEvent> checkInAndUpdateEventPayout(String eventID, String uid, double userAP) async {
    WebblenEvent event;
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'checkInAndUpdateEventPayout',
    );
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'eventID': eventID,
        'uid': uid,
        'userAP': userAP,
      },
    );
    if (result.data != null) {
      Map<String, dynamic> eventMap = Map<String, dynamic>.from(result.data);
      event = WebblenEvent.fromMap(eventMap);
    }
    return event;
  }

  Future<WebblenEvent> checkoutAndUpdateEventPayout(String eventID, String uid) async {
    WebblenEvent event;
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'checkoutAndUpdateEventPayout',
    );
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'eventID': eventID,
        'uid': uid,
      },
    );
    if (result.data != null) {
      Map<String, dynamic> eventMap = Map<String, dynamic>.from(result.data);
      event = WebblenEvent.fromMap(eventMap);
    }
    return event;
  }

  Future<String> createActiveLiveStream(String id, String uid, String username, String userImgURL, List nearbyZipcodes, int timeInMilliseconds) async {
    String error;
    await activeStreamRef.doc(id).set({
      "id": id,
      "uid": uid,
      "username": username,
      "userImgURL": userImgURL,
      "nearbyZipcodes": nearbyZipcodes,
      "timeInMilliseconds": timeInMilliseconds,
    }).catchError((e) {
      error = e.toString();
    });
    return error;
  }

  Future<String> endActiveStream(String id) async {
    String error;
    await activeStreamRef.doc(id).delete();
    return error;
  }

  Future<Null> notifyFollowersStreamIsLive(String eventID, String uid) async {
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'notifyFollowersStreamIsLive',
    );
    await callable.call(
      <String, dynamic>{
        'eventID': eventID,
        'uid': uid,
      },
    );
  }

  //UPDATE

  Future updateEvent(WebblenEvent data, String id) async {
    await eventsRef.doc(id).update(data.toMap());
    return;
  }

  Future<String> saveOrUnsaveEvent(WebblenEvent event, String uid) async {
    String error;
    List savedByIDs = [];
    if (event.savedBy != null) {
      savedByIDs = event.savedBy;
    }
    if (savedByIDs.contains(uid)) {
      savedByIDs.remove(uid);
    } else {
      savedByIDs.add(uid);
    }
    await eventsRef.doc(event.id).update({"d.savedBy": savedByIDs}).catchError((e) {
      error = e.toString();
    });
    return error;
  }

  //***DELETE
  Future<String> deleteEvent(String eventID) async {
    String error = "";
    await eventsRef.doc(eventID).get().then((doc) async {
      if (doc.exists) {
        await eventsRef.doc(eventID).delete();
      } else {
        //await pastEventsRef.doc(eventID).delete();
      }
    });
    return error;
  }

//  Future<String> transferOldEventData() async {
//    String error = "";
//    CollectionReference oldEventsRef = Firestore().collection("past_events");
//    QuerySnapshot querySnapshot = await oldEventsRef.getDocuments();
//    querySnapshot.docs.forEach((doc) async {
//      int eventStartDateTimeInMilliseconds = doc.data['d']['startDateInMilliseconds'];
//      DateTime eventDateTime = DateTime.fromMillisecondsSinceEpoch(eventStartDateTimeInMilliseconds);
//      DateFormat formatter = DateFormat('MMM dd, yyyy');
//      WebblenEvent event = WebblenEvent(
//        id: doc.data['d']['eventKey'],
//        actualTurnout: doc.data['d']['actualTurnout'],
//        authorID: doc.data['d']['authorUid'],
//        attendees: doc.data['d']['attendees'],
//        streetAddress: doc.data['d']['address'],
//        webAppLink: 'https://app.webblen.io/#/event?id=${doc.data['d']['eventKey']}',
//        category: "Film, Media, & Entertainment",
//        checkInRadius: 10.5,
//        digitalEventLink: null,
//        startDate: formatter.format(eventDateTime),
//        endDate: formatter.format(eventDateTime),
//        startTime: doc.data['d']['startTime'],
//        endTime: doc.data['d']['endTime'],
//        eventPayout: doc.data['d']['eventPayout'],
//        fbUsername: "",
//        instaUsername: "",
//        website: "",
//        twitterUsername: "",
//        flashEvent: doc.data['d']['flashEvent'],
//        hasTickets: false,
//        imageURL: doc.data['d']['imageURL'],
//        isDigitalEvent: false,
//        lat: null,
//        lon: null,
//        nearbyZipcodes: [
//          '58047',
//          '58104',
//          '56560',
//          '58059',
//          '58103',
//          '58102',
//          '56561',
//        ],
//        sharedComs: [],
//        startDateTimeInMilliseconds: eventStartDateTimeInMilliseconds,
//        tags: [],
//        venueName: null,
//        privacy: doc.data['d']['privacy'],
//        estimatedTurnout: 0,
//        clicks: doc.data['d']['views'],
//        city: doc.data['d']['communityAreaName'],
//        province: 'ND',
//        desc: doc.data['d']['description'],
//        recurrence: doc.data['d']['recurrence'],
//        reported: false,
//        timezone: 'CDT',
//        title: doc.data['d']['title'],
//        type: 'Other',
//      );
//      await eventsRef.doc(event.id).set({
//        'd': event.toMap(),
//        'g': doc.data['g'],
//        'l': doc.data['l'],
//      });
//    });
//  }

//  Future<Null> addEventDataField(String dataName, dynamic data) async {
//    QuerySnapshot querySnapshot = await pastEventsRef.getDocuments();
//    print(querySnapshot.docs.length);
//    querySnapshot.docs.forEach((doc) {
//      pastEventsRef.doc(doc.docID).updateData({"$dataName": data}).whenComplete(() {}).catchError((e) {});
//    });
//  }
//
//  Future<Null> addRecEventDataField(String dataName, dynamic data) async {
//    QuerySnapshot querySnapshot = await recurringEventRef.getDocuments();
//    querySnapshot.docs.forEach((doc) {
//      recurringEventRef.doc(doc.docID).updateData({"$dataName": data}).whenComplete(() {}).catchError((e) {});
//    });
//  }
}
