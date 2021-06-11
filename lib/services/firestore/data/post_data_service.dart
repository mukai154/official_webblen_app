import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/firestore/common/firestore_storage_service.dart';

class PostDataService {
  CollectionReference postsRef = FirebaseFirestore.instance.collection('webblen_posts');
  int dateTimeInMilliseconds1YearAgo = DateTime.now().millisecondsSinceEpoch - 31500000000;
  DialogService? _dialogService = locator<DialogService>();
  FirestoreStorageService? _firestoreStorageService = locator<FirestoreStorageService>();
  CustomDialogService _customDialogService = locator<CustomDialogService>();

  Future checkIfPostExists(String id) async {
    bool exists = false;
    DocumentSnapshot snapshot = await postsRef.doc(id).get().catchError((e) {
      return e.message;
    });
    if (snapshot.exists) {
      exists = true;
    }
    return exists;
  }

  FutureOr<bool> checkIfPostSaved({required String? userID, required String? postID}) async {
    bool saved = false;
    String? error;
    DocumentSnapshot snapshot = await postsRef.doc(postID).get().catchError((e) {
      //return e.message;
    });
    if (error != null) {
      return false;
    }
    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      if (snapshotData.isNotEmpty) {
        List savedBy = snapshotData['savedBy'] == null ? [] : snapshotData['savedBy'].toList(growable: true);
        if (!savedBy.contains(userID)) {
          saved = false;
        } else {
          saved = true;
        }
      }
    }

