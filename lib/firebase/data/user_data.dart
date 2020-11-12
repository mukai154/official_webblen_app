import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:webblen/firebase/services/file_upload.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/location/location_service.dart';

class WebblenUserData {
  final CollectionReference userRef = FirebaseFirestore.instance.collection("webblen_user");
  final CollectionReference stripeRef = FirebaseFirestore.instance.collection("stripe");
  final CollectionReference eventRef = FirebaseFirestore.instance.collection("events");
  final CollectionReference notifRef = FirebaseFirestore.instance.collection("user_notifications");
  final Reference storageReference = FirebaseStorage.instance.ref();

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
    Reference storageReference = FirebaseStorage.instance.ref();
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

  Future<bool> checkIfUserOnboarded(String uid) async {
    DocumentSnapshot docSnapshot = await userRef.doc(uid).get();
    Map<dynamic, dynamic> data = docSnapshot.data() == null ? {} : docSnapshot.data();
    if (data['onboarded'] == null || data['onboarded'] == false) {
      return false;
    } else {
      return true;
    }
  }

  Stream<WebblenUser> streamCurrentUser(String uid) {
    return userRef.doc(uid).snapshots().map((snapshot) => WebblenUser.fromMap(Map<String, dynamic>.from(snapshot.data()['d'])));
  }

  Stream<Map<String, dynamic>> streamStripeAccount(String uid) {
    return stripeRef.doc(uid).snapshots().map((snapshot) => snapshot.data());
  }

  Future<bool> isAdmin(String uid) async {
    bool isAdmin = false;
    DocumentSnapshot docSnapshot = await userRef.doc(uid).get();
    if (docSnapshot.exists) {
      Map<String, dynamic> docData = docSnapshot.data();
      isAdmin = docData['isAdmin'] == null ? false : docData['isAdmin'];
    }
    return isAdmin;
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

  Future<double> getWebblenWalletTotal(String uid) async {
    double webblen = 0.001;
    DocumentSnapshot docSnapshot = await userRef.doc(uid).get();
    if (docSnapshot.exists) {
      Map<String, dynamic> docData = docSnapshot.data();
      webblen = docData['d']['eventPoints'];
    }
    return webblen;
  }

  Future<List> getInterests(String uid) async {
    List interests = [];
    DocumentSnapshot docSnapshot = await userRef.doc(uid).get();
    if (docSnapshot.exists) {
      Map<String, dynamic> docData = docSnapshot.data();
      interests = docData['tags'] == null ? [] : docData['tags'];
    }
    return interests;
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

  Future<bool> displayDepositAnimation(String uid) async {
    bool displayAnimation = false;
    DocumentSnapshot snapshot = await userRef.doc(uid).get();
    if (snapshot.exists) {
      Map<String, dynamic> docData = snapshot.data();
      if (docData['canDisplayDepositAnimation'] == null || docData['canDisplayDepositAnimation'] == true) {
        displayAnimation = true;
      }
    }
    return displayAnimation;
  }

  Future<double> depositAnimationValue(String uid) async {
    double val = 0.01;
    QuerySnapshot query =
        await notifRef.where('uid', isEqualTo: uid).where('notificationType', isEqualTo: 'deposit').where('notificationSeen', isEqualTo: false).get();
    query.docs.forEach((doc) {
      String notifData = doc.data()['notificationData'];
      if (notifData.isNotEmpty) {
        try {
          val += double.parse(notifData);
        } catch (e) {
          print('invalid val');
        }
      }
    });
    await userRef.doc(uid).update({"canDisplayDepositAnimation": false}).catchError((e) {});
    return val;
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

  Future<List<WebblenUser>> getFollowerSuggestions(String uid, String zipcode, List tags) async {
    List<String> tagFilter = List<String>.from(tags);
    List<WebblenUser> users = [];
    QuerySnapshot snapshot = await userRef.where("nearbyZipcodes", arrayContains: zipcode).where("tags", arrayContainsAny: tagFilter).get().catchError((e) {
      //print(e);
    });
    if (snapshot.docs.length == null || snapshot.docs.length < 10) {
      snapshot = await userRef.where("nearbyZipcodes", arrayContains: zipcode).orderBy("appOpenInMilliseconds", descending: true).get().catchError((e) {
        // print(e);
      });
    }
    snapshot.docs.forEach((doc) {
      if (doc.data()['d']['followers'] == null || !doc.data()['d']['followers'].contains(uid)) {
        WebblenUser user = WebblenUser.fromMap(doc.data()['d']);
        if (user.uid != uid) {
          users.add(user);
        }
      }
    });
    return users;
  }

  Future<Null> updateOnboardStatus(String uid, List tags) async {
    await userRef.doc(uid).update({"tags": tags});
    await userRef.doc(uid).update({"canDisplayDepositAnimation": false});
    await userRef.doc(uid).update({"onboarded": true});
  }

  Future<String> updateInterests(String uid, List tags) async {
    String error;
    await userRef.doc(uid).update({"tags": tags}).catchError((e) {
      error = e.details;
    });
    return error;
  }

  Future<String> updateFollowing(String currentUID, String userUID, List currentUserFollowingList, List userFollowerList) async {
    String error;
    await userRef.doc(currentUID).update({"d.following": currentUserFollowingList});
    await userRef.doc(userUID).update({"d.followers": userFollowerList});
    return error;
  }

  Future<String> updateFollowingByID(String currentUID, String userUID) async {
    String error;
    DocumentSnapshot currentUserSnapshot = await userRef.doc(currentUID).get();
    List following = currentUserSnapshot.data()['d']['following'] == null ? [] : currentUserSnapshot.data()['d']['following'].toList(growable: true);
    DocumentSnapshot userSnapshot = await userRef.doc(userUID).get();
    List followers = userSnapshot.data()['d']['followers'] == null ? [] : currentUserSnapshot.data()['d']['followers'].toList(growable: true);

    if (following.contains(userUID)) {
      following.remove(userUID);
      followers.remove(currentUID);
    } else {
      following.add(userUID);
      followers.add(currentUID);
    }
    await userRef.doc(currentUID).update({"d.following": following});
    await userRef.doc(userUID).update({"d.followers": followers});

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
    DocumentSnapshot snapshot = await userRef.doc(uid).get();
    List nearbyZipcodes = snapshot.data()['nearbyZipcodes'] == null ? [] : snapshot.data()['nearbyZipcodes'];
    if (!nearbyZipcodes.contains(zipcode)) {
      nearbyZipcodes = await LocationService().findNearestZipcodes(zipcode);
    }
    userRef.doc(uid).update({
      'g': null,
      'l': null,
      'appOpenInMilliseconds': appOpenInMilliseconds,
      'lastSeenZipcode': zipcode,
      'nearbyZipcodes': nearbyZipcodes,
    });
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

  Future<Null> setFBAccessToken(String uid, String fbAccessToken) async {
    userRef.doc(uid).update({"fbAccessToken": fbAccessToken}).whenComplete(() {}).catchError((e) {});
  }

  Future<Null> setAssociatedEmailAddress(String uid, String emailAddress) async {
    userRef.doc(uid).update({"emailAddress": emailAddress}).whenComplete(() {}).catchError((e) {});
  }

  Future<Null> setGoogleAccessTokenAndID(String uid, String googleAccessToken, String googleIDToken) async {
    userRef.doc(uid).update({"googleAccessToken": googleAccessToken, "googleIDToken": googleIDToken}).whenComplete(() {}).catchError((e) {});
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
