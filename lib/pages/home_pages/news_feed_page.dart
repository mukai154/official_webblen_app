import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import 'package:webblen/firebase_data/community_data.dart';
import 'package:webblen/firebase_data/news_post_data.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:webblen/models/community.dart';
import 'package:webblen/models/community_news.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/widgets_common/common_button.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';
import 'package:webblen/widgets/widgets_community/community_post_row.dart';

class NewsFeedPage extends StatefulWidget {
  final String uid;
  final VoidCallback discoverAction;
  final Key key;

  NewsFeedPage({
    this.uid,
    this.discoverAction,
    this.key,
  });

  @override
  _NewsFeedPageState createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  WebblenUser currentUser;
  ScrollController _scrollController;
  List<CommunityNewsPost> newsPosts = [];
  bool isLoading = true;

  Future<Null> getNewsFeed() async {
    newsPosts = [];
    UserDataService().getUserByID(widget.uid).then((res) {
      currentUser = res;
      NewsPostDataService().getNewsFeed(currentUser.uid).then((result) {
        if (result.isEmpty) {
          isLoading = false;
          if (this.mounted) {
            setState(() {});
          }
        } else {
          newsPosts = result;
          newsPosts.sort((postA, postB) => postB.datePostedInMilliseconds
              .compareTo(postA.datePostedInMilliseconds));
          isLoading = false;
          if (this.mounted) {
            setState(() {});
          }
        }
      });
    });
  }

  Future<void> refreshData() async {
    getNewsFeed();
  }

  void transitionToCommunityPage(CommunityNewsPost post) async {
    ShowAlertDialogService().showLoadingCommunityDialog(
      context,
      post.areaName,
      post.communityName,
    );
    Community com = await CommunityDataService().getCommunityByName(
      post.areaName,
      post.communityName,
    );
    Navigator.of(context).pop();
    PageTransitionService(
      context: context,
      currentUser: currentUser,
      community: com,
    ).transitionToCommunityProfilePage();
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    getNewsFeed();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (
          BuildContext context,
          bool boxIsScrolled,
        ) {
          return <Widget>[
            SliverAppBar(
              brightness: Brightness.light,
              backgroundColor: Colors.white,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0,
                    ),
                    child: Fonts().textW700(
                      'News',
                      40,
                      Colors.black,
                      TextAlign.left,
                    ),
                  ),
                  IconButton(
                    onPressed: () => PageTransitionService(
                      context: context,
                      uid: currentUser.uid,
                      action: 'newPost',
                    ).transitionToMyCommunitiesPage(), //() => PageTransitionService(context: context).transitionToVideoNewsPage(),
                    icon: Icon(
                      FontAwesomeIcons.edit,
                      size: 18.0,
                      color: Colors.black,
                    ),
                  )
                ],
              ),
              pinned: true,
            ),
          ];
        },
        body: isLoading
            ? LoadingScreen(
                context: context,
                loadingDescription: 'Loading News...',
              )
            : LiquidPullToRefresh(
                onRefresh: refreshData,
                color: FlatColors.webblenRed,
                child: newsPosts.isEmpty
                    ? ListView(
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Fonts().textW300(
                                'Pull Down To Refresh',
                                14.0,
                                Colors.black26,
                                TextAlign.center,
                              ),
                              SizedBox(
                                height: 64.0,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width,
                                    ),
                                    child: Fonts().textW300(
                                      "No Community You're Following Has News",
                                      18.0,
                                      FlatColors.lightAmericanGray,
                                      TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  CustomColorButton(
                                    text: 'Discover Communities Near Me',
                                    textColor: FlatColors.darkGray,
                                    backgroundColor: Colors.white,
                                    height: 45.0,
                                    width: 300,
                                    hPadding: 8.0,
                                    vPadding: 8.0,
                                    onPressed: widget.discoverAction,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.only(
                          bottom: 8.0,
                        ),
                        itemCount: newsPosts.length,
                        itemBuilder: (context, index) {
                          return CommunityPostRow(
                            newsPost: newsPosts[index],
                            currentUser: currentUser,
                            transitionToComAction: () =>
                                transitionToCommunityPage(newsPosts[index]),
                            showCommunity: true,
                          );
                        },
                      ),
              ), // scroll view
      ),
    );
  }
}
