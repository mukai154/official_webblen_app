import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/widgets_icons/icon_bubble.dart';
import 'package:webblen/widgets/widgets_user/user_details_profile_pic.dart';
import 'package:webblen/widgets/widgets_user/user_details_badges.dart';

class UserRow extends StatelessWidget {
  final WebblenUser user;
  final VoidCallback transitionToUserDetails;
  final VoidCallback sendUserFriendRequest;
  final bool isFriendsWithUser;
  final TextStyle headerTextStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 20.0,
    color: FlatColors.lightAmericanGray,
  );
  final TextStyle subHeaderTextStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14.0,
    color: FlatColors.londonSquare,
  );
  final TextStyle bodyTextStyle = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w500,
    color: FlatColors.blackPearl,
  );

  UserRow({
    this.user,
    this.transitionToUserDetails,
    this.sendUserFriendRequest,
    this.isFriendsWithUser,
  });

  @override
  Widget build(BuildContext context) {
//    final communityBuilderBadge = new Container(
//      child: user.isCommunityBuilder ? UserDetailsBadge(badgeType: "communityBuilder", size: 18.0) : Container(),
//    );

    final friendBadge = Container(
      child: isFriendsWithUser
          ? UserDetailsBadge(
              badgeType: "friend",
              size: 16.0,
            )
          : Container(),
    );

    final userCard = Container(
      color: Colors.white,
      margin: EdgeInsets.only(
        bottom: 1.0,
      ),
      padding: EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                UserDetailsProfilePic(
                  userPicUrl: user.profile_pic,
                  size: 70.0,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 8.0,
                    ),
                    MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaleFactor: 1.0,
                      ),
                      child: user.username.length > 15
                          ? Fonts().textW700(
                              "@${user.username}",
                              15.0,
                              Colors.black,
                              TextAlign.left,
                            )
                          : Fonts().textW700(
                              "@${user.username}",
                              18.0,
                              Colors.black,
                              TextAlign.left,
                            ),
                    ),
                    friendBadge,
                    //communityBuilderBadge,
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: <Widget>[
                isFriendsWithUser
                    ? Container()
                    : IconButton(
                        icon: Icon(
                          Icons.person_add,
                          size: 24.0,
                          color: Colors.black12,
                        ),
                        onPressed: sendUserFriendRequest,
                      ),
              ],
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: transitionToUserDetails,
      child: userCard,
    );
  }
}

class UserRowMin extends StatelessWidget {
  final WebblenUser user;
  final VoidCallback transitionToUserDetails;
  final TextStyle headerTextStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 18.0,
    color: FlatColors.lightAmericanGray,
  );
  final TextStyle subHeaderTextStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14.0,
    color: FlatColors.londonSquare,
  );
  final TextStyle bodyTextStyle = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w500,
    color: FlatColors.blackPearl,
  );

  UserRowMin({
    this.user,
    this.transitionToUserDetails,
  });

  @override
  Widget build(BuildContext context) {
    final userPic = UserDetailsProfilePic(
      userPicUrl: user.profile_pic,
      size: 75.0,
    );

    final userCard = Container(
      child: Column(
        children: <Widget>[
          userPic,
          user.username == null
              ? Text(
                  "",
                  style: headerTextStyle,
                )
              : user.username.length > 10
                  ? Fonts().textW500(
                      " @" + user.username,
                      10.0,
                      Colors.black,
                      TextAlign.center,
                    )
                  : Fonts().textW500(
                      " @" + user.username,
                      12.0,
                      Colors.black,
                      TextAlign.center,
                    ),
        ],
      ),
    );

    return GestureDetector(onTap: transitionToUserDetails, child: userCard);
  }
}

class UserRowInvite extends StatelessWidget {
  final WebblenUser user;
  final VoidCallback onTap;
  final bool didInvite;

  UserRowInvite({
    this.user,
    this.onTap,
    this.didInvite,
  });

  @override
  Widget build(BuildContext context) {
    final userPic = didInvite
        ? IconBubble(
            icon: Icon(
              FontAwesomeIcons.check,
              color: Colors.white,
              size: 18.0,
            ),
            size: 60.0,
            color: FlatColors.darkMountainGreen,
          )
        : UserDetailsProfilePic(
            userPicUrl: user.profile_pic,
            size: 60.0,
          );

    final userCard = Container(
      color: Colors.white,
      margin: EdgeInsets.only(
        bottom: 4.0,
      ),
      padding: EdgeInsets.only(
        left: 16.0,
        top: 8.0,
        bottom: 8.0,
        right: 16.0,
      ),
      child: Row(
        children: <Widget>[
          Column(
            children: <Widget>[userPic],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                constraints: BoxConstraints(
                  maxWidth: 250.0,
                ),
                child: Fonts().textW700(
                  " @" + user.username,
                  20.0,
                  FlatColors.darkGray,
                  TextAlign.left,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: userCard,
    );
  }
}
