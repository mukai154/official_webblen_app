import 'package:flutter/material.dart';
import 'user_details_profile_pic.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'stats_event_history_count.dart';
import 'stats_impact.dart';

class UserDetailsHeader extends StatelessWidget {

  final String username;
  final String userPicUrl;
  final String eventPoints;
  final String eventImpact;
  final String eventHistoryCount;
  final VoidCallback addFriendAction;
  final VoidCallback viewFriendsAction;

  UserDetailsHeader({this.username, this.userPicUrl, this.eventPoints, this.eventImpact, this.eventHistoryCount, this.addFriendAction, this.viewFriendsAction});

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
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              StatsImpact(impactPoints: "x1.25", textColor: FlatColors.darkGray, textSize: 18.0, iconSize: 18.0, onTap: null),
              new Container(width: 32.0,),
              StatsEventHistoryCount(eventHistoryCount: eventHistoryCount, textColor: FlatColors.darkGray, textSize: 18.0, iconSize: 18.0, onTap: null),
            ],
          ),
        ],
      ),
    );
  }
}