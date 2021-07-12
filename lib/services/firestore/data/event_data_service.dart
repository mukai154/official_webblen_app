import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_event_ticket.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/firestore/common/firestore_storage_service.dart';
import 'package:webblen/services/firestore/data/ticket_distro_data_service.dart';
import 'package:webblen/utils/custom_string_methods.dart';

class EventDataService {
  final CollectionReference eventsRef = FirebaseFirestore.instance.collection("webblen_events");
  CustomDialogService _customDialogService = locator<CustomDialogService>();
  SnackbarService _snackbarService = locator<SnackbarService>();
  TicketDistroDataService _ticketDistroDataService = locator<TicketDistroDataService>();
  FirestoreStorageService _firestoreStorageService = locator<FirestoreStorageService>();

  Future<bool?> checkIfEventExists(String id) async {
    bool exists = false;
    try {
      DocumentSnapshot snapshot = await eventsRef.doc(id).get();
      if (snapshot.exists) {
        exists = true;
      }
    } catch (e) {
      _snackbarService.showSnackbar(
        title: 'Error',
        message: e.toString(),
        duration: Duration(seconds: 5),
      );
      return null;
    }
    return exists;
  }

  Future<bool> checkIfEventSaved({required String uid, required String eventID}) async {
    bool saved = false;
    DocumentSnapshot snapshot = await eventsRef.doc(eventID).get();
    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      List savedBy = snapshotData['savedBy'] == null ? [] : snapshotData['savedBy'].toList(growable: true);
      if (!savedBy.contains(uid)) {
        saved = false;
      } else {
        saved = true;
      }
    }
    return saved;
  }

  Future<String?> saveUnsaveEvent({required String uid, required String eventID, required bool savedEvent}) async {
    String? error;
    if (savedEvent) {
      await eventsRef.doc(eventID).update({
        'savedBy': FieldValue.arrayUnion([uid])
      }).catchError((e) {
        error = e.message;
      });
    } else {
      await eventsRef.doc(eventID).update({
        'savedBy': FieldValue.arrayRemove([uid])
      }).catchError((e) {
        error = e.message;
      });
    }
    return error;
  }

  Future<bool> checkInScannedTicket({required String ticketID, required String eventID}) async {
    bool checkedIn = true;
    if (isValidTicket(ticketID)) {
      WebblenEventTicket ticket = await _ticketDistroDataService.getTicketByID(ticketID);
      if (ticket.eventID == eventID) {
        if (ticket.used == null || !ticket.used!) {
          ticket.used = await _ticketDistroDataService.scanInTicket(ticket.id!);
          if (ticket.used!) {
            checkIntoEvent(uid: ticket.purchaserUID!, eventID: eventID);
            HapticFeedback.lightImpact();
          } else {
            checkedIn = false;
            HapticFeedback.heavyImpact();
            await Future.delayed(Duration(milliseconds: 200));
            HapticFeedback.heavyImpact();
          }
        } else {
          _customDialogService.showErrorDialog(description: "This ticket has already been checked in");
          checkedIn = false;
          HapticFeedback.heavyImpact();
          await Future.delayed(Duration(milliseconds: 200));
          HapticFeedback.heavyImpact();
        }
      } else {
        _customDialogService.showErrorDialog(description: "Invalid Ticket");
        HapticFeedback.heavyImpact();
        await Future.delayed(Duration(milliseconds: 200));
        HapticFeedback.heavyImpact();
        checkedIn = false;
      }
    } else {
      _customDialogService.showErrorDialog(description: "This is not a Webblen Ticket");
      HapticFeedback.heavyImpact();
      await Future.delayed(Duration(milliseconds: 200));
      HapticFeedback.heavyImpact();
      checkedIn = false;
    }
    return checkedIn;
  }

  Future<bool> checkIntoEvent({required String uid, required String eventID}) async {
    bool checkedIn = false;
    DocumentSnapshot snapshot = await eventsRef.doc(eventID).get().catchError((e) {
      _customDialogService.showErrorDialog(description: "There was an error checking into this event. Please try again.");
    });
    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      WebblenEvent event = WebblenEvent.fromMap(snapshotData);
      List attendeeUIDs = event.attendees != null ? event.attendees!.keys.toList(growable: true) : [];

      //check if user already checked in
      if (attendeeUIDs.contains(uid)) {
        checkedIn = true;
        return checkedIn;
      }

      event.attendees![uid] = {
        'checkInTime': DateTime.now().millisecondsSinceEpoch,
        'checkOutTime': null,
      };

      await eventsRef.doc(eventID).update({
        'attendees': event.attendees,
      });

      checkedIn = true;
    }

    return checkedIn;
  }

  Future<bool> checkOutOfEvent({required String uid, required String eventID}) async {
    bool checkedOut = false;
    DocumentSnapshot snapshot = await eventsRef.doc(eventID).get().catchError((e) {
      _customDialogService.showErrorDialog(description: "There was an error checking out of this event. Please try again.");
    });

    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      WebblenEvent event = WebblenEvent.fromMap(snapshotData);
      List attendeeUIDs = event.attendees != null ? event.attendees!.keys.toList(growable: true) : [];
      //check if user already checked in
      if (!attendeeUIDs.contains(uid)) {
        checkedOut = true;
        return checkedOut;
      }
      event.attendees!.remove(uid);
      await eventsRef.doc(eventID).update({
        'attendees': event.attendees,
      });
      checkedOut = true;
    }
    return checkedOut;
  }

  Future<void> reportEvent({required String? eventID, required String? reporterID}) async {
    DocumentSnapshot snapshot = await eventsRef.doc(eventID).get().catchError((e) {
      _snackbarService.showSnackbar(
        title: 'Event Error',
        message: e.message,
        duration: Duration(seconds: 5),
      );
    });
    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      List reportedBy = snapshotData['reportedBy'] == null ? [] : snapshotData['reportedBy'].toList(growable: true);
      if (reportedBy.contains(reporterID)) {
        _snackbarService.showSnackbar(
          title: 'Report Error',
          message: "You've already reported this event. This event is currently pending review.",
          duration: Duration(seconds: 5),
        );
      } else {
        reportedBy.add(reporterID);
        eventsRef.doc(eventID).update({"reportedBy": reportedBy});
        _snackbarService.showSnackbar(
          title: 'Event Reported',
          message: "This event is now pending review.",
          duration: Duration(seconds: 5),
        );
      }
    }
  }

  Future<bool> createEvent({required WebblenEvent event}) async {
    String? error;
    await eventsRef.doc(event.id).set(event.toMap()).catchError((e) {
      error = e.message;
    });
    if (error != null) {
      _customDialogService.showErrorDialog(description: error!);
      return false;
    }
    return true;
  }

  Future updateEvent({required WebblenEvent event}) async {
    await eventsRef.doc(event.id).update(event.toMap()).catchError((e) {
      return e.message;
    });
  }

  Future deleteEvent({required WebblenEvent event}) async {
    await eventsRef.doc(event.id).delete();
    if (event.imageURL != null) {
      await _firestoreStorageService.deleteImage(storageBucket: 'images', folderName: 'events', fileName: event.id!);
    }
  }

  Future<WebblenEvent> getEventByID(String id) async {
    WebblenEvent event = WebblenEvent();
    String? error;
    DocumentSnapshot snapshot = await eventsRef.doc(id).get().catchError((e) {
      error = e.message;
      _customDialogService.showErrorDialog(description: error!);
    });
    if (error != null) {
      _customDialogService.showErrorDialog(description: "There was an unknown issue loading this event");
      return event;
    }

    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      event = WebblenEvent.fromMap(snapshotData);
    } else {
      _customDialogService.showErrorDialog(description: "This Event No Longer Exists");
      return event;
    }
    return event;
  }

  Future getEventForEditingByID(String id) async {
    WebblenEvent? event;
    String? error;
    DocumentSnapshot snapshot = await eventsRef.doc(id).get().catchError((e) {
      error = e.message;
    });

    if (error != null) {
      _customDialogService.showErrorDialog(description: "There was an unknown issue loading this event");
      return event;
    }

    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      event = WebblenEvent.fromMap(snapshotData);
    } else {
      _customDialogService.showErrorDialog(description: "This Event No Longer Exists");
      return event;
    }
    return event;
  }

  ///READ & QUERIES
  Future<List<DocumentSnapshot>> loadEvents({
    required String areaCode,
    required int resultsLimit,
    required String tagFilter,
    required String sortBy,
  }) async {
    int dateTimeInMilliseconds2hrsAgo = DateTime.now().millisecondsSinceEpoch - 7200000;
    Query query;
    List<DocumentSnapshot> docs = [];
    String? error;
    if (areaCode.isEmpty) {
      query = eventsRef
          .where('startDateTimeInMilliseconds', isGreaterThan: dateTimeInMilliseconds2hrsAgo)
          .orderBy('startDateTimeInMilliseconds', descending: false)
          .limit(resultsLimit);
    } else {
      query = eventsRef
          .where('nearbyZipcodes', arrayContains: areaCode)
          .where('startDateTimeInMilliseconds', isGreaterThan: dateTimeInMilliseconds2hrsAgo)
          .orderBy('startDateTimeInMilliseconds', descending: false)
          .limit(resultsLimit);
    }
    QuerySnapshot snapshot = await query.get().catchError((e) {
      print(e.message);
      error = e.message;
      _customDialogService.showErrorDialog(description: error!);
    });

    if (error != null) {
      return docs;
    }

    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
      if (tagFilter.isNotEmpty) {
        docs.removeWhere((doc) => !(doc.data() as Map<String, dynamic>)['tags'].contains(tagFilter));
      }
      if (sortBy == "Latest") {
        docs.sort((docA, docB) => (docA.data() as Map<String, dynamic>)['startDateTimeInMilliseconds']
            .compareTo((docB.data() as Map<String, dynamic>)['startDateTimeInMilliseconds']));
      } else {
        docs.sort((docA, docB) => (docB.data() as Map<String, dynamic>)['savedBy'].length.compareTo((docA.data() as Map<String, dynamic>)['savedBy'].length));
      }
    }
    return docs;
  }

  Future<List<DocumentSnapshot>> loadAdditionalEvents({
    required DocumentSnapshot lastDocSnap,
    required String areaCode,
    required int resultsLimit,
    required String tagFilter,
    required String sortBy,
  }) async {
    int dateTimeInMilliseconds2hrsAgo = DateTime.now().millisecondsSinceEpoch - 7200000;
    Query query;
    List<DocumentSnapshot> docs = [];
    String? error;
    if (areaCode.isEmpty) {
      query = eventsRef
          .where('startDateTimeInMilliseconds', isGreaterThan: dateTimeInMilliseconds2hrsAgo)
          .orderBy('startDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastDocSnap)
          .limit(resultsLimit);
    } else {
      query = eventsRef
          .where('nearbyZipcodes', arrayContains: areaCode)
          .where('startDateTimeInMilliseconds', isGreaterThan: dateTimeInMilliseconds2hrsAgo)
          .orderBy('startDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastDocSnap)
          .limit(resultsLimit);
    }
    QuerySnapshot snapshot = await query.get().catchError((e) {
      print(e.message);
      error = e.message;
      _customDialogService.showErrorDialog(description: error!);
    });

    if (error != null) {
      return docs;
    }

    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
      if (tagFilter.isNotEmpty) {
        docs.removeWhere((doc) => !(doc.data() as Map<String, dynamic>)['tags'].contains(tagFilter));
      }
      if (sortBy == "Latest") {
        docs.sort((docA, docB) => (docA.data() as Map<String, dynamic>)['startDateTimeInMilliseconds']
            .compareTo((docB.data() as Map<String, dynamic>)['startDateTimeInMilliseconds']));
      } else {
        docs.sort((docA, docB) => (docB.data() as Map<String, dynamic>)['savedBy'].length.compareTo((docA.data() as Map<String, dynamic>)['savedBy'].length));
      }
    }
    return docs;
  }

  Future<List<DocumentSnapshot>> loadEventsByUserID({required String? id, required int resultsLimit}) async {
    List<DocumentSnapshot> docs = [];
    String? error;
    Query query = eventsRef.where('authorID', isEqualTo: id).orderBy('startDateTimeInMilliseconds', descending: true).limit(resultsLimit);
    QuerySnapshot snapshot = await query.get().catchError((e) {
      print(e.message);
      error = e.message;
      _customDialogService.showErrorDialog(description: error!);
    });

    if (error != null) {
      return docs;
    }

    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
    }
    return docs;
  }

  Future<List<DocumentSnapshot>> loadAdditionalEventsByUserID({
    required String? id,
    required DocumentSnapshot lastDocSnap,
    required int resultsLimit,
  }) async {
    List<DocumentSnapshot> docs = [];
    String? error;
    Query query =
        eventsRef.where('authorID', isEqualTo: id).orderBy('startDateTimeInMilliseconds', descending: true).startAfterDocument(lastDocSnap).limit(resultsLimit);
    QuerySnapshot snapshot = await query.get().catchError((e) {
      print(e.message);
      error = e.message;
      _customDialogService.showErrorDialog(description: error!);
    });

    if (error != null) {
      return docs;
    }

    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
    }
    return docs;
  }

  Future<List<DocumentSnapshot>> loadSavedEvents({required String? id, required int resultsLimit}) async {
    List<DocumentSnapshot> docs = [];
    String? error;
    Query query = eventsRef.where('savedBy', arrayContains: id).orderBy('startDateTimeInMilliseconds', descending: true).limit(resultsLimit);
    QuerySnapshot snapshot = await query.get().catchError((e) {
      print(e.message);
      error = e.message;
      _customDialogService.showErrorDialog(description: error!);
    });

    if (error != null) {
      return docs;
    }

    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
    }
    return docs;
  }

  Future<List<DocumentSnapshot>> loadAdditionalSavedEvents({
    required String? id,
    required DocumentSnapshot lastDocSnap,
    required int resultsLimit,
  }) async {
    List<DocumentSnapshot> docs = [];
    String? error;
    Query query = eventsRef
        .where('savedBy', arrayContains: id)
        .orderBy('startDateTimeInMilliseconds', descending: true)
        .startAfterDocument(lastDocSnap)
        .limit(resultsLimit);
    QuerySnapshot snapshot = await query.get().catchError((e) {
      print(e.message);
      error = e.message;
      _customDialogService.showErrorDialog(description: error!);
    });

    if (error != null) {
      return docs;
    }

    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
    }
    return docs;
  }

  Future<List<DocumentSnapshot>> loadNearbyEvents({required String areaCode, required double lat, required double lon, required int resultsLimit}) async {
    int currentDateTimeInMilliseconds = DateTime.now().millisecondsSinceEpoch;
    GeoFlutterFire geoFlutterFire = GeoFlutterFire();
    GeoFirePoint geoPoint = geoFlutterFire.point(latitude: lat, longitude: lon);
    List<DocumentSnapshot> docs = [];
    String? error;
    Query query = eventsRef
        .where('nearbyZipcodes', arrayContains: areaCode)
        .where('endDateTimeInMilliseconds', isGreaterThan: currentDateTimeInMilliseconds)
        .orderBy('endDateTimeInMilliseconds', descending: false)
        .limit(resultsLimit);
    QuerySnapshot snapshot = await query.get().catchError((e) {
      print(e.message);
      error = e.message;
      _customDialogService.showErrorDialog(description: error!);
    });

    if (error != null) {
      return docs;
    }

    if (snapshot.docs.isNotEmpty) {
      snapshot.docs.forEach((doc) {
        Map<String, dynamic> snapshotData = doc.data() as Map<String, dynamic>;
        if (snapshotData['startDateTimeInMilliseconds'] != null && snapshotData['startDateTimeInMilliseconds'] <= currentDateTimeInMilliseconds) {
          double distanceFromPoint = geoPoint.distance(lat: snapshotData['lat'], lng: snapshotData['lon']);
          String venueSize = snapshotData['venueSize'] ?? "small";
          if (venueSize == "small") {
            if (distanceFromPoint < 0.03) {
              docs.add(doc);
            }
          } else if (venueSize == "medium") {
            if (distanceFromPoint < 0.06) {
              docs.add(doc);
            }
          } else if (venueSize == "large") {
            if (distanceFromPoint < 0.1) {
              docs.add(doc);
            }
          } else if (venueSize == "huge") {
            if (distanceFromPoint < 0.5) {
              docs.add(doc);
            }
          }
        }
      });
    }
    return docs;
  }

  Future<List<DocumentSnapshot>> loadAdditionalNearbyEvents({
    required String areaCode,
    required double lat,
    required double lon,
    required DocumentSnapshot lastDocSnap,
    required int resultsLimit,
  }) async {
    int currentDateTimeInMilliseconds = DateTime.now().millisecondsSinceEpoch;
    GeoFlutterFire geoFlutterFire = GeoFlutterFire();
    GeoFirePoint geoPoint = geoFlutterFire.point(latitude: lat, longitude: lon);
    List<DocumentSnapshot> docs = [];
    String? error;
    Query query = eventsRef
        .where('nearbyZipcodes', arrayContains: areaCode)
        .where('endDateTimeInMilliseconds', isGreaterThan: currentDateTimeInMilliseconds)
        .orderBy('endDateTimeInMilliseconds', descending: false)
        .startAfterDocument(lastDocSnap)
        .limit(resultsLimit);
    QuerySnapshot snapshot = await query.get().catchError((e) {
      print(e.message);
      error = e.message;
      _customDialogService.showErrorDialog(description: error!);
    });

    if (error != null) {
      return docs;
    }

    if (snapshot.docs.isNotEmpty) {
      snapshot.docs.forEach((doc) {
        Map<String, dynamic> snapshotData = doc.data() as Map<String, dynamic>;
        double distanceFromPoint = geoPoint.distance(lat: snapshotData['lat'], lng: snapshotData['lon']);
        String venueSize = snapshotData['venueSize'] ?? "small";
        if (venueSize == "small") {
          if (distanceFromPoint < 0.03) {
            docs.add(doc);
          }
        } else if (venueSize == "medium") {
          if (distanceFromPoint < 0.06) {
            docs.add(doc);
          }
        } else if (venueSize == "large") {
          if (distanceFromPoint < 0.1) {
            docs.add(doc);
          }
        } else if (venueSize == "huge") {
          if (distanceFromPoint < 0.5) {
            docs.add(doc);
          }
        }
      });
    }

    return docs;
  }
}
