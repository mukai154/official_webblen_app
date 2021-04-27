import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/firestore/common/firestore_storage_service.dart';
import 'package:webblen/utils/custom_string_methods.dart';

class UserDataService {
  CollectionReference userRef = FirebaseFirestore.instance.collection('webblen_users');
  CollectionReference postsRef = FirebaseFirestore.instance.collection('posts');
  FirestoreStorageService? _firestoreStorageService = locator<FirestoreStorageService>();
  SnackbarService? _snackbarService = locator<SnackbarService>();

  Future checkIfUserExists(String? id) async {
    bool exists = false;
    DocumentSnapshot snapshot = await userRef.doc(id).get().catchError((e) {
      return e.message;
    });
    if (snapshot.exists) {
      exists = true;
    }
    return exists;
  }

  Future createWebblenUser(WebblenUser user) async {
    await userRef.doc(user.id).set(user.toMap()).catchError((e) {
      return e.message;
    });
  }

  Future<WebblenUser?> getWebblenUserByID(String? id) async {
    WebblenUser? user;
    DocumentSnapshot snapshot = await userRef.doc(id).get().catchError((e) {
      // _snackbarService.showSnackbar(
      //   title: 'Unknown Error',
      //   message: e.message,
      //   duration: Duration(seconds: 5),
      // );
      return null;
    });
    if (snapshot != null && snapshot.exists) {
      user = WebblenUser.fromMap(snapshot.data()!);
    }
    return user;
  }

