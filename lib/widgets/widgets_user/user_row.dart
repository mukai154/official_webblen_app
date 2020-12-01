import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/widgets_icons/icon_bubble.dart';
import 'package:webblen/widgets/widgets_user/user_profile_pic.dart';

class UserRow extends StatelessWidget {
  final WebblenUser user;
  final double size;
  final VoidCallback transitionToUserDetails;
  final VoidCallback followUnfollowUser;

  UserRow({
    this.user,
    this.size,
    this.transitionToUserDetails,
    this.followUnfollowUser,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: transitionToUserDetails,
      child: Container(
        child: Row(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 4.0),
                CachedNetworkImage(
                  imageUrl: user.profile_pic,
                  imageBuilder: (context, imageProvider) => Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "@${user.username}",
                  style: TextStyle(color: Colors.black, fontSize: size < 50 ? 14 : 18, fontWeight: FontWeight.bold),
                ),
              ],
            )
          ],
        ),
      ),
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
    final userPic = UserProfilePic(
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
        : UserProfilePic(
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
