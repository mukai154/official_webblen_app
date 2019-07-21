import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:webblen/firebase_data/event_data.dart';
import 'firebase_notification_services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:webblen/models/event.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:convert';
import 'dart:io';
import 'package:webblen/firebase_services/file_uploader.dart';
import 'package:webblen/models/community.dart';

class UserDataService {

  Geoflutterfire geo = Geoflutterfire();
  final CollectionReference userRef = Firestore.instance.collection("users");
  final CollectionReference userRf = Firestore.instance.collection("webblen_user");
  final CollectionReference eventRef = Firestore.instance.collection("events");
  final CollectionReference questionRef = Firestore.instance.collection("question_user");
  final StorageReference storageReference = FirebaseStorage.instance.ref();
  final double degreeMinMax = 0.145;


  Future<String> createNewUser(File userImage, WebblenUser user, String uid) async {
    String error = "";
    StorageReference storageReference = FirebaseStorage.instance.ref();
    String fileName = "$uid.jpg";
    storageReference.child("profile_pics").child(fileName).putFile(userImage);
    String downloadUrl = await FileUploader().upload(userImage, fileName, 'profile_pics');
    user.profile_pic = downloadUrl.toString();
    Firestore.instance.collection("users").document(uid).setData({'d': user.toMap(), 'g': '', 'l': null}).whenComplete(() {
    }).catchError((e) {
      error = e.details;
    });
    return error;
  }

