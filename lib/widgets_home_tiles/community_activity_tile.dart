import 'package:flutter/material.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/widgets_user/user_row.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/widgets_data_streams/stream_nearby_users.dart';


class CommunityActivityTile extends StatelessWidget {

  final WebblenUser currentUser;
  final double lat;
  final double lon;
  CommunityActivityTile({this.lat, this.lon, this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Column (
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Fonts().textW400('Community Activity', 12.0, FlatColors.darkGray, TextAlign.start),
        ),
        Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: StreamNumberOfNearbyUsers(lat: lat, lon: lon)
        ),
        SizedBox(height: 8.0),
        StreamTop10NearbyUsers(currentUser: currentUser, lat: lat, lon: lon)
      ],
    );
  }
}

class NoNearbyUsersTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 16.0),
          Fonts().textW500("No Nearby Users Found", 24.0, FlatColors.darkGray, TextAlign.center),
        ],
      ),
    );
  }
}


class BuildTopUsers {

  final List<WebblenUser> top10NearbyUsers;
  final WebblenUser currentUser;
  final BuildContext context;

  BuildTopUsers({this.context, this.top10NearbyUsers, this.currentUser});

  List buildTopUsers() {
    List<Widget> topUsers = List();
    for (int i = 0; i < top10NearbyUsers.length; i++) {
      topUsers.add(
          UserRowMin(
              user: top10NearbyUsers[i],
              transitionToUserDetails: () => PageTransitionService(context: context, currentUser: currentUser, webblenUser: top10NearbyUsers[i]).transitionToUserDetailsPage()
          )
      );
    }
    return topUsers;
  }

}