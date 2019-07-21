import 'package:flutter/material.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets_user/user_row.dart';
import 'package:webblen/services_general/service_page_transitions.dart';


class UserCarousel extends StatelessWidget {

  final WebblenUser currentUser;
  final List<WebblenUser> users;
  UserCarousel({this.currentUser, this.users});

  @override
  Widget build(BuildContext context) {
    return Container(
      //margin: EdgeInsets.symmetric(horizontal: 12.0),
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: new CarouselSlider(
          items:  BuildTopUsers(context: context, currentUser: currentUser, top10NearbyUsers: users).buildTopUsers(),
          height: 100.0,
          viewportFraction: 0.3 ,
          autoPlay: true,
          autoPlayAnimationDuration: Duration(seconds: 10),
          autoPlayCurve: Curves.linear,
        ),
      ),
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
