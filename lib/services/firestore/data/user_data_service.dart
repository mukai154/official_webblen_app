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
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      if (snapshotData.isNotEmpty) {
        WebblenUser user = WebblenUser.fromMap(snapshotData);
        if (user.isAdmin != null && user.isAdmin!) {
          isAdmin = true;
        }
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
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      if (snapshotData.isNotEmpty) {
        user = WebblenUser.fromMap(snapshotData);
      }
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
      Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
      user = WebblenUser.fromMap(docData);
    }
    return user;
  }

  Future<String> getCurrentFbUsername(String id) async {
    String val = "";
    DocumentSnapshot snapshot = await userRef.doc(id).get();

    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      if (snapshotData.isNotEmpty) {
        if (snapshotData['fbUsername'] != null) {
          val = snapshotData['fbUsername'];
        }
      }
    }

    return val;
  }

  Future<String> getCurrentInstaUsername(String id) async {
    String val = "";
    DocumentSnapshot snapshot = await userRef.doc(id).get();

    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      if (snapshotData.isNotEmpty) {
        if (snapshotData['instaUsername'] != null) {
          val = snapshotData['instaUsername'];
        }
      }
    }

    return val;
  }

  Future<String> getCurrentTwitterUsername(String id) async {
    String val = "";
    DocumentSnapshot snapshot = await userRef.doc(id).get();

    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      if (snapshotData.isNotEmpty) {
        if (snapshotData['twitterUsername'] != null) {
          val = snapshotData['twitterUsername'];
        }
      }
    }

    return val;
  }

  Future<String> getCurrentTwitchUsername(String id) async {
    String val = "";
    DocumentSnapshot snapshot = await userRef.doc(id).get();

    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      if (snapshotData.isNotEmpty) {
        if (snapshotData['twitchUsername'] != null) {
          val = snapshotData['twitchUsername'];
        }
      }
    }

    return val;
  }

  Future<String> getCurrentYoutube(String id) async {
    String val = "";
    DocumentSnapshot snapshot = await userRef.doc(id).get();

    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      if (snapshotData.isNotEmpty) {
        if (snapshotData['youtube'] != null) {
          val = snapshotData['youtube'];
        }
      }
    }
    return val;
  }

  Future<String> getCurrentUserWebsite(String id) async {
    String val = "";
    DocumentSnapshot snapshot = await userRef.doc(id).get();

    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      if (snapshotData.isNotEmpty) {
        if (snapshotData['website'] != null) {
          val = snapshotData['website'];
        }
      }
    }

    return val;
  }

  Future<String> getCurrentUserTwitchStreamURL(String id) async {
    String val = "";
    DocumentSnapshot snapshot = await userRef.doc(id).get();

    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      if (snapshotData.isNotEmpty) {
        if (snapshotData['twitchStreamURL'] != null) {
          val = snapshotData['twitchStreamURL'];
        }
      }
    }

    return val;
  }

  Future<String> getCurrentUserTwitchStreamKey(String id) async {
    String val = "";
    DocumentSnapshot snapshot = await userRef.doc(id).get();

    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      if (snapshotData.isNotEmpty) {
        if (snapshotData['twitchStreamKey'] != null) {
          val = snapshotData['twitchStreamKey'];
        }
      }
    }

    return val;
  }

  Future<String> getCurrentUserYoutubeStreamURL(String id) async {
    String val = "";
    DocumentSnapshot snapshot = await userRef.doc(id).get();

    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      if (snapshotData.isNotEmpty) {
        if (snapshotData['youtubeStreamURL'] != null) {
          val = snapshotData['youtubeStreamURL'];
        }
      }
    }

    return val;
  }

  Future<String> getCurrentUserYoutubeStreamKey(String id) async {
    String val = "";
    DocumentSnapshot snapshot = await userRef.doc(id).get();

    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      if (snapshotData.isNotEmpty) {
        if (snapshotData['youtubeStreamKey'] != null) {
          val = snapshotData['youtubeStreamKey'];
        }
      }
    }

    return val;
  }

  Future<String> getCurrentUserFBStreamURL(String id) async {
    String val = "";
    DocumentSnapshot snapshot = await userRef.doc(id).get();

    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      if (snapshotData.isNotEmpty) {
        if (snapshotData['fbStreamURL'] != null) {
          val = snapshotData['fbStreamURL'];
        }
      }
    }

    return val;
  }

  Future<String> getCurrentUserFBStreamKey(String id) async {
    String val = "";
    DocumentSnapshot snapshot = await userRef.doc(id).get();

    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      if (snapshotData.isNotEmpty) {
        if (snapshotData['fbStreamKey'] != null) {
          val = snapshotData['fbStreamKey'];
        }
      }
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

  Future<bool> followUser(String currentUID, String targetUserID) async {
    bool didFollow = true;
    await userRef.doc(currentUID).update({
      'following': FieldValue.arrayUnion([targetUserID])
    }).catchError((e) {
      print(e);
      didFollow = false;
    });
    await userRef.doc(targetUserID).update({
      'followers': FieldValue.arrayUnion([currentUID])
    }).catchError((e) {
      print(e);
      didFollow = false;
    });

    //follow posts by user
    if (didFollow) {
      QuerySnapshot postQuery = await postsRef.where('authorID', isEqualTo: targetUserID).get();
      postQuery.docs.forEach((doc) {
        postsRef.doc(doc.id).update({
          'suggestedUIDs': FieldValue.arrayUnion([currentUID])
        });
      });
    }
    return didFollow;
  }

  Future<bool> unFollowUser(String currentUID, String targetUserID) async {
    bool didUnfollow = true;
    await userRef.doc(currentUID).update({
      'following': FieldValue.arrayRemove([targetUserID])
    }).catchError((e) {
      print(e);
      didUnfollow = false;
    });
    await userRef.doc(targetUserID).update({
      'followers': FieldValue.arrayRemove([currentUID])
    }).catchError((e) {
      print(e);
      didUnfollow = false;
    });

    //follow posts by user
    if (didUnfollow) {
      QuerySnapshot postQuery = await postsRef.where('authorID', isEqualTo: targetUserID).get();
      postQuery.docs.forEach((doc) {
        postsRef.doc(doc.id).update({
          'suggestedUIDs': FieldValue.arrayRemove([currentUID])
        });
      });
    }
    return didUnfollow;
  }

  Future<bool> muteUser(String currentUID, String targetUserID) async {
    bool didMute = true;

    await userRef.doc(targetUserID).update({
      'mutedBy': FieldValue.arrayUnion([currentUID])
    }).catchError((e) {
      print(e);
      didMute = false;
    });

    return didMute;
  }

  Future<bool> unMuteUser(String currentUID, String targetUserID) async {
    bool didUnMute = true;

    await userRef.doc(targetUserID).update({
      'mutedBy': FieldValue.arrayRemove([currentUID])
    }).catchError((e) {
      print(e);
      didUnMute = false;
    });

    return didUnMute;
  }

  Future<void> updateUserAppOpen({required String uid, required String zipcode}) async {
    int appOpenInMilliseconds = DateTime.now().millisecondsSinceEpoch;
    DocumentSnapshot snapshot = await userRef.doc(uid).get();

    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      if (snapshotData.isNotEmpty) {
        List? nearbyZipcodes = snapshotData['nearbyZipcodes'] == null ? [] : snapshotData['nearbyZipcodes'];
        if (!nearbyZipcodes!.contains(zipcode)) {
          nearbyZipcodes = await _locationService.findNearestZipcodes(zipcode) ?? nearbyZipcodes;
        }

        userRef.doc(uid).update({
          'appOpenInMilliseconds': appOpenInMilliseconds,
          'lastSeenZipcode': zipcode,
          'nearbyZipcodes': nearbyZipcodes,
        });
      }
    }
  }

  Future<List<WebblenUser>> getFollowerSuggestions(String id, String zipcode, List? tags) async {
    //print(tags);
    List<WebblenUser> users = [];
    QuerySnapshot snapshot =
        await userRef.where("nearbyZipcodes", arrayContains: zipcode).where("suggestedAccount", isEqualTo: true).limit(10).get().catchError((e) {
      //print(e);
    });
    snapshot.docs.forEach((doc) {
      Map<String, dynamic> snapshotData = doc.data() as Map<String, dynamic>;
      if ((snapshotData['followers'] == null || !snapshotData['followers'].contains(id)) && doc.id != id) {
        WebblenUser user = WebblenUser.fromMap(snapshotData);
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
        Map<String, dynamic> snapshotData = doc.data() as Map<String, dynamic>;
        if ((snapshotData['followers'] == null || !snapshotData['followers'].contains(id)) && doc.id != id) {
          WebblenUser user = WebblenUser.fromMap(snapshotData);
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
        Map<String, dynamic> snapshotData = doc.data() as Map<String, dynamic>;
        if ((snapshotData['followers'] == null || !snapshotData['followers'].contains(id)) && doc.id != id) {
          WebblenUser user = WebblenUser.fromMap(snapshotData);
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

    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      if (snapshotData.isNotEmpty) {
        WebblenUser user = WebblenUser.fromMap(snapshotData);
        double initialBalance = user.WBLN == null ? 0.00001 : user.WBLN!;
        double newBalance = amount + initialBalance;
        await userRef.doc(uid).update({"WBLN": newBalance}).catchError((e) {
          print(e.message);
          //error = e.toString();
        });
      }
    }

    return true;
  }

  Future<bool> withdrawWebblen({String? uid, required double amount}) async {
    //String error;

    DocumentSnapshot snapshot = await userRef.doc(uid).get();

    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      if (snapshotData.isNotEmpty) {
        WebblenUser user = WebblenUser.fromMap(snapshotData);
        double initialBalance = user.WBLN == null ? 0.00001 : user.WBLN!;
        double newBalance = initialBalance - amount;

        await userRef.doc(uid).update({"WBLN": newBalance}).catchError((e) {
          print(e.message);
          //error = e.toString();
        });
      }
    }

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
