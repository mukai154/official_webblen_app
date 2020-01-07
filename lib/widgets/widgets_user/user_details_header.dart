import 'package:flutter/material.dart';

import 'package:webblen/styles/fonts.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';
import 'package:webblen/widgets/widgets_wallet/wallet_attendance_power_bar.dart';
import 'package:webblen/widgets/widgets_user/user_details_profile_pic.dart';

class UserDetailsHeader extends StatelessWidget {
  final String username;
  final String userPicUrl;
  final double ap;
  final int apLvl;
  final String eventHistoryCount;
  final String communityCount;
  final VoidCallback addFriendAction;
  final VoidCallback viewFriendsAction;
  final bool isLoading;

  UserDetailsHeader({
    this.username,
    this.userPicUrl,
    this.ap,
    this.apLvl,
    this.communityCount,
    this.eventHistoryCount,
    this.addFriendAction,
    this.viewFriendsAction,
    this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 0.0),
                child: UserDetailsProfilePic(
                  userPicUrl: userPicUrl,
                  size: 90.0,
                ),
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Fonts().textW700(
                "@$username",
                18.0,
                Colors.black,
                TextAlign.left,
              ),
              SizedBox(height: 4.0),
              isLoading
                  ? Container(
                      margin: EdgeInsets.only(
                        top: 4.0,
                      ),
                      height: 1.0,
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: CustomLinearProgress(
                        progressBarColor: FlatColors.webblenRed,
                      ),
                    )
                  : Fonts().textW500(
                      "Communities: $communityCount | Events Attended: $eventHistoryCount",
                      12.0,
                      Colors.black,
                      TextAlign.left,
                    ),
              SizedBox(
                height: 8.0,
              ),
              SmallAttendancePowerBar(
                currentAP: ap,
                apLvl: apLvl,
              ),
              SizedBox(
                height: 4.0,
              ),
              Fonts().textW300(
                'Attendance Power',
                10,
                Colors.black,
                TextAlign.left,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
