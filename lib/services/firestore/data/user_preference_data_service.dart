import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/models/webblen_user_preferences.dart';

class UserPreferenceDataService {
  final CollectionReference prefRef = FirebaseFirestore.instance.collection("webblen_activity");

  bool? notifyNewFollowers;
  bool? notifyMentions;
  bool? notifyEvents;
  bool? notifyPosts;
  bool? notifyStreams;
  bool? notifyContentSaves;
  bool? notifyContentComments;
  bool? notifyAvailableCheckIns;
  bool? displayCreateEventActivity;
  bool? displayCheckInEventActivity;
  bool? displayCreateLiveStreamActivity;
  bool? displayCheckInLiveStreamActivity;
  bool? displayCreatePostActivity;
  bool? displayCommentPostActivity;

  Future<WebblenUserPreferences> getExistingPreferences({required String id}) async {
    WebblenUserPreferences preferences;
    DocumentSnapshot snapshot = await prefRef.doc(id).get();

    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      preferences = WebblenUserPreferences.fromMap(snapshotData);
    } else {
      preferences = WebblenUserPreferences().generateNewPreferences(id: id);
    }
    return preferences;
  }

  setNotifyNewFollowers({required String id, required bool val}) async {
    WebblenUserPreferences preferences = await getExistingPreferences(id: id);
    preferences.notifyNewFollowers = val;
    prefRef.doc(id).set(preferences.toMap());
  }

  setNotifyMentions({required String id, required bool val}) async {
    WebblenUserPreferences preferences = await getExistingPreferences(id: id);
    preferences.notifyMentions = val;
    prefRef.doc(id).set(preferences.toMap());
  }

  setNotifyEvents({required String id, required bool val}) async {
    WebblenUserPreferences preferences = await getExistingPreferences(id: id);
    preferences.notifyEvents = val;
    prefRef.doc(id).set(preferences.toMap());
  }

  setNotifyPosts({required String id, required bool val}) async {
    WebblenUserPreferences preferences = await getExistingPreferences(id: id);
    preferences.notifyPosts = val;
    prefRef.doc(id).set(preferences.toMap());
  }

  setNotifyStreams({required String id, required bool val}) async {
    WebblenUserPreferences preferences = await getExistingPreferences(id: id);
    preferences.notifyStreams = val;
    prefRef.doc(id).set(preferences.toMap());
  }

  setNotifyContentSaves({required String id, required bool val}) async {
    WebblenUserPreferences preferences = await getExistingPreferences(id: id);
    preferences.notifyContentSaves = val;
    prefRef.doc(id).set(preferences.toMap());
  }

  setNotifyContentComments({required String id, required bool val}) async {
    WebblenUserPreferences preferences = await getExistingPreferences(id: id);
    preferences.notifyContentComments = val;
    prefRef.doc(id).set(preferences.toMap());
  }

  setNotifyAvailableCheckIns({required String id, required bool val}) async {
    WebblenUserPreferences preferences = await getExistingPreferences(id: id);
    preferences.notifyAvailableCheckIns = val;
    prefRef.doc(id).set(preferences.toMap());
  }

  setDisplayCreateEventActivity({required String id, required bool val}) async {
    WebblenUserPreferences preferences = await getExistingPreferences(id: id);
    preferences.displayCreateEventActivity = val;
    prefRef.doc(id).set(preferences.toMap());
  }

  setDisplayCheckInEventActivity({required String id, required bool val}) async {
    WebblenUserPreferences preferences = await getExistingPreferences(id: id);
    preferences.displayCheckInEventActivity = val;
    prefRef.doc(id).set(preferences.toMap());
  }

  setDisplayCreateLiveStreamActivity({required String id, required bool val}) async {
    WebblenUserPreferences preferences = await getExistingPreferences(id: id);
    preferences.notifyNewFollowers = val;
    prefRef.doc(id).set(preferences.toMap());
  }

  setDisplayCheckInLiveStreamActivity({required String id, required bool val}) async {
    WebblenUserPreferences preferences = await getExistingPreferences(id: id);
    preferences.displayCheckInLiveStreamActivity = val;
    prefRef.doc(id).set(preferences.toMap());
  }

  setDisplayCreatePostActivity({required String id, required bool val}) async {
    WebblenUserPreferences preferences = await getExistingPreferences(id: id);
    preferences.displayCreatePostActivity = val;
    prefRef.doc(id).set(preferences.toMap());
  }

  setDisplayCommentPostActivity({required String id, required bool val}) async {
    WebblenUserPreferences preferences = await getExistingPreferences(id: id);
    preferences.displayCommentPostActivity = val;
    prefRef.doc(id).set(preferences.toMap());
  }
}
