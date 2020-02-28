import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:random_string/random_string.dart';
import 'package:webblen/firebase_data/community_data.dart';
import 'package:webblen/models/calendar_event.dart';
import 'package:webblen/models/event.dart';
import 'package:webblen/models/event_ticket.dart';
import 'package:webblen/models/event_ticket_distribution.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/utils/time.dart';

import 'calendar_event_data.dart';

class EventDataService {
  Geoflutterfire geo = Geoflutterfire();
  final CollectionReference pastEventsRef = Firestore.instance.collection("past_events");
  final CollectionReference upcomingEventsRef = Firestore.instance.collection("upcoming_events");
  final CollectionReference recurringEventRef = Firestore.instance.collection("recurring_events");
  final CollectionReference ticketDistroRef = Firestore.instance.collection("ticket_distros");
  final CollectionReference userRef = Firestore.instance.collection("users");
  final CollectionReference purchasedTicketsRef = Firestore.instance.collection("purchased_tickets");
  final StorageReference storageReference = FirebaseStorage.instance.ref();

  getAttendanceMultiplier(int attendanceCount) {
    double multiplier = 0.75;
    if (attendanceCount > 5 && attendanceCount <= 10) {
      multiplier = 0.85;
    } else if (attendanceCount > 10 && attendanceCount <= 20) {
      multiplier = 1.00;
    } else if (attendanceCount > 20 && attendanceCount <= 100) {
      multiplier = 1.25;
    } else if (attendanceCount > 100 && attendanceCount <= 500) {
      multiplier = 1.75;
    } else if (attendanceCount > 500 && attendanceCount <= 1000) {
      multiplier = 2.00;
    } else if (attendanceCount > 1000 && attendanceCount <= 2000) {
      multiplier = 2.15;
    } else if (attendanceCount > 2000) {
      multiplier = 2.5;
    }
    return multiplier;
  }

  //***CREATE
  Future<String> uploadEvent(File eventImage, Event event, double lat, double lon, List tickets, List fees) async {
    String error = '';
    final String eventKey = randomAlphaNumeric(16);
    String fileName = "$eventKey.jpg";
    String downloadUrl = await setEventImage(
      eventImage,
      fileName,
    );
    event.imageURL = downloadUrl;
    event.eventKey = eventKey;
    GeoFirePoint geoFirePoint = geo.point(
      latitude: lat,
      longitude: lon,
    );
    event.location = geo
        .point(
          latitude: lat,
          longitude: lon,
        )
        .data;
    await upcomingEventsRef.document(eventKey).setData({'d': event.toMap(), 'g': geoFirePoint.hash, 'l': geoFirePoint.geoPoint}).whenComplete(() async {
      if (!event.flashEvent) {
        DateTime eventDateTime = DateTime.fromMillisecondsSinceEpoch(event.startDateInMilliseconds);
        String eventDateTimeString = Time().getStringFromDate(eventDateTime);
        String timezone = await Time().getLocalTimezone();
        CalendarEvent calEvent = CalendarEvent(
          title: event.title,
          description: event.description,
          data: event.communityAreaName + "/" + event.communityName,
          key: event.eventKey,
          timezone: timezone,
          dateTime: eventDateTimeString,
          type: 'created',
        );
        await CalendarEventDataService().saveEvent(event.authorUid, calEvent);
        CommunityDataService().updateCommunityEventActivity(
          event.tags,
          event.communityAreaName,
          event.communityName,
        );
        if (tickets != null && tickets.isNotEmpty) {
          await uploadEventTickets(eventKey, tickets, fees);
        }
      }
    }).catchError((e) {
      error = e.toString();
    });
    return error;
  }

