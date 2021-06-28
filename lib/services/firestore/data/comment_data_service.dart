import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_comment.dart';
import 'package:webblen/models/webblen_live_stream.dart';
import 'package:webblen/models/webblen_post.dart';

class CommentDataService {
  final SnackbarService _snackbarService = locator<SnackbarService>();
  final CollectionReference commentsRef = FirebaseFirestore.instance.collection("comments");
  final CollectionReference videoCommentsRef = FirebaseFirestore.instance.collection("video_comments");
  final CollectionReference streamsRef = FirebaseFirestore.instance.collection("webblen_live_streams");
  final CollectionReference postsRef = FirebaseFirestore.instance.collection("webblen_posts");

  //CREATE
  Future<String?> sendComment(String? parentID, String? postAuthorID, WebblenComment comment) async {
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

  Future<String?> sendVideoComment(String? parentID, String? postAuthorID, WebblenComment comment) async {
    String? error;
    await videoCommentsRef.doc(parentID).collection("comments").doc(comment.timePostedInMilliseconds.toString()).set(comment.toMap()).catchError((e) {
      error = e.details;
    });

    DocumentSnapshot snapshot = await streamsRef.doc(parentID).get();
    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;

      if (snapshotData.isNotEmpty) {
        WebblenLiveStream stream = WebblenLiveStream.fromMap(snapshotData);
        stream.commentCount = stream.commentCount! + 1;
        await streamsRef.doc(parentID).update({
          'commentCount': stream.commentCount,
        }).catchError((e) {
          error = e.details;
        });
      }
    } else {
      error = "This video no longer exists";
    }

    return error;
  }

  Future<String?> replyToComment(String? parentID, String? originaCommenterUID, String originalCommentID, WebblenComment comment) async {
    String? error;
    DocumentSnapshot snapshot = await commentsRef.doc(parentID).collection("comments").doc(originalCommentID).get();
    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;

      if (snapshotData.isNotEmpty) {
        WebblenComment originalComment = WebblenComment.fromMap(snapshotData);
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

  Future<String?> replyToVideoComment(String? parentID, String? originaCommenterUID, String originalCommentID, WebblenComment comment) async {
    String? error;
    DocumentSnapshot snapshot = await videoCommentsRef.doc(parentID).collection("comments").doc(originalCommentID).get();
    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;

      if (snapshotData.isNotEmpty) {
        WebblenComment originalComment = WebblenComment.fromMap(snapshotData);
        List replies = originalComment.replies!.toList(growable: true);
        replies.add(comment.toMap());
        originalComment.replies = replies;
        originalComment.replyCount = originalComment.replyCount! + 1;
        await videoCommentsRef.doc(parentID).collection("comments").doc(originalCommentID).update(originalComment.toMap()).catchError((e) {
          error = e.details;
        });
      }
    } else {
      error = "This video no longer exists";
    }

    return error;
  }

  Future<String?> deleteComment(String? parentID, WebblenComment comment) async {
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

  Future<String?> deleteVideoComment(String? parentID, WebblenComment comment) async {
    String? error;
    //comment id is time posted in milliseconds
    String commentID = comment.timePostedInMilliseconds.toString();
    await videoCommentsRef.doc(parentID).collection("comments").doc(commentID).delete().catchError((e) {
      error = e.toString();
    });

    DocumentSnapshot snapshot = await postsRef.doc(parentID).get();
    if (snapshot.exists) {
      Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;

      if (snapshotData.isNotEmpty) {
        WebblenLiveStream stream = WebblenLiveStream.fromMap(snapshotData);
        stream.commentCount = stream.commentCount! - 1;
        await streamsRef.doc(parentID).update(stream.toMap()).catchError((e) {
          error = e.details;
        });
      }
    } else {
      error = "This video no longer exists";
    }

    return error;
  }

  Future<String?> deleteReply(String? parentID, WebblenComment comment) async {
    String? error;
    DocumentSnapshot snapshot = await commentsRef.doc(parentID).collection("comments").doc(comment.originalReplyCommentID).get();
    Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;

    if (snapshot.exists) {
      if (snapshotData.isNotEmpty) {
        WebblenComment originalComment = WebblenComment.fromMap(snapshotData);
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

  Future<String?> deleteVideoCommentReply(String? parentID, WebblenComment comment) async {
    String? error;
    DocumentSnapshot snapshot = await videoCommentsRef.doc(parentID).collection("comments").doc(comment.originalReplyCommentID).get();
    Map<String, dynamic> snapshotData = snapshot.data() as Map<String, dynamic>;

    if (snapshot.exists) {
      if (snapshotData.isNotEmpty) {
        WebblenComment originalComment = WebblenComment.fromMap(snapshotData);
        List replies = originalComment.replies!.toList(growable: true);
        int replyIndex = replies.indexWhere((element) => element['message'] == comment.message);
        replies.removeAt(replyIndex);
        originalComment.replies = replies;
        originalComment.replyCount = originalComment.replyCount! - 1;
        await videoCommentsRef.doc(parentID).collection("comments").doc(comment.originalReplyCommentID).update(originalComment.toMap()).catchError((e) {
          error = e.details;
        });
      }
    } else {
      error = "This video no longer exists";
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

  Future<List<DocumentSnapshot>> loadVideoComments({
    required String? streamID,
    required int resultsLimit,
  }) async {
    List<DocumentSnapshot> docs = [];
    String? error;
    Query query = videoCommentsRef.doc(streamID).collection('comments').orderBy('timePostedInMilliseconds', descending: true).limit(resultsLimit);

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

  Future<List<DocumentSnapshot>> loadAdditionalVideoComments({
    required String? streamID,
    required DocumentSnapshot lastDocSnap,
    required int resultsLimit,
  }) async {
    Query query;
    List<DocumentSnapshot> docs = [];
    query = videoCommentsRef
        .doc(streamID)
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
