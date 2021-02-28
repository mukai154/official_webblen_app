class WebblenRedeemedReward {
  String address1;
  String address2;
  String email;
  int purchaseTimeInMilliseconds;
  String rewardID;
  String rewardTitle;
  String rewardType;
  String clothingSize;
  String rewardStatus;
  String uid;

  WebblenRedeemedReward({
    this.address1,
    this.address2,
    this.email,
    this.purchaseTimeInMilliseconds,
    this.rewardID,
    this.rewardTitle,
    this.rewardType,
    this.clothingSize,
    this.rewardStatus,
    this.uid,
  });

  WebblenRedeemedReward.fromMap(Map<String, dynamic> data)
      : this(
          address1: data['address1'],
          address2: data['address2'],
          email: data['email'],
          purchaseTimeInMilliseconds: data['purchaseTimeInMilliseconds'],
          rewardID: data['rewardID'],
          rewardTitle: data['rewardTitle'],
          rewardType: data['rewardType'],
          clothingSize: data['size'],
          rewardStatus: data['status'],
          uid: data['uid'],
        );

  Map<String, dynamic> toMap() => {
        'address1': this.address1,
        'address2': this.address2,
        'email': this.email,
        'purchaseTimeInMilliseconds': this.purchaseTimeInMilliseconds,
        'rewardID': this.rewardID,
        'rewardTitle': this.rewardTitle,
        'rewardType': this.rewardType,
        'size': this.clothingSize,
        'status': this.rewardStatus,
        'uid': this.uid,
      };
}
