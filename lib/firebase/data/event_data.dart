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

class EventDataService {
  final CollectionReference eventsRef = Firestore().collection("events");
  final CollectionReference activeStreamRef = Firestore().collection("active_streams");
  final CollectionReference ticketsRef = Firestore().collection("purchased_tickets");
  final CollectionReference ticketDistroRef = Firestore().collection("ticket_distros");
  final StorageReference storageReference = FirebaseStorage.instance.ref();

  //CREATE
  Future<WebblenEvent> uploadEvent(WebblenEvent newEvent, String zipPostalCode, File eventImageFile, TicketDistro ticketDistro) async {
    print("uploading event...");
    print(zipPostalCode);
    String error;
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
    await eventsRef.document(newEventID).setData({'d': newEvent.toMap(), 'g': null, 'l': null});
    if (ticketDistro.tickets.isNotEmpty) {
      await uploadEventTickets(newEventID, ticketDistro);
    }
    return newEvent;
  }

  Future<String> uploadEventTickets(String eventID, TicketDistro ticketDistro) async {
    String error;
    await ticketDistroRef.document(eventID).setData(ticketDistro.toMap()).catchError((e) {
      error = e.details;
    });
    return error;
  }

  Future<String> uploadEventImage(File eventImage, String fileName) async {
    StorageReference ref = storageReference.child("events").child(fileName);
    StorageUploadTask uploadTask = ref.putFile(eventImage);
    String downloadUrl = await (await uploadTask.onComplete).ref.getDownloadURL() as String;
    return downloadUrl;
  }

  //READ
  Future<List<WebblenEvent>> getEvents({String cityFilter, String stateFilter, String categoryFilter, String typeFilter}) async {
    List<WebblenEvent> events = [];
    QuerySnapshot querySnapshot = await eventsRef.getDocuments();
    querySnapshot.documents.forEach((snapshot) {
      WebblenEvent event = WebblenEvent.fromMap(snapshot.data['d']);
      events.add(event);
    });
    events.sort((eventA, eventB) => eventA.startDateTimeInMilliseconds.compareTo(eventB.startDateTimeInMilliseconds));
    return events;
  }

  Future<WebblenEvent> getEvent(String eventID) async {
    WebblenEvent event;
    await eventsRef.document(eventID).get().then((res) {
      if (res.exists) {
        event = WebblenEvent.fromMap(res.data['d']);
      }
    }).catchError((e) {
      print(e.details);
    });
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
    QuerySnapshot querySnapshot = await eventsRef.orderBy('d.clicks').limit(3).getDocuments();
    querySnapshot.documents.forEach((snapshot) {
      WebblenEvent event = WebblenEvent.fromMap(snapshot.data['d']);
      events.add(event);
    });
    events.sort((eventA, eventB) => eventA.startDateTimeInMilliseconds.compareTo(eventB.startDateTimeInMilliseconds));
    return events;
  }

  Future<TicketDistro> getEventTicketDistro(String eventID) async {
    TicketDistro ticketDistro;
    DocumentSnapshot snapshot = await ticketDistroRef.document(eventID).get();
    if (snapshot.exists) {
      ticketDistro = TicketDistro.fromMap(snapshot.data);
    }
    return ticketDistro;
  }

  Future<List<EventTicket>> getPurchasedTickets(String uid) async {
    List<EventTicket> eventTickets = [];
    QuerySnapshot snapshot = await ticketsRef.where("purchaserUID", isEqualTo: uid).getDocuments();
    snapshot.documents.forEach((doc) {
      EventTicket ticket = EventTicket.fromMap(doc.data);
      eventTickets.add(ticket);
    });
    return eventTickets;
  }

  Future<List<EventTicket>> getPurchasedTicketsFromEvent(String uid, String eventID) async {
    List<EventTicket> eventTickets = [];
    QuerySnapshot snapshot = await ticketsRef.where("purchaserUID", isEqualTo: uid).where("eventID", isEqualTo: eventID).getDocuments();
    snapshot.documents.forEach((doc) {
      EventTicket ticket = EventTicket.fromMap(doc.data);
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
//    await eventGeoRef.within(center: geoPoint, radius: 50, field: 'l', strictMode: false).first.then((documents) {
//      print(documents.length);
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
        .getDocuments()
        .catchError((e) {
      print(e);
    });
    snapshot.documents.forEach((doc) {
      WebblenEvent event = WebblenEvent.fromMap(doc.data['d']);
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
    await activeStreamRef.document(id).setData({
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
    await activeStreamRef.document(id).delete();
    return error;
  }

  Future<Null> notifyFollowersStreamIsLive(String eventID, String uid) async {
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'notifyFollowersStreamIsLive',
    );
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'eventID': eventID,
        'uid': uid,
      },
    );
  }

  //UPDATE

  Future updateEvent(WebblenEvent data, String id) async {
    await eventsRef.document(id).updateData(data.toMap());
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
    await eventsRef.document(event.id).updateData({"d.savedBy": savedByIDs}).catchError((e) {
      error = e.toString();
    });
    return error;
  }

  //***DELETE
  Future<String> deleteEvent(String eventID) async {
    String error = "";
    await eventsRef.document(eventID).get().then((doc) async {
      if (doc.exists) {
        await eventsRef.document(eventID).delete();
      } else {
        //await pastEventsRef.document(eventID).delete();
      }
    });
    return error;
  }

//  Future<String> transferOldEventData() async {
//    String error = "";
//    CollectionReference oldEventsRef = Firestore().collection("past_events");
//    QuerySnapshot querySnapshot = await oldEventsRef.getDocuments();
//    querySnapshot.documents.forEach((doc) async {
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
//      await eventsRef.document(event.id).setData({
//        'd': event.toMap(),
//        'g': doc.data['g'],
//        'l': doc.data['l'],
//      });
//    });
//  }

//  Future<Null> addEventDataField(String dataName, dynamic data) async {
//    QuerySnapshot querySnapshot = await pastEventsRef.getDocuments();
//    print(querySnapshot.documents.length);
//    querySnapshot.documents.forEach((doc) {
//      pastEventsRef.document(doc.documentID).updateData({"$dataName": data}).whenComplete(() {}).catchError((e) {});
//    });
//  }
//
//  Future<Null> addRecEventDataField(String dataName, dynamic data) async {
//    QuerySnapshot querySnapshot = await recurringEventRef.getDocuments();
//    querySnapshot.documents.forEach((doc) {
//      recurringEventRef.document(doc.documentID).updateData({"$dataName": data}).whenComplete(() {}).catchError((e) {});
//    });
//  }
}
