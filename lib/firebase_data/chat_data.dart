import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/models/webblen_chat_message.dart';
import 'dart:math';

class ChatDataService {

  final CollectionReference chatDataRef = Firestore.instance.collection("chats");
  final CollectionReference userRef = Firestore.instance.collection("users");


  Future<Stream<QuerySnapshot>> getMessagesFromChat(String chatKey) async {
    Stream<QuerySnapshot> messagesSnapshots = chatDataRef
        .document(chatKey)
        .collection('messages')
        .orderBy('dateSent', descending: true)
        .limit(20)
        .snapshots();
    return messagesSnapshots;
  }

  Future<Stream<QuerySnapshot>> getMessagesByUser(String uid) async {
    Stream<QuerySnapshot> messagesSnapshots = chatDataRef
        .where('users', arrayContains: uid)
        .orderBy('lastMessageTimeStamp', descending: true)
        .snapshots();
    return messagesSnapshots;
  }

  Future<List> getSeenByList(String chatID) async {
    DocumentSnapshot chatDoc = await chatDataRef.document(chatID).get();
    List seenBy = chatDoc.data['seenBy'];
    seenBy = seenBy.toList(growable: true);
    return seenBy;
  }

  Future<Null> updateSeenMessage(String chatID, String currentUID) async {
    String error = "";
    DocumentSnapshot chatDoc = await chatDataRef.document(chatID).get();
    List seenBy = chatDoc.data['seenBy'];
    if (!seenBy.contains(currentUID) && chatDoc['isActive'] == true){
      seenBy = seenBy.toList(growable: true);
      seenBy.add(currentUID);
      chatDataRef.document(chatID).updateData({
        "seenBy": seenBy,
      }).whenComplete((){
      }).catchError((e) {
        error = e.details;
        return error;
      });
    }
  }

  Future<Null> updateLastMessageSent(String chatID, String sentBy, int timestamp, String messageType, List seenBy, String message) async {
    String error = "";
    await chatDataRef.document(chatID).updateData({
      "lastMessagePreview": message.length >= 80 ? message.substring(0, 80) : message,
      "lastMessageSentBy": sentBy,
      "seenBy": seenBy,
      "lastMessageTimeStamp": timestamp,
      "lastMessageType": messageType,
      "isActive": true
    }).whenComplete((){

      return error;
    }).catchError((e) {
      error = e.details;
      return error;
    });
  }

  Future<String> createChat(String currentUID, String peerUID, String currentUsername, String peerUsername, String currentProfilePic, String peerProfilePic) async {
    String result;
    final String chatDocKey = Random().nextInt(99999999).toString();
    WebblenChat chat = WebblenChat(
      chatDocKey: chatDocKey,
      lastMessagePreview: "Empty Conversation",
      lastMessageSentBy: "",
      lastMessageTimeStamp: DateTime.now().millisecondsSinceEpoch,
      lastMessageType: "text",
      usernames: [currentUsername, peerUsername],
      users: [currentUID, peerUID],
      seenBy: [],
      isActive: false,
    );
    await Firestore.instance.collection("chats").document(chatDocKey).setData(chat.toMap()).whenComplete(() {
      sendFirstMessage(chatDocKey, currentUsername, currentUID, 1544413794927, "", "initial");
      result = chatDocKey;
    }).catchError((e) {
      result = e.toString();
    });
    return result;
  }

  Future<Null> sendFirstMessage(String chatKey, String currentUsername, String uid, int timestamp, String content, String messageType) async {
    WebblenChatMessage newMessage = WebblenChatMessage(
        username: currentUsername,
        uid: uid,
        timestamp: timestamp,
        messageContent: content,
        messageType: messageType
    );
    await Firestore.instance.collection("chats").document(chatKey).collection('messages').document(timestamp.toString()).setData(newMessage.toMap(), merge: true).then((result) {
    }).catchError((e) {

    });
  }

  Future<bool> checkIfChatExists(String currentUID, String peerUID) async {
    bool chatExists = false;
    QuerySnapshot chatQuerySnapshot = await chatDataRef.where('users', arrayContains: currentUID).getDocuments();
    chatQuerySnapshot.documents.forEach((chatDoc){
      List usersInChat = chatDoc['users'];
      if (usersInChat.contains(peerUID)){
        chatExists = true;
        return;
      }
    });
    return chatExists;
  }

  Future<String> chatWithUser(String currentUID, String peerUID) async {
    String chatKey;
    QuerySnapshot chatQuerySnapshot = await chatDataRef.where('users', arrayContains: currentUID).getDocuments();
    chatQuerySnapshot.documents.forEach((chatDoc){
      List usersInChat = chatDoc['users'];
      if (usersInChat.contains(peerUID)){
        chatKey = chatDoc.documentID;
        return;
      }
    });
    return chatKey;
  }

  Future<bool> userHasUnreadMessages(String currentUID) async {
    bool hasUnreadMessages = false;
    QuerySnapshot chatQuerySnapshot = await chatDataRef.where('users', arrayContains: currentUID).getDocuments();
    chatQuerySnapshot.documents.forEach((chatDoc){
      List seenBy = chatDoc['seenBy'];
      if (!seenBy.contains(currentUID)){
        hasUnreadMessages = true;
        return;
      }
    });
    return hasUnreadMessages;
  }

}