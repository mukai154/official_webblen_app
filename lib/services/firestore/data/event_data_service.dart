import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_event_ticket.dart';
import 'package:webblen/models/webblen_ticket_distro.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/firestore/common/firestore_storage_service.dart';
import 'package:webblen/services/firestore/data/post_data_service.dart';
import 'package:webblen/services/firestore/data/ticket_distro_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/utils/custom_string_methods.dart';

class EventDataService {
  final CollectionReference eventsRef =
      FirebaseFirestore.instance.collection("webblen_events");
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection("webblen_users");
  PostDataService? _postDataService = locator<PostDataService>();
  CustomDialogService _customDialogService = locator<CustomDialogService>();
  SnackbarService? _snackbarService = locator<SnackbarService>();
  TicketDistroDataService _ticketDistroDataService =
      locator<TicketDistroDataService>();
  FirestoreStorageService? _firestoreStorageService =
      locator<FirestoreStorageService>();
  UserDataService _userDataService = locator<UserDataService>();

  int dateTimeInMilliseconds2hrsAgog =
      DateTime.now().millisecondsSinceEpoch - 7200000;
  int currentDateTimeInMilliseconds = DateTime.now().millisecondsSinceEpoch;

  Future<bool?> checkIfEventExists(String id) async {
    bool exists = false;
    try {
      DocumentSnapshot snapshot = await eventsRef.doc(id).get();
      if (snapshot.exists) {
        exists = true;
      }
    } catch (e) {
      _snackbarService!.showSnackbar(
        title: 'Error',
        message: e.toString(),
        duration: Duration(seconds: 5),
      );
      return null;
    }
    return exists;
  }

  Future<bool?> checkIfEventSaved(
      {required String uid, required String eventID}) async {
    bool saved = false;
    try {
      DocumentSnapshot snapshot = await eventsRef.doc(eventID).get();
      if (snapshot.exists) {
        List savedBy = snapshot.data()!['savedBy'] == null
            ? []
            : snapshot.data()!['savedBy'].toList(growable: true);
        if (!savedBy.contains(uid)) {
          saved = false;
        } else {
          saved = true;
        }
      }
    } catch (e) {
      return null;
    }
    return saved;
  }

  Future saveUnsaveEvent(
      {required String? uid,
      required String? eventID,
      required bool savedEvent}) async {
    List? savedBy = [];
    DocumentSnapshot snapshot =
        await eventsRef.doc(eventID).get().catchError((e) {
      _snackbarService!.showSnackbar(
        title: 'Event Error',
        message: e.message,
        duration: Duration(seconds: 5),
      );
      return false;
    });
    if (snapshot.exists) {
      savedBy = snapshot.data()!['savedBy'] == null
          ? []
          : snapshot.data()!['savedBy'].toList(growable: true);
      if (savedEvent) {
        if (!savedBy!.contains(uid)) {
          savedBy.add(uid);
        }
      } else {
        if (savedBy!.contains(uid)) {
          savedBy.remove(uid);
        }
      }
      await eventsRef.doc(eventID).update({'savedBy': savedBy});
    }
    return savedBy.contains(uid);
  }

