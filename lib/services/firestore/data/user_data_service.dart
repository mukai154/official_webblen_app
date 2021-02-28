import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/firestore/common/firestore_storage_service.dart';
import 'package:webblen/utils/custom_string_methods.dart';

class UserDataService {
  CollectionReference userRef = FirebaseFirestore.instance.collection('webblen_users');
  FirestoreStorageService _firestoreStorageService = locator<FirestoreStorageService>();
  SnackbarService _snackbarService = locator<SnackbarService>();

  Future checkIfUserExists(String id) async {
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

  Future getWebblenUserByID(String id) async {
    WebblenUser user;
    DocumentSnapshot snapshot = await userRef.doc(id).get().catchError((e) {
      return e.message;
    });
    if (snapshot.exists) {
      user = WebblenUser.fromMap(snapshot.data());
    }
    return user;
  }

  Future getWebblenUserByUsername(String username) async {
    WebblenUser user;
    QuerySnapshot querySnapshot = await userRef.where("username", isEqualTo: username).get();
    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot doc = querySnapshot.docs.first;
      Map<String, dynamic> docData = doc.data();
      user = WebblenUser.fromMap(docData);
    }
    return user;
  }

  Future updateWebblenUser(WebblenUser user) async {
    await userRef.doc(user.id).update(user.toMap()).catchError((e) {
      return e.message;
    });
  }

  Future updateProfilePic(String id, File img) async {
    String imgURL = await _firestoreStorageService.uploadImage(
      img: img,
      storageBucket: 'webblen_users',
      folderName: id,
      fileName: getRandomString(10) + ".png",
    );
    await userRef.doc(id).update({
      "profilePicURL": imgURL,
    }).catchError((e) {
      return e.message;
    });
  }

  Future<bool> updateBio({String id, String bio}) async {
    bool updated = true;
    await userRef.doc(id).update({
      "bio": bio,
    }).catchError((e) {
      updated = false;
      _snackbarService.showSnackbar(
        title: 'Error',
        message: 'There was an issue updating your profile. Please try again.',
        duration: Duration(seconds: 3),
      );
      return updated;
    });
    return updated;
  }

  Future<bool> updateWebsite({String id, String website}) async {
    bool updated = true;
    await userRef.doc(id).update({
      "website": website,
    }).catchError((e) {
      updated = false;
      _snackbarService.showSnackbar(
        title: 'Error',
        message: 'There was an issue updating your profile. Please try again.',
        duration: Duration(seconds: 3),
      );
      return updated;
    });
    return updated;
  }
}
