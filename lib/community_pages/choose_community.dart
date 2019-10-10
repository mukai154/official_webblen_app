import 'package:flutter/material.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/models/community.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/widgets_data_streams/stream_user_data.dart';
import 'package:webblen/firebase_data/community_data.dart';
import 'package:webblen/widgets_common/common_progress.dart';
import 'package:webblen/widgets_community/community_row.dart';
import 'package:webblen/widgets_common/common_appbar.dart';


class ChooseCommunityPage extends StatefulWidget {

  final String uid;
  final String newEventOrPost;
  ChooseCommunityPage({this.uid, this.newEventOrPost});

  @override
  _ChooseCommunityPageState createState() => _ChooseCommunityPageState();
}

class _ChooseCommunityPageState extends State<ChooseCommunityPage> {

  StreamSubscription userStream;
  WebblenUser currentUser;
  bool isLoading = true;
  List<Community> userComs = [];

  @override
  void initState() {
    super.initState();
    initialize();
  }

  initialize() async {
    StreamUserData.getUserStream(widget.uid, getUser).then((StreamSubscription<DocumentSnapshot> s){
      userStream = s;
    });
  }

  getUser(WebblenUser user) async {
    currentUser = user;
    if (currentUser != null){
      getUserCommunities();
    }
  }

  Future<void> getUserCommunities() async {
    userComs = [];
    await CommunityDataService().getUserCommunities(widget.uid).then((result){
      userComs = result.where((com) => com.status == 'active').toList();
      userComs.sort((comA, comB) => comA.name[1].compareTo(comB.name[1]));
      isLoading = false;
      setState(() {});
    });
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: WebblenAppBar().basicAppBar(
            widget.newEventOrPost == 'event'
                ? 'Create New Event For...'
                : 'Create New Post For...',
          context
        ),
        body: isLoading
            ? LoadingScreen(context: context, loadingDescription: 'Loading Your Communities...')
            : userComs.isEmpty
            ? Padding(
          padding: EdgeInsets.only(top: 64.0, left: 8.0, right: 8.0),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: Fonts().textW300('You are not a member of any communities', 18.0, FlatColors.lightAmericanGray, TextAlign.center),
          ),
        )
            : ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.only(top: 24.0, bottom: 8.0, left: 8.0, right: 8.0),
          itemCount: userComs.length,
          itemBuilder: (context, index){
            return CommunityRow(
                showAreaName: true,
                community: userComs[index],
                onClickAction: widget.newEventOrPost == 'event'
                    ? () => PageTransitionService(context: context, currentUser: currentUser, community: userComs[index], isRecurring: false).transitionToNewEventPage()
                    : widget.newEventOrPost == 'post'
                    ? () => PageTransitionService(context: context, currentUser: currentUser, community: userComs[index]).transitionToCommunityCreatePostPage()
                    : null
            );
          },
        ),
      );
  }
}
