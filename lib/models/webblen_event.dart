class WebblenEvent {
  String id;
  String authorID;
  bool hasTickets;
  bool flashEvent;
  bool isDigitalEvent;
  String digitalEventLink;
  String title;
  String desc;
  String imageURL;
  String venueName;
  String streetAddress;
  List nearbyZipcodes;
  String city;
  String province;
  double lat;
  double lon;
  List sharedComs;
  List tags;
  String type;
  String category;
  int clicks;
  String website;
  String fbUsername;
  String twitterUsername;
  String instaUsername;
  double checkInRadius;
  int estimatedTurnout;
  int actualTurnout;
  List attendees;
  double eventPayout;
  String recurrence;
  int startDateTimeInMilliseconds;
  int endDateTimeInMilliseconds;
  String startDate;
  String startTime;
  String endDate;
  String endTime;
  String timezone;
  String privacy;
  bool reported;
  String webAppLink;
  List savedBy;
  bool paidOut;

  WebblenEvent({
    this.id,
    this.authorID,
    this.hasTickets,
    this.flashEvent,
    this.isDigitalEvent,
    this.digitalEventLink,
    this.title,
    this.desc,
    this.imageURL,
    this.venueName,
    this.nearbyZipcodes,
    this.streetAddress,
    this.city,
    this.province,
    this.lat,
    this.lon,
    this.sharedComs,
    this.tags,
    this.type,
    this.category,
    this.clicks,
    this.website,
    this.fbUsername,
    this.twitterUsername,
    this.instaUsername,
    this.checkInRadius,
    this.estimatedTurnout,
    this.actualTurnout,
    this.attendees,
    this.eventPayout,
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
  });

  WebblenEvent.fromMap(Map<String, dynamic> data)
      : this(
          id: data['id'],
          authorID: data['authorID'],
          hasTickets: data['hasTickets'],
          flashEvent: data['flashEvent'],
          isDigitalEvent: data['isDigitalEvent'],
          digitalEventLink: data['digitalEventLink'],
          title: data['title'],
          desc: data['desc'],
          imageURL: data['imageURL'],
          venueName: data['venueName'],
          nearbyZipcodes: data['nearbyZipcodes'],
          streetAddress: data['streetAddress'],
          city: data['city'],
          province: data['province'],
          lat: data['lat'],
          lon: data['lon'],
          sharedComs: data['sharedComs'],
          tags: data['tags'],
          type: data['type'],
          category: data['category'],
          clicks: data['clicks'],
          website: data['website'],
          fbUsername: data['fbUsername'],
          twitterUsername: data['twitterUsername'],
          instaUsername: data['instaUsername'],
          checkInRadius: data['checkInRadius'] * 1.0001,
          estimatedTurnout: data['estimatedTurnout'],
          actualTurnout: data['actualTurnout'],
          attendees: data['attendees'],
          eventPayout: data['eventPayout'],
          recurrence: data['recurrence'],
          startDateTimeInMilliseconds: data['startDateTimeInMilliseconds'],
          endDateTimeInMilliseconds: data['endDateTimeInMilliseconds'],
          startDate: data['startDate'],
          startTime: data['startTime'],
          endDate: data['endDate'],
          endTime: data['endTime'],
          timezone: data['timezone'],
          privacy: data['privacy'],
          reported: data['reported'],
          webAppLink: data['webAppLink'],
          savedBy: data['savedBy'],
          paidOut: data['paidOut'],
        );

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'authorID': this.authorID,
        'hasTickets': this.hasTickets,
        'flashEvent': this.flashEvent,
        'isDigitalEvent': this.isDigitalEvent,
        'digitalEventLink': this.digitalEventLink,
        'title': this.title,
        'desc': this.desc,
        'imageURL': this.imageURL,
        'venueName': this.venueName,
        'nearbyZipcodes': this.nearbyZipcodes,
        'streetAddress': this.streetAddress,
        'city': this.city,
        'province': this.province,
        'lat': this.lat,
        'lon': this.lon,
        'sharedComs': this.sharedComs,
        'tags': this.tags,
        'type': this.type,
        'category': this.category,
        'clicks': this.clicks,
        'website': this.website,
        'fbUsername': this.fbUsername,
        'twitterUsername': this.twitterUsername,
        'instaUsername': this.instaUsername,
        'checkInRadius': this.checkInRadius,
        'estimatedTurnout': this.estimatedTurnout,
        'actualTurnout': this.actualTurnout,
        'attendees': this.attendees,
        'eventPayout': this.eventPayout,
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
      };
}
