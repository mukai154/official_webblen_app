import 'package:flutter/material.dart';
import 'package:webblen/firebase_services/community_data.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/models/community_news.dart';
import 'package:webblen/widgets_common/common_progress.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets_community/community_post_row.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/widgets_common/common_button.dart';


class NewsFeedPage extends StatefulWidget {

  final WebblenUser currentUser;
  final VoidCallback discoverAction;
  final Key key;
  NewsFeedPage({this.currentUser, this.discoverAction, this.key});

  @override
  _NewsFeedPageState createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {

  List<CommunityNewsPost> newsPosts = [];
  bool isLoading = true;

  Future<Null> getNewsPosts() async {
    if (widget.currentUser.followingCommunities == null || widget.currentUser.followingCommunities.isEmpty){
      setState(() {
        isLoading = false;
      });
    } else {
      widget.currentUser.followingCommunities.forEach((key, val) async {
        String areaName = key;
        List communities = val;
        communities.forEach((com) async {
          await CommunityDataService().getPostsFromCommunity(areaName, com).then((result){
            newsPosts.addAll(result);
          });
          if (widget.currentUser.followingCommunities.keys.last == key &&  communities.last == com){
            newsPosts.sort((postA, postB) => postB.datePostedInMilliseconds.compareTo(postA.datePostedInMilliseconds));
            if (this.mounted){
              setState(() {
                isLoading = false;
              });
            }
          }
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getNewsPosts();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? LoadingScreen(context: context, loadingDescription: 'Loading News...')
        : newsPosts.isEmpty
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width
                    ),
                    child: Fonts().textW300("No Community You're Following Has News", 18.0, FlatColors.lightAmericanGray, TextAlign.center),
                  )
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
                  )
                ],
              )
            ],
          )
        : Container(
          color: FlatColors.clouds,
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.only(bottom: 8.0),
            itemCount: newsPosts.length,
            itemBuilder: (context, index){
              return CommunityPostRow(
                newsPost: newsPosts[index],
                currentUser: widget.currentUser,
                showCommunity: true,
              );
            },
          ),
    );
  }
}
