import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:webblen/firebase_services/file_uploader.dart';

class UserDataService {
  Geoflutterfire geo = Geoflutterfire();
  final CollectionReference userRef =
      Firestore.instance.collection("webblen_user");
  final CollectionReference eventRef = Firestore.instance.collection("events");
  final CollectionReference notifRef =
      Firestore.instance.collection("user_notifications");

  final StorageReference storageReference = FirebaseStorage.instance.ref();
  final double degreeMinMax = 0.145;

  Future<bool> checkAdminStatus(String uid) async {
    bool isAdmin = false;
    DocumentSnapshot comDoc = await userRef.document(uid).get();
    if (comDoc.exists) {
      if (comDoc.data['isAdmin'] != null) {
        isAdmin = comDoc.data['isAdmin'];
      }
    }
    return isAdmin;
  }

  //***CREATE
  Future<bool> createNewUser(
      File userImage, WebblenUser user, String uid) async {
    bool success = true;
    StorageReference storageReference = FirebaseStorage.instance.ref();
    String fileName = "$uid.jpg";
    storageReference.child("profile_pics").child(fileName).putFile(userImage);
    String downloadUrl = await FileUploader().upload(
      userImage,
      fileName,
      'profile_pics',
    );
    user.profile_pic = downloadUrl.toString();
    GeoPoint geoPoint = GeoFirePoint(0, 0).geoPoint;
    await Firestore.instance
        .collection("webblen_user")
        .document(uid)
        .setData({
          'appOpenInMilliseconds': DateTime.now().millisecondsSinceEpoch,
          'd': user.toMap(),
          'g': '',
          'l': geoPoint,
          'lastAPRechargeInMilliseconds': DateTime.now().millisecondsSinceEpoch
        })
        .whenComplete(() {})
        .catchError((e) {
          success = false;
        });
    return success;
  }

  //***READ
  Future<String> findProfilePicUrlByUsername(String username) async {
    String userPicURL;
    QuerySnapshot querySnapshot = await userRef
        .where(
          'd.username',
          isEqualTo: username,
        )
        .getDocuments();
    if (querySnapshot.documents.isNotEmpty) {
      userPicURL = querySnapshot.documents.first.data['d']['profile_pic'];
    }
    return userPicURL;
  }

