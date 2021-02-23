enum RewardType {
  webblenClothes,
  cash,
}

class RewardTypeConverter {
  static RewardType stringToRewardType(String rewardType) {
    if (rewardType == 'webblenClothes') {
      return RewardType.webblenClothes;
    } else {
      return RewardType.cash;
    }
  }

  static String rewardTypeToString(RewardType rewardType) {
    if (rewardType == RewardType.webblenClothes) {
      return 'webblenClothes';
    } else {
      return 'cash';
    }
  }
}