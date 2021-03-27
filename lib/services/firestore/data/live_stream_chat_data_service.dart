import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/models/webblen_stream_chat_message.dart';

class LiveStreamChatDataService {
  final CollectionReference chatRef = FirebaseFirestore.instance.collection("webblen_live_stream_chats");

  //CREATE
  Future<String> joinChatStream({@required String streamID, @required String uid, @required bool isHost, @required String username}) async {
    String error;
    WebblenStreamChatMessage message = WebblenStreamChatMessage(
      senderUID: uid,
      username: 'system',
      message: isHost ? '@$username has started streaming!' : '@$username has joined',
      timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
    );

    await chatRef.doc(streamID).collection("messages").doc(message.timePostedInMilliseconds.toString()).set(message.toMap()).catchError((e) {
      error = e.details;
    });

    return error;
  }

  Future<String> sendLeftChatStreamMessage({@required String streamID, @required String uid, @required bool isHost, @required String username}) async {
    String error;
    WebblenStreamChatMessage message = WebblenStreamChatMessage(
      senderUID: uid,
      username: 'system',
      message: '@$username has stopped streaming',
      timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
    );
    await chatRef.doc(streamID).collection("messages").doc(message.timePostedInMilliseconds.toString()).set(message.toMap()).catchError((e) {
      error = e.details;
    });
    return error;
  }

  Future<String> sendCheckIntoStreamMessage({@required String streamID, @required String uid, @required String username}) async {
    String error;
    WebblenStreamChatMessage message = WebblenStreamChatMessage(
      senderUID: uid,
      username: 'system',
      message: '@$username has checked in',
      timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
    );
    await chatRef.doc(streamID).collection("messages").doc(message.timePostedInMilliseconds.toString()).set(message.toMap()).catchError((e) {
      error = e.details;
    });
    return error;
  }

  Future<String> sendCheckoutOfStream({@required String streamID, @required String uid, @required String username}) async {
    String error;
    WebblenStreamChatMessage message = WebblenStreamChatMessage(
      senderUID: uid,
      username: 'system',
      message: '@$username has checked out',
      timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
    );
    await chatRef.doc(streamID).collection("messages").doc(message.timePostedInMilliseconds.toString()).set(message.toMap()).catchError((e) {
      error = e.details;
    });
    return error;
  }

  Future<String> sendStreamChatMessage({@required String streamID, @required WebblenStreamChatMessage message}) async {
    String error;
    await chatRef.doc(streamID).collection("messages").doc(message.timePostedInMilliseconds.toString()).set(message.toMap()).catchError((e) {
      error = e.details;
    });
    return error;
  }
}
