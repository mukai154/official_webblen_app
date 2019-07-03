//class CommunityChallenge {
//
//  String communityChallengeTitle;
//  String goalType;
//  String goalRequirement;
//  double lat;
//  double lon;
//  double pointsRequired;
//  double pointsAcquired;
//  double pointRewardAmount;
//  List usersThatContributed;
//
//  CommunityChallenge({
//    this.communityChallengeTitle,
//    this.goalType,
//    this.goalRequirement,
//    this.lat,
//    this.lon,
//    this.pointsRequired,
//    this.pointsAcquired,
//    this.pointRewardAmount,
//    this.usersThatContributed
//  });
//
//  CommunityChallenge.fromMap(Map<String, dynamic> data)
//      : this (
//      communityChallengeTitle: data['communityChallengeTitle'],
//      goalType: data['goalType'],
//      goalRequirement: data['goalRequirement'],
//      lat: data['lat'],
//      lon: data['lon'],
//      pointsRequired: data['pointsRequired'],
//      pointsAcquired: data['pointsAcquired'],
//      pointRewardAmount: data['pointRewardAmount'],
//      usersThatContributed: data['usersThatContributed']
//  );
//
//  Map<String, dynamic> toMap() => {
//    'communityChallengeTitle': this.communityChallengeTitle,
//    'goalType': this.goalType,
//    'goalRequirement': this.goalRequirement,
//    'lat': this.lat,
//    'lon': this.lon,
//    'pointsRequired': this.pointsRequired,
//    'pointsAcquired': this.pointsAcquired,
//    'pointRewardAmount': this.pointRewardAmount,
//    'usersThatContributed': this.usersThatContributed
//  };
//}