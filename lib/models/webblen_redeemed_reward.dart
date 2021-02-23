import 'package:webblen/enums/clothing_size.dart';
import 'package:webblen/enums/reward_status.dart';
import 'package:webblen/enums/reward_type.dart';

class WebblenRedeemedReward {
  String address1;
  String address2;
  String email;
  int purchaseTimeInMilliseconds;
  String rewardID;
  String rewardTitle;
  RewardType rewardType;
  ClothingSize clothingSize;
  RewardStatus rewardStatus;
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
          rewardType:
              RewardTypeConverter.stringToRewardType(data['rewardType']),
          clothingSize:
              ClothingSizeConverter.stringToClothingSize(data['size']),
          rewardStatus:
              RewardStatusConverter.stringToRewardStatus(data['status']),
          uid: data['uid'],
        );

  Map<String, dynamic> toMap() => {
        'address1': this.address1,
        'address2': this.address2,
        'email': this.email,
        'purchaseTimeInMilliseconds': this.purchaseTimeInMilliseconds,
        'rewardID': this.rewardID,
        'rewardTitle': this.rewardTitle,
        'rewardType': RewardTypeConverter.rewardTypeToString(this.rewardType),
        'size': ClothingSizeConverter.clothingSizeToString(this.clothingSize),
        'status': RewardStatusConverter.rewardStatusToString(this.rewardStatus),
        'uid': this.uid,
      };
}
