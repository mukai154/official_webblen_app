import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/location/location_service.dart';

class UserDataService {
  CollectionReference userRef = FirebaseFirestore.instance.collection('webblen_users');
  CollectionReference postsRef = FirebaseFirestore.instance.collection('webblen_posts');
  SnackbarService? _snackbarService = locator<SnackbarService>();
  CustomDialogService _customDialogService = locator<CustomDialogService>();
  LocationService _locationService = locator<LocationService>();

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

  Future<String> getCurrentFbUsername(String id) async {
    String val = "";
    DocumentSnapshot snapshot = await userRef.doc(id).get();
    Map<String, dynamic> data = snapshot.data()!;
    if (data['fbUsername'] != null) {
      val = data['fbUsername'];
    }
    return val;
  }

  Future<String> getCurrentInstaUsername(String id) async {
    String val = "";
    DocumentSnapshot snapshot = await userRef.doc(id).get();
    Map<String, dynamic> data = snapshot.data()!;
    if (data['instaUsername'] != null) {
      val = data['instaUsername'];
    }
    return val;
  }

  Future<String> getCurrentTwitterUsername(String id) async {
    String val = "";
    DocumentSnapshot snapshot = await userRef.doc(id).get();
    Map<String, dynamic> data = snapshot.data()!;
    if (data['twitterUsername'] != null) {
      val = data['twitterUsername'];
    }
    return val;
  }

  Future<String> getCurrentTwitchUsername(String id) async {
    String val = "";
    DocumentSnapshot snapshot = await userRef.doc(id).get();
    Map<String, dynamic> data = snapshot.data()!;
    if (data['twitchUsername'] != null) {
      val = data['twitchUsername'];
    }
    return val;
  }

  Future<String> getCurrentYoutube(String id) async {
    String val = "";
    DocumentSnapshot snapshot = await userRef.doc(id).get();
    Map<String, dynamic> data = snapshot.data()!;
    if (data['youtube'] != null) {
      val = data['youtube'];
    }
    return val;
  }

  Future<String> getCurrentUserWebsite(String id) async {
    String val = "";
    DocumentSnapshot snapshot = await userRef.doc(id).get();
    Map<String, dynamic> data = snapshot.data()!;
    if (data['website'] != null) {
      val = data['website'];
    }
    return val;
  }

  Future<String> getCurrentUserTwitchStreamURL(String id) async {
    String val = "";
    DocumentSnapshot snapshot = await userRef.doc(id).get();
    Map<String, dynamic> data = snapshot.data()!;
    if (data['twitchStreamURL'] != null) {
      val = data['twitchStreamURL'];
    }
    return val;
  }

  Future<String> getCurrentUserTwitchStreamKey(String id) async {
    String val = "";
    DocumentSnapshot snapshot = await userRef.doc(id).get();
    Map<String, dynamic> data = snapshot.data()!;
    if (data['twitchStreamKey'] != null) {
      val = data['twitchStreamKey'];
    }
    return val;
  }

  Future<String> getCurrentUserYoutubeStreamURL(String id) async {
    String val = "";
    DocumentSnapshot snapshot = await userRef.doc(id).get();
    Map<String, dynamic> data = snapshot.data()!;
    if (data['youtubeStreamURL'] != null) {
      val = data['youtubeStreamURL'];
    }
    return val;
  }

  Future<String> getCurrentUserYoutubeStreamKey(String id) async {
    String val = "";
    DocumentSnapshot snapshot = await userRef.doc(id).get();
    Map<String, dynamic> data = snapshot.data()!;
    if (data['youtubeStreamKey'] != null) {
      val = data['youtubeStreamKey'];
    }
    return val;
  }

  Future<String> getCurrentUserFBStreamURL(String id) async {
    String val = "";
    DocumentSnapshot snapshot = await userRef.doc(id).get();
    Map<String, dynamic> data = snapshot.data()!;
    if (data['fbStreamURL'] != null) {
      val = data['fbStreamURL'];
    }
    return val;
  }

  Future<String> getCurrentUserFBStreamKey(String id) async {
    String val = "";
    DocumentSnapshot snapshot = await userRef.doc(id).get();
    Map<String, dynamic> data = snapshot.data()!;
    if (data['fbStreamKey'] != null) {
      val = data['fbStreamKey'];
    }
    return val;
  }

