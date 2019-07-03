class WebblenChat {

  int lastMessageTimeStamp;
  String lastMessagePreview;
  String lastMessageSentBy;
  String lastMessageType;
  List users;
  List usernames;
  Map<dynamic, dynamic> userProfiles;
  List seenBy;
  bool isActive;


  WebblenChat({
    this.lastMessageTimeStamp,
    this.lastMessagePreview,
    this.lastMessageSentBy,
    this.lastMessageType,
    this.users,
    this.usernames,
    this.seenBy,
    this.userProfiles,
    this.isActive
  });

  WebblenChat.fromMap(Map<String, dynamic> data)
      : this(lastMessageTimeStamp: data['lastMessageTimeStamp'],
      lastMessagePreview: data['lastMessagePreview'],
      lastMessageSentBy: data['lastMessageSentBy'],
      lastMessageType: data['lastMessageType'],
      users: data['users'],
      usernames: data['usernames'],
      seenBy: data['seenBy'],
      userProfiles: data ['userProfiles'],
      isActive: data['isActive']
  );

  Map<String, dynamic> toMap() => {
    'lastMessageTimeStamp': this.lastMessageTimeStamp,
    'lastMessagePreview': this.lastMessagePreview,
    'lastMessageSentBy': this.lastMessageSentBy,
    'lastMessageType': this.lastMessageType,
    'users': this.users,
    'usernames': this.usernames,
    'seenBy': this.seenBy,
    'userProfiles': this.userProfiles,
    'isActive': this.isActive
  };
}

class WebblenChatMessage {

  int timestamp;
  String username;
  String userImageURL;
  String messageContent;
  String messageType;


  WebblenChatMessage({
    this.timestamp,
    this.username,
    this.userImageURL,
    this.messageContent,
    this.messageType
  });

  WebblenChatMessage.fromMap(Map<String, dynamic> data)
      : this(timestamp: data['timestamp'],
      username: data['username'],
      userImageURL: data['userImageURL'],
      messageContent: data['messageContent'],
      messageType: data['messageType']
  );

  Map<String, dynamic> toMap() => {
    'timestamp': this.timestamp,
    'username': this.username,
    'userImageURL': this.userImageURL,
    'messageContent': this.messageContent,
    'messageType': this.messageType
  };
}