class LocalAd {

  String adKey;
  int datePostedInMilliseconds;
  String authorUid;
  String imageURL;
  String adURL;
  int clicks;
  int impressions;


  LocalAd({
    this.adKey,
    this.datePostedInMilliseconds,
    this.authorUid,
    this.imageURL,
    this.adURL,
    this.clicks,
    this.impressions,
  });

  LocalAd.fromMap(Map<String, dynamic> data)
      : this(
      adKey: data['adKey'],
      datePostedInMilliseconds: data['datePostedInMilliseconds'],
      authorUid: data['authorUid'],
      imageURL: data['imageURL'],
      clicks: data['clicks'],
      impressions: data['impressions'],
      adURL: data['adURL']
  );

  Map<String, dynamic> toMap() => {
    'adKey': this.adKey,
    'datePostedInMilliseconds': this.datePostedInMilliseconds,
    'authorUid': this.authorUid,
    'imageURL': this.imageURL,
    'clicks': this.clicks,
    'impressions': this.impressions,
    'adURL': this.adURL
  };
}