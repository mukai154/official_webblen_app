import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:webblen/models/webblen_activity.dart';

class ActivityDataService {
  final CollectionReference activityRef = FirebaseFirestore.instance.collection("webblen_activity");

  Future createActivity({@required WebblenActivity activity}) async {
    await activityRef.doc(activity.id).set(activity.toMap()).catchError((e) {
      return e.message;
    });
  }

  Future updateEvent({@required WebblenActivity activity}) async {
    await activityRef.doc(activity.id).update(activity.toMap()).catchError((e) {
      return e.message;
    });
  }

  Future deleteEvent({@required WebblenActivity activity}) async {
    await activityRef.doc(activity.id).delete();
  }

  ///READ & QUERIES
  Future<List<DocumentSnapshot>> loadActivity({
    @required String uid,
    @required int resultsLimit,
    @required bool personalActivity,
  }) async {
    Query query;
    List<DocumentSnapshot> docs = [];
    if (personalActivity) {
      query = activityRef.where('uid', isEqualTo: uid).orderBy('timePostedInMilliseconds', descending: true).limit(resultsLimit);
    } else {
      query =
          activityRef.where('uid', isEqualTo: uid).where('isPublic', isEqualTo: true).orderBy('timePostedInMilliseconds', descending: true).limit(resultsLimit);
    }
    QuerySnapshot snapshot = await query.get().catchError((e) {});
    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
    }
    return docs;
  }

  Future<List<DocumentSnapshot>> loadAdditionalActivity({
    @required String uid,
    @required DocumentSnapshot lastDocSnap,
    @required int resultsLimit,
    @required bool personalActivity,
  }) async {
    Query query;
    List<DocumentSnapshot> docs = [];
    if (personalActivity) {
      query =
          activityRef.where('uid', isEqualTo: uid).startAfterDocument(lastDocSnap).orderBy('timePostedInMilliseconds', descending: true).limit(resultsLimit);
    } else {
      query = activityRef
          .where('uid', isEqualTo: uid)
          .where('isPublic', isEqualTo: true)
          .startAfterDocument(lastDocSnap)
          .orderBy('timePostedInMilliseconds', descending: true)
          .limit(resultsLimit);
    }

    QuerySnapshot snapshot = await query.get().catchError((e) {});
    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
    }
    return docs;
  }
}
