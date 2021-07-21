import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_check_in.dart';
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
  final CollectionReference eventsRef = FirebaseFirestore.instance.collection("webblen_events");
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection("webblen_users");
  CustomDialogService _customDialogService = locator<CustomDialogService>();
  SnackbarService _snackbarService = locator<SnackbarService>();
  TicketDistroDataService _ticketDistroDataService = locator<TicketDistroDataService>();
  FirestoreStorageService _firestoreStorageService = locator<FirestoreStorageService>();
  PostDataService? _postDataService = locator<PostDataService>();
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

  Future<bool> checkInScannedTicket(
      {required String ticketID, required String eventID}) async {
    bool checkedIn = true;
    if (isValidTicket(ticketID)) {
      WebblenEventTicket ticket = await _ticketDistroDataService.getTicketByID(ticketID);
      if (ticket.eventID == eventID) {
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
      WebblenEvent event = WebblenEvent.fromMap(snapshot.data()! as Map<String, dynamic>);

      List<WebblenCheckIn> checkIns =
          event.webblenCheckIns != null ? event.webblenCheckIns! : [];

      // check if user already checked in to an event
      if (user.isCheckedIntoEvent!) {
        return checkedInToThisEvent;
      }

      // Find if user has already checked into this event
      WebblenCheckIn checkInResult = checkIns.singleWhere(
        (checkIn) => checkIn.uid == user.id,
        orElse: () => WebblenCheckIn(uid: ''),
      );

      // If user has already checked into this event, add to their check in data
      if (checkInResult.uid != null) {
        List<CheckInData> userCheckInData = checkInResult.checkInData!;
        CheckInData newCheckIn = CheckInData(
          checkInTimeInMilliseconds: DateTime.now().millisecondsSinceEpoch,
          checkOutTimeInMilliseconds: null,
        );
        userCheckInData.add(newCheckIn);
        checkIns[checkIns.indexWhere((checkIn) => checkIn.uid == user.id)] =
            checkInResult;
        // Otherwise create a new check in
      } else {
        WebblenCheckIn newCheckIn = WebblenCheckIn(uid: user.id, checkInData: [
          CheckInData(
            checkInTimeInMilliseconds: DateTime.now().millisecondsSinceEpoch,
            checkOutTimeInMilliseconds: null,
          )
        ]);
        checkIns.add(newCheckIn);
      }

      // If the user hasn't checked into this event before, add them to the attendees list and update doc
      if (!event.eventAttendees!.contains(user.id)) {
        event.eventAttendees!.add(user.id);
        await eventsRef.doc(eventID).update({
          'attendees': event.eventAttendees,
          'webblenCheckIns': checkIns,
          'isCheckedIntoEvent': true,
        });
      } else {
        // Otherwise update doc
        await eventsRef.doc(eventID).update({
          'webblenCheckIns': checkIns,
          'isCheckedIntoEvent': true,
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
      WebblenEvent event = WebblenEvent.fromMap(snapshot.data()! as Map<String, dynamic>);

      List<WebblenCheckIn> checkIns =
          event.webblenCheckIns != null ? event.webblenCheckIns! : [];

      // Check to see if user is already checked out
      if (!user.isCheckedIntoEvent!) {
        return checkedOutOfThisEvent;
      }

      // Finds the relevant WebblenCheckIn instance the user should check out of
      WebblenCheckIn checkInToCheckOutOfResult = checkIns.singleWhere(
        (checkIn) => checkIn.uid == user.id,
        orElse: () => WebblenCheckIn(uid: ''),
      );

      if (checkInToCheckOutOfResult.uid != '') {
        List<CheckInData> userCheckInData =
            checkInToCheckOutOfResult.checkInData!;

        // Finds the check in data that's null to fill in
        CheckInData unCompletedCheckInResult = userCheckInData.singleWhere(
          (val) => val.checkOutTimeInMilliseconds == null,
          orElse: () => CheckInData(
            checkInTimeInMilliseconds: 0,
          ),
        );

        if (unCompletedCheckInResult.checkInTimeInMilliseconds != 0) {
          int currentTime = DateTime.now().millisecondsSinceEpoch;

          // Adds check out time to CheckIn instace,
          // if checked out after event end time then event end time is added instead
          if (currentTime > event.endDateTimeInMilliseconds!) {
            unCompletedCheckInResult.checkOutTimeInMilliseconds =
                event.endDateTimeInMilliseconds;
          } else {
            unCompletedCheckInResult.checkOutTimeInMilliseconds = currentTime;
          }

          // Updates check in data list entry
          userCheckInData[userCheckInData.indexWhere(
            (val) =>
                val.checkInTimeInMilliseconds ==
                unCompletedCheckInResult.checkInTimeInMilliseconds,
          )] = unCompletedCheckInResult;

          // Updates webbldn check in entry
          checkIns[checkIns.indexWhere((checkIn) => checkIn.uid == user.id)] =
              checkInToCheckOutOfResult;
        } else {
          print('1: There was an error in check out function');
        }
      } else {
        print('2: There was an error in the check out function');
      }

      // Updates event doc
      await eventsRef.doc(eventID).update({
        'webblenCheckIns': checkIns,
        'isCheckedIntoEvent': false,
      });

      checkedOutOfThisEvent = true;
    }

    return checkedOutOfThisEvent;
  }

  Future<bool> isCheckedIntoThisEvent({
    required WebblenUser user,
    required String eventID,
  }) async {
    bool isCheckedintoThisEvent = false;
    DocumentSnapshot snapshot =
        await eventsRef.doc(eventID).get().catchError((e) {
      _customDialogService.showErrorDialog(
          description:
              "There was an error checking out of this stream. Please try again.");
    });
    if (snapshot.exists) {
      WebblenEvent event = WebblenEvent.fromMap(snapshot.data()! as Map<String, dynamic>);

      List<WebblenCheckIn> checkIns =
          event.webblenCheckIns != null ? event.webblenCheckIns! : [];

      // Finds the relevant CheckIn instance the user should check out of
      final checkInToCheckOutOfResult = checkIns.singleWhere(
          (checkIn) => checkIn.uid == user.id,
          orElse: () => WebblenCheckIn(uid: ''));

      // If the user is currently checked into event or has checked into event in the past
      if (checkInToCheckOutOfResult.uid != '') {
        for (CheckInData checkInData
            in checkInToCheckOutOfResult.checkInData!) {
          // If user has not checkout of event (meaning they're checked in)
          if (checkInData.checkOutTimeInMilliseconds == null) {
            isCheckedintoThisEvent = true;
            // Otherwise the user has checked into event in the past but is not currently checked in
          } else {
            isCheckedintoThisEvent = false;
          }
        }
        // The user has never checked into this event
      } else {
        isCheckedintoThisEvent = false;
      }
    }
    return isCheckedintoThisEvent;
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
          message:
              "You've already reported this event. This event is currently pending review.",
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
      _customDialogService.showErrorDialog(
          description: "There was an unknown issue loading this event");
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

  Future<List<DocumentSnapshot>> loadNearbyEvents({required String areaCode, required double lat, required double lon, required int resultsLimit}) async {
    int currentDateTimeInMilliseconds = DateTime.now().millisecondsSinceEpoch;
    GeoFlutterFire geoFlutterFire = GeoFlutterFire();
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
