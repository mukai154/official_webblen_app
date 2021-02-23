enum RewardStatus {
  pending,
  complete,
}

class RewardStatusConverter {
  static RewardStatus stringToRewardStatus(String rewardStatus) {
    if (rewardStatus == 'pending') {
      return RewardStatus.pending;
    } else {
      return RewardStatus.complete;
    }
  }

  static String rewardStatusToString(RewardStatus rewardStatus) {
    if (rewardStatus == RewardStatus.pending) {
      return 'pending';
    } else {
      return 'complete';
    }
  }
}