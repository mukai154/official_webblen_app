import 'package:flutter/material.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/widgets_user/user_row.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/styles/flat_colors.dart';


//
//class BuildTopUsers {
//
//  final List<WebblenUser> top10NearbyUsers;
//  final WebblenUser currentUser;
//  final BuildContext context;
//
//  BuildTopUsers({this.context, this.top10NearbyUsers, this.currentUser});
//
//  List buildTopUsers() {
//    List<Widget> topUsers = List();
//    for (int i = 0; i < top10NearbyUsers.length; i++) {
//      topUsers.add(
//          UserRowMin(
//              user: top10NearbyUsers[i],
//              transitionToUserDetails: () => PageTransitionService(context: context, currentUser: currentUser, webblenUser: top10NearbyUsers[i]).transitionToUserDetailsPage()
//          )
//      );
//    }
//    return topUsers;
//  }
//
//}