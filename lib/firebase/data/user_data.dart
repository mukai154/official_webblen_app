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

  Future<bool> checkIfUsernameExists(String username) async {
    bool usernameExists = false;
    QuerySnapshot snapshot = await userRef.where("d.username", isEqualTo: username).getDocuments();
    if (snapshot.documents.isNotEmpty) {
      usernameExists = true;
    }
    return usernameExists;
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
