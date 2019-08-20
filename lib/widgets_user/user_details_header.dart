import 'package:flutter/material.dart';
import 'user_details_profile_pic.dart';
import 'package:webblen/widgets_wallet/wallet_attendance_power_bar.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/styles/flat_colors.dart';

class UserDetailsHeader extends StatelessWidget {

  final String username;
  final String userPicUrl;
  final double ap;
  final int apLvl;
  final String eventHistoryCount;
  final VoidCallback addFriendAction;
  final VoidCallback viewFriendsAction;

  UserDetailsHeader({this.username, this.userPicUrl, this.ap, this.apLvl, this.eventHistoryCount, this.addFriendAction, this.viewFriendsAction});

  @override
  Widget build(BuildContext context) {

    return Container(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
                    child: UserDetailsProfilePic(userPicUrl: userPicUrl, size: 90.0),
                  )
                ],
              ),
            ],
          ),
          SizedBox(height: 14.0),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SmallAttendancePowerBar(currentAP: ap, apLvl: apLvl),
              SizedBox(height: 4.0),
              Fonts().textW400('Attendance Power', 12.0, FlatColors.darkGray, TextAlign.center)
            ],
          ),
        ],
      ),
    );
  }
}