import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/firestore/common/firestore_storage_service.dart';

import 'notification_data_service.dart';

class UserDataService {
  CollectionReference userRef = FirebaseFirestore.instance.collection('webblen_users');
  CollectionReference postsRef = FirebaseFirestore.instance.collection('posts');
  FirestoreStorageService? _firestoreStorageService = locator<FirestoreStorageService>();
  SnackbarService? _snackbarService = locator<SnackbarService>();
  CustomDialogService _customDialogService = locator<CustomDialogService>();
  NotificationDataService _notificationDataService = locator<NotificationDataService>();

  Future<bool> checkIfCurrentUserIsAdmin(String id) async {
    bool isAdmin = false;
    String? error;
    DocumentSnapshot snapshot = await userRef.doc(id).get().catchError((e) {
      error = e.message;
      print(error);
    });
    if (error != null) {
      return false;
    }
    if (snapshot.exists) {
      WebblenUser user = WebblenUser.fromMap(snapshot.data()!);
      if (user.isAdmin != null && user.isAdmin!) {
        isAdmin = true;
      }
    }
    return isAdmin;
  }

  Future<bool?> checkIfUserExists(String? id) async {
    bool exists = false;
    String? error;
    DocumentSnapshot snapshot = await userRef.doc(id).get().catchError((e) {
      print(e.message);
      error = e.message;
    });
    if (error != null) {
      return null;
    }
    if (snapshot.exists) {
      exists = true;
    }
    return exists;
  }

  Future<bool> checkIfUsernameExists(String username) async {
    bool usernameExists = false;
    QuerySnapshot snapshot = await userRef.where("username", isEqualTo: username).get();
    if (snapshot.docs.isNotEmpty) {
      usernameExists = true;
    }
    return usernameExists;
  }

  Future createWebblenUser(WebblenUser user) async {
    await userRef.doc(user.id).set(user.toMap()).catchError((e) {
      return e.message;
    });
  }

  FutureOr<WebblenUser> getWebblenUserByID(String? id) async {
    WebblenUser user = WebblenUser();
    String? error;
    DocumentSnapshot snapshot = await userRef.doc(id).get().catchError((e) {
      error = e.message;
    });
    if (error != null) {
      return user;
    }
    if (snapshot.exists) {
      user = WebblenUser.fromMap(snapshot.data()!);
    }
    return user;
  }