  Future<String> uploadRecurringEvent(File eventImage, RecurringEvent event, double lat, double lon) async {
    String error = '';
    GeoFirePoint eventLoc = geo.point(
      latitude: lat,
      longitude: lon,
    );
    final String eventKey = "${Random().nextInt(999999999)}";
    String fileName = "$eventKey.jpg";
    String downloadUrl = await setEventImage(
      eventImage,
      fileName,
    );
    event.imageURL = downloadUrl;
    event.eventKey = eventKey;
    event.location = eventLoc.data;
    await recurringEventRef.document(eventKey).setData(event.toMap()).whenComplete(() {
      CommunityDataService().updateCommunityEventActivity(
        event.tags,
        event.areaName,
        event.comName,
      );
    }).catchError((e) {
      error = e.toString();
    });
    return error;
  }

  Future<String> uploadEventTickets(String eventID, List tickets, List fees) async {
    String error = "";
    DocumentSnapshot ticketDistro = await ticketDistroRef.document(eventID).get();
    if (ticketDistro.exists) {
      await ticketDistroRef.document(eventID).updateData({
        "fees": fees,
        "tickets": tickets,
      }).catchError((e) {
        error = e;
      });
    } else {
      await ticketDistroRef.document(eventID).setData({
        "eventID": eventID,
        "fees": fees,
        "tickets": tickets,
        "usedTicketIDs": [],
        "validTicketIDs": [],
      }).catchError((e) {
        error = e;
      });
      return error;
    }
  }

  Future<String> setEventImage(File eventImage, String fileName) async {
    StorageReference ref = storageReference.child("events").child(fileName);
    StorageUploadTask uploadTask = ref.putFile(eventImage);
    String downloadUrl = await (await uploadTask.onComplete).ref.getDownloadURL() as String;
    return downloadUrl;
  }

  Future<String> completeTicketPurchase(String uid, List<Map<String, dynamic>> ticketsToPurchase, Event event) async {
    String error = "";
    DocumentSnapshot documentSnapshot = await ticketDistroRef.document(event.eventKey).get();
    EventTicketDistribution ticketDistro = EventTicketDistribution.fromMap(documentSnapshot.data);
    List validTicketIDs = ticketDistro.validTicketIDs.toList(growable: true);
    ticketsToPurchase.forEach((purchasedTicket) async {
      String ticketName = purchasedTicket['ticketName'];
      int ticketIndex = ticketDistro.tickets.indexWhere((ticket) => ticket["ticketName"] == ticketName);
      int ticketPurchaseQty = purchasedTicket['qty'];
      int ticketAvailableQty = int.parse(purchasedTicket['ticketQuantity']);
      String newTicketAvailableQty = (ticketAvailableQty - ticketPurchaseQty).toString();
      ticketDistro.tickets[ticketIndex]['ticketQuantity'] = newTicketAvailableQty;
      for (int i = ticketPurchaseQty; i >= 1; i--) {
        String ticketID = randomAlphaNumeric(32);
        validTicketIDs.add(ticketID);
        EventTicket newTicket = EventTicket(
          ticketID: ticketID,
          ticketName: ticketName,
          purchaserUID: uid,
          eventID: event.eventKey,
          eventImageURL: event.imageURL,
          eventTitle: event.title,
          address: event.address,
          startDate: event.startDate,
          endDate: event.endDate,
          startTime: event.startTime,
          endTime: event.endTime,
          timezone: event.timezone,
        );
        await purchasedTicketsRef.document(ticketID).setData(newTicket.toMap());
      }
      await ticketDistroRef.document(event.eventKey).updateData({"tickets": ticketDistro.tickets, "validTicketIDs": validTicketIDs});
    });
    return error;
  }

  //***READ
  Future<bool> checkIfEventExists(String eventType, String eventID) async {
    bool eventExists = false;
    if (eventType == 'upcoming') {
      await upcomingEventsRef.document(eventID).get().then((result) {
        if (result.exists) {
          eventExists = true;
        }
      });
    } else if (eventType == 'past') {
      await pastEventsRef.document(eventID).get().then((result) {
        if (result.exists) {
          eventExists = true;
        }
      });
    } else if (eventType == 'recurring') {
      await recurringEventRef.document(eventID).get().then((result) {
        if (result.exists) {
          eventExists = true;
        }
      });
    }
    return eventExists;
  }

