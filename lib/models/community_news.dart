class CommunityNewsPost {

  int datePostedInMilliseconds;
  String title;
  String imageURL;
  String newsURL;
  String username;
  String userImageURL;
  String content;
  String communityName;
  String areaName;
  String postID;


  CommunityNewsPost({
    this.datePostedInMilliseconds,
    this.title,
    this.imageURL,
    this.newsURL,
    this.username,
    this.userImageURL,
    this.content,
    this.communityName,
    this.areaName,
    this.postID
  });

  CommunityNewsPost.fromMap(Map<String, dynamic> data)
      : this(
      datePostedInMilliseconds: data['datePostedInMilliseconds'],
      title: data['title'],
      imageURL: data['imageURL'],
      newsURL: data['newsURL'],
      username: data['username'],
      userImageURL: data['userImageURL'],
      content: data['content'],
      communityName: data['communityName'],
      areaName: data['areaName'],
      postID: data['postID']
  );

  Map<String, dynamic> toMap() => {
    'datePostedInMilliseconds': this.datePostedInMilliseconds,
    'title': this.title,
    'imageURL': this.imageURL,
    'newsURL': this.newsURL,
    'userImageURL': this.userImageURL,
    'username': this.username,
    'content': this.content,
    'communityName': this.communityName,
    'areaName': this.areaName,
    'postID': this.postID
  };
}