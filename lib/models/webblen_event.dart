import 'package:webblen/utils/custom_string_methods.dart';

class WebblenEvent {
  String? id;
  String? authorID;
  bool? hasTickets;
  bool? flashEvent;
  bool? hasStream;
  String? title;
  String? description;
  String? imageURL;
  String? venueName;
  String? venueSize;
  String? streetAddress;
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
  int? estimatedTurnout;
  int? actualTurnout;
  Map<dynamic, dynamic>? attendees;
  double? payout;
  String? recurrence;
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
  bool? paidOut;
  bool? openToSponsors;
  List? suggestedUIDs;

  WebblenEvent({
    this.id,
    this.authorID,
    this.hasTickets,
    this.hasStream,
    this.flashEvent,
    this.title,
    this.description,
    this.imageURL,
    this.venueName,
    this.venueSize,
    this.nearbyZipcodes,
    this.streetAddress,
    this.city,
    this.province,
    this.lat,
    this.lon,
    this.sharedComs,
    this.tags,
    this.clicks,
    this.website,
    this.fbUsername,
    this.twitterUsername,
    this.instaUsername,
    this.estimatedTurnout,
    this.actualTurnout,
    this.attendees,
    this.payout,
    this.recurrence,
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
    this.paidOut,
    this.openToSponsors,
    this.suggestedUIDs,
  });

  WebblenEvent.fromMap(Map<String, dynamic> data)
      : this(
          id: data['id'],
          authorID: data['authorID'],
          hasTickets: data['hasTickets'],
          flashEvent: data['flashEvent'],
          hasStream: data['hasStream'],
          title: data['title'],
          description: data['description'],
          imageURL: data['imageURL'],
          venueName: data['venueName'],
          venueSize: data['venueSize'],
          nearbyZipcodes: data['nearbyZipcodes'],
          streetAddress: data['streetAddress'],
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
          estimatedTurnout: data['estimatedTurnout'],
          actualTurnout: data['actualTurnout'],
          attendees: data['attendees'],
          payout: data['payout'] == null ? null : data['payout'] * 1.001,
          recurrence: data['recurrence'],
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
          paidOut: data['paidOut'],
          openToSponsors: data['openToSponsors'],
          suggestedUIDs: data['suggestedUIDs'],
        );

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'authorID': this.authorID,
        'hasTickets': this.hasTickets,
        'flashEvent': this.flashEvent,
        'hasStream': this.hasStream,
        'title': this.title,
        'description': this.description,
        'imageURL': this.imageURL,
        'venueName': this.venueName,
        'venueSize': this.venueSize,
        'nearbyZipcodes': this.nearbyZipcodes,
        'streetAddress': this.streetAddress,
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
        'estimatedTurnout': this.estimatedTurnout,
        'actualTurnout': this.actualTurnout,
        'attendees': this.attendees,
        'eventPayout': this.payout,
        'recurrence': this.recurrence,
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
        'paidOut': this.paidOut,
        'openToSponsors': this.openToSponsors,
        'suggestedUIDs': this.suggestedUIDs,
      };

  WebblenEvent generateNewWebblenEvent({required String authorID, required List suggestedUIDs}) {
    String id = getRandomString(30);
    WebblenEvent event = WebblenEvent(
      id: id,
      authorID: authorID,
      privacy: "Public",
      reported: false,
      hasStream: false,
      hasTickets: false,
      paidOut: false,
      openToSponsors: false,
      tags: [],
      savedBy: [],
      attendees: {},
      clicks: 0,
      estimatedTurnout: 0,
    );
    return event;
  }

  //checks if obj is valid
  bool isValid() {
    bool isValid = true;
    if (id == null) {
      isValid = false;
    }
    return isValid;
  }
}
