class EventChatMessage {
  String senderUID;
  String userImgURL;
  String username;
  String message;
  int timePostedInMilliseconds;

  EventChatMessage({
    this.senderUID,
    this.userImgURL,
    this.username,
    this.message,
    this.timePostedInMilliseconds,
  });

  EventChatMessage.fromMap(Map<String, dynamic> data)
      : this(
          senderUID: data['senderUID'],
          userImgURL: data['userImgURL'],
          username: data['usernmae'],
          message: data['message'],
          timePostedInMilliseconds: data['timePostedInMilliseconds'],
        );

  Map<String, dynamic> toMap() => {
        'senderUID': this.senderUID,
        'userImgURL': this.userImgURL,
        'username': this.username,
        'message': this.message,
        'timePostedInMilliseconds': this.timePostedInMilliseconds,
      };
}