  Future<String> getUsername(String uid) async {
    String username = '';
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'getUsername');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'uid': uid});
    if (result.data != null){
      username = result.data.toString();
    }
    return username;
  }


  Future<WebblenUser> getUserByID(String uid) async {
    WebblenUser user;
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'getUserByID');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'uid': uid});
    if (result.data != null){
      Map<String, dynamic> userMap =  Map<String, dynamic>.from(result.data);
      user = WebblenUser.fromMap(userMap);
    }
    return user;
  }

  Future<WebblenUser> getUserByName(String username) async {
    WebblenUser user;
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'getUserByName');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'username': username});
    if (result.data != null){
      Map<String, dynamic> userMap =  Map<String, dynamic>.from(result.data);
      user = WebblenUser.fromMap(userMap);
    }
    return user;
  }

  Future<String> getUserProfilePicURL(String uid) async {
    String url = '';
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'getUserProfilePicURL');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'uid': uid});
    if (result.data != null){
      url = result.data.toString();
    }
    return url;
  }

  Future<List<Event>> getUserEventHistory(String uid) async {
    List<Event> events = [];
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'getUserEventHistory');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'uid': uid});
    if (result.data != null){
      List query =  List.from(result.data);
      query.forEach((resultMap){
        Map<String, dynamic> evMap =  Map<String, dynamic>.from(resultMap);
        Event event = Event.fromMap(evMap);
        events.add(event);
      });
    }
    return events;
  }

  Future<List<WebblenUser>> getNearbyUsers(double lat, double lon) async {
    List<WebblenUser> users = [];
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'getNearbyUsers');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'lat': lat, 'lon': lon});
    if (result.data != null){
      List query =  List.from(result.data);
      query.forEach((resultMap){
        Map<String, dynamic> userMap =  Map<String, dynamic>.from(resultMap);
        WebblenUser user = WebblenUser.fromMap(userMap);
        users.add(user);
      });
    }
    return users;
  }

  Future<String> getNumberOfNearbyUsers(double lat, double lon) async {
    String numOfNearbyUsers = '0';
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'getNumberOfNearbyUsers');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'lat': lat, 'lon': lon});
    if (result.data != null){
      numOfNearbyUsers = result.data.toString();
    }
    return numOfNearbyUsers;
  }

  Future<List<WebblenUser>> get10RandomUsers(double lat, double lon) async {
    List<WebblenUser> users = [];
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'get10RandomUsers');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'lat': lat, 'lon': lon});
    if (result.data != null){
      List query =  List.from(result.data);
      query.forEach((resultMap){
        Map<String, dynamic> userMap =  Map<String, dynamic>.from(resultMap);
        WebblenUser user = WebblenUser.fromMap(userMap);
        users.add(user);
      });
    }
    return users;
  }

  Future<String> updateUserCheckIn(String uid, double lat, double lon) async {
    String error;
    int checkInTimeInMilliseconds = DateTime.now().millisecondsSinceEpoch;
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'updateUserCheckIn',
    );
    try {
      await callable.call(<String, dynamic>{'uid': uid, 'checkInTimeInMilliseconds': checkInTimeInMilliseconds, 'lat': lat, 'lon': lon});
    } on CloudFunctionsException catch (e) {
      error = e.details;
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<String> updateUserProfilePic(String uid, String downloadUrl) async {
    String error;
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'updateUserProfilePic',
    );
    try {
      await callable.call(<String, dynamic>{'uid': uid, 'profile_pic': downloadUrl});
    } on CloudFunctionsException catch (e) {
     error = e.details;
    } catch (e) {
      error = e.toString();
    }
    return error;
  }


  Future<bool> checkIfUserExists(String uid) async {
    DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
    if (documentSnapshot.exists){
      return true;
    } else {
      return false;
    }
  }

  Future<Null> updateNewUser(String uid) async {
    userRef.document(uid).updateData({"d.isNew": false}).whenComplete(() {
    }).catchError((e) {
    });
  }


  Future<String> findProfilePicUrlByUsername(String username) async {
    String userPicURL;
    QuerySnapshot querySnapshot = await userRef.where('username', isEqualTo: username).getDocuments();
    if (querySnapshot.documents.isNotEmpty){
      userPicURL = querySnapshot.documents.first.data['profile_pic'];
    }
    return userPicURL;
  }

  Future<String> findUserMesseageTokenByID(String uid) async {
    String token = "";
    DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
    if (documentSnapshot.exists){
      token = documentSnapshot.data["messageToken"];
    }
    return token;
  }


  Future<String> eventCheckInStatus(String uid) async {
    String timeCheckInIsAvailable = "";
    DateTime currentDateTime = DateTime.now();
    DateFormat formatter = new DateFormat("MM/dd/yyyy h:mm a");
    DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
    String eventCheckIn = documentSnapshot.data["eventCheckIn"] == null ? "01/01/2010 10:00 AM" : documentSnapshot.data["eventCheckIn"];
    DateTime eventCheckInDateTime = formatter.parse(eventCheckIn);
    if (currentDateTime.isAfter(eventCheckInDateTime.add(Duration(hours: 1)))){
      return timeCheckInIsAvailable;
    } else {
      eventCheckInDateTime = eventCheckInDateTime.add(Duration(hours: 1));
      timeCheckInIsAvailable = formatter.format(eventCheckInDateTime);
      return timeCheckInIsAvailable;
    }
  }

  Future<String> updateEventCheckIn(String uid, Event event) async {
    String error = "";
    int eventEndInMilliseconds = event.endDateInMilliseconds;
    DateTime currentDateTime = DateTime.now();
    DateFormat formatter = new DateFormat("MM/dd/yyyy h:mm a");
    String lastCheckIn = formatter.format(currentDateTime);
    DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
    List eventsAttended = documentSnapshot["eventHistory"];
    eventsAttended = eventsAttended.toList(growable: true);
    eventsAttended.add(event.eventKey);
    userRef.document(uid).updateData({"eventCheckIn": lastCheckIn, "eventHistory": eventsAttended}).whenComplete(() {
    }).catchError((e) {
      error = e.details;
    });
    List attendees = event.attendees == null ? [] : event.attendees.toList(growable: true);
    if (!attendees.contains(uid)){
      attendees.add(uid);
    }
    double payoutMultiplier = EventDataService().getAttendanceMultiplier(attendees.length);
    int eventPayout = (attendees.length * payoutMultiplier).round();
    if (event.flashEvent){
      eventEndInMilliseconds = DateTime.fromMillisecondsSinceEpoch(eventEndInMilliseconds).add(Duration(minutes: 10)).millisecondsSinceEpoch;
    }
    eventRef.document(event.eventKey).updateData({"attendees": attendees, "eventPayout": eventPayout, "endDateInMilliseconds": eventEndInMilliseconds}).whenComplete(() {
    }).catchError((e) {
      error = e.details;
    });
    return error;
  }

  Future<String> checkoutOfEvent(String uid, Event event) async {
    String error = "";
    int eventEndInMilliseconds = event.endDateInMilliseconds;
    DateTime currentDateTime = DateTime.now();
    DateTime checkInUpdateTime = DateTime.now().subtract(Duration(hours: 4));
    DateFormat formatter = DateFormat("MM/dd/yyyy h:mm a");
    String lastCheckIn = formatter.format(checkInUpdateTime);
    DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
    List eventsAttended = documentSnapshot["eventHistory"];
    eventsAttended = eventsAttended.toList(growable: true);
    eventsAttended.remove(event.eventKey);

    userRef.document(uid).updateData({"eventCheckIn": lastCheckIn, "eventHistory": eventsAttended}).whenComplete(() {
    }).catchError((e) {
      error = e.details;
    });
    List attendees = event.attendees == null ? [] : event.attendees.toList(growable: true);
    if (attendees.contains(uid)){
      attendees.remove(uid);
    }

    double payoutMultiplier = EventDataService().getAttendanceMultiplier(attendees.length);
    int eventPayout = (attendees.length * payoutMultiplier).round();
    if (event.flashEvent){
      if (!DateTime.fromMillisecondsSinceEpoch(eventEndInMilliseconds).subtract((Duration(minutes: 10))).isBefore(currentDateTime)){
        eventEndInMilliseconds = DateTime.fromMillisecondsSinceEpoch(eventEndInMilliseconds).subtract(Duration(minutes: 10)).millisecondsSinceEpoch;
      } else {
        eventEndInMilliseconds = DateTime.fromMillisecondsSinceEpoch(eventEndInMilliseconds).subtract(Duration(minutes: 5)).millisecondsSinceEpoch;
      }
    }
    eventRef.document(event.eventKey).updateData({"attendees": attendees, "eventPayout": eventPayout, "endDateInMilliseconds": eventEndInMilliseconds}).whenComplete(() {
    }).catchError((e) {
      error = e.details;
    });
    return error;
  }


  Future<String> updateEventPoints(String uid, double newPoints) async {
    String error = "";
    DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
    double pointCount = documentSnapshot.data["eventPoints"] * 1.00;
    pointCount += newPoints;
    userRef.document(uid).updateData({"eventPoints": pointCount}).whenComplete((){
    }).catchError((e) {
      error = e.details;
    });
    return error;
  }

  Future<String> powerUpPoints(String uid, double powerUpAmount) async {
    String status = "";
    DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
    double pointCount = documentSnapshot.data["eventPoints"] * 1.00;
    double impactCount = documentSnapshot.data["impactPoints"] * 1.00;
    pointCount -= powerUpAmount;
    impactCount += powerUpAmount;
    userRef.document(uid).updateData({"eventPoints": pointCount, "impactPoints": impactCount}).whenComplete((){
    }).catchError((e) {
      status = e.details;
    });
    return status;
  }

  Future<Null> addUserDataField(String dataName, dynamic data) async {
    QuerySnapshot querySnapshot = await userRef.getDocuments();
    querySnapshot.documents.forEach((doc){
      userRef.document(doc.documentID).updateData({"$dataName": data}).whenComplete(() {

      }).catchError((e) {

      });
    });
  }

  Future<String> setUserCloudMessageToken(String uid, String messageToken) async {
    String status = "";
    userRef.document(uid).updateData({"messageToken": messageToken}).whenComplete((){
    }).catchError((e) {
      status = e.details;
    });
    return status;
  }

