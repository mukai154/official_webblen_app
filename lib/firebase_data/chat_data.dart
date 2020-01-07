import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_string/random_string.dart';
import 'package:webblen/models/webblen_chat_message.dart';

class ChatDataService {
  final CollectionReference chatRef = Firestore.instance.collection("chats");
  final CollectionReference userRef =
      Firestore.instance.collection("webblen_user");

  Future<WebblenChat> findChatByKey(String chatKey) async {
    WebblenChat chat;
    DocumentSnapshot doc = await chatRef.document(chatKey).get();
    if (doc.exists) {
      chat = WebblenChat.fromMap(doc.data);
    }
    return chat;
  }

  Future<Stream<QuerySnapshot>> getMessagesFromChat(String chatKey) async {
    Stream<QuerySnapshot> messagesSnapshots = chatRef
        .document(chatKey)
        .collection('messages')
        .orderBy('dateSent', descending: true)
        .limit(20)
        .snapshots();
    return messagesSnapshots;
  }

  Future<Stream<QuerySnapshot>> getMessagesByUser(String uid) async {
    Stream<QuerySnapshot> messagesSnapshots = chatRef
        .where(
          'users',
          arrayContains: uid,
        )
        .orderBy(
          'lastMessageTimeStamp',
          descending: true,
        )
        .snapshots();
    return messagesSnapshots;
  }

  Future<List> getSeenByList(String chatID) async {
    DocumentSnapshot chatDoc = await chatRef.document(chatID).get();
    List seenBy = chatDoc.data['seenBy'];
    seenBy = seenBy.toList(
      growable: true,
    );
    return seenBy;
  }

  Future<Null> updateSeenMessage(String chatID, String currentUID) async {
    String error = "";
    DocumentSnapshot chatDoc = await chatRef.document(chatID).get();
    List seenBy = chatDoc.data['seenBy'];
    if (!seenBy.contains(currentUID) && chatDoc['isActive'] == true) {
      seenBy = seenBy.toList(
        growable: true,
      );
      seenBy.add(currentUID);
      chatRef
          .document(chatID)
          .updateData({
            "seenBy": seenBy,
          })
          .whenComplete(() {})
          .catchError((e) {
            error = e.details;
            return error;
          });
    }
  }

  Future<Null> updateLastMessageSent(
    String chatID,
    String sentBy,
    int timestamp,
    String messageType,
    List seenBy,
    String message,
  ) async {
    String error = "";
    await chatRef.document(chatID).updateData({
      "lastMessagePreview":
          message.length >= 80 ? message.substring(0, 80) : message,
      "lastMessageSentBy": sentBy,
      "seenBy": seenBy,
      "lastMessageTimeStamp": timestamp,
      "lastMessageType": messageType,
      "isActive": true
    }).whenComplete(() {
      return error;
    }).catchError((e) {
      error = e.details;
      return error;
    });
  }

  Future<String> createChat(String currentUID, List<String> userIDs) async {
    userIDs.sort();
    String result;
    int currentDateInMilli = DateTime.now().millisecondsSinceEpoch;
    final String chatDocKey = randomAlphaNumeric(10);
    WebblenChat chat = WebblenChat(
      chatDocKey: chatDocKey,
      lastMessagePreview: "Empty Conversation",
      lastMessageSentBy: "",
      lastMessageTimeStamp: currentDateInMilli,
      lastMessageType: "text",
      users: userIDs,
      seenBy: [],
      isActive: false,
    );
    await Firestore.instance
        .collection("chats")
        .document(chatDocKey)
        .setData(chat.toMap())
        .whenComplete(() {
      sendMessage(
        chatDocKey,
        '',
        currentUID,
        currentDateInMilli,
        "",
        "initial",
      );
      result = chatDocKey;
    }).catchError((e) {});
    return result;
  }

  Future<String> checkIfChatExists(List<String> userIDs) async {
    String chatKey;
    userIDs.sort();
    QuerySnapshot query =
        await chatRef.where('users', isEqualTo: userIDs).getDocuments();
    if (query.documents != null && query.documents.length > 0) {
      WebblenChat chat = WebblenChat.fromMap(query.documents.first.data);
      chatKey = chat.chatDocKey;
    }
    return chatKey;
  }

  Future<String> sendMessage(
    String chatKey,
    String currentUsername,
    String uid,
    int timestamp,
    String content,
    String messageType,
  ) async {
    String error = '';
    DocumentSnapshot chatDoc = await chatRef.document(chatKey).get();
    WebblenChat chat = WebblenChat.fromMap(chatDoc.data);
    if (messageType == 'text') {
      chat.lastMessagePreview =
          content.length > 20 ? content.substring(0, 20) + "..." : content;
    } else if (messageType == 'image') {
      chat.lastMessagePreview = '@$currentUsername sent an image';
    } else if (messageType == 'eventShare') {
      chat.lastMessagePreview = '@$currentUsername shared an event';
    }
    chat.lastMessageTimeStamp = timestamp;
    chat.lastMessageSentBy = currentUsername;
    chat.isActive = true;

    WebblenChatMessage newMessage = WebblenChatMessage(
      username: currentUsername,
      uid: uid,
      timestamp: timestamp,
      messageContent: content,
      messageType: messageType,
    );
    await Firestore.instance
        .collection("chats")
        .document(chatKey)
        .collection('messages')
        .document(timestamp.toString())
        .setData(
          newMessage.toMap(),
          merge: true,
        )
        .then((result) async {
      await chatRef.document(chatKey).updateData(chat.toMap());
    }).catchError((e) {
      error = e.details;
    });
    return error;
  }

//  Future<bool> checkIfChatExists(String currentUID, String peerUID) async {
//    bool chatExists = false;
//    QuerySnapshot chatQuerySnapshot = await chatRef.where('users', arrayContains: currentUID).getDocuments();
//    chatQuerySnapshot.documents.forEach((chatDoc){
//      List usersInChat = chatDoc['users'];
//      if (usersInChat.contains(peerUID)){
//        chatExists = true;
//        return;
//      }
//    });
//    return chatExists;
//  }
//
//  Future<String> chatWithUser(String currentUID, String peerUID) async {
//    String chatKey;
//    QuerySnapshot chatQuerySnapshot = await chatRef.where('users', arrayContains: currentUID).getDocuments();
//    chatQuerySnapshot.documents.forEach((chatDoc) {
//      List usersInChat = chatDoc['users'];
//      if (usersInChat.contains(peerUID)) {
//        chatKey = chatDoc.documentID;
//        return;
//      }
//    });
//    return chatKey;
//  }

  Future<bool> userHasUnreadMessages(String currentUID) async {
    bool hasUnreadMessages = false;
    QuerySnapshot chatQuerySnapshot =
        await chatRef.where('users', arrayContains: currentUID).getDocuments();
    chatQuerySnapshot.documents.forEach((chatDoc) {
      List seenBy = chatDoc['seenBy'];
      if (!seenBy.contains(currentUID)) {
        hasUnreadMessages = true;
        return;
      }
    });
    return hasUnreadMessages;
  }
}