  Future<bool> checkInScannedTicket(
      {required String ticketID, required String eventID}) async {
    bool checkedIn = true;
    if (isValidTicket(ticketID)) {
      WebblenEventTicket ticket =
          await _ticketDistroDataService.getTicketByID(ticketID);
      WebblenTicketDistro ticketDistro =
          await _ticketDistroDataService.getTicketDistroByID(eventID);
      if (ticketDistro.validTicketIDs!.contains(ticketID)) {
        if (ticket.used == null || !ticket.used!) {
          ticket.used = await _ticketDistroDataService.scanInTicket(ticket.id!);
          if (ticket.used!) {
            WebblenUser user =
                await _userDataService.getWebblenUserByID(ticket.purchaserUID!);
            checkIntoEvent(user: user, eventID: eventID);
            // checkIntoEvent(uid: ticket.purchaserUID!, eventID: eventID);
            HapticFeedback.lightImpact();
          } else {
            checkedIn = false;
            HapticFeedback.heavyImpact();
            await Future.delayed(Duration(milliseconds: 200));
            HapticFeedback.heavyImpact();
          }
        } else {
          _customDialogService.showErrorDialog(
              description: "This ticket has already been checked in");
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
      _customDialogService.showErrorDialog(
          description: "This is not a Webblen Ticket");
      HapticFeedback.heavyImpact();
      await Future.delayed(Duration(milliseconds: 200));
      HapticFeedback.heavyImpact();
      checkedIn = false;
    }
    return checkedIn;
  }

  Future<bool> checkIntoEvent({
    required WebblenUser user,
    required String eventID,
  }) async {
    bool checkedInToThisEvent = false;
    DocumentSnapshot snapshot =
        await eventsRef.doc(eventID).get().catchError((e) {
      _customDialogService.showErrorDialog(
          description:
              "There was an error checking into this event. Please try again.");
    });

    if (snapshot.exists) {
      WebblenEvent event = WebblenEvent.fromMap(snapshot.data()!);

      List<CheckIn> checkIns = event.checkIns != null ? event.checkIns! : [];

      // check if user already checked in to an event
      if (user.isCheckedIntoEvent!) {
        checkedInToThisEvent = false;
        return checkedInToThisEvent;
      }

      CheckIn newCheckIn = CheckIn(
        uid: user.id,
        checkInTimeInMilliseconds: DateTime.now().millisecondsSinceEpoch,
        checkOutTimeInMilliseconds: null,
      );

      checkIns.add(newCheckIn);

      await eventsRef.doc(eventID).update({
        'checkIns': checkIns,
      });

      await usersRef.doc(user.id).update({
        'isCheckedIntoEvent': true,
      });

      // If the user hasn't checked into this event before, add them to the attendees list
      if (!event.attendees!.contains(user.id)) {
        event.attendees!.add(user.id);
        await eventsRef.doc(eventID).update({
          'attendees': event.attendees,
        });
      }

      checkedInToThisEvent = true;
    }
    return checkedInToThisEvent;
  }

  Future<bool> checkOutOfEvent({
    required WebblenUser user,
    required String eventID,
  }) async {
    bool checkedOutOfThisEvent = false;
    DocumentSnapshot snapshot =
        await eventsRef.doc(eventID).get().catchError((e) {
      _customDialogService.showErrorDialog(
          description:
              "There was an error checking out of this event. Please try again.");
    });
    if (snapshot.exists) {
      WebblenEvent event = WebblenEvent.fromMap(snapshot.data()!);

      List<CheckIn> checkIns = event.checkIns != null ? event.checkIns! : [];

      // Check to see if user is already checked out
      if (!user.isCheckedIntoEvent!) {
        checkedOutOfThisEvent = false;
        return checkedOutOfThisEvent;
      }

      // Finds the relevant CheckIn instance the user should check out of
      CheckIn checkInToCheckOutOf = checkIns.singleWhere(
        (checkIn) =>
            checkIn.uid == user.id &&
            checkIn.checkOutTimeInMilliseconds == null,
      );

      int currentTime = DateTime.now().millisecondsSinceEpoch;

      // Adds check out time to CheckIn instace,
      // if checked out after event end time then event end time is added instead
      if (currentTime > event.endDateTimeInMilliseconds!) {
        checkInToCheckOutOf.checkOutTimeInMilliseconds =
            event.endDateTimeInMilliseconds;
      } else {
        checkInToCheckOutOf.checkOutTimeInMilliseconds = currentTime;
      }

      // Updates list entry
      checkIns[checkIns.indexWhere((checkIn) =>
          checkIn.uid == user.id &&
          checkIn.checkOutTimeInMilliseconds == null)] = checkInToCheckOutOf;

      // Updates event doc
      await eventsRef.doc(eventID).update({
        'checkIns': checkIns,
      });

      checkedOutOfThisEvent = true;
    }

    return checkedOutOfThisEvent;
  }

  Future reportEvent(
      {required String? eventID, required String? reporterID}) async {
    DocumentSnapshot snapshot =
        await eventsRef.doc(eventID).get().catchError((e) {
      _snackbarService!.showSnackbar(
        title: 'Event Error',
        message: e.message,
        duration: Duration(seconds: 5),
      );
      return null;
    });
    if (snapshot.exists) {
      List reportedBy = snapshot.data()!['reportedBy'] == null
          ? []
          : snapshot.data()!['reportedBy'].toList(growable: true);
      if (reportedBy.contains(reporterID)) {
        return _snackbarService!.showSnackbar(
          title: 'Report Error',
          message:
              "You've already reported this event. This event is currently pending review.",
          duration: Duration(seconds: 5),
        );
      } else {
        reportedBy.add(reporterID);
        eventsRef.doc(eventID).update({"reportedBy": reportedBy});
        return _snackbarService!.showSnackbar(
          title: 'Event Reported',
          message: "This event is now pending review.",
          duration: Duration(seconds: 5),
        );
      }
    }
  }

  Future createEvent({required WebblenEvent event}) async {
    await eventsRef.doc(event.id).set(event.toMap()).catchError((e) {
      return e.message;
    });
  }

  Future updateEvent({required WebblenEvent event}) async {
    await eventsRef.doc(event.id).update(event.toMap()).catchError((e) {
      return e.message;
    });
  }

  Future deleteEvent({required WebblenEvent event}) async {
    await eventsRef.doc(event.id).delete();
    if (event.imageURL != null) {
      await _firestoreStorageService!.deleteImage(
          storageBucket: 'images', folderName: 'events', fileName: event.id!);
    }
    await _postDataService!
        .deleteEventOrStreamPost(eventOrStreamID: event.id, postType: 'event');
  }

  Future<WebblenEvent> getEventByID(String id) async {
    WebblenEvent event = WebblenEvent();
    String? error;
    DocumentSnapshot snapshot = await eventsRef.doc(id).get().catchError((e) {
      error = e.message;
      _customDialogService.showErrorDialog(description: error!);
    });
    if (error != null) {
      _customDialogService.showErrorDialog(
          description: "There was an unknown issue loading this event");
      return event;
    }
    if (snapshot.exists) {
      event = WebblenEvent.fromMap(snapshot.data()!);
    } else if (!snapshot.exists) {
      _customDialogService.showErrorDialog(
          description: "This Event No Longer Exists");
      return event;
    }
    return event;
  }

  Future getEventForEditingByID(String id) async {
    WebblenEvent? event;
    DocumentSnapshot snapshot = await eventsRef.doc(id).get().catchError((e) {
      return null;
    });
    if (snapshot.exists) {
      event = WebblenEvent.fromMap(snapshot.data()!);
    } else if (!snapshot.exists) {
      return null;
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
    Query query;
    List<DocumentSnapshot> docs = [];
    String? error;
    if (areaCode.isEmpty) {
      query = eventsRef
          .where('startDateTimeInMilliseconds',
              isGreaterThan: dateTimeInMilliseconds2hrsAgog)
          .orderBy('startDateTimeInMilliseconds', descending: false)
          .limit(resultsLimit);
    } else {
      query = eventsRef
          .where('nearbyZipcodes', arrayContains: areaCode)
          .where('startDateTimeInMilliseconds',
              isGreaterThan: dateTimeInMilliseconds2hrsAgog)
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
        docs.removeWhere((doc) => !doc.data()!['tags'].contains(tagFilter));
      }
      if (sortBy == "Latest") {
        docs.sort((docA, docB) => docA
            .data()!['startDateTimeInMilliseconds']
            .compareTo(docB.data()!['startDateTimeInMilliseconds']));
      } else {
        docs.sort((docA, docB) => docB
            .data()!['savedBy']
            .length
            .compareTo(docA.data()!['savedBy'].length));
      }
    }
    return docs;
  }

  Future<List<DocumentSnapshot>> loadAdditionalEvents(
      {required DocumentSnapshot lastDocSnap,
      required String areaCode,
      required int resultsLimit,
      required String tagFilter,
      required String sortBy}) async {
    Query query;
    List<DocumentSnapshot> docs = [];
    String? error;
    if (areaCode.isEmpty) {
      query = eventsRef
          .where('startDateTimeInMilliseconds',
              isGreaterThan: dateTimeInMilliseconds2hrsAgog)
          .orderBy('startDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastDocSnap)
          .limit(resultsLimit);
    } else {
      query = eventsRef
          .where('nearbyZipcodes', arrayContains: areaCode)
          .where('startDateTimeInMilliseconds',
              isGreaterThan: dateTimeInMilliseconds2hrsAgog)
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
        docs.removeWhere((doc) => !doc.data()!['tags'].contains(tagFilter));
      }
      if (sortBy == "Latest") {
        docs.sort((docA, docB) => docA
            .data()!['startDateTimeInMilliseconds']
            .compareTo(docB.data()!['startDateTimeInMilliseconds']));
      } else {
        docs.sort((docA, docB) => docB
            .data()!['savedBy']
            .length
            .compareTo(docA.data()!['savedBy'].length));
      }
    }
    return docs;
  }

  Future<List<DocumentSnapshot>> loadEventsByUserID(
      {required String? id, required int resultsLimit}) async {
    List<DocumentSnapshot> docs = [];
    String? error;
    Query query = eventsRef
        .where('authorID', isEqualTo: id)
        .orderBy('startDateTimeInMilliseconds', descending: true)
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

  Future<List<DocumentSnapshot>> loadAdditionalEventsByUserID({
    required String? id,
    required DocumentSnapshot lastDocSnap,
    required int resultsLimit,
  }) async {
    List<DocumentSnapshot> docs = [];
    String? error;
    Query query = eventsRef
        .where('authorID', isEqualTo: id)
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

  Future<List<DocumentSnapshot>> loadSavedEvents(
      {required String? id, required int resultsLimit}) async {
    List<DocumentSnapshot> docs = [];
    String? error;
    Query query = eventsRef
        .where('savedBy', arrayContains: id)
        .orderBy('startDateTimeInMilliseconds', descending: true)
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

  Future<List<DocumentSnapshot>> loadNearbyEvents(
      {required String areaCode,
      required double lat,
      required double lon,
      required int resultsLimit}) async {
    Geoflutterfire geoFlutterFire = Geoflutterfire();
    GeoFirePoint geoPoint = geoFlutterFire.point(latitude: lat, longitude: lon);
    List<DocumentSnapshot> docs = [];
    String? error;
    Query query = eventsRef
        .where('nearbyZipcodes', arrayContains: areaCode)
        .where('endDateTimeInMilliseconds',
            isGreaterThan: currentDateTimeInMilliseconds)
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
        double distanceFromPoint =
            geoPoint.distance(lat: doc.data()['lat'], lng: doc.data()['lon']);
        String venueSize = doc.data()['venueSize'] ?? "small";
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

  Future<List<DocumentSnapshot>> loadAdditionalNearbyEvents({
    required String areaCode,
    required double lat,
    required double lon,
    required DocumentSnapshot lastDocSnap,
    required int resultsLimit,
  }) async {
    Geoflutterfire geoFlutterFire = Geoflutterfire();
    GeoFirePoint geoPoint = geoFlutterFire.point(latitude: lat, longitude: lon);
    List<DocumentSnapshot> docs = [];
    String? error;
    Query query = eventsRef
        .where('nearbyZipcodes', arrayContains: areaCode)
        .where('endDateTimeInMilliseconds',
            isGreaterThan: currentDateTimeInMilliseconds)
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
        double distanceFromPoint =
            geoPoint.distance(lat: doc.data()['lat'], lng: doc.data()['lon']);
        String venueSize = doc.data()['venueSize'] ?? "small";
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
