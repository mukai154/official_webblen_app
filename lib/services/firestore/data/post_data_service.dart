import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/services/firestore/common/firestore_storage_service.dart';

class PostDataService {
  CollectionReference postsRef = FirebaseFirestore.instance.collection('posts');
  int dateTimeInMilliseconds1YearAgo = DateTime.now().millisecondsSinceEpoch - 31500000000;
  SnackbarService _snackbarService = locator<SnackbarService>();
  FirestoreStorageService _firestoreStorageService = locator<FirestoreStorageService>();

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

  Future checkIfPostSaved({@required String userID, @required String postID}) async {
    bool saved = false;
    DocumentSnapshot snapshot = await postsRef.doc(postID).get().catchError((e) {
      return e.message;
    });
    if (snapshot.exists) {
      List savedBy = snapshot.data()['savedBy'] == null ? [] : snapshot.data()['savedBy'].toList(growable: true);
      if (!savedBy.contains(userID)) {
        saved = false;
      } else {
        saved = true;
      }
    }
    return saved;
  }

  Future saveUnsavePost({@required String userID, @required String postID, @required bool savedPost}) async {
    List savedBy = [];
    DocumentSnapshot snapshot = await postsRef.doc(postID).get().catchError((e) {
      _snackbarService.showSnackbar(
        title: 'Post Error',
        message: e.message,
        duration: Duration(seconds: 5),
      );
      return false;
    });
    if (snapshot.exists) {
      savedBy = snapshot.data()['savedBy'] == null ? [] : snapshot.data()['savedBy'].toList(growable: true);
      if (savedPost) {
        if (!savedBy.contains(userID)) {
          savedBy.add(userID);
        }
      } else {
        if (savedBy.contains(userID)) {
          savedBy.remove(userID);
        }
      }
      await postsRef.doc(postID).update({'savedBy': savedBy});
    }
    return savedBy.contains(userID);
  }

  reportPost({@required String postID, @required String reporterID}) async {
    DocumentSnapshot snapshot = await postsRef.doc(postID).get().catchError((e) {
      return _snackbarService.showSnackbar(
        title: 'Post Error',
        message: e.message,
        duration: Duration(seconds: 5),
      );
    });
    if (snapshot.exists) {
      List reportedBy = snapshot.data()['reportedBy'] == null ? [] : snapshot.data()['reportedBy'].toList(growable: true);
      if (reportedBy.contains(reporterID)) {
        return _snackbarService.showSnackbar(
          title: 'Report Error',
          message: "You've already reported this post. This post is currently pending review.",
          duration: Duration(seconds: 5),
        );
      } else {
        reportedBy.add(reporterID);
        postsRef.doc(postID).update({"reportedBy": reportedBy});
        return _snackbarService.showSnackbar(
          title: 'Post Reported',
          message: "This post is now pending review.",
          duration: Duration(seconds: 5),
        );
      }
    }
  }

  Future createPost({@required WebblenPost post}) async {
    await postsRef.doc(post.id).set(post.toMap()).catchError((e) {
      return e.message;
    });
  }

  Future updatePost({@required WebblenPost post}) async {
    await postsRef.doc(post.id).update(post.toMap()).catchError((e) {
      return e.message;
    });
  }

  Future deletePost({@required WebblenPost post}) async {
    await postsRef.doc(post.id).delete();
    if (post.imageURL != null) {
      await _firestoreStorageService.deleteImage(storageBucket: 'images', folderName: 'posts', fileName: post.id);
    }
  }

  Future getPostByID(String id) async {
    WebblenPost post;
    DocumentSnapshot snapshot = await postsRef.doc(id).get().catchError((e) {
      _snackbarService.showSnackbar(
        title: 'Post Error',
        message: e.message,
        duration: Duration(seconds: 5),
      );
      return null;
    });
    if (snapshot.exists) {
      post = WebblenPost.fromMap(snapshot.data());
    }
    return post;
  }

  ///READ & QUERIES
  Future<List<DocumentSnapshot>> loadPosts({
    @required String areaCode,
    @required int resultsLimit,
    @required String tagFilter,
    @required String sortBy,
  }) async {
    Query query;
    List<DocumentSnapshot> docs = [];
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
      _snackbarService.showSnackbar(
        title: 'Error',
        message: e.message,
        duration: Duration(seconds: 5),
      );
      return docs;
    });
    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
      if (tagFilter.isNotEmpty) {
        docs.removeWhere((doc) => !doc.data()['tags'].contains(tagFilter));
      }
      if (sortBy == "Latest") {
        docs.sort((docA, docB) => docB.data()['postDateTimeInMilliseconds'].compareTo(docA.data()['postDateTimeInMilliseconds']));
      } else {
        docs.sort((docA, docB) => docB.data()['commentCount'].compareTo(docA.data()['commentCount']));
      }
    }
    return docs;
  }

  Future<List<DocumentSnapshot>> loadAdditionalPosts(
      {@required DocumentSnapshot lastDocSnap,
      @required String areaCode,
      @required int resultsLimit,
      @required String tagFilter,
      @required String sortBy}) async {
    Query query;
    List<DocumentSnapshot> docs = [];
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
      _snackbarService.showSnackbar(
        title: 'Error',
        message: e.message,
        duration: Duration(seconds: 5),
      );
    });
    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
      if (tagFilter.isNotEmpty) {
        docs.removeWhere((doc) => !doc.data()['tags'].contains(tagFilter));
      }
      if (sortBy == "Latest") {
        docs.sort((docA, docB) => docB.data()['postDateTimeInMilliseconds'].compareTo(docA.data()['postDateTimeInMilliseconds']));
      } else {
        docs.sort((docA, docB) => docB.data()['commentCount'].compareTo(docA.data()['commentCount']));
      }
    }
    return docs;
  }

  Future<List<DocumentSnapshot>> loadPostsByUserID({@required String id, @required int resultsLimit}) async {
    List<DocumentSnapshot> docs = [];
    Query query = postsRef.where('authorID', isEqualTo: id).orderBy('postDateTimeInMilliseconds', descending: true).limit(resultsLimit);
    QuerySnapshot snapshot = await query.get().catchError((e) {
      _snackbarService.showSnackbar(
        title: 'Error',
        message: e.message,
        duration: Duration(seconds: 5),
      );
    });
    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
    }
    return docs;
  }

  Future<List<DocumentSnapshot>> loadAdditionalPostsByUserID({
    @required String id,
    @required DocumentSnapshot lastDocSnap,
    @required int resultsLimit,
  }) async {
    List<DocumentSnapshot> docs = [];
    Query query =
        postsRef.where('authorID', isEqualTo: id).orderBy('postDateTimeInMilliseconds', descending: true).startAfterDocument(lastDocSnap).limit(resultsLimit);
    QuerySnapshot snapshot = await query.get().catchError((e) {
      _snackbarService.showSnackbar(
        title: 'Error',
        message: e.message,
        duration: Duration(seconds: 5),
      );
    });
    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
    }
    return docs;
  }
}