  Future<WebblenUser> getWebblenUserByUsername(String username) async {
    WebblenUser user = WebblenUser();
    String? error;
    QuerySnapshot querySnapshot = await userRef.where("username", isEqualTo: username).get().catchError((e) {
      //print(e.message)
      error = e.message;
    });
    if (error != null) {
      _customDialogService.showErrorDialog(description: error!);
      return user;
    }
    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot doc = querySnapshot.docs.first;
      Map<String, dynamic> docData = doc.data()!;
      user = WebblenUser.fromMap(docData);
    }
    return user;
  }

  Future<bool> updateUserDeviceToken({String? id, String? messageToken}) async {
    bool updated = true;
    String? error;
    await userRef.doc(id).update({
      "messageToken": messageToken,
    }).catchError((e) {
      error = e.message;
    });
    if (error != null) {
      updated = false;
    }
    return updated;
  }

  Future<bool> updateWebblenUser(WebblenUser user) async {
    bool updated = true;
    String? error;
    await userRef.doc(user.id).update(user.toMap()).catchError((e) {
      error = e.message;
    });
    if (error != null) {
      updated = false;
    }
    return updated;
  }

  Future<bool> updateProfilePicURL({required String id, required String url}) async {
    bool updated = true;
    String? error;
    await userRef.doc(id).update({
      "profilePicURL": url,
    }).catchError((e) {
      error = e.message;
    });
    if (error != null) {
      updated = false;
    }
    return updated;
  }

  Future<bool> updateUsername({required String username, required String id}) async {
    bool updated = true;
    String? error;
    bool usernameExists = await checkIfUsernameExists(username);
    if (usernameExists) {
      _customDialogService.showErrorDialog(description: "Username already exists, please choose another.");
      updated = false;
    } else if (username.startsWith("user")) {
      _customDialogService.showErrorDialog(description: "invalid username");
      updated = false;
    } else {
      await userRef.doc(id).update({
        "username": username,
      }).catchError((e) {
        error = e.message;
      });
      if (error != null) {
        updated = false;
      }
    }

    return updated;
  }

  Future<bool> updateBio({String? id, String? bio}) async {
    bool updated = true;
    String? error;
    await userRef.doc(id).update({
      "bio": bio,
    }).catchError((e) {
      error = e.message;
    });
    if (error != null) {
      updated = false;
    }
    return updated;
  }

  Future<bool> updateWebsite({String? id, String? website}) async {
    bool updated = true;
    String? error;
    await userRef.doc(id).update({
      "website": website,
    }).catchError((e) {
      error = e.message;
    });
    if (error != null) {
      updated = false;
    }
    return updated;
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
    bool didFollow = true;
    DocumentSnapshot currentUserSnapshot = await userRef.doc(currentUID).get();
    DocumentSnapshot targetUserSnapshot = await userRef.doc(targetUserID).get();
    Map<String, dynamic> currentUserData = currentUserSnapshot.data()!;
    Map<String, dynamic> targetUserData = targetUserSnapshot.data()!;
    List currentUserFollowing = currentUserData['following'] == null ? [] : currentUserData['following'].toList(growable: true);
    List targetUserFollowers = targetUserData['followers'] == null ? [] : targetUserData['followers'].toList(growable: true);
    if (!currentUserFollowing.contains(targetUserID)) {
      currentUserFollowing.add(targetUserID);
      await userRef.doc(currentUID).update({'following': currentUserFollowing}).catchError((e) {
        print(e);
        didFollow = false;
      });
    }
    if (!targetUserFollowers.contains(currentUID)) {
      targetUserFollowers.add(currentUID);
      await userRef.doc(targetUserID).update({'followers': targetUserFollowers}).catchError((e) {
        print(e);
        didFollow = false;
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
          didFollow = false;
        });
      }
    });
    return didFollow;
  }

  Future<bool> unFollowUser(String? currentUID, String? targetUserID) async {
    DocumentSnapshot currentUserSnapshot = await userRef.doc(currentUID).get();
    DocumentSnapshot targetUserSnapshot = await userRef.doc(targetUserID).get();
    Map<String, dynamic> currentUserData = currentUserSnapshot.data()!;
    Map<String, dynamic> targetUserData = targetUserSnapshot.data()!;
    List currentUserFollowing = currentUserData['following'] == null ? [] : currentUserData['following'].toList(growable: true);
    List targetUserFollowers = targetUserData['followers'] == null ? [] : targetUserData['followers'].toList(growable: true);
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

  Future<bool> muteUser(String? currentUID, String? targetUserID) async {
    bool didMute = true;
    DocumentSnapshot targetUserSnapshot = await userRef.doc(targetUserID).get();
    Map<String, dynamic> targetUserData = targetUserSnapshot.data()!;
    List mutedByList = targetUserData['mutedBy'] == null ? [] : targetUserData['mutedBy'].toList(growable: true);
    if (!mutedByList.contains(currentUID)) {
      mutedByList.add(currentUID);
      await userRef.doc(targetUserID).update({'mutedBy': mutedByList}).catchError((e) {
        print(e);
        didMute = false;
      });
    }
    return didMute;
  }

  Future<bool> unMuteUser(String? currentUID, String? targetUserID) async {
    bool didUnMute = true;
    DocumentSnapshot targetUserSnapshot = await userRef.doc(targetUserID).get();
    Map<String, dynamic> targetUserData = targetUserSnapshot.data()!;
    List mutedByList = targetUserData['mutedBy'] == null ? [] : targetUserData['mutedBy'].toList(growable: true);
    if (mutedByList.contains(currentUID)) {
      mutedByList.remove(currentUID);
      await userRef.doc(targetUserID).update({'mutedBy': mutedByList}).catchError((e) {
        print(e);
        didUnMute = false;
      });
    }
    return didUnMute;
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
