import 'package:webblen/utils/custom_string_methods.dart';

class WebblenPost {
  String? id;
  String? parentID;
  String? authorID;
  String? postType;
  String? imageURL;
  String? body;
  List? nearbyZipcodes;
  String? city;
  String? province;
  double? lat;
  double? lon;
  int? commentCount;
  int? postDateTimeInMilliseconds;
  bool? reported;
  String? webAppLink;
  List? savedBy;
  int? clicks;
  List? clickedBy;
  List? sharedComs;
  bool? paidOut;
  List? tags;
  List? participantIDs;
  List? followers;
  List? suggestedUIDs;

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
    this.lat,
    this.lon,
    this.commentCount,
    this.postDateTimeInMilliseconds,
    this.reported,
    this.webAppLink,
    this.savedBy,
    this.clicks,
    this.clickedBy,
    this.sharedComs,
    this.paidOut,
    this.tags,
    this.participantIDs,
    this.followers,
    this.suggestedUIDs,
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
          lat: data['lat'],
          lon: data['lon'],
          commentCount: data['commentCount'],
          postDateTimeInMilliseconds: data['postDateTimeInMilliseconds'],
          reported: false,
          webAppLink: data['webAppLink'],
          savedBy: data['savedBy'],
          clicks: data['clicks'],
          clickedBy: data['clickedBy'],
          sharedComs: data['sharedComs'],
          paidOut: data['paidOut'],
          tags: data['tags'],
          participantIDs: data['participantIDs'],
          followers: data['followers'],
          suggestedUIDs: data['suggestedUIDs'],
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
        'lat': this.lat,
        'lon': this.lon,
        'commentCount': this.commentCount,
        'postDateTimeInMilliseconds': this.postDateTimeInMilliseconds,
        'reported': this.reported,
        'webAppLink': this.webAppLink,
        'savedBy': this.savedBy,
        'clicks': this.clicks,
        'clickedBy': this.clickedBy,
        'sharedComs': this.sharedComs,
        'paidOut': this.paidOut,
        'tags': this.tags,
        'participantIDs': this.participantIDs,
        'followers': this.followers,
        'suggestedUIDs': this.suggestedUIDs,
      };

  WebblenPost generateNewWebblenPost({required String authorID, required List suggestedUIDs}) {
    String id = getRandomString(30);
    WebblenPost post = WebblenPost(
      id: id,
      authorID: authorID,
      reported: false,
      paidOut: false,
      tags: [],
      savedBy: [],
      clickedBy: [],
      clicks: 0,
      participantIDs: [],
      nearbyZipcodes: [],
      suggestedUIDs: suggestedUIDs,
      followers: suggestedUIDs,
      commentCount: 0,
      postType: 'post',
    );
    return post;
  }

  bool isValid() {
    bool isValid = true;
    if (this.id == null) {
      isValid = false;
    }
    return isValid;
  }
}
