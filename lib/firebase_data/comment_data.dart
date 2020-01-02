import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/models/comment.dart';
import 'dart:math';

class CommentDataService {

  final CollectionReference commentRef = Firestore.instance.collection("comments");

  Future<String> createComment(Comment comment) async {
    String error = "";
    await commentRef.document(comment.commentKey).setData(comment.toMap()).whenComplete(() {
    }).catchError((e) {
      error = e.toString();
    });
    return error;
  }

  Future<String> deleteComment(String commentKey) async {
    String error = "";
    await commentRef.document(commentKey).delete().whenComplete(() {
    }).catchError((e) {
      error = e.toString();
    });
    return error;
  }

  Future<Null> deleteComments(String postID) async {
    QuerySnapshot querySnapshot = await commentRef.where('postID', isEqualTo: postID).getDocuments();
    querySnapshot.documents.forEach((comDoc){
      commentRef.document(comDoc.documentID).delete();
    });
  }

  Future<Null> startChat(String postID) async {
    Comment comment = Comment(
        postID: postID,
        content: 'Begin Chat Below',
        contentType: 'start',
        postDateInMilliseconds: DateTime.now().millisecondsSinceEpoch
    );
    await commentRef.document(Random().nextInt(999999999).toString()).setData(comment.toMap()).whenComplete(() {
    }).catchError((e) {
    });
  }


}

class RequestCommentDataService {

  final CollectionReference reqCommentRef = Firestore.instance.collection("request_comments");

  Future<String> createComment(Comment comment) async {
    String error = "";
    await reqCommentRef.document(comment.commentKey).setData(comment.toMap()).whenComplete(() {
    }).catchError((e) {
      error = e.toString();
    });
    return error;
  }

  Future<String> deleteComment(String commentKey) async {
    String error = "";
    await reqCommentRef.document(commentKey).delete().whenComplete(() {
    }).catchError((e) {
      error = e.toString();
    });
    return error;
  }

  Future<Null> deleteComments(String reqID) async {
    QuerySnapshot querySnapshot = await reqCommentRef.where('requestID', isEqualTo: reqID).getDocuments();
    querySnapshot.documents.forEach((comDoc){
      reqCommentRef.document(comDoc.documentID).delete();
    });
  }

  Future<Null> startChat(String postID) async {
    Comment comment = Comment(
        postID: postID,
        content: 'Begin Chat Below',
        contentType: 'start',
        postDateInMilliseconds: DateTime.now().millisecondsSinceEpoch
    );
    await reqCommentRef.document(Random().nextInt(999999999).toString()).setData(comment.toMap()).whenComplete(() {
    }).catchError((e) {
    });
  }


}