  Future<WebblenUser?> getWebblenUserByUsername(String username) async {
    WebblenUser? user;
    QuerySnapshot querySnapshot = await userRef.where("username", isEqualTo: username).get().catchError((e) {
      //print(e.message)
      return null;
    });
    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot doc = querySnapshot.docs.first;
      Map<String, dynamic> docData = doc.data()!;
      user = WebblenUser.fromMap(docData);
    }
    return user;
  }

  Future<bool> updateWebblenUser(WebblenUser user) async {
    await userRef.doc(user.id).update(user.toMap()).catchError((e) {
      _snackbarService!.showSnackbar(
        title: 'Account Update Error',
        message: e.message,
        duration: Duration(seconds: 5),
      );
      return false;
    });
    return true;
  }

  Future<bool> updateProfilePic(String id, File img) async {
    String imgURL = await _firestoreStorageService!.uploadImage(
      img: img,
      storageBucket: 'webblen_users',
      folderName: id,
      fileName: getRandomString(10) + ".png",
    );
    await userRef.doc(id).update({
      "profilePicURL": imgURL,
    }).catchError((e) {
      _snackbarService!.showSnackbar(
        title: 'Photo Upload Error',
        message: e.message,
        duration: Duration(seconds: 5),
      );
      return false;
    });
    return true;
  }

  Future<bool> updateBio({String? id, String? bio}) async {
    await userRef.doc(id).update({
      "bio": bio,
    }).catchError((e) {
      _snackbarService!.showSnackbar(
        title: 'Error',
        message: 'There was an issue updating your profile. Please try again.',
        duration: Duration(seconds: 3),
      );
      return false;
    });
    return true;
  }

  Future<bool> updateWebsite({String? id, String? website}) async {
    await userRef.doc(id).update({
      "website": website,
    }).catchError((e) {
      _snackbarService!.showSnackbar(
        title: 'Error',
        message: 'There was an issue updating your profile. Please try again.',
        duration: Duration(seconds: 3),
      );
      return false;
    });
    return true;
  }

  Future<bool> updateLastSeenZipcode({String? id, String? zip}) async {
    await userRef.doc(id).update({
      "lastSeenZipcode": zip,
    }).catchError((e) {
      _snackbarService!.showSnackbar(
        title: 'Error',
        message: 'There was an issue updating your profile. Please try again.',
        duration: Duration(seconds: 3),
      );
      return false;
    });
    return true;
  }

  Future<bool> followUser(String? currentUID, String? targetUserID) async {
    DocumentSnapshot currentUserSnapshot = await userRef.doc(currentUID).get();
    DocumentSnapshot targetUserSnapshot = await userRef.doc(targetUserID).get();
    Map<String, dynamic> currentUserData = currentUserSnapshot.data()!;
    Map<String, dynamic> targetUserData = targetUserSnapshot.data()!;
    List currentUserFollowing = currentUserData['following'];
    List targetUserFollowers = targetUserData['followers'];
    if (!currentUserFollowing.contains(targetUserID)) {
      currentUserFollowing.add(targetUserID);
      await userRef.doc(currentUID).update({'following': currentUserFollowing}).catchError((e) {
        print(e);
        return false;
      });
    }
    if (!targetUserFollowers.contains(currentUID)) {
      targetUserFollowers.add(currentUID);
      await userRef.doc(targetUserID).update({'followers': targetUserFollowers}).catchError((e) {
        print(e);
        return false;
      });
    }

    //follow posts by user
    QuerySnapshot postQuery = await postsRef.where('authorID', isEqualTo: targetUserID).get();
    postQuery.docs.forEach((doc) {
      List followers = doc.data()['followers'].toList(growable: true);
      if (!followers.contains(currentUID)) {
        followers.add(currentUID);
        postsRef.doc(doc.id).update({'followers': followers}).catchError((e) {
          print(e);
          return false;
        });
      }
    });
    return true;
  }

  Future<bool> unFollowUser(String? currentUID, String? targetUserID) async {
    DocumentSnapshot currentUserSnapshot = await userRef.doc(currentUID).get();
    DocumentSnapshot targetUserSnapshot = await userRef.doc(targetUserID).get();
    Map<String, dynamic> currentUserData = currentUserSnapshot.data()!;
    Map<String, dynamic> targetUserData = targetUserSnapshot.data()!;
    List currentUserFollowing = currentUserData['following'].toList(growable: true);
    List targetUserFollowers = targetUserData['followers'].toList(growable: true);
    if (currentUserFollowing.contains(targetUserID)) {
      currentUserFollowing.remove(targetUserID);
      await userRef.doc(currentUID).update({'following': currentUserFollowing}).catchError((e) {
        print(e);
        return false;
      });
    }
    if (targetUserFollowers.contains(currentUID)) {
      targetUserFollowers.remove(currentUID);
      await userRef.doc(targetUserID).update({'followers': targetUserFollowers}).catchError((e) {
        print(e);
        return false;
      });
    }
    QuerySnapshot postQuery = await postsRef.where('authorID', isEqualTo: targetUserID).get().catchError((e) {
      print(e);
      return false;
    });
    postQuery.docs.forEach((doc) {
      List followers = doc.data()['followers'].toList(growable: true);
      if (followers.contains(currentUID)) {
        followers.remove(currentUID);
        postsRef.doc(doc.id).update({'followers': followers}).catchError((e) {
          print(e);
        });
      }
    });
    return true;
  }

  Future<bool> depositWebblen({String? uid, required double amount}) async {
    //String error;
    DocumentSnapshot snapshot = await userRef.doc(uid).get();
    WebblenUser user = WebblenUser.fromMap(snapshot.data()!);
    double initialBalance = user.WBLN == null ? 0.00001 : user.WBLN!;
    double newBalance = amount + initialBalance;
    await userRef.doc(uid).update({"WBLN": newBalance}).catchError((e) {
      print(e.message);
      //error = e.toString();
    });
    return true;
  }

  Future<bool> withdrawWebblen({String? uid, required double amount}) async {
    //String error;

    DocumentSnapshot snapshot = await userRef.doc(uid).get();
    WebblenUser user = WebblenUser.fromMap(snapshot.data()!);
    double initialBalance = user.WBLN == null ? 0.00001 : user.WBLN!;
    double newBalance = initialBalance - amount;

    await userRef.doc(uid).update({"WBLN": newBalance}).catchError((e) {
      print(e.message);
      //error = e.toString();
    });
    return true;
  }

  ///QUERIES
  Future<List<DocumentSnapshot>> loadUserFollowers({required String? id, required int resultsLimit}) async {
    List<DocumentSnapshot> docs = [];
    Query query = userRef.where('following', arrayContains: id).orderBy('username', descending: false).limit(resultsLimit);
    QuerySnapshot snapshot = await query.get().catchError((e) {
      if (!e.message.contains("insufficient permissions")) {
        _snackbarService!.showSnackbar(
          title: 'Error',
          message: e.message,
          duration: Duration(seconds: 5),
        );
      }
      return [];
    });
    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
    }
    return docs;
  }

  Future<List<DocumentSnapshot>> loadAdditionalUserFollowers({
    required String? id,
    required DocumentSnapshot lastDocSnap,
    required int resultsLimit,
  }) async {
    List<DocumentSnapshot> docs = [];
    Query query = userRef.where('following', isEqualTo: id).orderBy('username', descending: false).startAfterDocument(lastDocSnap).limit(resultsLimit);
    QuerySnapshot snapshot = await query.get().catchError((e) {
      if (!e.message.contains("insufficient permissions")) {
        _snackbarService!.showSnackbar(
          title: 'Error',
          message: e.message,
          duration: Duration(seconds: 5),
        );
      }
      return [];
    });
    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
    }
    return docs;
  }

  Future<List<DocumentSnapshot>> loadUserFollowing({required String? id, required int resultsLimit}) async {
    List<DocumentSnapshot> docs = [];
    Query query = userRef.where('followers', arrayContains: id).orderBy('username', descending: false).limit(resultsLimit);
    QuerySnapshot snapshot = await query.get().catchError((e) {
      if (!e.message.contains("insufficient permissions")) {
        _snackbarService!.showSnackbar(
          title: 'Error',
          message: e.message,
          duration: Duration(seconds: 5),
        );
      }
      return [];
    });
    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
    }
    return docs;
  }

  Future<List<DocumentSnapshot>> loadAdditionalUserFollowing({
    required String? id,
    required DocumentSnapshot lastDocSnap,
    required int resultsLimit,
  }) async {
    List<DocumentSnapshot> docs = [];
    Query query = userRef.where('followers', isEqualTo: id).orderBy('username', descending: false).startAfterDocument(lastDocSnap).limit(resultsLimit);
    QuerySnapshot snapshot = await query.get().catchError((e) {
      if (!e.message.contains("insufficient permissions")) {
        _snackbarService!.showSnackbar(
          title: 'Error',
          message: e.message,
          duration: Duration(seconds: 5),
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
