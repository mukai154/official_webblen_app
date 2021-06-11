import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/firestore/common/firestore_storage_service.dart';
import 'package:webblen/services/firestore/data/post_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/utils/custom_string_methods.dart';

class LiveStreamDataService {
  final CollectionReference streamsRef = FirebaseFirestore.instance.collection("webblen_live_streams");
  PostDataService _postDataService = locator<PostDataService>();
  CustomDialogService _customDialogService = locator<CustomDialogService>();
  DialogService _dialogService = locator<DialogService>();
  SnackbarService _snackbarService = locator<SnackbarService>();
  FirestoreStorageService _firestoreStorageService = locator<FirestoreStorageService>();
  UserDataService _userDataService = locator<UserDataService>();

  int dateTimeInMilliseconds2hrsAgog = DateTime.now().millisecondsSinceEpoch - 7200000;

  Future<bool?> checkIfStreamExists(String id) async {
    bool exists = false;
    try {
      DocumentSnapshot snapshot = await streamsRef.doc(id).get();
      if (snapshot.exists) {
        exists = true;
      }
    } catch (e) {
      _dialogService.showDialog(
        title: "Error",
        description: e.toString(),
      );
      return null;
    }
    return exists;
  }

  Future<bool> checkIfStreamSaved({required String uid, required String eventID}) async {
    bool saved = false;

    DocumentSnapshot snapshot = await streamsRef.doc(eventID).get();
    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      if (snapshotData.isNotEmpty) {
        List savedBy = snapshotData['savedBy'] == null ? [] : snapshotData['savedBy'].toList(growable: true);
        if (!savedBy.contains(uid)) {
          saved = false;
        } else {
          saved = true;
        }
      }
    }

