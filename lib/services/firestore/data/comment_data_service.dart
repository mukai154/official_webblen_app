import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/models/webblen_post_comment.dart';

class CommentDataService {
  final SnackbarService _snackbarService = locator<SnackbarService>();
  final CollectionReference commentsRef = FirebaseFirestore.instance.collection("comments");
  final CollectionReference postsRef = FirebaseFirestore.instance.collection("webblen_posts");

  //CREATE
  Future<String?> sendComment(String? parentID, String? postAuthorID, WebblenPostComment comment) async {
    String? error;
    await commentsRef.doc(parentID).collection("comments").doc(comment.timePostedInMilliseconds.toString()).set(comment.toMap()).catchError((e) {
      error = e.details;
    });

    DocumentSnapshot snapshot = await postsRef.doc(parentID).get();
    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;

      if (snapshotData.isNotEmpty) {
        WebblenPost post = WebblenPost.fromMap(snapshotData);
        post.commentCount = post.commentCount! + 1;
        await postsRef.doc(parentID).update(post.toMap()).catchError((e) {
          error = e.details;
        });
      }
    } else {
      error = "This post no longer exists";
    }

    return error;
  }

  Future<String?> replyToComment(String? parentID, String? originaCommenterUID, String originalCommentID, WebblenPostComment comment) async {
    String? error;
    DocumentSnapshot snapshot = await commentsRef.doc(parentID).collection("comments").doc(originalCommentID).get();
    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;

      if (snapshotData.isNotEmpty) {
        WebblenPostComment originalComment = WebblenPostComment.fromMap(snapshotData);
        List replies = originalComment.replies!.toList(growable: true);
        replies.add(comment.toMap());
        originalComment.replies = replies;
        originalComment.replyCount = originalComment.replyCount! + 1;
        await commentsRef.doc(parentID).collection("comments").doc(originalCommentID).update(originalComment.toMap()).catchError((e) {
          error = e.details;
        });
      }
    } else {
      error = "This post no longer exists";
    }

    return error;
  }

  Future<String?> deleteComment(String? parentID, WebblenPostComment comment) async {
    String? error;
    //comment id is time posted in milliseconds
    String commentID = comment.timePostedInMilliseconds.toString();
    await commentsRef.doc(parentID).collection("comments").doc(commentID).delete().catchError((e) {
      error = e.toString();
    });

    DocumentSnapshot snapshot = await postsRef.doc(parentID).get();
    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;

      if (snapshotData.isNotEmpty) {
        WebblenPost post = WebblenPost.fromMap(snapshotData);
        post.commentCount = post.commentCount! - 1;
        await postsRef.doc(parentID).update(post.toMap()).catchError((e) {
          error = e.details;
        });
      }
    } else {
      error = "This post no longer exists";
    }

    return error;
  }

  Future<String?> deleteReply(String? parentID, WebblenPostComment comment) async {
    String? error;
    DocumentSnapshot snapshot = await commentsRef.doc(parentID).collection("comments").doc(comment.originalReplyCommentID).get();
    Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;

    if (snapshot.exists) {
      if (snapshotData.isNotEmpty) {
        WebblenPostComment originalComment = WebblenPostComment.fromMap(snapshotData);
        List replies = originalComment.replies!.toList(growable: true);
        int replyIndex = replies.indexWhere((element) => element['message'] == comment.message);
        replies.removeAt(replyIndex);
        originalComment.replies = replies;
        originalComment.replyCount = originalComment.replyCount! - 1;
        await commentsRef.doc(parentID).collection("comments").doc(comment.originalReplyCommentID).update(originalComment.toMap()).catchError((e) {
          error = e.details;
        });
      }
    } else {
      error = "This post no longer exists";
    }

    return error;
  }

  ///QUERY DATA
  //Load Comments Created
  Future<List<DocumentSnapshot>> loadComments({
    required String? postID,
    required int resultsLimit,
  }) async {
    List<DocumentSnapshot> docs = [];
    String? error;
    Query query = commentsRef.doc(postID).collection('comments').orderBy('timePostedInMilliseconds', descending: true).limit(resultsLimit);

    QuerySnapshot snapshot = await query.get().catchError((e) {
      error = e.message;
      _snackbarService.showSnackbar(
        title: 'Error Loading Comments',
        message: e.message,
        duration: Duration(seconds: 5),
      );
    });

    if (error != null) {
      return docs;
    }

    if (snapshot.docs.isNotEmpty) {
      docs = snapshot.docs;
    }
    return docs;
  }

  //Load Additional Comments
  Future<List<DocumentSnapshot>> loadAdditionalComments({
    required String? postID,
    required DocumentSnapshot lastDocSnap,
    required int resultsLimit,
  }) async {
    Query query;
    List<DocumentSnapshot> docs = [];
    query = commentsRef
        .doc(postID)
        .collection('comments')
        .orderBy('timePostedInMilliseconds', descending: true)
        .startAfterDocument(lastDocSnap)
        .limit(resultsLimit);

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