//  //CLOUD
//  Future<String> updateWalletNotifications(String uid) async {
//    String requestStatus;
//    DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
//    int walletNotificationCount = documentSnapshot.data["walletNotificationCount"];
//    int userNotificationCount = documentSnapshot.data["notificationCount"];
//    userNotificationCount -= walletNotificationCount;
//    if (userNotificationCount < 0){
//      userNotificationCount = 0;
//    }
//    walletNotificationCount = 0;
//    await userRef.document(uid).updateData({"walletNotificationCount": walletNotificationCount, "notificationCount": userNotificationCount}).whenComplete(() {
//      requestStatus = "success";
//    }).catchError((e) {
//      requestStatus = e.details;
//    });
//    return requestStatus;
//  }


  //CLOUD
  Future<String> updateMessageNotifications(String uid) async {
    String requestStatus;
    DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
    int messageNotificationCount = documentSnapshot.data["messageNotificationCount"];
    int userNotificationCount = documentSnapshot.data["notificationCount"];
    userNotificationCount -= messageNotificationCount;
    if (userNotificationCount < 0){
      userNotificationCount = 0;
    }
    messageNotificationCount = 0;
    await userRef.document(uid).updateData({"messageNotificationCount": messageNotificationCount, "notificationCount": userNotificationCount}).whenComplete(() {
      requestStatus = "success";
    }).catchError((e) {
      requestStatus = e.details;
    });
    return requestStatus;
  }

  Future<String> addFriend(String currentUid, String currentUsername, String uid) async {
    String requestStatus;
    DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
    List friendsRequestsList= documentSnapshot.data["friendRequests"];
    friendsRequestsList = friendsRequestsList.toList(growable: true);
    friendsRequestsList.add(currentUid);
    await userRef.document(uid).updateData({"friendRequests": friendsRequestsList}).whenComplete(() {
      FirebaseNotificationsService().createFriendRequestNotification(uid, currentUid, currentUsername, null);
      requestStatus = "success";
    }).catchError((e) {
      requestStatus = e.details;
    });
    return requestStatus;
  }

  Future<String> confirmFriend(String currentUid, String uid) async {
    String requestStatus;
    DocumentSnapshot ownUserSnapshot = await userRef.document(currentUid).get();
    DocumentSnapshot otherUserSnapshot = await userRef.document(uid).get();
    List friendRequests = ownUserSnapshot.data["friendRequests"];
    int friendRequestNotifCount = ownUserSnapshot.data['friendRequestNotificationCount'];
    int notificationCount =  ownUserSnapshot.data['notificationCount'];
    notificationCount -= 1;
    if (notificationCount < 0){
      notificationCount = 0;
    }
    friendRequestNotifCount -=1;
    List ownUserFriendsList= ownUserSnapshot.data["friends"];
    List otherUserFriendsList= otherUserSnapshot.data["friends"];
    friendRequests = friendRequests.toList(growable: true);
    ownUserFriendsList = ownUserFriendsList.toList(growable: true);
    otherUserFriendsList = otherUserFriendsList.toList(growable: true);
    friendRequests.remove(uid);
    ownUserFriendsList.add(uid);
    otherUserFriendsList.add(currentUid);

    await userRef.document(uid).updateData({"friends": otherUserFriendsList}).whenComplete(() {
      userRef.document(currentUid).updateData({"friends": ownUserFriendsList, "friendRequests" : friendRequests, "friendRequestNotificationCount": friendRequestNotifCount, "notificationCount": notificationCount}).whenComplete(() {
        requestStatus = "success";
      }).catchError((e) {
        requestStatus = e.details;
      });
    }).catchError((e) {
      requestStatus = e.details;
    });
    return requestStatus;
  }

  Future<String> denyFriend(String currentUid, String uid) async {
    String requestStatus;
    DocumentSnapshot ownUserSnapshot = await userRef.document(currentUid).get();
    List friendRequests = ownUserSnapshot.data["friendRequests"];
    friendRequests = friendRequests.toList(growable: true);
    friendRequests.remove(uid);
    await userRef.document(currentUid).updateData({"friendRequests" : friendRequests}).whenComplete(() {
      requestStatus = "success";
    }).catchError((e) {
      requestStatus = e.details;
    });
    return requestStatus;
  }

  Future<String> removeFriend(String currentUid, String uid) async {
    String requestStatus;
    DocumentSnapshot ownUserSnapshot = await userRef.document(currentUid).get();
    DocumentSnapshot otherUserSnapshot = await userRef.document(uid).get();
    List ownUserFriendsList= ownUserSnapshot.data["friends"];
    List otherUserFriendsList= otherUserSnapshot.data["friends"];
    ownUserFriendsList = ownUserFriendsList.toList(growable: true);
    otherUserFriendsList = otherUserFriendsList.toList(growable: true);
    ownUserFriendsList.remove(uid);
    otherUserFriendsList.remove(currentUid);

    await userRef.document(uid).updateData({"friends": otherUserFriendsList}).whenComplete(() {
      userRef.document(currentUid).updateData({"friends": ownUserFriendsList}).whenComplete(() {
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
    DocumentSnapshot userSnapshot = await userRef.document(currentUid).get();
    List friendsList = peerDocSnapshot.data["friends"];
    if (friendsList.contains(currentUid)){
      friendStatus = "friends";
    } else {
      List friendRequests = peerDocSnapshot.data["friendRequests"];
      if (friendRequests.contains(currentUid)) {
        friendStatus = "pending";
      } else {
        List receivedRequests = userSnapshot.data['friendRequests'];
        if (receivedRequests.contains(uid)){
          friendStatus = "receivedRequest";
        } else {
          friendStatus = "not friends";
        }
      }
    }
    return friendStatus;
  }

  Future<List> getFriendsList(String uid) async {
    List friends;
    DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
    List friendUIDs = documentSnapshot.data["friends"];
    friends = friendUIDs.toList(growable: true);
    return friends;
  }

  Future<List> getFriendRequestIDs(String uid) async {
    DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
    List friendRequests = documentSnapshot.data["friendRequests"];
    return friendRequests;
  }

  Future<Null> updateNotificationPermission(String uid, String notif, bool status) async {
    userRef.document(uid).updateData({notif : status}).whenComplete((){
    }).catchError((e){
    });
  }

  Future<Null> powerDownEveryone() async {
    QuerySnapshot querySnapshot = await userRef.getDocuments();
    querySnapshot.documents.forEach((doc){
      double userImpact = doc["impactPoints"];
      double userPoints = doc["eventPoints"];
      double newPoints = userImpact + userPoints;
      userRef.document(doc.documentID).updateData({"eventPoints": newPoints, "impactPoints": 1.00}).whenComplete(() {

      }).catchError((e) {

      });
    });
  }

  Future<String> joinWaitList(String uid, double lat, double lon, String email, String phoneNo, String zipCode) async {
    String error = '';
    final CollectionReference waitListRef = Firestore.instance.collection("waitlist");
    await waitListRef.document(uid).get().then((snapshot){
      if (snapshot.exists){
        error = "You're Already on Our Waitlist!";
      } else {
        if (email == null){
          waitListRef.document(uid).setData({"lat": lat, "lon": lon, "phoneNo": phoneNo, "zipCode": zipCode}).whenComplete(() {
            userRef.document(uid).updateData({"isOnWaitList": true}).whenComplete((){
            });
          }).catchError((e) {
            error = e.details;
          });
        } else {
          waitListRef.document(uid).setData({"lat": lat, "lon": lon, "email": email, "zipCode": zipCode}).whenComplete(() {
          }).catchError((e) {
            error = e.details;
          });
        }
      }
    });

    return error;
  }

    Future<Null> convertData() async {
    userRef.getDocuments().then((docs){
      docs.documents.forEach((doc) async {
        String geoH = doc.data['location']['geohash'];
        double lat = doc.data['location']['geopoint'].latitude;
        double lon = doc.data['location']['geopoint'].longitude;
        GeoPoint latLon = geo.point(latitude: lat, longitude: lon).geoPoint;
        userRf.document(doc.documentID).setData({'d': doc.data, 'g': geoH, 'l': latLon});
      });
    });
  }

}