class WebblenStreamChatMessage {
  String senderUID;
  String userImgURL;
  String username;
  String message;
  int timePostedInMilliseconds;

  WebblenStreamChatMessage({
    this.senderUID,
    this.userImgURL,
    this.username,
    this.message,
    this.timePostedInMilliseconds,
  });

  WebblenStreamChatMessage.fromMap(Map<String, dynamic> data)
      : this(
          senderUID: data['senderUID'],
          userImgURL: data['userImgURL'],
          username: data['username'],
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
