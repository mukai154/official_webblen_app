import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/models/webblen_comment.dart';
import 'package:webblen/models/webblen_post.dart';

class CommentDataService {
  final CollectionReference commentsRef = FirebaseFirestore.instance.collection("comments");
  final CollectionReference postsRef = FirebaseFirestore.instance.collection("posts");
  //CREATE
  Future<String> sendComment(String parentID, WebblenComment comment) async {
    String error;
    await commentsRef.doc(parentID).collection("comments").doc(comment.timePostedInMilliseconds.toString()).set(comment.toMap()).catchError((e) {
      error = e.details;
    });
    DocumentSnapshot snapshot = await postsRef.doc(parentID).get();
    WebblenPost post = WebblenPost.fromMap(snapshot.data());
    post.commentCount += 1;
    await postsRef.doc(parentID).update(post.toMap()).catchError((e) {
      error = e.details;
    });
    return error;
  }

  Future<String> replyToComment(String parentID, String originalCommentID, WebblenComment comment) async {
    String error;
    DocumentSnapshot snapshot = await commentsRef.doc(parentID).collection("comments").doc(originalCommentID).get();
    WebblenComment originalComment = WebblenComment.fromMap(snapshot.data());
    List replies = originalComment.replies.toList(growable: true);
    replies.add(comment.toMap());
    originalComment.replies = replies;
    originalComment.replyCount += 1;
    await commentsRef.doc(parentID).collection("comments").doc(originalCommentID).update(originalComment.toMap()).catchError((e) {
      error = e.details;
    });
    return error;
  }

  Future<String> deleteComment(String parentID, WebblenComment comment) async {
    String error;
    await commentsRef.doc(parentID).collection("comments").doc(comment.timePostedInMilliseconds.toString()).delete().catchError((e) {
      error = e.toString();
    });
    DocumentSnapshot snapshot = await postsRef.doc(parentID).get();
    WebblenPost post = WebblenPost.fromMap(snapshot.data());
    post.commentCount -= 1;
    await postsRef.doc(parentID).update(post.toMap()).catchError((e) {
      error = e.details;
    });
    return error;
  }

  Future<String> deleteReply(String parentID, String originalCommentID, WebblenComment comment) async {
    String error;
    DocumentSnapshot snapshot = await commentsRef.doc(parentID).collection("comments").doc(originalCommentID).get();
    WebblenComment originalComment = WebblenComment.fromMap(snapshot.data());
    List replies = originalComment.replies.toList(growable: true);
    int replyIndex = replies.indexWhere((element) => element['message'] == comment.message);
    replies.removeAt(replyIndex);
    originalComment.replies = replies;
    originalComment.replyCount -= 1;
    await commentsRef.doc(parentID).collection("comments").doc(originalCommentID).update(originalComment.toMap()).catchError((e) {
      error = e.details;
    });
    return error;
  }
}
