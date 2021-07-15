import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_check_in.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/firestore/common/firestore_storage_service.dart';
import 'package:webblen/services/firestore/data/post_data_service.dart';
import 'package:webblen/utils/custom_string_methods.dart';

class LiveStreamDataService {
  final CollectionReference streamsRef =
      FirebaseFirestore.instance.collection("webblen_live_streams");
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection("webblen_users");
  PostDataService? _postDataService = locator<PostDataService>();
  CustomDialogService _customDialogService = locator<CustomDialogService>();
  DialogService? _dialogService = locator<DialogService>();
  FirestoreStorageService? _firestoreStorageService =
      locator<FirestoreStorageService>();

  int dateTimeInMilliseconds2hrsAgog =
      DateTime.now().millisecondsSinceEpoch - 7200000;

  Future<bool?> checkIfStreamExists(String id) async {
    bool exists = false;
    try {
      DocumentSnapshot snapshot = await streamsRef.doc(id).get();
      if (snapshot.exists) {
        exists = true;
      }
    } catch (e) {
      _dialogService!.showDialog(
        title: "Error",
        description: e.toString(),
      );
      return null;
    }
    return exists;
  }

  Future<bool?> checkIfStreamSaved(
      {required String uid, required String eventID}) async {
    bool saved = false;
    try {
      DocumentSnapshot snapshot = await streamsRef.doc(eventID).get();
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

  Future saveUnsaveStream(
      {required String? uid,
      required String? streamID,
      required bool savedStream}) async {
    List? savedBy = [];
    DocumentSnapshot snapshot =
        await streamsRef.doc(streamID).get().catchError((e) {
      _dialogService!.showDialog(
        title: "Stream Error",
        description: e.message,
      );
      return false;
    });
    if (snapshot.exists) {
      savedBy = snapshot.data()!['savedBy'] == null
          ? []
          : snapshot.data()!['savedBy'].toList(growable: true);
      if (savedStream) {
        if (!savedBy!.contains(uid)) {
          savedBy.add(uid);
        }
      } else {
        if (savedBy!.contains(uid)) {
          savedBy.remove(uid);
        }
      }
      await streamsRef.doc(streamID).update({'savedBy': savedBy});
    }
    return savedBy.contains(uid);
  }

  Future endStream({required String streamID}) async {
    await streamsRef.doc(streamID).update({
      'hasStreamEnded': true,
    });
  }

  Future reportStream(
      {required String? streamID, required String? reporterID}) async {
    DocumentSnapshot snapshot =
        await streamsRef.doc(streamID).get().catchError((e) {
      _dialogService!.showDialog(
        title: "Stream Error",
        description: e.message,
      );
      return null;
    });
    if (snapshot.exists) {
      List reportedBy = snapshot.data()!['reportedBy'] == null
          ? []
          : snapshot.data()!['reportedBy'].toList(growable: true);
      if (reportedBy.contains(reporterID)) {
        _dialogService!.showDialog(
          title: "Report Error",
          description:
              "You've already reported this stream. This stream is currently pending review.",
        );
      } else {
        reportedBy.add(reporterID);
        streamsRef.doc(streamID).update({"reportedBy": reportedBy});
        return _dialogService!.showDialog(
          title: "Stream Reported",
          description: "This stream is now pending review.",
        );
      }
    }
  }

  Future createStream({required WebblenLiveStream stream}) async {
    await streamsRef.doc(stream.id).set(stream.toMap()).catchError((e) {
      print(e.message);
      return e.message;
    });
  }

  Future updateStream({required WebblenLiveStream stream}) async {
    await streamsRef.doc(stream.id).update(stream.toMap()).catchError((e) {
      print(e.message);
      return e.message;
    });
  }

  Future deleteStream({required WebblenLiveStream stream}) async {
    await streamsRef.doc(stream.id).delete();
    if (stream.imageURL != null) {
      await _firestoreStorageService!.deleteImage(
          storageBucket: 'images', folderName: 'streams', fileName: stream.id!);
    }
    await _postDataService!.deleteEventOrStreamPost(
        eventOrStreamID: stream.id, postType: 'stream');
  }

  Future<WebblenLiveStream> getStreamByID(String? id) async {
    WebblenLiveStream stream = WebblenLiveStream();
    String? error;
    DocumentSnapshot snapshot = await streamsRef.doc(id).get().catchError((e) {
      error = e.message;
      _dialogService!.showDialog(
        title: "Stream Error",
        description: e.message,
      );
    });

    if (error != null) {
      return stream;
    }

    if (snapshot.exists) {
      stream = WebblenLiveStream.fromMap(snapshot.data()!);
    } else if (!snapshot.exists) {
      _dialogService!.showDialog(
        title: "his Stream No Longer Exists",
        description: "This stream has been removed",
      );
      return stream;
    }
    return stream;
  }

  FutureOr<WebblenLiveStream> getStreamForEditingByID(String? id) async {
    WebblenLiveStream stream = WebblenLiveStream();
    String? error;
    DocumentSnapshot snapshot = await streamsRef.doc(id).get().catchError((e) {
      print(e.message);
      _dialogService!.showDialog(
        title: "Stream Error",
        description: e.message,
      );
      error = e.message;
    });

    if (error != null) {
      return stream;
    }

    if (snapshot.exists) {
      stream = WebblenLiveStream.fromMap(snapshot.data()!);
    }

    return stream;
  }

  Future<String?> generateStreamToken(String streamID) async {
    String? token;
    DocumentSnapshot snapshot =
        await streamsRef.doc(streamID).get().catchError((e) {
      _dialogService!.showDialog(
        title: "There was an issue starting this stream",
        description: "Please try again",
      );
      return null;
    });
    if (snapshot.exists) {
      if (snapshot.data()!['token'] != null) {
        token = snapshot.data()!['token'];
      } else {
        token = getRandomString(30);
        await streamsRef.doc(streamID).update({'token': token});
      }
    }
    return token;
  }

  addToActiveViewers({required String uid, required String streamID}) async {
    String? error;
    DocumentSnapshot snapshot =
        await streamsRef.doc(streamID).get().catchError((e) {
      error = e.message;
      print(error);
    });
    if (error != null) {
      return;
    }
    if (snapshot.exists) {
      WebblenLiveStream stream = WebblenLiveStream.fromMap(snapshot.data()!);
      List<ActiveViewer> activeViewers = stream.activeViewers!;
      ActiveViewer result = activeViewers.singleWhere(
        (val) => val.uid == uid,
        orElse: () => ActiveViewer(uid: ''),
      );

      if (result.uid == '') {
        activeViewers.add(
          ActiveViewer(
            uid: uid,
            isHereSinceLastPayoutIteration: false,
          ),
        );
        streamsRef
            .doc(streamID)
            .update({'activeViewers': activeViewers}).catchError((e) {
          print(e.message);
        });
      }
    }
  }

  removeFromActiveViewers(
      {required String uid, required String streamID}) async {
    String? error;
    DocumentSnapshot snapshot =
        await streamsRef.doc(streamID).get().catchError((e) {
      error = e.message;
      print(error);
    });
    if (error != null) {
      return;
    }
    if (snapshot.exists) {
      WebblenLiveStream stream = WebblenLiveStream.fromMap(snapshot.data()!);
      List<ActiveViewer> activeViewers = stream.activeViewers!;
      ActiveViewer result = activeViewers.singleWhere(
        (val) => val.uid == uid,
        orElse: () => ActiveViewer(uid: ''),
      );
      if (result.uid == uid) {
        activeViewers.remove(result);
        streamsRef
            .doc(streamID)
            .update({'activeViewers': activeViewers}).catchError((e) {
          print(e.message);
        });
      }
    }
  }

  Future<bool> checkIntoStream(
      {required WebblenUser user, required String streamID}) async {
    bool checkedIntoThisStream = false;
    DocumentSnapshot snapshot =
        await streamsRef.doc(streamID).get().catchError((e) {
      _customDialogService.showErrorDialog(
          description:
              "There was an error checking into this stream. Please try again.");
    });
    if (snapshot.exists) {
      WebblenLiveStream stream = WebblenLiveStream.fromMap(snapshot.data()!);

      List<WebblenCheckIn> checkIns =
          stream.webblenCheckIns != null ? stream.webblenCheckIns! : [];

      // check if user already checked in to a stream
      if (user.isCheckedIntoStream!) {
        return checkedIntoThisStream;
      }

      // Find if user has already checked into this stream
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

      // If the user hasn't checked into this event before, add them to the attendees list
      if (!stream.attendees!.contains(user.id)) {
        stream.attendees!.add(user.id);
        await streamsRef.doc(streamID).update({
          'attendees': stream.attendees,
          'webblenCheckIns': checkIns,
          'isCheckedIntoStream': true,
        });
      } else {
        // Otherwise just update doc
        await streamsRef.doc(streamID).update({
          'webblenCheckIns': checkIns,
          'isCheckedIntoStream': true,
        });
      }
    }
    return checkedIntoThisStream;
  }

  Future<bool> checkOutOfStream(
      {required WebblenUser user, required String streamID}) async {
    bool checkedOutOfThisStream = false;
    DocumentSnapshot snapshot =
        await streamsRef.doc(streamID).get().catchError((e) {
      _customDialogService.showErrorDialog(
          description:
              "There was an error checking out of this stream. Please try again.");
    });
    if (snapshot.exists) {
      WebblenLiveStream stream = WebblenLiveStream.fromMap(snapshot.data()!);

      List<WebblenCheckIn> checkIns =
          stream.webblenCheckIns != null ? stream.webblenCheckIns! : [];

      // Check to see if user is already checked out
      if (!user.isCheckedIntoStream!) {
        return checkedOutOfThisStream;
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
          if (currentTime > stream.endDateTimeInMilliseconds!) {
            unCompletedCheckInResult.checkOutTimeInMilliseconds =
                stream.endDateTimeInMilliseconds;
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
          print('There was an error in check out function');
        }
      } else {
        print('There was an error in the check out function');
      }

      // Updates stream doc
      await streamsRef.doc(streamID).update({
        'webblenCheckIns': checkIns,
      });

      checkedOutOfThisStream = true;
    }
    return checkedOutOfThisStream;
  }

  Future<bool> isCheckedIntoThisStream({
    required WebblenUser user,
    required String streamID,
  }) async {
    bool isCheckedintoThisStream = false;
    DocumentSnapshot snapshot =
        await streamsRef.doc(streamID).get().catchError((e) {
      _customDialogService.showErrorDialog(
        description:
            "There was an error checking out of this stream. Please try again.",
      );
    });
    if (snapshot.exists) {
      WebblenLiveStream stream = WebblenLiveStream.fromMap(snapshot.data()!);

      List<WebblenCheckIn> checkIns =
          stream.webblenCheckIns != null ? stream.webblenCheckIns! : [];

      // Finds the relevant CheckIn instance the user should check out of
      final checkInToCheckOutOfResult = checkIns.singleWhere(
          (checkIn) => checkIn.uid == user.id,
          orElse: () => WebblenCheckIn(uid: ''));

      // If the user is currently checked into stream or has checked into stream in the past
      if (checkInToCheckOutOfResult.uid != '') {
        for (CheckInData checkInData
            in checkInToCheckOutOfResult.checkInData!) {
          // If user has not checked out of event (meaning they're checked in)
          if (checkInData.checkOutTimeInMilliseconds == null) {
            isCheckedintoThisStream = true;
            // Otherwise the user has checked into event in the past but is not currently checked in
          } else {
            isCheckedintoThisStream = false;
          }
        }
        // The user has never checked into this event
      } else {
        isCheckedintoThisStream = false;
      }
    }
    return isCheckedintoThisStream;
  }

  Future<void> startPayoutClock({
    required WebblenLiveStream currentStream,
    required int payoutClockDurationInMinutes,
    required int durationBetweenPayoutIterationsInMinutes,
  }) async {
    final Duration durationBetweenPayoutIterations = Duration(
      minutes: durationBetweenPayoutIterationsInMinutes,
    );

    // total amount that will be given to users
    final int totalMicroWebblenPayoutAmount =
        (currentStream.payout! * 1000000).toInt();
    // total amount of payout iterations
    final int totalNumOfPayoutIterations = payoutClockDurationInMinutes ~/
        durationBetweenPayoutIterationsInMinutes;
    // total amount of webblen that will be given to all the current active users
    // that have stayed during the whole payout iteration
    final int totalMicroWebblenToDistributePerPayoutIteration =
        totalMicroWebblenPayoutAmount ~/ totalNumOfPayoutIterations;
    // count the num of payout iterations that have occurred so timer knows when to end
    int numOfPayoutIterationsThatHaveOccurred = 0;

    // The first timer iteration gets called after specified duration so for the active viewers
    // that were there when the method was initially called, this shows that they are eligible
    // for the first payout iteration
    List<ActiveViewer> activeViewers = currentStream.activeViewers!;
    for (ActiveViewer activeViewer in activeViewers) {
      activeViewer.isHereSinceLastPayoutIteration = true;
    }

    Timer.periodic(durationBetweenPayoutIterations, (timer) async {
      // If the stream is currently happening
      if (!currentStream.hasStreamEnded!) {
        // If the payout clock hasn't ended yet
        if (numOfPayoutIterationsThatHaveOccurred <=
            totalNumOfPayoutIterations) {
          List<ActiveViewer> activeViewers = currentStream.activeViewers!;
          List<LiveStreamUserPayoutData> liveStreamUserPayoutData =
              currentStream.liveStreamUserPayoutData!;
          // For each active viewer in the stream
          for (ActiveViewer activeViewer in activeViewers) {
            // If they joined the stream after the payout clock has started
            if (!activeViewer.isHereSinceLastPayoutIteration!) {
              activeViewer.isHereSinceLastPayoutIteration = true;
              // Otherwise save their payout data
            } else {
              // Checks to see if user already has payout data from this stream
              LiveStreamUserPayoutData userLiveStreamPayouts =
                  liveStreamUserPayoutData.singleWhere(
                (val) => val.uid == activeViewer.uid,
                orElse: () => LiveStreamUserPayoutData(uid: ''),
              );
              // Calculates amount of webblen to give user
              int microWebblenToGiveUser =
                  totalMicroWebblenToDistributePerPayoutIteration ~/
                      activeViewers.length;
              // If they already have payout data from this stream
              // then save their payout iteration in their list
              if (userLiveStreamPayouts.uid != '') {
                userLiveStreamPayouts.microWebblenPayoutAmounts!
                    .add(microWebblenToGiveUser);
                // Otherwise create a new instance and save payout iteration
              } else {
                LiveStreamUserPayoutData newLiveStreamUserPayoutData =
                    LiveStreamUserPayoutData(
                  uid: activeViewer.uid,
                  microWebblenPayoutAmounts: [microWebblenToGiveUser],
                );
                liveStreamUserPayoutData.add(newLiveStreamUserPayoutData);
              }
            }
          }
          // Updates stream doc with new activeViewers and liveStreamUserPayoutData lists
          await streamsRef.doc(currentStream.id).update({
            'activeViewers': activeViewers,
            'liveStreamUserPayoutData': liveStreamUserPayoutData,
          });
          // Increases iteration count
          numOfPayoutIterationsThatHaveOccurred++;
        } else {
          // When the last iteration takes place
          timer.cancel();
        }
      } else {
        // If streams ends before the payout clock fully finishes and updates didPayoutClockEndEarly to true
        timer.cancel();
        await streamsRef.doc(currentStream.id).update({
          'didPayoutClockEndEarly': true,
        });
      }
    });
  }

  ///READ & QUERIES
  Future<List<DocumentSnapshot>> loadStreams({
    required String areaCode,
    required int resultsLimit,
    required String? tagFilter,
    required String? sortBy,
  }) async {
    Query query;
    List<DocumentSnapshot> docs = [];
    if (areaCode.isEmpty) {
      query = streamsRef
          .where('startDateTimeInMilliseconds',
              isGreaterThan: dateTimeInMilliseconds2hrsAgog)
          .orderBy('startDateTimeInMilliseconds', descending: false)
          .limit(resultsLimit);
    } else {
      query = streamsRef
          .where('nearbyZipcodes', arrayContains: areaCode)
          .where('startDateTimeInMilliseconds',
              isGreaterThan: dateTimeInMilliseconds2hrsAgog)
          .orderBy('startDateTimeInMilliseconds', descending: false)
          .limit(resultsLimit);
    }
    QuerySnapshot snapshot = await query.get().catchError((e) {
      if (!e.message.contains("insufficient permissions")) {
        print(e.message);
        _dialogService!.showDialog(
          title: "Stream Error",
          description: e.message,
        );
      }
      return [];
    });
    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
      if (tagFilter!.isNotEmpty) {
        docs.removeWhere((doc) => !doc.data()!['tags'].contains(tagFilter));
      }
      if (sortBy == "Latest") {
        docs.sort((docA, docB) => docB
            .data()!['startDateTimeInMilliseconds']
            .compareTo(docA.data()!['startDateTimeInMilliseconds']));
      } else {
        docs.sort((docA, docB) => docB
            .data()!['savedBy']
            .length
            .compareTo(docA.data()!['savedBy'].length));
      }
    }
    return docs;
  }

  Future<List<DocumentSnapshot>> loadAdditionalStreams(
      {required DocumentSnapshot lastDocSnap,
      required String areaCode,
      required int resultsLimit,
      required String? tagFilter,
      required String? sortBy}) async {
    Query query;
    List<DocumentSnapshot> docs = [];
    if (areaCode.isEmpty) {
      query = streamsRef
          .where('startDateTimeInMilliseconds',
              isGreaterThan: dateTimeInMilliseconds2hrsAgog)
          .orderBy('startDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastDocSnap)
          .limit(resultsLimit);
    } else {
      query = streamsRef
          .where('nearbyZipcodes', arrayContains: areaCode)
          .where('startDateTimeInMilliseconds',
              isGreaterThan: dateTimeInMilliseconds2hrsAgog)
          .orderBy('startDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastDocSnap)
          .limit(resultsLimit);
    }
    QuerySnapshot snapshot = await query.get().catchError((e) {
      if (!e.message.contains("insufficient permissions")) {
        print(e.message);
        _dialogService!.showDialog(
          title: "Stream Error",
          description: e.message,
        );
      }
      return [];
    });
    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
      if (tagFilter!.isNotEmpty) {
        docs.removeWhere((doc) => !doc.data()!['tags'].contains(tagFilter));
      }
      if (sortBy == "Latest") {
        docs.sort((docA, docB) => docB
            .data()!['startDateTimeInMilliseconds']
            .compareTo(docA.data()!['startDateTimeInMilliseconds']));
      } else {
        docs.sort((docA, docB) => docB
            .data()!['savedBy']
            .length
            .compareTo(docA.data()!['savedBy'].length));
      }
    }
    return docs;
  }

  Future<List<DocumentSnapshot>> loadStreamsByUserID(
      {required String? id, required int resultsLimit}) async {
    List<DocumentSnapshot> docs = [];
    Query query = streamsRef
        .where('hostID', isEqualTo: id)
        .orderBy('startDateTimeInMilliseconds', descending: true)
        .limit(resultsLimit);
    QuerySnapshot snapshot = await query.get().catchError((e) {
      if (!e.message.contains("insufficient permissions")) {
        print(e.message);
        _dialogService!.showDialog(
          title: "Stream Error",
          description: e.message,
        );
      }
      return [];
    });
    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
    }
    return docs;
  }

  Future<List<DocumentSnapshot>> loadAdditionalStreamsByUserID({
    required String? id,
    required DocumentSnapshot lastDocSnap,
    required int resultsLimit,
  }) async {
    List<DocumentSnapshot> docs = [];
    Query query = streamsRef
        .where('hostID', isEqualTo: id)
        .orderBy('startDateTimeInMilliseconds', descending: true)
        .startAfterDocument(lastDocSnap)
        .limit(resultsLimit);
    QuerySnapshot snapshot = await query.get().catchError((e) {
      if (!e.message.contains("insufficient permissions")) {
        print(e.message);
        _dialogService!.showDialog(
          title: "Stream Error",
          description: e.message,
        );
      }
      return [];
    });
    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
    }
    return docs;
  }