    return saved;
  }

  Future<String?> saveUnsaveStream({required String uid, required String streamID, required bool savedStream}) async {
    String? error;
    if (savedStream) {
      await streamsRef.doc(streamID).update({
        'savedBy': FieldValue.arrayUnion([uid])
      }).catchError((e) {
        error = e.message;
      });
    } else {
      await streamsRef.doc(streamID).update({
        'savedBy': FieldValue.arrayRemove([uid])
      }).catchError((e) {
        error = e.message;
      });
    }
    return error;
  }

  Future reportStream({required String streamID, required String reporterID}) async {
    DocumentSnapshot snapshot = await streamsRef.doc(streamID).get().catchError((e) {
      _snackbarService.showSnackbar(
        title: 'Stream Error',
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
          message: "You've already reported this stream. This event is currently pending review.",
          duration: Duration(seconds: 5),
        );
      } else {
        reportedBy.add(reporterID);
        streamsRef.doc(streamID).update({"reportedBy": reportedBy});
        _snackbarService.showSnackbar(
          title: 'Stream Reported',
          message: "This stream is now pending review.",
          duration: Duration(seconds: 5),
        );
      }
    }
  }

  Future<bool> createStream({required WebblenLiveStream stream}) async {
    String? error;
    await streamsRef.doc(stream.id).set(stream.toMap()).catchError((e) {
      error = e.message;
    });
    if (error != null) {
      _customDialogService.showErrorDialog(description: error!);
      return false;
    }
    if (isValidString(stream.fbUsername)) {
      await _userDataService.updateFbUsername(id: stream.hostID!, val: stream.fbUsername!);
    }
    if (isValidString(stream.twitterUsername)) {
      await _userDataService.updateTwitterUsername(id: stream.hostID!, val: stream.twitterUsername!);
    }
    if (isValidString(stream.website)) {
      await _userDataService.updateWebsite(id: stream.hostID!, website: stream.website!);
    }
    if (isValidString(stream.fbStreamKey)) {
      await _userDataService.updateFBStreamKey(id: stream.hostID!, val: stream.fbStreamKey!);
    }
    if (isValidString(stream.fbStreamURL)) {
      await _userDataService.updateFBStreamURL(id: stream.hostID!, val: stream.fbStreamURL!);
    }
    if (isValidString(stream.twitchStreamKey)) {
      await _userDataService.updateTwitchStreamKey(id: stream.hostID!, val: stream.twitchStreamKey!);
    }
    if (isValidString(stream.twitchStreamURL)) {
      await _userDataService.updateTwitchStreamURL(id: stream.hostID!, val: stream.twitchStreamURL!);
    }
    if (isValidString(stream.youtubeStreamKey)) {
      await _userDataService.updateYoutubeStreamKey(id: stream.hostID!, val: stream.youtubeStreamKey!);
    }
    if (isValidString(stream.youtubeStreamURL)) {
      await _userDataService.updateYoutubeStreamURL(id: stream.hostID!, val: stream.youtubeStreamURL!);
    }
    return true;
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
      await _firestoreStorageService.deleteImage(storageBucket: 'images', folderName: 'streams', fileName: stream.id!);
    }
    await _postDataService.deleteEventOrStreamPost(eventOrStreamID: stream.id, postType: 'stream');
  }

  Future<WebblenLiveStream> getStreamByID(String? id) async {
    WebblenLiveStream stream = WebblenLiveStream();
    String? error;
    DocumentSnapshot snapshot = await streamsRef.doc(id).get().catchError((e) {
      error = e.message;
      _dialogService.showDialog(
        title: "Stream Error",
        description: e.message,
      );
    });

    if (error != null) {
      return stream;
    }

    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      if (snapshotData.isNotEmpty) {
        stream = WebblenLiveStream.fromMap(snapshotData);
      }
    } else {
      _customDialogService.showErrorDialog(description: "This Stream No Longer Exists");
    }

    return stream;
  }

  FutureOr<WebblenLiveStream> getStreamForEditingByID(String? id) async {
    WebblenLiveStream stream = WebblenLiveStream();
    String? error;
    DocumentSnapshot snapshot = await streamsRef.doc(id).get().catchError((e) {
      print(e.message);
      error = e.message;
    });

    if (error != null) {
      return stream;
    }

    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      if (snapshotData.isNotEmpty) {
        stream = WebblenLiveStream.fromMap(snapshotData);
      }
    } else {
      _customDialogService.showErrorDialog(description: "This Stream No Longer Exists");
    }

    return stream;
  }

  Future<String?> generateStreamToken(String streamID) async {
    String? token;
    DocumentSnapshot snapshot = await streamsRef.doc(streamID).get().catchError((e) {
      _customDialogService.showErrorDialog(description: "There was an issue starting this stream");
    });

    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      if (snapshotData.isNotEmpty) {
        if (snapshotData['token'] != null) {
          token = snapshotData['token'];
        } else {
          token = getRandomString(30);
          await streamsRef.doc(streamID).update({'token': token});
        }
      }
    }

    return token;
  }

  addToActiveViewers({required String uid, required String streamID}) async {
    String? error;
    DocumentSnapshot snapshot = await streamsRef.doc(streamID).get().catchError((e) {
      error = e.message;
      print(error);
    });
    if (error != null) {
      return;
    }

    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      List viewers = snapshotData['activeViewers'] == null ? [] : snapshotData['activeViewers'].toList(growable: true);
      if (!viewers.contains(uid)) {
        viewers.add(uid);
        streamsRef.doc(streamID).update({'activeViewers': viewers}).catchError((e) {
          print(e.message);
        });
      }
    }
  }

  removeFromActiveViewers({required String uid, required String streamID}) async {
    String? error;
    DocumentSnapshot snapshot = await streamsRef.doc(streamID).get().catchError((e) {
      error = e.message;
      print(error);
    });
    if (error != null) {
      return;
    }

    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      if (snapshotData.isNotEmpty) {
        List viewers = snapshotData['activeViewers'] == null ? [] : snapshotData['activeViewers'].toList(growable: true);
        if (viewers.contains(uid)) {
          viewers.remove(uid);
          streamsRef.doc(streamID).update({'activeViewers': viewers}).catchError((e) {
            print(e.message);
          });
        }
      }
    }
  }

  Future<bool> checkIntoStream({required String uid, required String streamID}) async {
    bool checkedIn = false;
    DocumentSnapshot snapshot = await streamsRef.doc(streamID).get().catchError((e) {
      _customDialogService.showErrorDialog(description: "There was an error checking into this stream. Please try again.");
    });

    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      if (snapshotData.isNotEmpty) {
        WebblenLiveStream stream = WebblenLiveStream.fromMap(snapshotData);
        List attendeeUIDs = stream.attendees != null ? stream.attendees!.keys.toList(growable: true) : [];
        //check if user already checked in
        if (attendeeUIDs.contains(uid)) {
          checkedIn = true;
          return checkedIn;
        }

        stream.attendees![uid] = {
          'checkInTime': DateTime.now().millisecondsSinceEpoch,
          'checkOutTime': null,
        };

        await streamsRef.doc(streamID).update({
          'attendees': stream.attendees,
        });

        checkedIn = true;
      }
    }
    return checkedIn;
  }

  Future<bool> checkOutOfStream({required String uid, required String streamID}) async {
    bool checkedOut = false;
    DocumentSnapshot snapshot = await streamsRef.doc(streamID).get().catchError((e) {
      _customDialogService.showErrorDialog(description: "There was an error checking out of this stream. Please try again.");
    });

    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      if (snapshotData.isNotEmpty) {
        WebblenLiveStream stream = WebblenLiveStream.fromMap(snapshotData);
        List attendeeUIDs = stream.attendees != null ? stream.attendees!.keys.toList(growable: true) : [];
        //check if user already checked in
        if (!attendeeUIDs.contains(uid)) {
          checkedOut = true;
          return checkedOut;
        }
        stream.attendees!.remove(uid);
        await streamsRef.doc(streamID).update({
          'attendees': stream.attendees,
        });
        checkedOut = true;
      }
    }

    return checkedOut;
  }

  ///READ & QUERIES
  Future<List<DocumentSnapshot>> loadStreams({
    required String areaCode,
    required int resultsLimit,
    required String tagFilter,
    required String sortBy,
  }) async {
    Query query;
    List<DocumentSnapshot> docs = [];
    if (areaCode.isEmpty) {
      query = streamsRef
          .where('startDateTimeInMilliseconds', isGreaterThan: dateTimeInMilliseconds2hrsAgog)
          .orderBy('startDateTimeInMilliseconds', descending: false)
          .limit(resultsLimit);
    } else {
      query = streamsRef
          .where('nearbyZipcodes', arrayContains: areaCode)
          .where('startDateTimeInMilliseconds', isGreaterThan: dateTimeInMilliseconds2hrsAgog)
          .orderBy('startDateTimeInMilliseconds', descending: false)
          .limit(resultsLimit);
    }
    QuerySnapshot snapshot = await query.get().catchError((e) {
      if (!e.message.contains("insufficient permissions")) {
        print(e.message);
        _dialogService.showDialog(
          title: "Stream Error",
          description: e.message,
        );
      }
    });
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

  Future<List<DocumentSnapshot>> loadAdditionalStreams(
      {required DocumentSnapshot lastDocSnap, required String areaCode, required int resultsLimit, required String tagFilter, required String sortBy}) async {
    Query query;
    List<DocumentSnapshot> docs = [];
    if (areaCode.isEmpty) {
      query = streamsRef
          .where('startDateTimeInMilliseconds', isGreaterThan: dateTimeInMilliseconds2hrsAgog)
          .orderBy('startDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastDocSnap)
          .limit(resultsLimit);
    } else {
      query = streamsRef
          .where('nearbyZipcodes', arrayContains: areaCode)
          .where('startDateTimeInMilliseconds', isGreaterThan: dateTimeInMilliseconds2hrsAgog)
          .orderBy('startDateTimeInMilliseconds', descending: false)
          .startAfterDocument(lastDocSnap)
          .limit(resultsLimit);
    }
    QuerySnapshot snapshot = await query.get().catchError((e) {
      if (!e.message.contains("insufficient permissions")) {
        print(e.message);
        _dialogService.showDialog(
          title: "Stream Error",
          description: e.message,
        );
      }
    });
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

  Future<List<DocumentSnapshot>> loadStreamsByUserID({required String? id, required int resultsLimit}) async {
    List<DocumentSnapshot> docs = [];
    Query query = streamsRef.where('hostID', isEqualTo: id).orderBy('startDateTimeInMilliseconds', descending: true).limit(resultsLimit);
    QuerySnapshot snapshot = await query.get().catchError((e) {
      if (!e.message.contains("insufficient permissions")) {
        print(e.message);
        _dialogService.showDialog(
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
    Query query =
        streamsRef.where('hostID', isEqualTo: id).orderBy('startDateTimeInMilliseconds', descending: true).startAfterDocument(lastDocSnap).limit(resultsLimit);
    QuerySnapshot snapshot = await query.get().catchError((e) {
      if (!e.message.contains("insufficient permissions")) {
        print(e.message);
        _dialogService.showDialog(
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

  Future<List<DocumentSnapshot>> loadSavedStreams({required String? id, required int resultsLimit}) async {
    List<DocumentSnapshot> docs = [];
    Query query = streamsRef.where('savedBy', arrayContains: id).orderBy('startDateTimeInMilliseconds', descending: true).limit(resultsLimit);
    QuerySnapshot snapshot = await query.get().catchError((e) {
      if (!e.message.contains("insufficient permissions")) {
        print(e.message);
        _dialogService.showDialog(
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
        _dialogService.showDialog(
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
