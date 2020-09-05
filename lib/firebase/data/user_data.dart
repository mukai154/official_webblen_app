import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/models/webblen_user.dart';

class WebblenUserData {
  final CollectionReference userRef = Firestore().collection("webblen_user");
  final CollectionReference stripeRef = Firestore().collection("stripe");
  final CollectionReference eventRef = Firestore().collection("events");
  final CollectionReference notifRef = Firestore().collection("user_notifications");

  Stream<WebblenUser> streamCurrentUser(String uid) {
    return userRef.document(uid).snapshots().map((snapshot) => WebblenUser.fromMap(Map<String, dynamic>.from(snapshot.data['d'])));
  }

  Stream<Map<String, dynamic>> streamStripeAccount(String uid) {
    return stripeRef.document(uid).snapshots().map((snapshot) => snapshot.data);
  }

  Future<WebblenUser> getUserByID(String uid) async {
    WebblenUser user;
    DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
    if (documentSnapshot.exists) {
      Map<String, dynamic> docData = documentSnapshot.data;
      user = WebblenUser.fromMap(Map<String, dynamic>.from(docData['d']));
    }
    return user;
  }

  Future<String> getStripeUID(String uid) async {
    String stripeUID;
    DocumentSnapshot documentSnapshot = await stripeRef.document(uid).get();
    if (documentSnapshot.exists) {
      Map<String, dynamic> docData = documentSnapshot.data;
      stripeUID = docData['stripeUID'];
    }
    return stripeUID;
  }

  Future<bool> userAccountIsSetup(String uid) async {
    bool accountIsSetup = false;
    DocumentSnapshot snapshot = await userRef.document(uid).get();
    if (snapshot.exists) {
      accountIsSetup = true;
    }
    return accountIsSetup;
  }

  Future<bool> checkIfUserCanSellTickets(String uid) async {
    bool canSellTickets = false;
    DocumentSnapshot documentSnapshot = await stripeRef.document(uid).get();
    if (documentSnapshot.exists) {
      Map<String, dynamic> docData = documentSnapshot.data;
      if (docData['stripeUID'] != null) {
        canSellTickets = true;
      }
    }
    return canSellTickets;
  }

  Future<bool> checkIfUsernameExists(String username) async {
    bool usernameExists = false;
    QuerySnapshot snapshot = await userRef.where("d.username", isEqualTo: username).getDocuments();
    if (snapshot.documents.isNotEmpty) {
      usernameExists = true;
    }
    return usernameExists;
  }

  Future<List> getFollowingList(String uid) async {
    List followingList;
    DocumentSnapshot documentSnapshot = await userRef.document(uid).get();
    if (documentSnapshot.exists) {
      Map<String, dynamic> docData = documentSnapshot.data;
      WebblenUser user = WebblenUser.fromMap(Map<String, dynamic>.from(docData['d']));
      followingList = user.following;
    }
    return followingList;
  }

  Future<String> updateFollowing(String currentUID, String userUID, List currentUserFollowingList, List userFollowerList) async {
    String error;
    await userRef.document(currentUID).updateData({"d.following": currentUserFollowingList});
    await userRef.document(userUID).updateData({"d.followers": userFollowerList});
    return error;
  }

  Future<Null> transitionFriendsToFollowers() async {
    QuerySnapshot snapshot = await userRef.getDocuments();
    snapshot.documents.forEach((doc) async {
      await userRef.document(doc.documentID).updateData({"d.following": doc.data['d']['friends'], "d.followers": doc.data['d']['friends']}).catchError((e) {});
    });
  }

  Future<Null> changeEventPointsToWebblen() async {
    QuerySnapshot snapshot = await userRef.getDocuments();
    snapshot.documents.forEach((doc) async {
      await userRef.document(doc.documentID).updateData({"d.webblen": doc.data['d']['eventPoints']}).catchError((e) {});
    });
  }

  Future<String> depositWebblen(double depositAmount, String uid) async {
    String error;
    DocumentSnapshot snapshot = await userRef.document(uid).get();
    WebblenUser user = WebblenUser.fromMap(snapshot.data['d']);
    double initialBalance = user.webblen == null ? 0.00001 : user.webblen;
    double newBalance = depositAmount + initialBalance;
    await userRef.document(uid).updateData({"d.webblen": newBalance}).catchError((e) {
      error = e.toString();
    });
    return error;
  }

//  Future<String> updateUserImg(File userImgFile, String uid) async {
//    String error = "";
//    String userImgURL = await ImageUploadService().uploadImageToFirebaseStorage(userImgFile, UserImgFile, uid);
//    if (userImgFile != null) {
//      await userRef.document(uid).updateData({'d.profile_pic': userImgURL}).whenComplete(() {}).catchError((e) {
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
//        await userRef.document(uid).setData({'d': newUser.toMap(), 'g': null, 'l': null}).whenComplete(() {}).catchError((e) {
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
