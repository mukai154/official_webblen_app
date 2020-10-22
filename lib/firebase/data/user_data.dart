import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:webblen/firebase/services/file_upload.dart';
import 'package:webblen/models/webblen_user.dart';

class WebblenUserData {
  final CollectionReference userRef = FirebaseFirestore.instance.collection("webblen_user");
  final CollectionReference stripeRef = FirebaseFirestore.instance.collection("stripe");
  final CollectionReference eventRef = FirebaseFirestore.instance.collection("events");
  final CollectionReference notifRef = FirebaseFirestore.instance.collection("user_notifications");
  final StorageReference storageReference = FirebaseStorage.instance.ref();

  Future<bool> canUploadVideo(String uid) async {
    bool canUploadVideo = false;
    DocumentSnapshot snapshot = await userRef.doc(uid).get();
    if (snapshot.data()['canUploadVideo'] != null && snapshot.data()['canUploadVideo']) {
      canUploadVideo = true;
    }
    return canUploadVideo;
  }

  Future<bool> canUploadVideoAndIsAdmin(String uid) async {
    bool canUploadVideoAndIsAdmin = false;
    DocumentSnapshot snapshot = await userRef.doc(uid).get();
    if (snapshot.data()['canUploadVideo'] != null && snapshot.data()['canUploadVideo'] && snapshot.data()['isAdmin'] != null && snapshot.data()['isAdmin']) {
      canUploadVideoAndIsAdmin = true;
    }
    return canUploadVideoAndIsAdmin;
  }

  Future<bool> createNewUser(File userImage, WebblenUser user, String uid) async {
    bool success = true;
    StorageReference storageReference = FirebaseStorage.instance.ref();
    String fileName = "$uid.jpg";
    storageReference.child("profile_pics").child(fileName).putFile(userImage);
    String downloadUrl = await FileUploader().uploadProfilePic(
      userImage,
      fileName,
    );
    user.profile_pic = downloadUrl.toString();
    //GeoPoint geoPoint = GeoFirePoint(0, 0).geoPoint;
    await FirebaseFirestore.instance
        .collection("webblen_user")
        .doc(uid)
        .set({
          'appOpenInMilliseconds': DateTime.now().millisecondsSinceEpoch,
          'd': user.toMap(),
          'g': '',
          'l': null,
          'lastAPRechargeInMilliseconds': DateTime.now().millisecondsSinceEpoch
        })
        .whenComplete(() {})
        .catchError((e) {
          success = false;
        });
    return success;
  }

