import 'package:cached_network_image/cached_network_image.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/firebase/data/event_data.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/widgets/common/state/progress_indicator.dart';

class VideoPlayPage extends StatefulWidget {
  final WebblenUser currentUser;
  final String vidURL;
  final String eventID;
  final String authorID;
  VideoPlayPage({this.currentUser, this.vidURL, this.eventID, this.authorID});
  @override
  _VideoPlayPageState createState() => _VideoPlayPageState();
}

class _VideoPlayPageState extends State<VideoPlayPage> {
  bool isLoading = true;
  WebblenEvent event;
  WebblenUser host;
  FlickManager flickManager;
  VideoPlayerController videoPlayerController;

  Future<void> pausePlayVideo() async {
    if (flickManager.flickVideoManager.isPlaying) {
      await videoPlayerController?.pause();
      flickManager.flickDisplayManager.handleShowPlayerControls(showWithTimeout: true);
    } else {
      await videoPlayerController?.play();
      flickManager.flickDisplayManager.handleShowPlayerControls(showWithTimeout: true);
    }
  }

  Widget header() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: [Colors.black, Colors.transparent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      )),
      padding: EdgeInsets.only(top: 45.0, left: 16.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.85,
            child: Text(
              event.title,
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 4.0),
          Container(
            width: MediaQuery.of(context).size.width * 0.85,
            child: Text(
              "${event.startDate} ${event.startTime}",
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(height: 8.0),
          GestureDetector(
            onTap: () {
              videoPlayerController?.pause();
              PageTransitionService(
                context: context,
                currentUser: widget.currentUser,
                webblenUser: host,
              ).transitionToUserPage();
            },
            child: Container(
              child: Row(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 4.0),
                      CachedNetworkImage(
                        imageUrl: host.profile_pic,
                        imageBuilder: (context, imageProvider) => Container(
                          width: 32.0,
                          height: 32.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        child: Text(
                          "@${host.username}",
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WebblenUserData().getUserByID(widget.authorID).then((res) {
      host = res;
      EventDataService().getEvent(widget.eventID).then((res) {
        event = res;
        videoPlayerController = VideoPlayerController.network(widget.vidURL);
        flickManager = FlickManager(
          videoPlayerController: videoPlayerController,
          autoInitialize: true,
          autoPlay: true,
          onVideoEnd: () => Navigator.pop(context),
        );
        isLoading = false;
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.down,
      onDismissed: (_) => Navigator.pop(context),
      child: Scaffold(
        body: isLoading
            ? Container(
                color: Colors.white,
                child: Center(
                  child: CustomCircleProgress(
                    60.0,
                    60.0,
                    30.0,
                    30.0,
                    CustomColors.webblenRed,
                  ),
                ),
              )
            : Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => pausePlayVideo(),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: FlickVideoPlayer(
                          flickManager: flickManager,
                          flickVideoWithControls: FlickVideoWithControls(
                            videoFit: BoxFit.cover,
                            controls: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.only(left: 16, right: 16, bottom: 32),
                              alignment: Alignment.bottomCenter,
                              child: FlickAutoHideChild(
                                autoHide: true,
                                child: Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                    color: Colors.black38,
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  FlickCurrentPosition(
                                                    fontSize: 14,
                                                  ),
                                                  Text(
                                                    ' / ',
                                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                                  ),
                                                  FlickTotalDuration(
                                                    fontSize: 14,
                                                  ),
                                                ],
                                              ),
                                              Expanded(
                                                child: Container(),
                                              ),
                                              FlickPlayToggle(
                                                size: 18,
                                              ),
                                            ],
                                          ),
                                          FlickVideoProgressBar(
                                            flickProgressBarSettings: FlickProgressBarSettings(
                                              height: 5,
                                              handleRadius: 5,
                                              curveRadius: 50,
                                              backgroundColor: Colors.white10,
                                              bufferedColor: Colors.white24,
                                              playedColor: Colors.white54,
                                              handleColor: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    header(),
                  ],
                ),
              ),
      ),
    );
  }
}
