import 'package:webblen/utils/custom_string_methods.dart';

class WebblenLiveStream {
  String? id;
  String? hostID;
  bool? hasTickets;
  String? title;
  String? description;
  String? imageURL;
  String? audienceLocation;
  List? nearbyZipcodes;
  String? city;
  String? province;
  double? lat;
  double? lon;
  List? sharedComs;
  List? tags;
  int? clicks;
  String? website;
  String? fbUsername;
  String? twitterUsername;
  String? instaUsername;
  String? youtube;
  String? twitchUsername;
  int? actualTurnout;
  Map<dynamic, dynamic>? attendees;
  double? payout;
  int? startDateTimeInMilliseconds;
  int? endDateTimeInMilliseconds;
  String? startDate;
  String? startTime;
  String? endDate;
  String? endTime;
  String? timezone;
  String? privacy;
  bool? reported;
  String? webAppLink;
  List? savedBy;
  List? clickedBy;
  bool? paidOut;
  bool? openToSponsors;
  List<Map<dynamic, dynamic>>? gifters;
  double? totalGiftAmount;
  List? suggestedUIDs;
  String? youtubeStreamURL;
  String? youtubeStreamKey;
  String? twitchStreamURL;
  String? twitchStreamKey;
  String? fbStreamURL;
  String? fbStreamKey;
  String? agoraToken;

  WebblenLiveStream({
    this.id,
    this.hostID,
    this.hasTickets,
    this.title,
    this.description,
    this.imageURL,
    this.nearbyZipcodes,
    this.city,
    this.province,
    this.audienceLocation,
    this.lat,
    this.lon,
    this.sharedComs,
    this.tags,
    this.clicks,
    this.website,
    this.fbUsername,
    this.twitterUsername,
    this.instaUsername,
    this.youtube,
    this.twitchUsername,
    this.actualTurnout,
    this.attendees,
    this.payout,
    this.startDateTimeInMilliseconds,
    this.endDateTimeInMilliseconds,
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
    this.timezone,
    this.privacy,
    this.reported,
    this.webAppLink,
    this.savedBy,
    this.clickedBy,
    this.paidOut,
    this.openToSponsors,
    this.gifters,
    this.totalGiftAmount,
    this.suggestedUIDs,
    this.youtubeStreamURL,
    this.youtubeStreamKey,
    this.twitchStreamURL,
    this.twitchStreamKey,
    this.fbStreamURL,
    this.fbStreamKey,
    this.agoraToken,
  });

  WebblenLiveStream.fromMap(Map<String, dynamic> data)
      : this(
          id: data['id'],
          hostID: data['hostID'],
          hasTickets: data['hasTickets'],
          title: data['title'],
          description: data['description'],
          imageURL: data['imageURL'],
          nearbyZipcodes: data['nearbyZipcodes'],
          audienceLocation: data['audienceLocation'],
          city: data['city'],
          province: data['province'],
          lat: data['lat'],
          lon: data['lon'],
          sharedComs: data['sharedComs'],
          tags: data['tags'],
          clicks: data['clicks'],
          website: data['website'],
          fbUsername: data['fbUsername'],
          twitterUsername: data['twitterUsername'],
          instaUsername: data['instaUsername'],
          youtube: data['youtube'],
          twitchUsername: data['twitchUsername'],
          actualTurnout: data['actualTurnout'],
          attendees: data['attendees'],
          payout: data['payout'] == null ? null : data['payout'] * 1.001,
          startDateTimeInMilliseconds: data['startDateTimeInMilliseconds'],
          endDateTimeInMilliseconds: data['endDateTimeInMilliseconds'],
          startDate: data['startDate'],
          startTime: data['startTime'],
          endDate: data['endDate'],
          endTime: data['endTime'],
          timezone: data['timezone'],
          privacy: data['privacy'],
          reported: false,
          webAppLink: data['webAppLink'],
          savedBy: data['savedBy'],
          clickedBy: data['clickedBy'],
          paidOut: data['paidOut'],
          openToSponsors: data['openToSponsors'],
          gifters: data['gifters'],
          totalGiftAmount: data['totalGiftAmount'],
          suggestedUIDs: data['suggestedUIDs'],
          youtubeStreamURL: data['youtubeStreamURL'],
          youtubeStreamKey: data['youtubeStreamKey'],
          twitchStreamURL: data['twitchStreamURL'],
          twitchStreamKey: data['twitchStreamKey'],
          fbStreamURL: data['fbStreamURL'],
          fbStreamKey: data['fbStreamKey'],
          agoraToken: data['agoraToken'],
        );

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'hostID': this.hostID,
        'hasTickets': this.hasTickets,
        'title': this.title,
        'description': this.description,
        'imageURL': this.imageURL,
        'nearbyZipcodes': this.nearbyZipcodes,
        'audienceLocation': this.audienceLocation,
        'city': this.city,
        'province': this.province,
        'lat': this.lat,
        'lon': this.lon,
        'sharedComs': this.sharedComs,
        'tags': this.tags,
        'clicks': this.clicks,
        'website': this.website,
        'fbUsername': this.fbUsername,
        'twitterUsername': this.twitterUsername,
        'instaUsername': this.instaUsername,
        'youtube': this.youtube,
        'twitchUsername': this.twitchUsername,
        'actualTurnout': this.actualTurnout,
        'attendees': this.attendees,
        'payout': this.payout,
        'startDateTimeInMilliseconds': this.startDateTimeInMilliseconds,
        'endDateTimeInMilliseconds': this.endDateTimeInMilliseconds,
        'startDate': this.startDate,
        'startTime': this.startTime,
        'endDate': this.endDate,
        'endTime': this.endTime,
        'timezone': this.timezone,
        'privacy': this.privacy,
        'reported': this.reported,
        'webAppLink': this.webAppLink,
        'savedBy': this.savedBy,
        'clickedBy': this.clickedBy,
        'paidOut': this.paidOut,
        'openToSponsors': this.openToSponsors,
        'gifters': this.gifters,
        'totalGiftAmount': this.totalGiftAmount,
        'suggestedUIDs': this.suggestedUIDs,
        'youtubeStreamURL': this.youtubeStreamURL,
        'youtubeStreamKey': this.youtubeStreamKey,
        'twitchStreamURL': this.twitchStreamURL,
        'twitchStreamKey': this.twitchStreamKey,
        'fbStreamURL': this.fbStreamURL,
        'fbStreamKey': this.fbStreamKey,
        'agoraToken': this.agoraToken,
      };

  WebblenLiveStream generateNewWebblenLiveStream({required String hostID, required List suggestedUIDs}) {
    String id = getRandomString(30);
    WebblenLiveStream stream = WebblenLiveStream(
      id: id,
      hostID: hostID,
      privacy: "Public",
      reported: false,
      hasTickets: false,
      paidOut: false,
      openToSponsors: false,
      tags: [],
      savedBy: [],
      clickedBy: [],
      attendees: {},
      clicks: 0,
      suggestedUIDs: suggestedUIDs,
    );
    return stream;
  }

  bool isValid() {
    bool isValid = true;
    if (this.id == null) {
      isValid = false;
    }
    return isValid;
  }
}
