class EventChatMessage {
  String senderUID;
  String username;
  String message;
  int timePostedInMilliseconds;

  EventChatMessage({
    this.senderUID,
    this.username,
    this.message,
    this.timePostedInMilliseconds,
  });

  EventChatMessage.fromMap(Map<String, dynamic> data)
      : this(
          senderUID: data['senderUID'],
          username: data['usernmae'],
          message: data['message'],
          timePostedInMilliseconds: data['timePostedInMilliseconds'],
        );

  Map<String, dynamic> toMap() => {
        'senderUID': this.senderUID,
        'username': this.username,
        'message': this.message,
        'timePostedInMilliseconds': this.timePostedInMilliseconds,
      };
}
