import 'package:webblen/enums/post_type.dart';

class WebblenPost {
  String id;
  String parentID;
  String authorID;
  PostType postType;
  String imageURL;
  String body;
  List<String> nearbyZipcodes;
  String city;
  String province;
  int commentCount;
  int postDateTimeInMilliseconds;
  bool reported;
  String webAppLink;
  List<String> savedBy;
  List<String> sharedComs;
  bool paidOut;
  List<String> tags;
  List<String> participantIDs;
  List<String> followers;

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
          postType: PostTypeConverter.stringToPostType(data['postType']),
          imageURL: data['imageURL'],
          body: data['body'],
          nearbyZipcodes: data['nearbyZipcodes'].cast<String>(),
          city: data['city'],
          province: data['province'],
          commentCount: data['commentCount'],
          postDateTimeInMilliseconds: data['postDateTimeInMilliseconds'],
          reported: false,
          webAppLink: data['webAppLink'],
          savedBy: data['savedBy'].cast<String>(),
          sharedComs: data['sharedComs'].cast<String>(),
          paidOut: data['paidOut'],
          tags: data['tags'].cast<String>(),
          participantIDs: data['participantIDs'].cast<String>(),
          followers: data['followers'].cast<String>(),
        );

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'parentID': this.parentID,
        'authorID': this.authorID,
        'postType': PostTypeConverter.postTypeToString(this.postType),
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
