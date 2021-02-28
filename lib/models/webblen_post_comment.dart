class WebblenPostComment {
  String postID;
  String senderUID;
  String username;
  String message;
  bool isReply;
  String replyReceiverUsername;
  String originalReplyCommentID;
  List replies;
  int replyCount;
  int timePostedInMilliseconds;

  WebblenPostComment({
    this.postID,
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

  WebblenPostComment.fromMap(Map<String, dynamic> data)
      : this(
          postID: data['postID'],
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