  Future<List<EventTicket>> getPurchasedTickets(String uid) async {
    List<EventTicket> tickets = [];
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'getPurchasedTickets',
    );
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'uid': uid}).catchError((e) {});
    if (result != null && result.data != null) {
      List query = List.from(result.data);
      query.forEach((resultMap) {
        Map<String, dynamic> res = Map<String, dynamic>.from(resultMap);
        EventTicket ticket = EventTicket.fromMap(res);
        tickets.add(ticket);
      });
    }
    return tickets;
  }

  Future<EventTicketDistribution> getEventTicketDistro(String eventKey) async {
    EventTicketDistribution eventTicketDistro;
    DocumentSnapshot docSnap = await ticketDistroRef.document(eventKey).get();
    if (docSnap.exists) {
      eventTicketDistro = EventTicketDistribution.fromMap(docSnap.data);
    }
    return eventTicketDistro;
  }

  Future<Event> getEventByKey(String eventKey) async {
    Event event;
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'getEventByKey',
    );
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'eventKey': eventKey}).catchError((e) {});
    if (result != null && result.data != null) {
      Map<String, dynamic> evMap = Map<String, dynamic>.from(result.data);
      event = Event.fromMap(evMap);
    }
    return event;
  }

  Future<List<Event>> getEventsFromFollowedCommunities(String uid) async {
    List<Event> events = [];
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'getEventsFromFollowedCommunities',
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
        Event event = Event.fromMap(evMap);
        events.add(event);
      });
    }
    return events;
  }

  Future<List<Event>> getCreatedEvents(String uid) async {
    List<Event> events = [];
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'getCreatedEvents',
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
        Event event = Event.fromMap(evMap);
        events.add(event);
      });
    }
    return events;
  }

  Future<List<Event>> getEventsForTicketScans(String uid) async {
    List<Event> events = [];
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'getEventsForTicketScans',
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
        Event event = Event.fromMap(evMap);
        events.add(event);
      });
    }
    return events;
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

  Future<List<Event>> getEventsNearLocation(double lat, double lon, bool forCheckIn) async {
    List<Event> events = [];
    final HttpsCallable callable = forCheckIn
        ? CloudFunctions.instance.getHttpsCallable(
            functionName: 'getEventsForCheckIn',
          )
        : CloudFunctions.instance.getHttpsCallable(
            functionName: 'getEventsNearLocation',
          );
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'lat': lat,
        'lon': lon,
      },
    );
    if (result.data != null) {
      List query = List.from(result.data);
      query.forEach((resultMap) {
        Map<String, dynamic> eventMap = Map<String, dynamic>.from(resultMap);
        Event event = Event.fromMap(eventMap);
        events.add(event);
      });
    }
    return events;
  }

  Future<List<Event>> getUserEventHistory(String uid) async {
    List<Event> events = [];
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
        Event event = Event.fromMap(evMap);
        events.add(event);
      });
    }
    return events;
  }

  Future<List<Event>> getExclusiveWebblenEvents() async {
    List<Event> events = [];
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'getExclusiveWebblenEvents',
    );
    final HttpsCallableResult result = await callable.call();
    if (result.data != null) {
      List query = List.from(result.data);
      query.forEach((resultMap) {
        Map<String, dynamic> evMap = Map<String, dynamic>.from(resultMap);
        Event event = Event.fromMap(evMap);
        events.add(event);
      });
    }
    return events;
  }

  Future<List<Event>> getRecommendedEvents(String uid, String areaName) async {
    List<Event> events = [];
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'getRecommendedEvents',
    );
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'uid': uid,
        'areaName': areaName,
      },
    );
    if (result.data != null) {
      List query = List.from(result.data);
      query.forEach((resultMap) {
        Map<String, dynamic> evMap = Map<String, dynamic>.from(resultMap);
        Event event = Event.fromMap(evMap);
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

  Future<List<Event>> searchForEventByName(String searchTerm, String areaName) async {
    List<Event> events = [];
    QuerySnapshot querySnapshot = await upcomingEventsRef
        .where(
          "d.title",
          isEqualTo: searchTerm,
        )
        .getDocuments();
    if (querySnapshot.documents.isNotEmpty) {
      querySnapshot.documents.forEach((docSnap) {
        Event event = Event.fromMap(docSnap.data);
        events.add(event);
      });
    }
    return events;
  }

  Future<List<Event>> searchForEventByTag(String searchTerm, String areaName) async {
    List<Event> events = [];
    QuerySnapshot querySnapshot = await upcomingEventsRef
        .where(
          "d.tags",
          arrayContains: searchTerm,
        )
        .getDocuments();
    if (querySnapshot.documents.isNotEmpty) {
      querySnapshot.documents.forEach((docSnap) {
        Event event = Event.fromMap(docSnap.data);
        events.add(event);
      });
    }
    return events;
  }

  //**UPDATE
  Future<String> updateEvent(Event event, List tickets, List fees) async {
    String status = "";
    Map<String, dynamic> eventMap = event.toMap();
    upcomingEventsRef.document(event.eventKey).setData({'d': eventMap}).whenComplete(() async {
      DateTime eventDateTime = DateTime.fromMillisecondsSinceEpoch(event.startDateInMilliseconds);
      String eventDateTimeString = Time().getStringFromDate(eventDateTime);
      String timezone = await Time().getLocalTimezone();
      CalendarEvent calEvent = CalendarEvent(
        title: event.title,
        description: event.description,
        data: event.communityAreaName + "/" + event.communityName,
        key: event.eventKey,
        timezone: timezone,
        dateTime: eventDateTimeString,
        type: 'created',
      );
      await CalendarEventDataService().updateEvent(
        event.authorUid,
        calEvent,
      );
      if (tickets != null && tickets.isNotEmpty) {
        await uploadEventTickets(event.eventKey, tickets, fees);
      }
    }).catchError((e) {
      status = e.details;
    });
    return status;
  }

  Future<Null> updateEventViews(String eventID) async {
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'updateEventViews',
    );
    await callable.call(
      <String, dynamic>{
        'eventID': eventID,
      },
    );
  }

  Future<String> updateScannedTickets(String eventKey, List validTickets, List usedTickets) async {
    String error = "";
    await ticketDistroRef.document(eventKey).updateData({
      "validTicketIDs": validTickets,
      "usedTicketIDs": usedTickets,
    }).catchError((e) {
      error = e;
    });
    return error;
  }

  Future<Null> addEventDataField(String dataName, dynamic data) async {
    QuerySnapshot querySnapshot = await pastEventsRef.getDocuments();
    print(querySnapshot.documents.length);
    querySnapshot.documents.forEach((doc) {
      pastEventsRef.document(doc.documentID).updateData({"$dataName": data}).whenComplete(() {}).catchError((e) {});
    });
  }

  Future<Null> addRecEventDataField(String dataName, dynamic data) async {
    QuerySnapshot querySnapshot = await recurringEventRef.getDocuments();
    querySnapshot.documents.forEach((doc) {
      recurringEventRef.document(doc.documentID).updateData({"$dataName": data}).whenComplete(() {}).catchError((e) {});
    });
  }

  Future<Event> checkInAndUpdateEventPayout(String eventID, String uid, double userAP) async {
    Event event;
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
      event = Event.fromMap(eventMap);
    }
    return event;
  }

  Future<Event> checkoutAndUpdateEventPayout(String eventID, String uid) async {
    Event event;
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
      event = Event.fromMap(eventMap);
    }
    return event;
  }

  //***DELETE
  Future<String> deleteEvent(String eventID) async {
    String error = "";
    await upcomingEventsRef.document(eventID).get().then((doc) async {
      if (doc.exists) {
        await upcomingEventsRef.document(eventID).delete();
      } else {
        await pastEventsRef.document(eventID).delete();
      }
    });
    return error;
  }

  Future<String> deleteRecurringEvent(String eventID) async {
    String error = "";
    await recurringEventRef.document(eventID).delete().whenComplete(() {}).catchError((e) {
      error = e.toString();
    });
    return error;
  }
}
