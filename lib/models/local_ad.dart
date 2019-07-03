class LocalAd {

  String adKey;
  int datePostedInMilliseconds;
  String authorUid;
  String imageURL;
  String adURL;
  int clicks;
  int impressions;
  Map<dynamic, dynamic> location;

  LocalAd({
    this.adKey,
    this.datePostedInMilliseconds,
    this.authorUid,
    this.imageURL,
    this.adURL,
    this.clicks,
    this.impressions,
    this.location
  });

  LocalAd.fromMap(Map<String, dynamic> data)
      : this(
      adKey: data['adKey'],
      datePostedInMilliseconds: data['datePostedInMilliseconds'],
      authorUid: data['authorUid'],
      imageURL: data['imageURL'],
      clicks: data['clicks'],
      impressions: data['impressions'],
      location: data['location'],
      adURL: data['adURL']
  );

  Map<String, dynamic> toMap() => {
    'adKey': this.adKey,
    'datePostedInMilliseconds': this.datePostedInMilliseconds,
    'authorUid': this.authorUid,
    'imageURL': this.imageURL,
    'clicks': this.clicks,
    'impressions': this.impressions,
    'location': this.location,
    'adURL': this.adURL
  };
}