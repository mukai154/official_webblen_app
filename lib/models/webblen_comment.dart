class WebblenComment {
  String? postID;
  String? streamID;
  String? senderUID;
  String? username;
  String? message;
  bool? isReply;
  String? replyReceiverUsername;
  String? originalReplyCommentID;
  List? replies;
  int? replyCount;
  int? timePostedInMilliseconds;

  WebblenComment({
    this.postID,
    this.streamID,
    this.senderUID,
    this.username,
    this.message,
    this.isReply,
    this.replyReceiverUsername,
    this.originalReplyCommentID,
    this.replies,
    this.replyCount,
    this.timePostedInMilliseconds,
  });

  WebblenComment.fromMap(Map<String, dynamic> data)
      : this(
          postID: data['postID'],
          streamID: data['streamID'],
          senderUID: data['senderUID'],
          username: data['username'],
          message: data['message'],
          isReply: data['isReply'],
          replyReceiverUsername: data['replyReceiverUsername'],
          originalReplyCommentID: data['originalReplyCommentID'],
          replies: data['replies'],
          replyCount: data['replyCount'],
          timePostedInMilliseconds: data['timePostedInMilliseconds'],
        );

  Map<String, dynamic> toMap() => {
        'postID': this.postID,
        'streamID': this.streamID,
        'senderUID': this.senderUID,
        'username': this.username,
        'message': this.message,
        'isReply': this.isReply,
        'replyReceiverUsername': this.replyReceiverUsername,
        'originalReplyCommentID': this.originalReplyCommentID,
        'replies': this.replies,
        'replyCount': this.replyCount,
        'timePostedInMilliseconds': this.timePostedInMilliseconds,
      };
}
