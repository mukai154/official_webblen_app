class WebblenStream {
  String id;
  String authorID;
  bool hasTickets;
  bool flashEvent;
  String title;
  String desc;
  String imageURL;
  String streetAddress;
  List nearbyZipcodes;
  String city;
  String province;
  double lat;
  double lon;
  List tags;
  int clicks;
  String website;
  String fbUsername;
  String twitterUsername;
  String instaUsername;
  int checkInCount;
  List viewers;
  double totalPayout;
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

  WebblenStream({
    this.id,
    this.authorID,
    this.hasTickets,
    this.flashEvent,
    this.title,
    this.desc,
    this.imageURL,
    this.nearbyZipcodes,
    this.streetAddress,
    this.city,
    this.province,
    this.lat,
    this.lon,
    this.tags,
    this.clicks,
    this.website,
    this.fbUsername,
    this.twitterUsername,
    this.instaUsername,
    this.checkInCount,
    this.viewers,
    this.totalPayout,
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

  WebblenStream.fromMap(Map<String, dynamic> data)
      : this(
          id: data['id'],
          authorID: data['authorID'],
          hasTickets: data['hasTickets'],
          flashEvent: data['flashEvent'],
          title: data['title'],
          desc: data['desc'],
          imageURL: data['imageURL'],
          nearbyZipcodes: data['nearbyZipcodes'],
          streetAddress: data['streetAddress'],
          city: data['city'],
          province: data['province'],
          lat: data['lat'],
          lon: data['lon'],
          tags: data['tags'],
          clicks: data['clicks'],
          website: data['website'],
          fbUsername: data['fbUsername'],
          twitterUsername: data['twitterUsername'],
          instaUsername: data['instaUsername'],
          checkInCount: data['checkInCount'],
          viewers: data['viewers'],
          totalPayout: data['totalPayout'] * 1.001,
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
        'title': this.title,
        'desc': this.desc,
        'imageURL': this.imageURL,
        'nearbyZipcodes': this.nearbyZipcodes,
        'streetAddress': this.streetAddress,
        'city': this.city,
        'province': this.province,
        'lat': this.lat,
        'lon': this.lon,
        'tags': this.tags,
        'clicks': this.clicks,
        'website': this.website,
        'fbUsername': this.fbUsername,
        'twitterUsername': this.twitterUsername,
        'instaUsername': this.instaUsername,
        'checkInCount': this.checkInCount,
        'viewers': this.viewers,
        'totalPayout': this.totalPayout,
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
