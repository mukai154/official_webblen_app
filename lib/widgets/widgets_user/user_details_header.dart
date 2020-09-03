import 'package:flutter/material.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/widgets/common/buttons/custom_color_button.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';
import 'package:webblen/widgets/widgets_user/user_details_profile_pic.dart';

class UserDetailsHeader extends StatelessWidget {
  final String uid;
  final String username;
  final String userPicUrl;
  final VoidCallback followUnfollowAction;
  final VoidCallback viewFollowersAction;
  final VoidCallback viewFolllowingAction;
  final int followersLength;
  final int followingLength;
  final bool isOwner;
  final bool isFollowing;

  UserDetailsHeader({
    this.uid,
    this.username,
    this.userPicUrl,
    this.followUnfollowAction,
    this.viewFollowersAction,
    this.viewFolllowingAction,
    this.followersLength,
    this.followingLength,
    this.isOwner,
    this.isFollowing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 0.0),
            child: UserDetailsProfilePic(
              userPicUrl: userPicUrl,
              size: 90.0,
            ),
          ),
          SizedBox(height: 16.0),
          isOwner
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: viewFollowersAction,
                      child: Column(
                        children: [
                          CustomText(
                            context: context,
                            text: "$followersLength",
                            textColor: Colors.black,
                            textAlign: TextAlign.center,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                          ),
                          CustomText(
                            context: context,
                            text: "Followers",
                            textColor: Colors.black,
                            textAlign: TextAlign.center,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 32.0),
                    GestureDetector(
                      onTap: viewFolllowingAction,
                      child: Column(
                        children: [
                          CustomText(
                            context: context,
                            text: "$followingLength",
                            textColor: Colors.black,
                            textAlign: TextAlign.center,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                          ),
                          CustomText(
                            context: context,
                            text: "Following",
                            textColor: Colors.black,
                            textAlign: TextAlign.center,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : isFollowing == null
                  ? Container()
                  : isFollowing
                      ? CustomColorButton(
                          text: "Unfollow",
                          textColor: CustomColors.lightAmericanGray,
                          backgroundColor: Colors.white,
                          height: 35.0,
                          width: MediaQuery.of(context).size.width * 0.35,
                          onPressed: followUnfollowAction,
                        )
                      : CustomColorButton(
                          text: "Follow",
                          textColor: Colors.white,
                          backgroundColor: CustomColors.electronBlue,
                          height: 35.0,
                          width: MediaQuery.of(context).size.width * 0.35,
                          onPressed: followUnfollowAction,
                        ),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
