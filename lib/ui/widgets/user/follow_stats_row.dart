import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';

class FollowStatsRow extends StatelessWidget {
  final int followersLength;
  final int followingLength;
  final VoidCallback viewFollowersAction;
  final VoidCallback viewFollowingAction;

  FollowStatsRow({
    this.followersLength,
    this.followingLength,
    this.viewFollowersAction,
    this.viewFollowingAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: viewFollowersAction,
            child: Column(
              children: [
                CustomText(
                  text: followersLength.toString(),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: appFontColor(),
                ),
                CustomText(
                  text: "Followers",
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: appFontColorAlt(),
                ),
              ],
            ),
          ),
          SizedBox(width: 32.0),
          GestureDetector(
            onTap: viewFollowingAction,
            child: Column(
              children: [
                CustomText(
                  text: followingLength.toString(),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: appFontColor(),
                ),
                CustomText(
                  text: "Following",
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: appFontColorAlt(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