  Future<String> findUserMesseageTokenByID(String uid) async {
    String token = "";
    DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
    if (documentSnapshot.exists) {
      token = documentSnapshot.data["messageToken"];
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

  Future<List<WebblenUser>> getNearbyUsers(double lat, double lon) async {
    List<WebblenUser> users = [];
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'getNearbyUsers',
    );
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'lat': lat,
        'lon': lon,
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

  Future<String> getNumberOfNearbyUsers(double lat, double lon) async {
    String numOfNearbyUsers = '0';
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'getNumberOfNearbyUsers',
    );
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'lat': lat,
        'lon': lon,
      },
    );
    if (result.data != null) {
      numOfNearbyUsers = result.data.toString();
    }
    return numOfNearbyUsers;
  }

  Future<List<WebblenUser>> get10RandomUsers(double lat, double lon) async {
    List<WebblenUser> users = [];
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'get10RandomUsers',
    );
    final HttpsCallableResult result = await callable.call(
      <String, dynamic>{
        'lat': lat,
        'lon': lon,
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

  Future<Null> updateNotifTime(String uid) async {
    userRef.document(uid).updateData({
      'lastNotificationTimeInMilliseconds':
          DateTime.now().millisecondsSinceEpoch
    });
  }

  Future<int> getLastNotifTime(String uid) async {
    int lastNotifInMilliseconds;
    await userRef.document(uid).get().then((userDoc) {
      lastNotifInMilliseconds =
          userDoc.data['lastNotificationTimeInMilliseconds'];
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
    GeoFirePoint geoFirePoint = GeoFirePoint(lat, lon);
    userRef.document(uid).updateData({
      'g': geoFirePoint.hash,
      'l': geoFirePoint.geoPoint,
      'appOpenInMilliseconds': appOpenInMilliseconds,
    });
  }

  Future<String> updateUserProfilePic(
      String uid, String username, String downloadUrl) async {
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
        .getDocuments();
    if (query != null && query.documents.length > 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkIfUserExists(String uid) async {
    DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
    if (documentSnapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future<Null> addUserDataField(String dataName, dynamic data) async {
    QuerySnapshot querySnapshot = await userRef.getDocuments();
    querySnapshot.documents.forEach((doc) {
      userRef
          .document(doc.documentID)
          .updateData({"$dataName": data})
          .whenComplete(() {})
          .catchError((e) {});
    });
  }

  Future<String> setUserCloudMessageToken(
      String uid, String messageToken) async {
    String status = "";
    userRef
        .document(uid)
        .updateData({"d.messageToken": messageToken})
        .whenComplete(() {})
        .catchError((e) {
          status = e.details;
        });
    return status;
  }

  Future<String> removeFriend(String currentUid, String uid) async {
    String requestStatus;
    DocumentSnapshot ownUserSnapshot = await userRef.document(currentUid).get();
    DocumentSnapshot otherUserSnapshot = await userRef.document(uid).get();
    List ownUserFriendsList = ownUserSnapshot.data["d"]['friends'];
    List otherUserFriendsList = otherUserSnapshot.data["d"]['friends'];
    ownUserFriendsList = ownUserFriendsList.toList(growable: true);
    otherUserFriendsList = otherUserFriendsList.toList(growable: true);
    ownUserFriendsList.remove(uid);
    otherUserFriendsList.remove(currentUid);

    await userRef
        .document(uid)
        .updateData({"d.friends": otherUserFriendsList}).whenComplete(() {
      userRef
          .document(currentUid)
          .updateData({"d.friends": ownUserFriendsList}).whenComplete(() {
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
    DocumentSnapshot peerDocSnapshot = await userRef.document(uid).get();
    List friendsList = peerDocSnapshot.data["d"]['friends'];
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
          .getDocuments()
          .then((notifQuery) {
        if (notifQuery.documents != null && notifQuery.documents.length > 0) {
          friendStatus = 'pending';
        }
      });
    }
    return friendStatus;
  }

  Future<String> joinWaitList(String uid, double lat, double lon, String email,
      String phoneNo, String zipCode) async {
    String error = '';
    final CollectionReference waitListRef =
        Firestore.instance.collection("waitlist");
    await waitListRef.document(uid).get().then((snapshot) {
      if (snapshot.exists) {
        error = "You're Already on Our Waitlist!";
      } else {
        if (email == null) {
          waitListRef.document(uid).setData({
            "lat": lat,
            "lon": lon,
            "phoneNo": phoneNo,
            "zipCode": zipCode,
          }).whenComplete(() {
            userRef
                .document(uid)
                .updateData({"isOnWaitList": true}).whenComplete(() {});
          }).catchError((e) {
            error = e.details;
          });
        } else {
          waitListRef
              .document(uid)
              .setData({
                "lat": lat,
                "lon": lon,
                "email": email,
                "zipCode": zipCode,
              })
              .whenComplete(() {})
              .catchError((e) {
                error = e.details;
              });
        }
      }
    });

    return error;
  }

  Future<Null> updateNotificationPermission(
      String uid, String notif, bool status) async {
    userRef
        .document(uid)
        .updateData({notif: status})
        .whenComplete(() {})
        .catchError((e) {});
  }

//  Future<Null> updateUserField() async {
//    userRef.getDocuments().then((res){
//     res.documents.forEach((doc) async {
//       await userRef.document(doc.documentID).updateData(({
//         'd.userLat': FieldValue.delete(),
//         'd.userLon': FieldValue.delete()
//       }));
//     });
//    });
//  }

}
