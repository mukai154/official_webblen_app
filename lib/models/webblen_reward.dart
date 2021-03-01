import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/enums/reward_type.dart';

class WebblenReward {
  int amountAvailable;
  double cost;
  String description;
  String expirationDate;
  String rewardID;
  String imageURL;
  bool isGlobalReward;
  List<String> nearbyZipcodes;
  String providerID;
  String title;
  RewardType rewardType;

  WebblenReward({
    this.amountAvailable,
    this.cost,
    this.description,
    this.expirationDate,
    this.rewardID,
    this.imageURL,
    this.isGlobalReward,
    this.nearbyZipcodes,
    this.providerID,
    this.title,
    this.rewardType,
  });

  WebblenReward.fromMap(Map<String, dynamic> data)
      : this(
          amountAvailable: data['amountAvailable'],
          cost: data['cost'],
          description: data['description'],
          expirationDate: data['expirationDate'],
          rewardID: data['rewardID'],
          imageURL: data['imageURL'],
          isGlobalReward: data['isGlobalReward'],
          nearbyZipcodes: data['nearbyZipcodes'].cast<String>(),
          providerID: data['providerID'],
          title: data['title'],
          rewardType: RewardTypeConverter.stringToRewardType(data['type']),
        );

  Map<String, dynamic> toMap() => {
        'amountAvailable': this.amountAvailable,
        'cost': this.cost,
        'description': this.description,
        'expirationDate': this.expirationDate,
        'rewardID': this.rewardID,
        'imageURL': this.imageURL,
        'isGlobalReward': this.isGlobalReward,
        'nearbyZipcodes': this.nearbyZipcodes,
        'providerID': this.providerID,
        'title': this.title,
        'type': RewardTypeConverter.rewardTypeToString(this.rewardType),
      };
}
