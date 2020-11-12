import 'package:flutter/material.dart';
import 'package:webblen/models/webblen_reward.dart';

import 'reward_block.dart';

class RewardsGrid extends StatelessWidget {
  final List<WebblenReward> rewards;

  RewardsGrid({this.rewards});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: rewards.length,
      gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7),
      itemBuilder: (BuildContext context, int index) {
        return RewardBlock(
          reward: rewards[index],
        );
      },
    );
  }
}