    return saved;
  }

  Future saveUnsavePost({required String? userID, required String? postID, required bool savedPost}) async {
    List? savedBy = [];
    String? error;
    DocumentSnapshot snapshot = await postsRef.doc(postID).get().catchError((e) {
      _dialogService!.showDialog(
        title: "Post Error",
        description: e.message,
      );
      error = e.message;
    });

    if (error != null) {
      return false;
    }

    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      if (snapshotData.isNotEmpty) {
        savedBy = snapshotData['savedBy'] == null ? [] : snapshotData['savedBy'].toList(growable: true);
        if (savedPost) {
          if (!savedBy!.contains(userID)) {
            savedBy.add(userID);
          }
        } else {
          if (savedBy!.contains(userID)) {
            savedBy.remove(userID);
          }
        }
        await postsRef.doc(postID).update({'savedBy': savedBy});
      }
    }
    return savedBy.contains(userID);
  }

  reportPost({required String? postID, required String? reporterID}) async {
    String? error;
    DocumentSnapshot snapshot = await postsRef.doc(postID).get().catchError((e) {
      _dialogService!.showDialog(
        title: "Report Error",
        description: e.message,
      );
      error = e.message;
    });
    if (error != null) {
      return;
    }

    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      if (snapshotData.isNotEmpty) {
        List reportedBy = snapshotData['reportedBy'] == null ? [] : snapshotData['reportedBy'].toList(growable: true);
        if (reportedBy.contains(reporterID)) {
          return _dialogService!.showDialog(
            title: "Report Error",
            description: "You've already reported this post. This post is currently pending review.",
          );
        } else {
          reportedBy.add(reporterID);
          postsRef.doc(postID).update({"reportedBy": reportedBy});
          return _dialogService!.showDialog(
            title: "Report Error",
            description: "This post is now pending review",
          );
        }
      }
    }
  }

  Future createPost({required WebblenPost post}) async {
    await postsRef.doc(post.id).set(post.toMap()).catchError((e) {
      return e.message;
    });
  }

  Future updatePost({required WebblenPost post}) async {
    await postsRef.doc(post.id).update(post.toMap()).catchError((e) {
      return e.message;
    });
  }

  Future deletePost({required WebblenPost post}) async {
    await postsRef.doc(post.id).delete();
    if (post.imageURL != null) {
      await _firestoreStorageService!.deleteImage(storageBucket: 'images', folderName: 'posts', fileName: post.id!);
    }
  }

  Future deleteEventOrStreamPost({required String? eventOrStreamID, required String postType}) async {
    QuerySnapshot snapshot = await postsRef.where("parentID", isEqualTo: eventOrStreamID).get();
    snapshot.docs.forEach((doc) async {
      await postsRef.doc(doc.id).delete();
      if (postType == 'event') {
        await _firestoreStorageService!.deleteImage(storageBucket: 'images', folderName: 'events', fileName: eventOrStreamID!);
      } else {
        await _firestoreStorageService!.deleteImage(storageBucket: 'images', folderName: 'streams', fileName: eventOrStreamID!);
      }
    });
  }

  Future getPostByID(String? id) async {
    WebblenPost? post;
    String? error;
    DocumentSnapshot snapshot = await postsRef.doc(id).get().catchError((e) {
      _dialogService!.showDialog(
        title: "Post Error",
        description: e.message,
      );
      error = e.message;
    });
    if (error != null) {
      return post;
    }

    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      if (snapshotData.isNotEmpty) {
        post = WebblenPost.fromMap(snapshotData);
      }
    } else {
      _dialogService!.showDialog(
        title: "Post Error",
        description: "This post no longer exists",
      );
      return post;
    }
    return post;
  }

  Future<WebblenPost> getPostToEditByID(String? id) async {
    WebblenPost post = WebblenPost();
    String? error;
    DocumentSnapshot snapshot = await postsRef.doc(id).get().catchError((e) {
      error = e.message;
    });

    if (error != null) {
      _customDialogService.showErrorDialog(description: error!);
      return post;
    }

    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;
      if (snapshotData.isNotEmpty) {
        post = WebblenPost.fromMap(snapshotData);
      }
    }

    return post;
  }

  ///READ & QUERIES
  Future<List<DocumentSnapshot>> loadPosts({
    required String areaCode,
    required int resultsLimit,
    required String? tagFilter,
    required String? sortBy,
  }) async {
    Query query;
    List<DocumentSnapshot> docs = [];
    String? error;
    if (areaCode.isEmpty) {
      query = postsRef
          .where('postDateTimeInMilliseconds', isGreaterThan: dateTimeInMilliseconds1YearAgo)
          .orderBy('postDateTimeInMilliseconds', descending: true)
          .limit(resultsLimit);
    } else {
      query = postsRef
          .where('nearbyZipcodes', arrayContains: areaCode)
          .where('postDateTimeInMilliseconds', isGreaterThan: dateTimeInMilliseconds1YearAgo)
          .orderBy('postDateTimeInMilliseconds', descending: true)
          .limit(resultsLimit);
    }
    QuerySnapshot snapshot = await query.get().catchError((e) {
      if (!e.message.contains("insufficient permissions")) {
        _dialogService!.showDialog(
          title: "Insufficient Permissions",
          description: e.message,
        );
      }
      error = e.message;
    });
    if (error != null) {
      return docs;
    }
    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
      if (tagFilter!.isNotEmpty) {
        docs.removeWhere((doc) => !(doc.data() as Map<String, dynamic>)['tags'].contains(tagFilter));
      }
      if (sortBy == "Latest") {
        docs.sort((docA, docB) =>
            (docB.data() as Map<String, dynamic>)['postDateTimeInMilliseconds'].compareTo((docA.data() as Map<String, dynamic>)['postDateTimeInMilliseconds']));
      } else {
        docs.sort((docA, docB) => (docB.data() as Map<String, dynamic>)['commentCount'].compareTo((docA.data() as Map<String, dynamic>)['commentCount']));
      }
    }
    return docs;
  }

  Future<List<DocumentSnapshot>> loadAdditionalPosts({
    required DocumentSnapshot lastDocSnap,
    required String areaCode,
    required int resultsLimit,
    required String? tagFilter,
    required String? sortBy,
  }) async {
    Query query;
    List<DocumentSnapshot> docs = [];
    String? error;
    if (areaCode.isEmpty) {
      query = postsRef
          .where('postDateTimeInMilliseconds', isGreaterThan: dateTimeInMilliseconds1YearAgo)
          .orderBy('postDateTimeInMilliseconds', descending: true)
          .startAfterDocument(lastDocSnap)
          .limit(resultsLimit);
    } else {
      query = postsRef
          .where('nearbyZipcodes', arrayContains: areaCode)
          .where('postDateTimeInMilliseconds', isGreaterThan: dateTimeInMilliseconds1YearAgo)
          .orderBy('postDateTimeInMilliseconds', descending: true)
          .startAfterDocument(lastDocSnap)
          .limit(resultsLimit);
    }
    QuerySnapshot snapshot = await query.get().catchError((e) {
      if (!e.message.contains("insufficient permissions")) {
        _dialogService!.showDialog(
          title: "insufficient permissions",
          description: e.message,
        );
      }
      error = e.message;
    });
    if (error != null) {
      return docs;
    }
    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
      if (tagFilter!.isNotEmpty) {
        docs.removeWhere((doc) => !(doc.data() as Map<String, dynamic>)['tags'].contains(tagFilter));
      }
      if (sortBy == "Latest") {
        docs.sort((docA, docB) =>
            (docB.data() as Map<String, dynamic>)['postDateTimeInMilliseconds'].compareTo((docA.data() as Map<String, dynamic>)['postDateTimeInMilliseconds']));
      } else {
        docs.sort((docA, docB) => (docB.data() as Map<String, dynamic>)['commentCount'].compareTo((docA.data() as Map<String, dynamic>)['commentCount']));
      }
    }
    return docs;
  }

  Future<List<DocumentSnapshot>> loadPostsByUserID({
    required String? id,
    required int resultsLimit,
  }) async {
    List<DocumentSnapshot> docs = [];
    String? error;
    Query query = postsRef.where('authorID', isEqualTo: id).orderBy('postDateTimeInMilliseconds', descending: true).limit(resultsLimit);
    QuerySnapshot snapshot = await query.get().catchError((e) {
      if (!e.message.contains("insufficient permissions")) {
        _dialogService!.showDialog(
          title: "insufficient permissions",
          description: e.message,
        );
      }
      error = e.message;
    });
    if (error != null) {
      return docs;
    }
    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
    }
    return docs;
  }

  Future<List<DocumentSnapshot>> loadAdditionalPostsByUserID({
    required String? id,
    required DocumentSnapshot lastDocSnap,
    required int resultsLimit,
  }) async {
    List<DocumentSnapshot> docs = [];
    String? error;
    Query query =
        postsRef.where('authorID', isEqualTo: id).orderBy('postDateTimeInMilliseconds', descending: true).startAfterDocument(lastDocSnap).limit(resultsLimit);
    QuerySnapshot snapshot = await query.get().catchError((e) {
      print(e.message);
      error = e.message;
    });
    if (error != null) {
      return docs;
    }
    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
    }
    return docs;
  }

  Future<List<DocumentSnapshot>> loadSavedPosts({
    required String? id,
    required int resultsLimit,
  }) async {
    List<DocumentSnapshot> docs = [];
    String? error;
    Query query = postsRef.where('savedBy', arrayContains: id).orderBy('postDateTimeInMilliseconds', descending: true).limit(resultsLimit);
    QuerySnapshot snapshot = await query.get().catchError((e) {
      print(e.message);
      error = e.message;
    });
    if (error != null) {
      return docs;
    }
    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
    }
    return docs;
  }

  Future<List<DocumentSnapshot>> loadAdditionalSavedPosts({
    required String? id,
    required DocumentSnapshot lastDocSnap,
    required int resultsLimit,
  }) async {
    List<DocumentSnapshot> docs = [];
    String? error;
    Query query = postsRef
        .where('savedBy', arrayContains: id)
        .orderBy('postDateTimeInMilliseconds', descending: true)
        .startAfterDocument(lastDocSnap)
        .limit(resultsLimit);
    QuerySnapshot snapshot = await query.get().catchError((e) {
      print(e.message);
      error = e.message;
    });
    if (error != null) {
      return docs;
    }
    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
    }
    return docs;
  }
}