  Future<bool> checkIfUserExists(String uid) async {
    DocumentSnapshot docSnapshot = await userRef.doc(uid).get();
    if (docSnapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  Stream<WebblenUser> streamCurrentUser(String uid) {
    return userRef.doc(uid).snapshots().map((snapshot) => WebblenUser.fromMap(Map<String, dynamic>.from(snapshot.data()['d'])));
  }

  Stream<Map<String, dynamic>> streamStripeAccount(String uid) {
    return stripeRef.doc(uid).snapshots().map((snapshot) => snapshot.data());
  }

  Future<WebblenUser> getUserByID(String uid) async {
    WebblenUser user;
    DocumentSnapshot docSnapshot = await userRef.doc(uid).get();
    if (docSnapshot.exists) {
      Map<String, dynamic> docData = docSnapshot.data();
      user = WebblenUser.fromMap(Map<String, dynamic>.from(docData['d']));
    }
    return user;
  }

  Future<String> getUserImgByID(String uid) async {
    String userImgURL;
    DocumentSnapshot docSnapshot = await userRef.doc(uid).get();
    if (docSnapshot.exists) {
      Map<String, dynamic> docData = docSnapshot.data();
      userImgURL = docData['d']['profile_pic'];
    }
    return userImgURL;
  }

  Future<String> getUsername(String uid) async {
    String userImgURL;
    DocumentSnapshot docSnapshot = await userRef.doc(uid).get();
    if (docSnapshot.exists) {
      Map<String, dynamic> docData = docSnapshot.data();
      userImgURL = docData['d']['username'];
    }
    return userImgURL;
  }

  Future<String> getStripeUID(String uid) async {
    String stripeUID;
    DocumentSnapshot docSnapshot = await stripeRef.doc(uid).get();
    if (docSnapshot.exists) {
      Map<String, dynamic> docData = docSnapshot.data();
      stripeUID = docData['stripeUID'];
    }
    return stripeUID;
  }

  Future<bool> userAccountIsSetup(String uid) async {
    bool accountIsSetup = false;
    DocumentSnapshot snapshot = await userRef.doc(uid).get();
    if (snapshot.exists) {
      accountIsSetup = true;
    }
    return accountIsSetup;
  }

  Future<bool> checkIfUserCanSellTickets(String uid) async {
    bool canSellTickets = false;
    DocumentSnapshot docSnapshot = await stripeRef.doc(uid).get();
    if (docSnapshot.exists) {
      Map<String, dynamic> docData = docSnapshot.data();
      if (docData['stripeUID'] != null && docData['verified'] == "verified") {
        canSellTickets = true;
      }
    }
    return canSellTickets;
  }

  Future<bool> checkIfUsernameExists(String username) async {
    bool usernameExists = false;
    QuerySnapshot snapshot = await userRef.where("d.username", isEqualTo: username).get();
    if (snapshot.docs.isNotEmpty) {
      usernameExists = true;
    }
    return usernameExists;
  }

  Future<List> getFollowingList(String uid) async {
    List followingList;
    DocumentSnapshot docSnapshot = await userRef.doc(uid).get();
    if (docSnapshot.exists) {
      Map<String, dynamic> docData = docSnapshot.data();
      WebblenUser user = WebblenUser.fromMap(Map<String, dynamic>.from(docData['d']));
      followingList = user.following;
    }
    return followingList;
  }

  Future<String> updateFollowing(String currentUID, String userUID, List currentUserFollowingList, List userFollowerList) async {
    String error;
    await userRef.doc(currentUID).update({"d.following": currentUserFollowingList});
    await userRef.doc(userUID).update({"d.followers": userFollowerList});
    return error;
  }

  Future<String> depositWebblen(double depositAmount, String uid) async {
    String error;
    DocumentSnapshot snapshot = await userRef.doc(uid).get();
    WebblenUser user = WebblenUser.fromMap(snapshot.data()['d']);
    double initialBalance = user.eventPoints == null ? 0.00001 : user.eventPoints;
    double newBalance = depositAmount + initialBalance;
    await userRef.doc(uid).update({"d.eventPoints": newBalance}).catchError((e) {
      error = e.toString();
    });
    return error;
  }

  Future<Null> updateUserAppOpen(String uid, String zipcode, double lat, double lon) async {
    int appOpenInMilliseconds = DateTime.now().millisecondsSinceEpoch;
    //GeoFirePoint geoFirePoint = GeoFirePoint(lat, lon);
    userRef.doc(uid).update({'g': null, 'l': null, 'appOpenInMilliseconds': appOpenInMilliseconds, 'lastSeenZipcode': zipcode});
  }

  Future<Null> setGoogleTokens(String uid, String idToken, String accessToken) async {
    return userRef.doc(uid).update({'googleIDToken': idToken, 'googleAccessToken': accessToken});
  }

  Future<String> setUserCloudMessageToken(String uid, String messageToken) async {
    String status = "";
    userRef.doc(uid).update({"d.messageToken": messageToken}).whenComplete(() {}).catchError((e) {
          status = e.details;
        });
    return status;
  }

  Future<String> updateUserProfilePic(String uid, String downloadUrl) async {
    String error;
    userRef.doc(uid).update({"d.profile_pic": downloadUrl}).whenComplete(() {}).catchError((e) {
          error = e.details;
        });
    return error;
  }

  Future<Null> updateNotificationPermission(String uid, String notif, bool status) async {
    userRef.doc(uid).update({notif: status}).whenComplete(() {}).catchError((e) {});
  }

  // Future<Null> updateUserField() async {
  //   userRef.get().then((res) {
  //     res.docs.forEach((doc) async {
  //       await userRef.doc(doc.id).update(({
  //             'd.webblen': 1.001,
  //             'd.impactPoints': 1.001,
  //           }));
  //     });
  //   });
  // }

//  Future<String> updateUserImg(File userImgFile, String uid) async {
//    String error = "";
//    String userImgURL = await ImageUploadService().uploadImageToFirebaseStorage(userImgFile, UserImgFile, uid);
//    if (userImgFile != null) {
//      await userRef.doc(uid).updateData({'d.profile_pic': userImgURL}).whenComplete(() {}).catchError((e) {
//            error = e.toString();
//          });
//    } else {
//      error = "There was an Issue Uploading Your Image, Please Try Again.";
//    }
//    return error;
//  }

//  Future<String> completeAccountSetup(File userImgFile, String uid, String username) async {
//    String error = "";
//    bool usernameExists = await checkIfUsernameExists(username.toLowerCase());
//    if (!usernameExists) {
//      String userImgURL = await ImageUploadService().uploadImageToFirebaseStorage(userImgFile, UserImgFile, uid);
//      print(userImgURL);
//      if (userImgURL != null) {
//        WebblenUser newUser = WebblenUser(
//          uid: uid,
//          username: username.toLowerCase(),
//          messageToken: "",
//          profile_pic: userImgURL,
//          savedEvents: [],
//          //tags: [],
//          friends: [],
//          blockedUsers: [],
//          eventPoints: 0.001,
//          ap: 1.01,
//          apLvl: 1,
//          eventsToLvlUp: 20,
//          lastCheckInTimeInMilliseconds: 1584468891299,
//          lastNotifInMilliseconds: 1584468891299,
//          lastPayoutTimeInMilliseconds: 1584468891299,
//          canMakeAds: false,
//          //isAdmin: false,
//        );
//        await userRef.doc(uid).set({'d': newUser.toMap(), 'g': null, 'l': null}).whenComplete(() {}).catchError((e) {
//              error = e.toString();
//            });
//      } else {
//        error = "There was an Issue Setting Up Your Account. Please Try Again.";
//      }
//    } else {
//      error = "Username Unavailable";
//    }
//    return error;
//  }
}
