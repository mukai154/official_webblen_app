class Event {
  String eventKey;
  String address;
  Map<dynamic, dynamic> location;
  String authorUid;
  String communityName;
  String communityAreaName;
  String imageURL;
  String title;
  String description;
  String recurrence;
  bool promoted;
  double radius;
  List tags;
  int views;
  int estimatedTurnout;
  int actualTurnout;
  String fbSite;
  String twitterSite;
  String website;
  bool hasTickets;
  double eventPayout;
  bool pointsDistributedToUsers;
  List attendees;
  bool flashEvent;
  int startDateInMilliseconds;
  int endDateInMilliseconds;
  String startDate;
  String startTime;
  String endDate;
  String endTime;
  String timezone;
  String eventType;
  String privacy;

  Event(
      {this.eventKey,
      this.address,
      this.authorUid,
      this.title,
      this.communityName,
      this.communityAreaName,
      this.description,
      this.recurrence,
      this.promoted,
      this.location,
      this.radius,
      this.imageURL,
      this.tags,
      this.views,
      this.estimatedTurnout,
      this.actualTurnout,
      this.fbSite,
      this.twitterSite,
      this.website,
      this.hasTickets,
      this.eventPayout,
      this.pointsDistributedToUsers,
      this.attendees,
      this.flashEvent,
      this.startDateInMilliseconds,
      this.endDateInMilliseconds,
      this.startDate,
      this.startTime,
      this.endDate,
      this.endTime,
      this.timezone,
      this.eventType,
      this.privacy});

  Event.fromMap(Map<String, dynamic> data)
      : this(
            eventKey: data['eventKey'],
            address: data['address'],
            authorUid: data['authorUid'],
            title: data['title'],
            communityName: data['communityName'],
            communityAreaName: data['communityAreaName'],
            description: data['description'],
            recurrence: data['recurrence'],
            promoted: data['promoted'],
            location: data['location'],
            radius: data['radius'] * 1.01,
            imageURL: data['imageURL'],
            tags: data['tags'],
            views: data['views'],
            estimatedTurnout: data['estimatedTurnout'],
            actualTurnout: data['actualTurnout'],
            fbSite: data['fbSite'],
            twitterSite: data['twitterSite'],
            website: data['website'],
            hasTickets: data['hasTickets'],
            eventPayout: data['eventPayout'].toDouble(),
            pointsDistributedToUsers: data['pointsDistributedToUsers'],
            attendees: data['attendees'],
            flashEvent: data['flashEvent'],
            startDateInMilliseconds: data['startDateInMilliseconds'],
            endDateInMilliseconds: data['endDateInMilliseconds'],
            startDate: data['startDate'],
            endDate: data['endDate'],
            startTime: data['startTime'],
            endTime: data['endTime'],
            timezone: data['timzezone'],
            eventType: data['eventType'],
            privacy: data['privacy']);

  Map<String, dynamic> toMap() => {
        'eventKey': this.eventKey,
        'address': this.address,
        'authorUid': this.authorUid,
        'authorUsername': this.authorUid,
        'title': this.title,
        'communityName': this.communityName,
        'communityAreaName': this.communityAreaName,
        'description': this.description,
        'recurrence': this.recurrence,
        'promoted': this.promoted,
        'location': this.location,
        'radius': this.radius,
        'imageURL': this.imageURL,
        'tags': this.tags,
        'views': this.views,
        'estimatedTurnout': this.estimatedTurnout,
        'actualTurnout': this.actualTurnout,
        'fbSite': this.fbSite,
        'twitterSite': this.twitterSite,
        'website': this.website,
        'hasTickets': this.hasTickets,
        'eventPayout': this.eventPayout.toDouble(),
        'pointsDistributedToUsers': this.pointsDistributedToUsers,
        'attendees': this.attendees,
        'flashEvent': this.flashEvent,
        'startDateInMilliseconds': this.startDateInMilliseconds,
        'endDateInMilliseconds': this.endDateInMilliseconds,
        'startDate': this.startDate,
        'startTime': this.startTime,
        'endDate': this.endDate,
        'endTime': this.endTime,
        'timezone': this.timezone,
        'eventType': this.eventType,
        'privacy': this.privacy
      };
}

class RecurringEvent {
  String eventKey;
  String address;
  Map<dynamic, dynamic> location;
  String authorUid;
  String comName;
  String areaName;
  String imageURL;
  String title;
  String description;
  double radius;
  List tags;
  String fbSite;
  String twitterSite;
  String website;
  String recurrenceType;
  bool includeWeekends;
  String dayOfTheWeek;
  String dayOfTheMonth;
  String startTime;
  String endTime;
  String timezone;
  String eventType;
  String privacy;

  RecurringEvent(
      {this.eventKey,
      this.address,
      this.location,
      this.authorUid,
      this.comName,
      this.areaName,
      this.imageURL,
      this.title,
      this.description,
      this.radius,
      this.tags,
      this.fbSite,
      this.twitterSite,
      this.website,
      this.recurrenceType,
      this.includeWeekends,
      this.dayOfTheWeek,
      this.dayOfTheMonth,
      this.startTime,
      this.endTime,
      this.timezone,
      this.eventType,
      this.privacy});

  RecurringEvent.fromMap(Map<String, dynamic> data)
      : this(
            eventKey: data['eventKey'],
            address: data['address'],
            location: data['location'],
            authorUid: data['authorUid'],
            comName: data['comName'],
            areaName: data['areaName'],
            imageURL: data['imageURL'],
            title: data['title'],
            description: data['description'],
            radius: data['radius'],
            tags: data['tags'],
            fbSite: data['fbSite'],
            twitterSite: data['twitterSite'],
            website: data['website'],
            recurrenceType: data['recurrenceType'],
            includeWeekends: data['includeWeekends'],
            dayOfTheWeek: data['dayOfTheWeek'],
            dayOfTheMonth: data['dayOfTheMonth'],
            startTime: data['startTime'],
            endTime: data['endTime'],
            timezone: data['timezone'],
            eventType: data['eventType'],
            privacy: data['privacy']);

  Map<String, dynamic> toMap() => {
        'eventKey': this.eventKey,
        'address': this.address,
        'location': this.location,
        'authorUid': this.authorUid,
        'comName': this.comName,
        'areaName': this.areaName,
        'imageURL': this.imageURL,
        'title': this.title,
        'description': this.description,
        'radius': this.radius,
        'tags': this.tags,
        'fbSite': this.fbSite,
        'twitterSite': this.twitterSite,
        'website': this.website,
        'recurrenceType': this.recurrenceType,
        'includeWeekends': this.includeWeekends,
        'dayOfTheWeek': this.dayOfTheWeek,
        'dayOfTheMonth': this.dayOfTheMonth,
        'startTime': this.startTime,
        'endTime': this.endTime,
        'timezone': this.timezone,
        'eventType': this.eventType,
        'privacy': this.privacy
      };
}
