import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/models/community_news.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/utils/time_calc.dart';
import 'package:webblen/widgets_data_streams/stream_comment_data.dart';
import 'package:webblen/widgets_user/user_details_profile_pic.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class CommunityPostRow extends StatefulWidget {
  final CommunityNewsPost newsPost;
  final VoidCallback transitionToComAction;
  final WebblenUser currentUser;
  final bool showCommunity;
  CommunityPostRow({this.newsPost, this.transitionToComAction, this.currentUser, this.showCommunity});

  @override
  _CommunityPostRowState createState() => _CommunityPostRowState();
}

class _CommunityPostRowState extends State<CommunityPostRow> {
  String commentImageUrl;
  YoutubePlayerController vidController;
  bool isYoutubeVideo = false;
  String youtubeVideoID;
  bool isLoading;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.newsPost.newsURL != null && widget.newsPost.newsURL.contains('youtube.com')) {
      youtubeVideoID = YoutubePlayer.convertUrlToId(widget.newsPost.newsURL);
      isYoutubeVideo = true;
      vidController = YoutubePlayerController(
        initialVideoId: youtubeVideoID,
        flags: YoutubePlayerFlags(
          mute: true,
          autoPlay: false,
          forceHideAnnotation: true,
          disableDragSeek: false,
          enableCaption: true,
        ),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: GestureDetector(
        onTap: () => PageTransitionService(context: context, currentUser: widget.currentUser, newsPost: widget.newsPost).transitionToPostCommentsPage(),
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              youtubeVideoID != null
                  ? YoutubePlayer(
                      width: MediaQuery.of(context).size.width,
                      controller: vidController,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: Colors.amber,
                      progressColors: ProgressBarColors(
                        playedColor: Colors.amber,
                        handleColor: Colors.amberAccent,
                      ),
                    )
                  : widget.newsPost.imageURL == null
                      ? Container()
                      : Container(
                          height: 270.0,
                          decoration: BoxDecoration(image: DecorationImage(image: CachedNetworkImageProvider(widget.newsPost.imageURL), fit: BoxFit.cover)),
                        ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      widget.newsPost.userImageURL == null
                          ? Container()
                          : Padding(
                              padding: EdgeInsets.only(left: 12.0, top: 12.0, right: 4.0),
                              child: UserDetailsProfilePic(userPicUrl: widget.newsPost.userImageURL, size: 50.0),
                            ),
                      Padding(
                        padding: EdgeInsets.only(left: 4.0, top: 12.0, right: 4.0),
                        child: Fonts().textW500("@" + widget.newsPost.username, 18.0, Colors.black, TextAlign.start),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      StreamCommentCountData(
                        postID: widget.newsPost.postID,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: IconButton(
                          icon: Icon(FontAwesomeIcons.comment, color: Colors.black, size: 20.0),
                          onPressed: () => PageTransitionService(context: context, currentUser: widget.currentUser, newsPost: widget.newsPost)
                              .transitionToPostCommentsPage(),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 16.0, top: 8.0, right: 8.0),
                    constraints: BoxConstraints(maxWidth: 375),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Fonts().textW700(widget.newsPost.title, 24.0, Colors.black, TextAlign.start),
                    ),
                  )
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 16.0, top: 2.0, right: 8.0),
                    width: MediaQuery.of(context).size.width * 0.96,
                    child: Fonts().textW400('${widget.newsPost.content}', 14.0, Colors.black, TextAlign.left),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 16),
                    child: Fonts().textW300(
                        '${TimeCalc().getPastTimeFromMilliseconds(widget.newsPost.datePostedInMilliseconds)}', 12.0, FlatColors.darkGray, TextAlign.left),
                  ),
                  widget.showCommunity
                      ? GestureDetector(
                          onTap: widget.transitionToComAction,
                          child: Padding(
                            padding: EdgeInsets.only(right: 8.0, top: 4.0, bottom: 8.0),
                            child: Material(
                              borderRadius: BorderRadius.circular(8.0),
                              color: FlatColors.textFieldGray,
                              child: Padding(
                                  padding: EdgeInsets.all(6.0),
                                  child:
                                      Fonts().textW400('${widget.newsPost.areaName}/${widget.newsPost.communityName}', 12.0, Colors.black, TextAlign.center)),
                            ),
                          ))
                      : Container()
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
