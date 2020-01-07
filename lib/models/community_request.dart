class CommunityRequest {
  String requestTitle;
  String requestExplanation;
  String areaName;
  String requestType;
  String requestID;
  double lat;
  double lon;
  List upVotes;
  List downVotes;
  String uid;
  String status;
  int datePostedInMilliseconds;

  CommunityRequest({
    this.requestTitle,
    this.requestExplanation,
    this.requestType,
    this.requestID,
    this.areaName,
    this.lat,
    this.lon,
    this.upVotes,
    this.downVotes,
    this.uid,
    this.status,
    this.datePostedInMilliseconds,
  });

  CommunityRequest.fromMap(Map<String, dynamic> data)
      : this(
          requestTitle: data['requestTitle'],
          requestExplanation: data['requestExplanation'],
          requestType: data['requestType'],
          requestID: data['requestID'],
          areaName: data['areaName'],
          lat: data['lat'],
          lon: data['lon'],
          upVotes: data['upVotes'],
          downVotes: data['downVotes'],
          uid: data['uid'],
          status: data['status'],
          datePostedInMilliseconds: data['datePostedInMilliseconds'],
        );

  Map<String, dynamic> toMap() => {
        'requestTitle': this.requestTitle,
        'requestExplanation': this.requestExplanation,
        'requestType': this.requestType,
        'requestID': this.requestID,
        'areaName': this.areaName,
        'lat': this.lat,
        'lon': this.lon,
        'upVotes': this.upVotes,
        'downVotes': this.downVotes,
        'uid': this.uid,
        'status': this.status,
        'datePostedInMilliseconds': this.datePostedInMilliseconds,
      };
}
