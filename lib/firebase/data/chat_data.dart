import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/models/event_chat_message.dart';

class ChatDataService {
  final CollectionReference eventChatRef = Firestore().collection("event_chats");

  //CREATE
  Future<String> joinChatStream(String eventID, String uid, bool isHost, String username) async {
    String error;
    EventChatMessage message = EventChatMessage(
      senderUID: uid,
      username: 'system',
      message: isHost ? '@$username has started streaming!' : '@$username has joined',
      timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
    );
    await eventChatRef.document(eventID).collection("messages").document(message.timePostedInMilliseconds.toString()).setData(message.toMap()).catchError((e) {
      error = e.details;
    });
    return error;
  }

  Future<String> leaveChatStream(String eventID, String uid, bool isHost, String username) async {
    String error;
    EventChatMessage message = EventChatMessage(
      senderUID: uid,
      username: 'system',
      message: isHost ? '@$username has stopped streaming' : '@$username has left',
      timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
    );
    await eventChatRef.document(eventID).collection("messages").document(message.timePostedInMilliseconds.toString()).setData(message.toMap()).catchError((e) {
      error = e.details;
    });
    return error;
  }

  Future<String> sendEventChatMessage(String eventID, EventChatMessage message) async {
    String error;
    await eventChatRef.document(eventID).collection("messages").document(message.timePostedInMilliseconds.toString()).setData(message.toMap()).catchError((e) {
      error = e.details;
    });
    return error;
  }

  //READ

}