  Future<List<DocumentSnapshot>> loadSavedStreams(
      {required String? id, required int resultsLimit}) async {
    List<DocumentSnapshot> docs = [];
    Query query = streamsRef
        .where('savedBy', arrayContains: id)
        .orderBy('startDateTimeInMilliseconds', descending: true)
        .limit(resultsLimit);
    QuerySnapshot snapshot = await query.get().catchError((e) {
      if (!e.message.contains("insufficient permissions")) {
        print(e.message);
        _dialogService!.showDialog(
          title: "Stream Error",
          description: e.message,
        );
      }
      return [];
    });
    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
    }
    return docs;
  }

  Future<List<DocumentSnapshot>> loadAdditionalSavedStreams({
    required String? id,
    required DocumentSnapshot lastDocSnap,
    required int resultsLimit,
  }) async {
    List<DocumentSnapshot> docs = [];
    Query query = streamsRef
        .where('savedBy', arrayContains: id)
        .orderBy('startDateTimeInMilliseconds', descending: true)
        .startAfterDocument(lastDocSnap)
        .limit(resultsLimit);
    QuerySnapshot snapshot = await query.get().catchError((e) {
      if (!e.message.contains("insufficient permissions")) {
        print(e.message);
        _dialogService!.showDialog(
          title: "Stream Error",
          description: e.message,
        );
      }
      return [];
    });
    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
    }
    return docs;
  }
}
