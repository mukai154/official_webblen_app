class Comment {

  String commentKey;
  int postDateInMilliseconds;
  String username;
  String userImageURL;
  String uid;
  String postID;
  String content;
  String contentType;
  bool flagged;


  Comment({
    this.commentKey,
    this.postDateInMilliseconds,
    this.username,
    this.userImageURL,
    this.postID,
    this.content,
    this.uid,
    this.contentType,
    this.flagged
  });

  Comment.fromMap(Map<String, dynamic> data)
      : this (
      commentKey: data['commentKey'],
      postDateInMilliseconds: data['postDateInMilliseconds'],
      username: data['username'],
      userImageURL: data['userImageURL'],
      postID: data['postID'],
      uid: data['uid'],
      content: data['content'],
      contentType: data['contentType'],
      flagged: data['flagged']
  );

  Map<String, dynamic> toMap() => {
    'commentKey': this.commentKey,
    'postDateInMilliseconds': this.postDateInMilliseconds,
    'username': this.username,
    'userImageURL': this.userImageURL,
    'postID': this.postID,
    'content': this.content,
    'uid': this.uid,
    'contentType': this.contentType,
    'flagged': this.flagged
  };
}