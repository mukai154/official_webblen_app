import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:webblen/models/webblen_user.dart';

class UserDataService {
  //Geoflutterfire geo = Geoflutterfire();
  final CollectionReference userRef = FirebaseFirestore.instance.collection("webblen_user");
  final CollectionReference eventRef = FirebaseFirestore.instance.collection("events");
  final CollectionReference notifRef = FirebaseFirestore.instance.collection("user_notifications");

  final StorageReference storageReference = FirebaseStorage.instance.ref();
  final double degreeMinMax = 0.145;

  Future<bool> checkAdminStatus(String uid) async {
    bool isAdmin = false;
    DocumentSnapshot comDoc = await userRef.doc(uid).get();
    if (comDoc.exists) {
      if (comDoc.data()['isAdmin'] != null) {
        isAdmin = comDoc.data()['isAdmin'];
      }
    }
    return isAdmin;
  }

  //***CREATE
  Stream<WebblenUser> streamCurrentUser(String uid) {
    return userRef.doc(uid).snapshots().map((snapshot) => WebblenUser.fromMap(Map<String, dynamic>.from(snapshot.data()['d'])));
  }

  //***READ
  Future<String> findProfilePicUrlByUsername(String username) async {
    String userPicURL;
    QuerySnapshot querySnapshot = await userRef
        .where(
          'd.username',
          isEqualTo: username,
        )
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      userPicURL = querySnapshot.docs.first.data()['d']['profile_pic'];
    }
    return userPicURL;
  }

  Future<String> findUserMesseageTokenByID(String uid) async {
    String token = "";
    DocumentSnapshot docSnapshot = await userRef.doc(uid).get();
    if (docSnapshot.exists) {
      token = docSnapshot.data()["messageToken"];
    }
    return token;
  }

  Future<String> getUsername(String uid) async {
    String username = '';
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'getUsername',
    );
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'uid': uid,
      },
    );
    if (result.data != null) {
      username = result.data.toString();
    }
    return username;
  }

  Future<WebblenUser> getUserByID(String uid) async {
    WebblenUser user;
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'getUserByID',
    );
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'uid': uid,
      },
    );
    if (result.data != null) {
      Map<String, dynamic> userMap = Map<String, dynamic>.from(result.data);
      user = WebblenUser.fromMap(userMap);
    }
    return user;
  }

  Future<List<WebblenUser>> getUsersFromList(List userIDs) async {
    List<WebblenUser> users = [];
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'getUsersFromList',
    );
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'userIDs': userIDs,
      },
    );
    if (result.data != null) {
      List query = List.from(json.decode(result.data));
      query.forEach((resultMap) {
        Map<String, dynamic> userMap = Map<String, dynamic>.from(resultMap);
        WebblenUser user = WebblenUser.fromMap(userMap);
        users.add(user);
      });
    }
    return users;
  }

  Future<WebblenUser> getUserByName(String username) async {
    WebblenUser user;
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'getUserByName',
    );
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'username': username,
      },
    );
    if (result.data != null) {
      Map<String, dynamic> userMap = Map<String, dynamic>.from(result.data);
      user = WebblenUser.fromMap(userMap);
    }
    return user;
  }

  Future<String> getUserProfilePicURL(String uid) async {
    String url = '';
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'getUserProfilePicURL',
    );
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'uid': uid,
      },
    );
    if (result.data != null) {
      url = result.data.toString();
    }
    return url;
  }

  Future<Null> updateNotifTime(String uid) async {
    userRef.doc(uid).update({'lastNotificationTimeInMilliseconds': DateTime.now().millisecondsSinceEpoch});
  }

  Future<int> getLastNotifTime(String uid) async {
    int lastNotifInMilliseconds;
    await userRef.doc(uid).get().then((userDoc) {
      lastNotifInMilliseconds = userDoc.data()['lastNotificationTimeInMilliseconds'];
    });
    return lastNotifInMilliseconds;
  }

  //***UPDATE
  Future<String> updateUserCheckIn(String uid, double lat, double lon) async {
    String error;
    int checkInTimeInMilliseconds = DateTime.now().millisecondsSinceEpoch;
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'updateUserCheckIn',
    );
    try {
      await callable.call(
        <String, dynamic>{
          'uid': uid,
          'checkInTimeInMilliseconds': checkInTimeInMilliseconds,
          'lat': lat,
          'lon': lon,
        },
      );
    } on CloudFunctionsException catch (e) {
      error = e.details;
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<Null> updateUserAppOpen(String uid, double lat, double lon) async {
    int appOpenInMilliseconds = DateTime.now().millisecondsSinceEpoch;
    //GeoFirePoint geoFirePoint = GeoFirePoint(lat, lon);
    userRef.doc(uid).update({
      'g': null,
      'l': null,
      'appOpenInMilliseconds': appOpenInMilliseconds,
    });
  }

  Future<String> updateUserProfilePic(String uid, String username, String downloadUrl) async {
    String error;
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'updateUserProfilePic',
    );
    try {
      await callable.call(
        <String, dynamic>{
          'uid': uid,
          'username': username,
          'profile_pic': downloadUrl,
        },
      );
    } on CloudFunctionsException catch (e) {
      error = e.details;
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<bool> checkIfUsernameExists(String username) async {
    QuerySnapshot query = await userRef
        .where(
          'd.username',
          isEqualTo: username,
        )
        .get();
    if (query != null && query.docs.length > 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkIfUserExists(String uid) async {
    DocumentSnapshot docSnapshot = await userRef.doc(uid).get();
    if (docSnapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future<Null> addUserDataField(String dataName, dynamic data) async {
    QuerySnapshot querySnapshot = await userRef.get();
    querySnapshot.docs.forEach((doc) {
      userRef.doc(doc.id).update({"$dataName": data}).whenComplete(() {}).catchError((e) {});
    });
  }

  Future<String> setUserCloudMessageToken(String uid, String messageToken) async {
    String status = "";
    userRef.doc(uid).update({"d.messageToken": messageToken}).whenComplete(() {}).catchError((e) {
          status = e.details;
        });
    return status;
  }

  Future<String> removeFriend(String currentUid, String uid) async {
    String requestStatus;
    DocumentSnapshot ownUserSnapshot = await userRef.doc(currentUid).get();
    DocumentSnapshot otherUserSnapshot = await userRef.doc(uid).get();
    List ownUserFriendsList = ownUserSnapshot.data()["d"]['friends'];
    List otherUserFriendsList = otherUserSnapshot.data()["d"]['friends'];
    ownUserFriendsList = ownUserFriendsList.toList(growable: true);
    otherUserFriendsList = otherUserFriendsList.toList(growable: true);
    ownUserFriendsList.remove(uid);
    otherUserFriendsList.remove(currentUid);

    await userRef.doc(uid).update({"d.friends": otherUserFriendsList}).whenComplete(() {
      userRef.doc(currentUid).update({"d.friends": ownUserFriendsList}).whenComplete(() {
        requestStatus = "success";
      }).catchError((e) {
        requestStatus = e.details;
      });
    }).catchError((e) {
      requestStatus = e.details;
    });
    return requestStatus;
  }

  Future<String> checkFriendStatus(String currentUid, String uid) async {
    String friendStatus;
    DocumentSnapshot peerDocSnapshot = await userRef.doc(uid).get();
    List friendsList = peerDocSnapshot.data()["d"]['friends'];
    if (friendsList.contains(currentUid)) {
      friendStatus = "friends";
    } else {
      await notifRef
          .where(
            'notificationType',
            isEqualTo: 'friendRequest',
          )
          .where(
            'uid',
            isEqualTo: uid,
          )
          .where(
            'notificationData',
            isEqualTo: currentUid,
          )
          .get()
          .then((notifQuery) {
        if (notifQuery.docs != null && notifQuery.docs.length > 0) {
          friendStatus = 'pending';
        }
      });
    }
    return friendStatus;
  }

  Future<Null> updateNotificationPermission(String uid, String notif, bool status) async {
    userRef.doc(uid).update({notif: status}).whenComplete(() {}).catchError((e) {});
  }

//  Future<Null> updateUserField() async {
//    userRef.getDocuments().then((res){
//     res.docs.forEach((doc) async {
//       await userRef.doc(doc.docID).updateData(({
//         'd.userLat': FieldValue.delete(),
//         'd.userLon': FieldValue.delete()
//       }));
//     });
//    });
//  }

}