  Future<bool> updateAssociatedEmailAddress(String uid, String emailAddress) async {
    bool updated = true;
    String? error;
    userRef.doc(uid).update({"emailAddress": emailAddress}).whenComplete(() {}).catchError((e) {
          error = e.message;
        });
    if (error != null) {
      updated = false;
    }
    return updated;
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

  Future<bool> updateFbUsername({String? id, String? val}) async {
    bool updated = true;
    String? error;
    await userRef.doc(id).update({
      "fbUsername": val,
    }).catchError((e) {
      error = e.message;
    });
    if (error != null) {
      updated = false;
    }
    return updated;
  }

  Future<bool> updateInstaUsername({String? id, String? val}) async {
    bool updated = true;
    String? error;
    await userRef.doc(id).update({
      "instaUsername": val,
    }).catchError((e) {
      error = e.message;
    });
    if (error != null) {
      updated = false;
    }
    return updated;
  }

  Future<bool> updateTwitterUsername({String? id, String? val}) async {
    bool updated = true;
    String? error;
    await userRef.doc(id).update({
      "twitterUsername": val,
    }).catchError((e) {
      error = e.message;
    });
    if (error != null) {
      updated = false;
    }
    return updated;
  }

  Future<bool> updateTwitchUsername({String? id, String? val}) async {
    bool updated = true;
    String? error;
    await userRef.doc(id).update({
      "twitchUsername": val,
    }).catchError((e) {
      error = e.message;
    });
    if (error != null) {
      updated = false;
    }
    return updated;
  }

  Future<bool> updateYoutube({String? id, String? val}) async {
    bool updated = true;
    String? error;
    await userRef.doc(id).update({
      "youtube": val,
    }).catchError((e) {
      error = e.message;
    });
    if (error != null) {
      updated = false;
    }
    return updated;
  }

  Future<bool> updateYoutubeStreamURL({String? id, String? val}) async {
    bool updated = true;
    String? error;
    await userRef.doc(id).update({
      "youtubeStreamURL": val,
    }).catchError((e) {
      error = e.message;
    });
    if (error != null) {
      updated = false;
    }
    return updated;
  }

  Future<bool> updateYoutubeStreamKey({String? id, String? val}) async {
    bool updated = true;
    String? error;
    await userRef.doc(id).update({
      "youtubeStreamKey": val,
    }).catchError((e) {
      error = e.message;
    });
    if (error != null) {
      updated = false;
    }
    return updated;
  }

  Future<bool> updateTwitchStreamURL({String? id, String? val}) async {
    bool updated = true;
    String? error;
    await userRef.doc(id).update({
      "twitchStreamURL": val,
    }).catchError((e) {
      error = e.message;
    });
    if (error != null) {
      updated = false;
    }
    return updated;
  }

  Future<bool> updateTwitchStreamKey({String? id, String? val}) async {
    bool updated = true;
    String? error;
    await userRef.doc(id).update({
      "twitchStreamKey": val,
    }).catchError((e) {
      error = e.message;
    });
    if (error != null) {
      updated = false;
    }
    return updated;
  }

  Future<bool> updateFBStreamURL({String? id, String? val}) async {
    bool updated = true;
    String? error;
    await userRef.doc(id).update({
      "fbStreamURL": val,
    }).catchError((e) {
      error = e.message;
    });
    if (error != null) {
      updated = false;
    }
    return updated;
  }

  Future<bool> updateFBStreamKey({String? id, String? val}) async {
    bool updated = true;
    String? error;
    await userRef.doc(id).update({
      "fbStreamKey": val,
    }).catchError((e) {
      error = e.message;
    });
    if (error != null) {
      updated = false;
    }
    return updated;
  }

  Future<bool> updateInterests(String uid, List tags) async {
    bool updated = true;
    String? error;
    await userRef.doc(uid).update({"tags": tags}).catchError((e) {
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

  Future<void> updateUserAppOpen({required String uid, required String zipcode}) async {
    int appOpenInMilliseconds = DateTime.now().millisecondsSinceEpoch;
    DocumentSnapshot snapshot = await userRef.doc(uid).get();
    List? nearbyZipcodes = snapshot.data()!['nearbyZipcodes'] == null ? [] : snapshot.data()!['nearbyZipcodes'];
    if (!nearbyZipcodes!.contains(zipcode)) {
      nearbyZipcodes = await _locationService.findNearestZipcodes(zipcode) ?? nearbyZipcodes;
    }
    userRef.doc(uid).update({
      'appOpenInMilliseconds': appOpenInMilliseconds,
      'lastSeenZipcode': zipcode,
      'nearbyZipcodes': nearbyZipcodes,
    });
  }

  Future<List<WebblenUser>> getFollowerSuggestions(String id, String zipcode, List? tags) async {
    //print(tags);
    List<WebblenUser> users = [];
    QuerySnapshot snapshot =
        await userRef.where("nearbyZipcodes", arrayContains: zipcode).where("suggestedAccount", isEqualTo: true).limit(10).get().catchError((e) {
      //print(e);
    });
    snapshot.docs.forEach((doc) {
      if ((doc.data()['followers'] == null || !doc.data()['followers'].contains(id)) && doc.id != id) {
        WebblenUser user = WebblenUser.fromMap(doc.data());
        if (user.id! != id) {
          users.add(user);
        }
      }
    });
    if (tags != null) {
      snapshot = await userRef.where("nearbyZipcodes", arrayContains: zipcode).limit(100).get().catchError((e) {
        //print(e);
      });
      snapshot.docs.forEach((doc) {
        if ((doc.data()['followers'] == null || !doc.data()['followers'].contains(id)) && doc.id != id) {
          WebblenUser user = WebblenUser.fromMap(doc.data());
          if (user.tags != null) {
            for (String tag in user.tags!) {
              print(tags);
              if (tags.contains(tag)) {
                if (!users.contains(user)) {
                  users.add(user);
                  break;
                }
              }
            }
          }
        }
      });
    }

    if (users.length < 10) {
      QuerySnapshot query = await userRef
          // .where("appOpenInMilliseconds", isGreaterThanOrEqualTo: val)
          .orderBy("appOpenInMilliseconds", descending: true)
          .limit(50)
          .get()
          .catchError((e) {
        //print(e);
      });
      query.docs.forEach((doc) {
        if ((doc.data()['followers'] == null || !doc.data()['followers'].contains(id)) && doc.id != id) {
          WebblenUser user = WebblenUser.fromMap(doc.data());
          if (user.id != id) {
            List existing = users.where((x) => x.id == doc.id).toList();
            if (existing.isEmpty) {
              users.add(user);
            }
          }
        }
      });
    }
    return users;
  }

  Future<bool> completeOnboarding({required String uid}) async {
    bool updated = true;
    await userRef.doc(uid).update({"onboarded": true}).catchError((e) {
      print(e.meesage);
    });
    return updated;
  }

  Future<bool> depositWebblen({required String uid, required double amount}) async {
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
