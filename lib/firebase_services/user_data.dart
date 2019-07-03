import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:webblen/firebase_services/event_data.dart';
import 'firebase_notification_services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:webblen/models/event.dart';

class UserDataService {

  Geoflutterfire geo = Geoflutterfire();
  final CollectionReference userRef = Firestore.instance.collection("users");
  final CollectionReference eventRef = Firestore.instance.collection("events");
  final CollectionReference questionRef = Firestore.instance.collection("question_user");
  final StorageReference storageReference = FirebaseStorage.instance.ref();
  final double degreeMinMax = 0.145;

  Future<bool> checkIfUserExistsByUID(String uid) async {
    DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
    if (documentSnapshot.exists){
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkIfNewUser(String uid) async {
    DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
    if (documentSnapshot.data["isNewUser"] == null){
      return true;
    } else {
      return false;
    }
  }

  Future<List<WebblenUser>> searchForUserByName(String searchTerm, String areaName) async {
    List<WebblenUser> users = [];
    QuerySnapshot querySnapshot = await userRef.where("username", isEqualTo: searchTerm).getDocuments();
    if (querySnapshot.documents.isNotEmpty){
      querySnapshot.documents.forEach((docSnap){
        WebblenUser event = WebblenUser.fromMap(docSnap.data);
        users.add(event);
      });
    }
    return users;
  }

  Future<Null> updateNewUser(String uid) async {
    userRef.document(uid).updateData({"isNew": false}).whenComplete(() {
    }).catchError((e) {
    });
  }

  Future<String> updateUserTags(String uid, List tags) async {
    String error = "";
   await userRef.document(uid).updateData({'tags': tags}).whenComplete((){
    }).catchError((e){
      error = e.details;
    });
   return error;
  }

  Future<Null> updateUserNotificationSettings(WebblenUser user) async {
    userRef.document(user.uid).updateData({
      'notifyFlashEvents': user.notifyFlashEvents,
      'notifyFriendRequests': user.notifyFriendRequests,
      'notifySuggestedEvents': user.notifySuggestedEvents,
      'notifyWalletDeposits': user.notifyWalletDeposits,
      'notifiyNewMessages': user.notifyNewMessages,
    }).whenComplete(() {
    }).catchError((e) {
    });
  }

  Future<bool> checkIfUserExists(String username) async {
    bool doesUserExist;
    QuerySnapshot querySnapshot = await userRef.where("username", isEqualTo: username).getDocuments();
    if (querySnapshot.documents.isNotEmpty){
      doesUserExist = true;
    } else {
      doesUserExist = false;
    }
    return doesUserExist;
  }


  Future<String> currentUsername(String uid) async {
    DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
    String username = documentSnapshot.data["username"];
    return username;
  }

  Future<String> findProfilePicUrl(String uid) async {
    DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
    String profilePicUrl = documentSnapshot.data["profile_pic"];
    return profilePicUrl;
  }

  Future<String> findProfilePicUrlByUsername(String username) async {
    String userPicURL;
    QuerySnapshot querySnapshot = await userRef.where('username', isEqualTo: username).getDocuments();
    if (querySnapshot.documents.isNotEmpty){
      userPicURL = querySnapshot.documents.first.data['profile_pic'];
    }
    return userPicURL;
  }


  Future<WebblenUser> findUserByID(String uid) async {
    WebblenUser user;
    DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
    if (documentSnapshot.exists){
      user = WebblenUser.fromMap(documentSnapshot.data);
    }
    return user;
  }

  Future<String> findUserMesseageTokenByID(String uid) async {
    String token = "";
    DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
    if (documentSnapshot.exists){
      token = documentSnapshot.data["messageToken"];
    }
    return token;
  }

  Future<List> eventHistory(String uid) async {
    DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
    List eventHistory = documentSnapshot.data["eventHistory"];
    return eventHistory;
  }

  Future<String> userImagePath(String uid) async {
    DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
    String pathToImage = documentSnapshot.data["profile_pic"];
    return pathToImage;
  }

  Future<double> userPoints(String uid) async {
    DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
    double points = documentSnapshot.data["eventPoints"] * 1.00;
    return points;
  }

  Future<List> currentUserTags(String uid) async {
    DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
    List tags = documentSnapshot.data["tags"];
    return tags;
  }

  Future<List> currentUserRewards(String uid) async {
    DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
    List rewards = documentSnapshot.data["rewards"];
    return rewards;
  }

  Future<int> findNumberOfNearbyUsers(double lat, double lon) async {
    double latMax = lat + degreeMinMax;
    double latMin = lat - degreeMinMax;
    double lonMax = lon + degreeMinMax;
    double lonMin = lon - degreeMinMax;

    int userNum = 0;

    QuerySnapshot querySnapshot = await userRef
        .where('userLat', isLessThanOrEqualTo: latMax)
        .where('userLat', isGreaterThanOrEqualTo: latMin)
        .getDocuments();
    querySnapshot.documents.removeWhere((doc) => doc['userLon'] > lonMax && doc['userLon'] < lonMin);
    userNum = querySnapshot.documents.length;
    return userNum;
  }
  Future<List<WebblenUser>> findNearbyUsers(double lat, double lon) async {
    double latMax = lat + degreeMinMax;
    double latMin = lat - degreeMinMax;
    double lonMax = lon + degreeMinMax;
    double lonMin = lon - degreeMinMax;

    List<WebblenUser> nearbyUsers = [];

    QuerySnapshot querySnapshot = await userRef
        .where('userLat', isLessThanOrEqualTo: latMax)
        .where('userLat', isGreaterThanOrEqualTo: latMin)
        .getDocuments();
    var eventsSnapshot = querySnapshot.documents;
    eventsSnapshot.forEach((userDoc){
      double lon = userDoc["userLon"];
      if (lon >= lonMin && lon <= lonMax){
        WebblenUser user = WebblenUser.fromMap(userDoc.data);
        nearbyUsers.add(user);
      }
    });
    nearbyUsers..sort((a, b) => b.eventHistory.length.compareTo(a.eventHistory.length));
    return nearbyUsers;
  }

  Future<double> calculateCompatibility(String uid, WebblenUser otherUser) async {
    double compatibility = 0.01;
    int numberOfSharedTags = 0;
    List userTags = await currentUserTags(uid);
//    if (otherUser.tags.length > 0 && userTags.length > 0){
//      otherUser.tags.forEach((tag){
//        if (userTags.contains(tag)){
//          numberOfSharedTags += 1;
//        }
//      });
//      compatibility = numberOfSharedTags / userTags.length;
//    }
    return compatibility;
  }

  Future<String> updateUserCheckIn(String uid, double lat, double lon) async {
    String status = "";
    GeoFirePoint newLocation = geo.point(latitude: lat, longitude: lon);
    DateTime currentDateTime = DateTime.now();
    DateFormat formatter = new DateFormat("MM/dd/yyyy h:mm a");
    String lastCheckIn = formatter.format(currentDateTime);
    userRef.document(uid).updateData({"location": newLocation.data, "lastCheckIn" : lastCheckIn}).whenComplete(() {
      status = 'success';
    }).catchError((e) {
      status = 'error' + e.details;
    });
    return status;
  }

  Future<Null> updateAllUsers() async{
    QuerySnapshot snapshot = await userRef.getDocuments();
    snapshot.documents.forEach((doc){
      if (doc.data['userLat'] != null && doc.data['userLon'] != null){
        double lat = doc.data['userLat'];
        double lon = doc.data['userLon'];
        GeoFirePoint newLocation = geo.point(latitude: lat, longitude: lon);
        userRef.document(doc.documentID).updateData({"location": newLocation.data}).whenComplete(() {
        }).catchError((e) {
        });
      }
    });
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

//  Future<Null> reformatCommunities() async {
//    QuerySnapshot querySnapshot = await userRef.getDocuments();
//    querySnapshot.documents.forEach((doc){
//      Map<dynamic, dynamic> userComs = doc.data['communityMemberMap'];
//      Map<dynamic, dynamic> newComs = {};
//      if (userComs != null){
//        userComs.forEach((key, val){
//          List comsFromArea = newComs[val] == null ? [] : newComs[val];
//          comsFromArea.toList(growable: true);
//          comsFromArea.add(key);
//          newComs.addAll({"$val": comsFromArea});
//        });
//        userRef.document(doc.documentID).updateData({"communities": newComs}).whenComplete(() {
//
//        }).catchError((e) {
//
//        });
//      }
//    });
//  }

  Future<String> setUserCloudMessageToken(String uid, String messageToken) async {
    String status = "";
    userRef.document(uid).updateData({"messageToken": messageToken}).whenComplete((){
    }).catchError((e) {
      status = e.details;
    });
    return status;
  }

  //Questions
  Future<Map<String, dynamic>> retrieveMultipleChoiceQuestion(String uid) async {
    DocumentSnapshot questionSnapshot = await questionRef.document("multiple_choice").get();
    Map<String, dynamic> questionData = questionSnapshot.data;
    String dataVal = questionData["dataVal"];
    DocumentSnapshot userSnapshot =  await userRef.document(uid).get();
    Map<String, dynamic> userData = userSnapshot.data;
    if (userData[dataVal] != null){
      return null;
    } else {
      return questionData;
    }
  }

  Future<String> submitAnswerData(String uid, String dataVal, String answer) async {
    String status = "";
    userRef.document(uid).updateData({dataVal: answer}).whenComplete((){
    }).catchError((e) {
      status = e.details;
    });
    return status;
  }

  Future<DocumentSnapshot> retrieveYesOrNoQuestion() async {
    DocumentSnapshot documentSnapshot = await questionRef.document("yes_or_no").get();
    return documentSnapshot;
  }

  Future<DocumentSnapshot> retrieveOpenQuestion() async {
    DocumentSnapshot documentSnapshot = await questionRef.document("open").get();
    return documentSnapshot;
  }

  Future<String> updateWalletNotifications(String uid) async {
    String requestStatus;
    DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
    int walletNotificationCount = documentSnapshot.data["walletNotificationCount"];
    int userNotificationCount = documentSnapshot.data["notificationCount"];
    userNotificationCount -= walletNotificationCount;
    if (userNotificationCount < 0){
      userNotificationCount = 0;
    }
    walletNotificationCount = 0;
    await userRef.document(uid).updateData({"walletNotificationCount": walletNotificationCount, "notificationCount": userNotificationCount}).whenComplete(() {
      requestStatus = "success";
    }).catchError((e) {
      requestStatus = e.details;
    });
    return requestStatus;
  }

  Future<String> updateFriendRequestNotifications(String uid) async {
    String requestStatus;
    DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
    int friendRequestNotificationCount = documentSnapshot.data["friendRequestNotificationCount"];
    int userNotificationCount = documentSnapshot.data["notificationCount"];
    userNotificationCount -= friendRequestNotificationCount;
    if (userNotificationCount < 0){
      userNotificationCount = 0;
    }
    friendRequestNotificationCount = 0;
    await userRef.document(uid).updateData({"friendRequestNotificationCount": friendRequestNotificationCount, "notificationCount": userNotificationCount}).whenComplete(() {
      requestStatus = "success";
    }).catchError((e) {
      requestStatus = e.details;
    });
    return requestStatus;
  }

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

}