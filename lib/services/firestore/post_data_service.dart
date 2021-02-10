import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/models/webblen_post.dart';

class PostDataService {
  CollectionReference postsRef = FirebaseFirestore.instance.collection('posts');
  int dateTimeInMilliseconds1MonthAgo = DateTime.now().millisecondsSinceEpoch - 2628000000;
  SnackbarService _snackbarService = locator<SnackbarService>();

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

  Future createPost({
    @required String id,
    @required String parentID,
    @required String authorID,
    @required String webAppLink,
    @required String imageURL,
    @required List nearbyZipcodes,
    @required bool paidOut,
    @required List participantIDs,
    @required String city,
    @required String province,
    @required int postDateTimeInMilliseconds,
    @required List savedBy,
    @required List sharedComs,
    @required List tags,
    @required List followers,
    @required bool reported,
    @required int commentCount,
    @required String postType,
    @required String body,
  }) async {
    WebblenPost post = WebblenPost(
      id: id,
      parentID: parentID,
      authorID: authorID,
      webAppLink: webAppLink,
      imageURL: imageURL,
      nearbyZipcodes: nearbyZipcodes,
      paidOut: paidOut,
      participantIDs: participantIDs,
      city: city,
      province: province,
      postDateTimeInMilliseconds: postDateTimeInMilliseconds,
      savedBy: savedBy,
      sharedComs: sharedComs,
      tags: tags,
      followers: followers,
      reported: reported,
      commentCount: commentCount,
      postType: postType,
      body: body,
    );

    await postsRef.doc(post.id).set(post.toMap()).catchError((e) {
      return e.message;
    });
  }

  Future getPostByID(String id) async {
    WebblenPost post;
    DocumentSnapshot snapshot = await postsRef.doc(id).get().catchError((e) {
      print(e.message);
      return _snackbarService.showSnackbar(
        title: 'Post Error',
        message: e.message,
        duration: Duration(seconds: 5),
      );
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
    print(tagFilter);
    Query query;
    List<DocumentSnapshot> docs = [];
    if (areaCode.isEmpty) {
      query = postsRef
          .where('postDateTimeInMilliseconds', isGreaterThan: dateTimeInMilliseconds1MonthAgo)
          .orderBy('postDateTimeInMilliseconds', descending: true)
          .limit(resultsLimit);
    } else {
      query = postsRef
          .where('nearbyZipcodes', arrayContains: areaCode)
          .where('postDateTimeInMilliseconds', isGreaterThan: dateTimeInMilliseconds1MonthAgo)
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
    print(tagFilter);
    Query query;
    List<DocumentSnapshot> docs = [];
    if (areaCode.isEmpty) {
      query = postsRef
          .where('postDateTimeInMilliseconds', isGreaterThan: dateTimeInMilliseconds1MonthAgo)
          .orderBy('postDateTimeInMilliseconds', descending: true)
          .startAfterDocument(lastDocSnap)
          .limit(resultsLimit);
    } else {
      query = postsRef
          .where('nearbyZipcodes', arrayContains: areaCode)
          .where('postDateTimeInMilliseconds', isGreaterThan: dateTimeInMilliseconds1MonthAgo)
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
}
