class WebblenPost {
  String id;
  String parentID;
  String authorID;
  String postType;
  String imageURL;
  String body;
  List nearbyZipcodes;
  String city;
  String province;
  int commentCount;
  int postDateTimeInMilliseconds;
  bool reported;
  String webAppLink;
  List savedBy;
  List sharedComs;
  bool paidOut;
  List tags;
  List participantIDs;
  List followers;

  WebblenPost({
    this.id,
    this.parentID,
    this.authorID,
    this.postType,
    this.imageURL,
    this.body,
    this.nearbyZipcodes,
    this.city,
    this.province,
    this.commentCount,
    this.postDateTimeInMilliseconds,
    this.reported,
    this.webAppLink,
    this.savedBy,
    this.sharedComs,
    this.paidOut,
    this.tags,
    this.participantIDs,
    this.followers,
  });

  WebblenPost.fromMap(Map<String, dynamic> data)
      : this(
          id: data['id'],
          parentID: data['parentID'],
          authorID: data['authorID'],
          postType: data['postType'],
          imageURL: data['imageURL'],
          body: data['body'],
          nearbyZipcodes: data['nearbyZipcodes'],
          city: data['city'],
          province: data['province'],
          commentCount: data['commentCount'],
          postDateTimeInMilliseconds: data['postDateTimeInMilliseconds'],
          reported: false,
          webAppLink: data['webAppLink'],
          savedBy: data['savedBy'],
          sharedComs: data['sharedComs'],
          paidOut: data['paidOut'],
          tags: data['tags'],
          participantIDs: data['participantIDs'],
          followers: data['followers'],
        );

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'parentID': this.parentID,
        'authorID': this.authorID,
        'postType': this.postType,
        'imageURL': this.imageURL,
        'body': this.body,
        'nearbyZipcodes': this.nearbyZipcodes,
        'city': this.city,
        'province': this.province,
        'commentCount': this.commentCount,
        'postDateTimeInMilliseconds': this.postDateTimeInMilliseconds,
        'reported': this.reported,
        'webAppLink': this.webAppLink,
        'savedBy': this.savedBy,
        'sharedComs': this.sharedComs,
        'paidOut': this.paidOut,
        'tags': this.tags,
        'participantIDs': this.participantIDs,
        'followers': this.followers,
      };
}
