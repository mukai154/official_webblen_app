import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_button.dart';

class FollowUnfollowButton extends StatelessWidget {
  final bool isFollowing;
  final VoidCallback followUnfollowAction;

  FollowUnfollowButton({
    @required this.isFollowing,
    @required this.followUnfollowAction,
  });

  @override
  Widget build(BuildContext context) {
    return isFollowing == null || isFollowing == false
        ? CustomButton(
            isBusy: false,
            text: "Follow",
            textColor: appFontColor(),
            backgroundColor: appButtonColorAlt(),
            height: 30.0,
            width: 100,
            onPressed: followUnfollowAction,
          )
        : CustomButton(
            isBusy: false,
            text: "Following",
            elevation: 0.0,
            textColor: appFontColor(),
            backgroundColor: appButtonColorAlt(),
            height: 30.0,
            width: 100,
            onPressed: followUnfollowAction,
          );
  }
}
