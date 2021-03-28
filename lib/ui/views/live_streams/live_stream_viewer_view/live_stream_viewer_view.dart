import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/ui/views/live_streams/live_stream_viewer_view/live_stream_viewer_view_model.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/live_streams/video_ui/check_in_count_box.dart';
import 'package:webblen/ui/widgets/live_streams/video_ui/video_streaming_status.dart';
import 'package:webblen/ui/widgets/live_streams/video_ui/viewer_count_box.dart';

class LiveStreamViewerView extends StatefulWidget {
  @override
  _LiveStreamViewerViewState createState() => _LiveStreamViewerViewState();
}

class _LiveStreamViewerViewState extends State<LiveStreamViewerView> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  ScrollController chatViewController = ScrollController();
  AnimationController giftAnimationController;
  Animation giftAnimation;

  /// Helper function to get list of native views
  List<Widget> getRenderedViews(LiveStreamViewerViewModel model) {
    final List<StatefulWidget> list = [];
    list.add(RtcLocalView.SurfaceView());
    model.users.forEach((uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    return list;
  }

  /// Video view wrapper
  Widget videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget viewRows(LiveStreamViewerViewModel model) {
    final views = getRenderedViews(model);

    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            expandedVideoRow([views[0]]),
            expandedVideoRow([views[1]])
          ],
        ));
    }
    return Container();
  }

  ///VIDEO UI
  Widget streamHeader(LiveStreamViewerViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Text(
                    model.webblenLiveStream.title,
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap: null, //() => model.toggleEndingStream(),
                  child: Icon(
                    FontAwesomeIcons.times,
                    color: Colors.white60,
                    size: 24.0,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 40,
            child: Row(
              children: [
                LiveNowBox(),
                SizedBox(width: 8.0),
                ViewerCountBox(viewCount: 1),
                SizedBox(width: 8.0),
                CheckInCountBox(checkInCount: model.webblenLiveStream.viewers.length),
              ],
            ),
          ),

//          Row(
//            children: [
//              GestureDetector(
//                onTap: recording ? () => stopScreenAndAudioRecord() : () => requestRecordingStart(),
//                child: Container(
//                  height: 24,
//                  width: 30,
//                  padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
//                  decoration: BoxDecoration(
//                    color: finishedRecording
//                        ? CustomColors.darkMountainGreen
//                        : recording
//                            ? CustomColors.webblenRed
//                            : Colors.black38,
//                    borderRadius: BorderRadius.all(Radius.circular(8)),
//                  ),
//                  child: Icon(
//                    finishedRecording
//                        ? FontAwesomeIcons.solidFileVideo
//                        : recording
//                            ? FontAwesomeIcons.solidDotCircle
//                            : FontAwesomeIcons.video,
//                    color: Colors.white,
//                    size: 11.0,
//                  ),
//                ),
//              ),
//            ],
//          ),
        ],
      ),
    );
  }

  Widget endStreamButton(LiveStreamViewerViewModel model) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
            child: GestureDetector(
              onTap: null, //() => model.toggleEndingStream(),
              child: Text(
                'END',
                style: TextStyle(color: Colors.black54, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomBar(LiveStreamViewerViewModel model) {
    if (!model.isInAgoraChannel) {
      return Container();
    }
    return Container(
      alignment: Alignment.bottomRight,
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.only(left: 8, top: 5, right: 8, bottom: 5),
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            new Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 2.0),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                height: 40,
                child: TextField(
                  minLines: 1,
                  maxLines: 5,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  cursorColor: Colors.white,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (val) => model.sendChatMessage(val),
                  style: TextStyle(color: Colors.white),
                  controller: model.messageFieldController,
                  textCapitalization: TextCapitalization.sentences,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(150),
                  ],
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: 'Comment',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
              child: MaterialButton(
                minWidth: 0,
                onPressed: () => model.displayGifters(),
                child: Icon(
                  Icons.card_giftcard,
                  color: Colors.white,
                  size: 20.0,
                ),
                shape: CircleBorder(),
                elevation: 0.0,
                color: Colors.black26,
                padding: const EdgeInsets.all(12.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
              child: MaterialButton(
                minWidth: 0,
                onPressed: () => model.toggleMute(),
                child: Icon(
                  model.muted ? Icons.mic_off : Icons.mic,
                  color: Colors.white,
                  size: 20.0,
                ),
                shape: CircleBorder(),
                elevation: 0.0,
                color: Colors.black26,
                padding: const EdgeInsets.all(12.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
              child: MaterialButton(
                minWidth: 0,
                onPressed: () => model.switchCamera(),
                child: Icon(
                  Icons.switch_camera,
                  color: Colors.white,
                  size: 20.0,
                ),
                shape: CircleBorder(),
                elevation: 0.0,
                color: Colors.black26,
                padding: const EdgeInsets.all(12.0),
              ),
            )
          ]),
        ),
      ),
    );
  }

  Widget endLive(LiveStreamViewerViewModel model) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text(
                'Are you sure you want to end your live stream?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 4.0, top: 8.0, bottom: 8.0),
                    child: ElevatedButton(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          'End Stream',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      onPressed: () => model.endStream(),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0, right: 8.0, top: 8.0, bottom: 8.0),
                    child: ElevatedButton(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      onPressed: () => model.toggleEndingStream(),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  scrollToChatMessage() async {
    if (chatViewController.hasClients && chatViewController.position.pixels == chatViewController.position.maxScrollExtent) {
      await Future.delayed(Duration(milliseconds: 500));
      if (chatViewController.hasClients) {
        chatViewController.jumpTo(chatViewController.position.maxScrollExtent);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    giftAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3500),
    );
    giftAnimation = CurvedAnimation(parent: giftAnimationController, curve: Curves.elasticInOut);
    giftAnimationController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        giftAnimationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) => scrollToChatMessage());

    Widget messageList(LiveStreamViewerViewModel model) {
      return Container(
        margin: EdgeInsets.only(bottom: 50),
        alignment: Alignment.bottomLeft,
        child: FractionallySizedBox(
          heightFactor: 0.3,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("webblen_live_stream_chats")
                  .doc(model.streamID)
                  .collection("messages")
                  .where('timePostedInMilliseconds', isGreaterThan: model.startChatAfterTimeInMilliseconds)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData || snapshot.data.docs.isEmpty) return Container();
                return ListView.builder(
                  controller: chatViewController,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (snapshot.data.docs.length > 3) {
                      scrollToChatMessage();
                    }
                    String uid = snapshot.data.docs[index].data()['senderUID'];
                    String username = '@' + snapshot.data.docs[index].data()['username'];
                    String message = snapshot.data.docs[index].data()['message'];
                    String userImgURL = snapshot.data.docs[index].data()['userImgURL'];
                    return username == '@system'
                        ? Container(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            padding: EdgeInsets.only(left: 8.0),
                            child: CustomText(
                              text: message,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white54,
                            ),
                          )
                        : GestureDetector(
                            onTap: () => model.navigateToUserView(uid),
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                              padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              //width: MediaQuery.of(context).size.width * 0.7,
                              child: Row(
                                children: <Widget>[
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 4.0),
                                      CachedNetworkImage(
                                        imageUrl: userImgURL,
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
                                          username,
                                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.6,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Text(
                                          message,
                                          style: TextStyle(color: Colors.white, fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                  },
                );
              },
            ),
          ),
        ),
      );
    }

    Widget giftsAndDonationsStream(LiveStreamViewerViewModel model) {
      return Container(
        margin: EdgeInsets.only(bottom: 50),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          heightFactor: 0.3,
          child: Container(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("webblen_content_gift_pools")
                  .doc(model.webblenLiveStream.id)
                  .collection("logs")
                  .where('timePostedInMilliseconds', isGreaterThan: DateTime.now().millisecondsSinceEpoch - 30000)
                  .orderBy("timePostedInMilliseconds", descending: false)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData || snapshot.data.docs.isEmpty) return Container();
                return ListView.builder(
                  //controller: chatViewController,
                  itemCount: 1, //snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    int giftID = snapshot.data.docs.last.data()['giftID'];
                    String message = snapshot.data.docs.last.data()['message'].toStringAsFixed(2);
                    giftAnimationController.forward();
                    return FadeTransition(
                      opacity: giftAnimation,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 32,
                        child: Column(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              child: Image.asset(
                                giftID == 1
                                    ? 'assets/images/heart_icon.png'
                                    : giftID == 2
                                        ? 'assets/images/double_heart_icon.png'
                                        : giftID == 3
                                            ? 'assets/images/confetti_icon.png'
                                            : giftID == 4
                                                ? 'assets/images/dj_icon.png'
                                                : giftID == 5
                                                    ? 'assets/images/wolf_icon.png'
                                                    : giftID == 6
                                                        ? 'assets/images/eagle_icon.png'
                                                        : giftID == 7
                                                            ? 'assets/images/heart_fire_icon.png'
                                                            : 'assets/images/webblen_coin.png',
                              ),
                            ),
                            CustomText(
                              text: message,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        //color: Colors.green,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );
    }

    return ViewModelBuilder<LiveStreamViewerViewModel>.reactive(
      onModelReady: (model) => model.initialize(context: context),
      viewModelBuilder: () => LiveStreamViewerViewModel(),
      builder: (context, model, child) => SafeArea(
        child: Scaffold(
          body: Container(
            color: Colors.black,
            child: Center(
              child: Stack(
                children: <Widget>[
                  model.isBusy ? Container() : viewRows(model), // Video Widget
                  if (!model.endingStream && !model.isBusy) streamHeader(model),
                  if (!model.endingStream && !model.isBusy) giftsAndDonationsStream(model),
                  if (!model.endingStream && !model.isBusy) messageList(model),
                  if (!model.endingStream && !model.isBusy) bottomBar(model), // send message
                  if (model.endingStream && !model.isBusy) endLive(model), //
                  //if (uploadingFiles && !isLoading) upload(), // view message
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
