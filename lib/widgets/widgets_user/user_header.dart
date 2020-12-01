import 'package:flutter/material.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/widgets/common/buttons/custom_color_button.dart';
import 'package:webblen/widgets/widgets_user/user_profile_pic.dart';

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
          UserProfilePic(
            userPicUrl: userPicUrl,
            size: 70.0,
          ),
          SizedBox(height: 8.0),
          isOwner
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: viewFollowersAction,
                      child: Column(
                        children: [
                          Text(
                            followersLength.toString(),
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Followers",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 32.0),
                    GestureDetector(
                      onTap: viewFolllowingAction,
                      child: Column(
                        children: [
                          Text(
                            followingLength.toString(),
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Following",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
                          text: "Following",
                          elevation: 0.0,
                          textColor: Colors.black,
                          backgroundColor: CustomColors.iosOffWhite,
                          height: 30.0,
                          width: MediaQuery.of(context).size.width * 0.25,
                          onPressed: followUnfollowAction,
                        )
                      : CustomColorButton(
                          text: "Follow",
                          textColor: Colors.black,
                          backgroundColor: Colors.white,
                          height: 30.0,
                          width: MediaQuery.of(context).size.width * 0.25,
                          onPressed: followUnfollowAction,
                        ),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
