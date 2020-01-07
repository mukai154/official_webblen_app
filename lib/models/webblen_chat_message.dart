class WebblenChat {
  String chatName;
  int lastMessageTimeStamp;
  String lastMessagePreview;
  String lastMessageSentBy;
  String lastMessageType;
  List users;
  String chatDocKey;
  List seenBy;
  bool isActive;

  WebblenChat({
    this.chatName,
    this.lastMessageTimeStamp,
    this.lastMessagePreview,
    this.lastMessageSentBy,
    this.lastMessageType,
    this.users,
    this.chatDocKey,
    this.seenBy,
    this.isActive,
  });

  WebblenChat.fromMap(Map<String, dynamic> data)
      : this(
          chatName: data['chatName'],
          lastMessageTimeStamp: data['lastMessageTimeStamp'],
          lastMessagePreview: data['lastMessagePreview'],
          lastMessageSentBy: data['lastMessageSentBy'],
          lastMessageType: data['lastMessageType'],
          users: data['users'],
          chatDocKey: data['chatDocKey'],
          seenBy: data['seenBy'],
          isActive: data['isActive'],
        );

  Map<String, dynamic> toMap() => {
        'chatName': this.chatName,
        'lastMessageTimeStamp': this.lastMessageTimeStamp,
        'lastMessagePreview': this.lastMessagePreview,
        'lastMessageSentBy': this.lastMessageSentBy,
        'lastMessageType': this.lastMessageType,
        'users': this.users,
        'chatDocKey': this.chatDocKey,
        'seenBy': this.seenBy,
        'isActive': this.isActive,
      };
}

class WebblenChatMessage {
  int timestamp;
  String uid;
  String username;
  String messageContent;
  String messageType;
  String messageData;

  WebblenChatMessage({
    this.timestamp,
    this.uid,
    this.username,
    this.messageContent,
    this.messageType,
    this.messageData,
  });

  WebblenChatMessage.fromMap(Map<String, dynamic> data)
      : this(
          timestamp: data['timestamp'],
          uid: data['uid'],
          username: data['username'],
          messageContent: data['messageContent'],
          messageType: data['messageType'],
          messageData: data['messageData'],
        );

  Map<String, dynamic> toMap() => {
        'timestamp': this.timestamp,
        'uid': this.uid,
        'username': this.username,
        'messageContent': this.messageContent,
        'messageType': this.messageType,
        'messageData': this.messageData,
      };
}
