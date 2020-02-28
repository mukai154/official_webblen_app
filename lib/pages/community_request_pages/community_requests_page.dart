import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import 'package:webblen/firebase_data/community_request_data.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/models/community_request.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_location.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/widgets_common/common_button.dart';
import 'package:webblen/widgets/widgets_community/community_request_row.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';

class CommunityRequestsPage extends StatefulWidget {
  final WebblenUser currentUser;
  final String areaName;
  final String simLocation;
  final double simLat;
  final double simLon;

  CommunityRequestsPage({
    this.currentUser,
    this.areaName,
    this.simLocation,
    this.simLat,
    this.simLon,
  });

  @override
  _CommunityRequestsPageState createState() => _CommunityRequestsPageState();
}

class _CommunityRequestsPageState extends State<CommunityRequestsPage> {
  String areaName;
  double currentLat;
  double currentLon;
  bool isLoading = true;
  List<CommunityRequest> allRequests = [];
//  List<CommunityRequest> popularRequests = [];
//  List<CommunityRequest> recentRequests = [];

  Future<Null> loadData() async {
    if (widget.simLocation != null) {
      areaName = widget.simLocation;
      currentLat = widget.simLat;
      currentLon = widget.simLon;
      isLoading = false;
      getRequests();
    } else {
      LocationService().getCurrentLocation(context).then((location) {
        if (this.mounted) {
          if (location != null) {
            areaName = widget.areaName;
            currentLat = location.latitude;
            currentLon = location.longitude;
            getRequests();
          }
        }
      });
    }
  }

  Future<void> getRequests() async {
    allRequests = [];
//    popularRequests = [];
//    recentRequests = [];
    await CommunityRequestDataService()
        .getComRequests(widget.areaName)
        .then((result) {
      allRequests = result;
//      popularRequests = result;
//      recentRequests = result;
//      recentRequests.sort((reqA, reqB) => reqA.datePostedInMilliseconds.compareTo(reqA.datePostedInMilliseconds));
      allRequests.sort(
          (reqA, reqB) => reqB.upVotes.length.compareTo(reqA.upVotes.length));
      isLoading = false;
      if (this.mounted) {
        setState(() {});
      }
    });
  }

  Future<void> voteAction(CommunityRequest req, String voteUpOrDown) async {
    HapticFeedback.lightImpact();
    bool didChangeVote = false;
    if (voteUpOrDown == 'up') {
      if (!req.upVotes.contains(widget.currentUser.uid)) {
        List upVotes = req.upVotes.toList(
          growable: true,
        );
        upVotes.add(widget.currentUser.uid);
        req.upVotes = upVotes;
        if (req.downVotes.contains(widget.currentUser.uid)) {
          List downVotes = req.downVotes.toList(
            growable: true,
          );
          downVotes.remove(widget.currentUser.uid);
          req.downVotes = downVotes;
        }
        didChangeVote = true;
      }
    } else {
      if (!req.downVotes.contains(widget.currentUser.uid)) {
        List downVotes = req.downVotes.toList(
          growable: true,
        );
        downVotes.add(widget.currentUser.uid);
        req.downVotes = downVotes;
        if (req.upVotes.contains(widget.currentUser.uid)) {
          List upVotes = req.upVotes.toList(
            growable: true,
          );
          upVotes.remove(widget.currentUser.uid);
          req.upVotes = upVotes;
        }
        didChangeVote = true;
      }
    }
    if (didChangeVote) {
      setState(() {});
      await CommunityRequestDataService().updateVoting(
        req.requestID,
        req.upVotes,
        req.downVotes,
      );
    }
  }

  initialize() async {
    loadData();
    getRequests();
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    // ** APP BAR
    final appBar = AppBar(
      elevation: 0.0,
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title: Fonts().textW700(
        'Community Suggestions',
        18.0,
        Colors.black,
        TextAlign.center,
      ),
      leading: BackButton(
        color: FlatColors.darkGray,
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            FontAwesomeIcons.plus,
            color: Colors.black,
            size: 18.0,
          ),
          onPressed: () => PageTransitionService(
            context: context,
            currentUser: widget.currentUser,
            areaName: areaName,
          ).transitionToCreateCommunityRequestPage(),
        ),
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: Container(
        child: isLoading
            ? LoadingScreen(
                context: context,
                loadingDescription: 'Loading Suggestions...',
              )
            : LiquidPullToRefresh(
                color: FlatColors.webblenRed,
                onRefresh: getRequests,
                child: allRequests.isEmpty
                    ? ListView(
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height: 8.0,
                              ),
                              MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                  textScaleFactor: 1.0,
                                ),
                                child: Fonts().textW300(
                                  'Pull Down To Refresh',
                                  14.0,
                                  Colors.black26,
                                  TextAlign.center,
                                ),
                              ),
                              SizedBox(
                                height: 32.0,
                              ),
                              MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                  textScaleFactor: 1.0,
                                ),
                                child: Fonts().textW300(
                                  "There are currently no suggestions",
                                  18.0,
                                  FlatColors.lightAmericanGray,
                                  TextAlign.center,
                                ),
                              ),
                              CustomColorButton(
                                text: 'Submit Suggestion',
                                textColor: Colors.black,
                                height: 45.0,
                                width: 200.0,
                                backgroundColor: Colors.white,
                                onPressed: () => PageTransitionService(
                                  context: context,
                                  currentUser: widget.currentUser,
                                  areaName: areaName,
                                ).transitionToCreateCommunityRequestPage(),
                              ),
                            ],
                          )
                        ],
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.only(
                          bottom: 8.0,
                        ),
                        itemCount: allRequests.length,
                        itemBuilder: (context, index) {
                          return CommunityRequestRow(
                            request: allRequests[index],
                            upVoteAction: () => voteAction(
                              allRequests[index],
                              'up',
                            ),
                            downVoteAction: () => voteAction(
                              allRequests[index],
                              'down',
                            ),
                            transitionToComRequestDetails:
                                null, //() => PageTransitionService(context: context, currentUser: widget.currentUser, comRequest: popularRequests[index]).transitionToCommunityRequestDetailsPage(),
                            uid: widget.currentUser.uid,
                          );
                        },
                      ),
              ),
      ),
    );
  }
}
