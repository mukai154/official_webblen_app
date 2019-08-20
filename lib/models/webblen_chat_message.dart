class WebblenChat {

  int lastMessageTimeStamp;
  String lastMessagePreview;
  String lastMessageSentBy;
  String lastMessageType;
  List users;
  List usernames;
  String chatDocKey;
  List seenBy;
  bool isActive;


  WebblenChat({
    this.lastMessageTimeStamp,
    this.lastMessagePreview,
    this.lastMessageSentBy,
    this.lastMessageType,
    this.users,
    this.usernames,
    this.chatDocKey,
    this.seenBy,
    this.isActive
  });

  WebblenChat.fromMap(Map<String, dynamic> data)
      : this(lastMessageTimeStamp: data['lastMessageTimeStamp'],
      lastMessagePreview: data['lastMessagePreview'],
      lastMessageSentBy: data['lastMessageSentBy'],
      lastMessageType: data['lastMessageType'],
      users: data['users'],
      usernames: data['usernames'],
      chatDocKey: data['chatDocKey'],
      seenBy: data['seenBy'],
      isActive: data['isActive']
  );

  Map<String, dynamic> toMap() => {
    'lastMessageTimeStamp': this.lastMessageTimeStamp,
    'lastMessagePreview': this.lastMessagePreview,
    'lastMessageSentBy': this.lastMessageSentBy,
    'lastMessageType': this.lastMessageType,
    'users': this.users,
    'usernames': this.usernames,
    'chatDocKey': this.chatDocKey,
    'seenBy': this.seenBy,
    'isActive': this.isActive
  };
}

class WebblenChatMessage {

  int timestamp;
  String uid;
  String username;
  String userImageURL;
  String messageContent;
  String messageType;


  WebblenChatMessage({
    this.timestamp,
    this.uid,
    this.username,
    this.messageContent,
    this.messageType
  });

  WebblenChatMessage.fromMap(Map<String, dynamic> data)
      : this(timestamp: data['timestamp'],
      uid: data['uid'],
      username: data['username'],
      messageContent: data['messageContent'],
      messageType: data['messageType']
  );

  Map<String, dynamic> toMap() => {
    'timestamp': this.timestamp,
    'uid': this.uid,
    'username': this.username,
    'messageContent': this.messageContent,
    'messageType': this.messageType
  };
}