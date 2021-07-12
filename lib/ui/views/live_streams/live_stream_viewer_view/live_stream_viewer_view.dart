import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/views/live_streams/live_stream_viewer_view/live_stream_viewer_view_model.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/live_streams/check_in_button/virtual_check_in_button.dart';
import 'package:webblen/ui/widgets/live_streams/video_ui/check_in_count_box.dart';
import 'package:webblen/ui/widgets/live_streams/video_ui/video_streaming_status.dart';
import 'package:webblen/ui/widgets/live_streams/video_ui/viewer_count_box.dart';
import 'package:webblen/utils/custom_string_methods.dart';

class LiveStreamViewerView extends StatefulWidget {
  final String? id;
  LiveStreamViewerView(@PathParam() this.id);
  @override
  _LiveStreamViewerViewState createState() => _LiveStreamViewerViewState();
}

class _LiveStreamViewerViewState extends State<LiveStreamViewerView> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  ScrollController chatViewController = ScrollController();
  late AnimationController giftAnimationController;
  late Animation<double> giftAnimation;

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
                Expanded(
                  flex: 9,
                  child: Text(
                    model.webblenLiveStream.title!,
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () => model.toggleEndingStream(),
                    child: Icon(
                      FontAwesomeIcons.times,
                      color: Colors.white60,
                      size: 24.0,
                    ),
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
                CheckInCountBox(checkInCount: model.webblenLiveStream.attendees == null ? 0 : model.webblenLiveStream.attendees!.length),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => model.customNavigationService.navigateToUserView(model.webblenLiveStream.hostID!),
            child: Text(
              "Hosted by: @${model.hostUserName}",
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          )
        ],
      ),
    );
  }

  Widget exitStreamButton(LiveStreamViewerViewModel model) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
            child: GestureDetector(
              onTap: () => model.toggleEndingStream(),
              child: Text(
                'X',
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
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.only(left: 8, top: 5, right: 8, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
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
                  onPressed: () => model.giftWBLN(),
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
              // model.showWaitingRoom
              //     ? Container(height: 0)
              //     :
              model.checkedIn
                  ? AltCheckInFloatingAction(
                      checkOutAction: () => model.checkInCheckoutOfStream(),
                    )
                  : CheckInFloatingAction(
                      checkInAction: () => model.checkInCheckoutOfStream(),
                    ),
            ],
          ),
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
                'Are you sure you want to leave this live stream?',
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
                          'Leave Stream',
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
      duration: Duration(milliseconds: 2500),
    );
    giftAnimation = CurvedAnimation(parent: giftAnimationController, curve: Curves.elasticInOut);
    giftAnimationController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        giftAnimationController.reverse();
      }
    });
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance!.addPostFrameCallback((_) => scrollToChatMessage());

    return ViewModelBuilder<LiveStreamViewerViewModel>.reactive(
      onModelReady: (model) => model.initialize(widget.id!),
      viewModelBuilder: () => LiveStreamViewerViewModel(),
      builder: (context, model, child) => Scaffold(
        body: Container(
          height: screenHeight(context),
          color: appBackgroundColor(),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: model.isBusy
                ? Container(
                    color: Colors.black,
                    child: Center(
                      child: CustomText(
                        text: "Joining Stream...",
                        color: Colors.white,
                        textAlign: TextAlign.left,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : OrientationBuilder(
                    builder: (context, orientation) {
                      return orientation == Orientation.portrait
                          ? SafeArea(
                              child: Stack(
                                children: [
                                  Container(
                                    height: screenHeight(context),
                                    child: Column(
                                      children: [
                                        _PortraitStreamVideo(),
                                        _PortraitStreamInfo(),
                                        Expanded(
                                          flex: 10,
                                          child: _PortraitChat(),
                                        ),
                                        if (!model.isBusy) _PortraitBottomBar(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : _LandscapeStreamVideo();
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class _GiftsAndDonationsAnimator extends HookViewModelWidget<LiveStreamViewerViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, LiveStreamViewerViewModel model) {
    AnimationController _animationController = useAnimationController(duration: Duration(milliseconds: 2500));
    Animation<double> _giftAnimation = CurvedAnimation(parent: _animationController, curve: Curves.elasticInOut);
    _animationController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    });

    return Container(
      alignment: Alignment.center,
      constraints: BoxConstraints(
        maxHeight: 300,
        maxWidth: 500,
      ),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("webblen_content_gift_pools")
            .doc(model.webblenLiveStream.id)
            .collection("logs")
            .where('timePostedInMilliseconds', isGreaterThan: DateTime.now().millisecondsSinceEpoch - 30000)
            .orderBy("timePostedInMilliseconds", descending: false)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Container();
          return ListView.builder(
            shrinkWrap: true,
            itemCount: 1,
            itemBuilder: (context, index) {
              Map<String, dynamic> snapshotData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              int? giftID = snapshotData['giftID'];
              String? message = snapshotData['message'];
              String? senderUsername = snapshotData['senderUsername'];
              print(giftID);
              print(message);
              _animationController.forward();
              return FadeTransition(
                opacity: _giftAnimation,
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      Container(
                        child: CustomText(
                          text: "@$senderUsername gifted ${getGiftAmountFromGiftID(giftID!)} WBLN",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          textAlign: TextAlign.center,
                        ),
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
    );
  }
}

class _PortraitLiveVideoWrapper extends HookViewModelWidget<LiveStreamViewerViewModel> {
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                color: Colors.grey,
                child: Center(
                  child: CustomText(
                    text: "Host is Currently Offline",
                    color: Colors.white,
                    textAlign: TextAlign.left,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      case 2:
        return Container(
          child: Column(
            children: <Widget>[
              expandedVideoRow([views[1]])
            ],
          ),
        );
    }
    return Container();
  }

  @override
  Widget buildViewModelWidget(BuildContext context, LiveStreamViewerViewModel model) {
    return Container(
      color: CustomColors.webblenDarkGray,
      child: AspectRatio(
        aspectRatio: 16.0 / 9.0,
        child: Stack(
          children: <Widget>[
            model.showWaitingRoom
                ? Container(
                    color: CustomColors.webblenDarkGray,
                    child: Center(
                      child: CustomText(
                        text: "Connecting to Host...",
                        color: Colors.white,
                        textAlign: TextAlign.left,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : viewRows(model), // Video Widget
            Align(
              alignment: Alignment.topRight,
              child: Container(
                margin: EdgeInsets.only(right: 8, top: 8),
                child: GestureDetector(
                  onTap: () => model.toggleEndingStream(),
                  child: Icon(
                    FontAwesomeIcons.times,
                    color: Colors.white60,
                    size: 24.0,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: EdgeInsets.only(right: 8, bottom: 8),
                child: GestureDetector(
                  onTap: () => model.switchToLandScape(),
                  child: Icon(
                    Icons.crop_landscape,
                    color: Colors.white60,
                    size: 24.0,
                  ),
                ),
              ),
            ),
            if (!model.endingStream && !model.isBusy) _GiftsAndDonationsAnimator(), // send message
            // if (model.endingStream && !model.isBusy) endLive(model), //
          ],
        ),
      ),
    );
  }
}

class _PortraitStreamVideo extends HookViewModelWidget<LiveStreamViewerViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, LiveStreamViewerViewModel model) {
    return Container(
      color: CustomColors.webblenDarkGray,
      child: AspectRatio(
        aspectRatio: 16.0 / 9.0,
        child: Stack(
          children: <Widget>[
            model.showWaitingRoom
                ? Container(
                    color: Colors.grey,
                    child: Center(
                      child: CustomText(
                        text: "Host is Currently Offline",
                        color: Colors.white,
                        textAlign: TextAlign.left,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : _PortraitLiveVideoWrapper(),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                margin: EdgeInsets.only(right: 8, top: 8),
                child: GestureDetector(
                  onTap: () => model.endStream(),
                  child: Icon(
                    FontAwesomeIcons.times,
                    color: Colors.white60,
                    size: 24.0,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: EdgeInsets.only(right: 8, bottom: 8),
                child: GestureDetector(
                  onTap: () => model.switchToLandScape(),
                  child: Icon(
                    Icons.crop_landscape,
                    color: Colors.white60,
                    size: 24.0,
                  ),
                ),
              ),
            ),
            if (!model.endingStream && !model.isBusy) _GiftsAndDonationsAnimator(), // send message
            // if (model.endingStream && !model.isBusy) endLive(model), //
          ],
        ),
      ),
    );
  }
}

class _PortraitStreamInfo extends HookViewModelWidget<LiveStreamViewerViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, LiveStreamViewerViewModel model) {
    return Container(
      height: 110,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            model.webblenLiveStream.title!,
            style: TextStyle(color: appFontColor(), fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Container(
            height: 40,
            child: Row(
              children: [
                model.showWaitingRoom ? Container() : LiveNowBox(),
                model.showWaitingRoom ? Container() : SizedBox(width: 8.0),
                ViewerCountBox(viewCount: 1),
                SizedBox(width: 8.0),
                CheckInCountBox(checkInCount: model.webblenLiveStream.attendees == null ? 0 : model.webblenLiveStream.attendees!.length),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => model.customNavigationService.navigateToUserView(model.webblenLiveStream.hostID!),
                child: Text(
                  "Hosted by: @${model.hostUserName}",
                  style: TextStyle(color: appFontColor(), fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
              GestureDetector(
                onTap: () => model.customBottomSheetService.showContentOptions(content: model.webblenLiveStream),
                child: Icon(
                  FontAwesomeIcons.ellipsisH,
                  color: appIconColor(),
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PortraitChat extends HookViewModelWidget<LiveStreamViewerViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, LiveStreamViewerViewModel model) {
    final _scrollController = useScrollController();

    SchedulerBinding.instance!.addPostFrameCallback((_) => model.scrollToChatMessage(_scrollController));

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode() ? CustomColors.webblenDarkGray : CustomColors.iosOffWhite,
        border: Border(
          top: BorderSide(
            color: appBorderColor(),
            width: 0.8,
          ),
          bottom: BorderSide(
            color: appBorderColor(),
            width: 0.8,
          ),
        ),
      ),
      child: Container(
        width: screenWidth(context),
        alignment: Alignment.bottomCenter,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("webblen_live_stream_chats")
              .doc(model.webblenLiveStream.id)
              .collection("messages")
              .where('timePostedInMilliseconds', isGreaterThan: model.startChatAfterTimeInMilliseconds)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Container();
            return ListView.builder(
              controller: _scrollController,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                Map<String, dynamic> snapshotData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                String? uid = snapshotData['senderUID'];
                String username = '@' + snapshotData['username'];
                String? message = snapshotData['message'];
                String? userImgURL = snapshotData['userImgURL'];
                return username == '@system'
                    ? Container(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        padding: EdgeInsets.only(left: 16.0),
                        child: CustomText(
                          text: message,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode() ? Colors.white54 : Colors.black45,
                        ),
                      )
                    : GestureDetector(
                        onTap: () => model.customNavigationService.navigateToUserView(uid!),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                          padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                          //width: MediaQuery.of(context).size.width * 0.7,
                          child: Row(
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: userImgURL!,
                                    imageBuilder: (context, imageProvider) => Container(
                                      width: 35.0,
                                      height: 35.0,
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
                                      style: TextStyle(color: appFontColor(), fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    width: screenWidth(context) - 69,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      message!,
                                      style: TextStyle(color: appFontColor(), fontSize: 14),
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
    );
  }
}

class _PortraitBottomBar extends HookViewModelWidget<LiveStreamViewerViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, LiveStreamViewerViewModel model) {
    return !model.isInAgoraChannel
        ? Container()
        : Container(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(top: 8),
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
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
                        onPressed: () => model.giftWBLN(),
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
                    // model.showWaitingRoom
                    //     ? Container(height: 0)
                    //     :
                    model.checkedIn
                        ? AltCheckInFloatingAction(
                            checkOutAction: () => model.checkInCheckoutOfStream(),
                          )
                        : CheckInFloatingAction(
                            checkInAction: () => model.checkInCheckoutOfStream(),
                          ),
                  ],
                ),
              ),
            ),
          );
  }
}

class _LandscapeLiveVideoWrapper extends HookViewModelWidget<LiveStreamViewerViewModel> {
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                color: Colors.grey,
                child: Center(
                  child: CustomText(
                    text: "Host is Currently Offline",
                    color: Colors.white,
                    textAlign: TextAlign.left,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      case 2:
        return Container(
          child: Column(
            children: <Widget>[
              expandedVideoRow([views[1]])
            ],
          ),
        );
    }
    return Container();
  }

  @override
  Widget buildViewModelWidget(BuildContext context, LiveStreamViewerViewModel model) {
    return Container(
      color: Colors.grey,
      height: screenHeight(context),
      width: screenWidth(context),
      child: Stack(
        children: <Widget>[
          model.showWaitingRoom
              ? Container(
                  color: Colors.grey,
                  child: Center(
                    child: CustomText(
                      text: "Host is Currently Offline",
                      color: Colors.white,
                      textAlign: TextAlign.left,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : viewRows(model), // Video Widget
          if (!model.endingStream && !model.isBusy) _GiftsAndDonationsAnimator(), // send message
          // if (model.endingStream && !model.isBusy) endLive(model), //
        ],
      ),
    );
  }
}

class _LandscapeLiveVideoHeader extends HookViewModelWidget<LiveStreamViewerViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, LiveStreamViewerViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 9,
                  child: Text(
                    model.webblenLiveStream.title!,
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () => model.endStream(),
                    child: Icon(
                      FontAwesomeIcons.times,
                      color: Colors.white60,
                      size: 24.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 40,
            child: Row(
              children: [
                model.isInAgoraChannel ? Container() : LiveNowBox(),
                model.isInAgoraChannel ? Container() : SizedBox(width: 8.0),
                ViewerCountBox(viewCount: model.webblenLiveStream.activeViewers == null ? 0 : model.webblenLiveStream.activeViewers!.length),
                SizedBox(width: 8.0),
                CheckInCountBox(checkInCount: model.webblenLiveStream.attendees == null ? 0 : model.webblenLiveStream.attendees!.length),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => model.customNavigationService.navigateToUserView(model.webblenLiveStream.hostID!),
            child: Text(
              "Hosted by: @${model.hostUserName}",
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          )
        ],
      ),
    );
  }
}

class _LandscapeStreamVideo extends HookViewModelWidget<LiveStreamViewerViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, LiveStreamViewerViewModel model) {
    return Container(
      color: Colors.grey,
      child: Stack(
        children: <Widget>[
          model.showWaitingRoom
              ? Container(
                  color: Colors.grey,
                  child: Center(
                    child: CustomText(
                      text: "Host is Currently Offline",
                      color: Colors.white,
                      textAlign: TextAlign.left,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : _LandscapeLiveVideoWrapper(),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(left: 16, top: 8, right: 16),
              child: _LandscapeLiveVideoHeader(),
            ),
          ),
          _LandscapeChat(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(left: 16, bottom: 8, right: 16),
              child: _LandscapeBottomBar(),
            ),
          ),
          if (!model.endingStream && !model.isBusy) _GiftsAndDonationsAnimator(), // send message
          // if (model.endingStream && !model.isBusy) endLive(model), //
        ],
      ),
    );
  }
}

class _LandscapeChat extends HookViewModelWidget<LiveStreamViewerViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, LiveStreamViewerViewModel model) {
    final _scrollController = useScrollController();

    SchedulerBinding.instance!.addPostFrameCallback((_) => model.scrollToChatMessage(_scrollController));

    return Container(
      margin: EdgeInsets.only(bottom: 60, left: 16, right: 16),
      alignment: Alignment.bottomLeft,
      child: FractionallySizedBox(
        heightFactor: 0.45,
        child: Container(
          width: screenWidth(context) * 0.5,
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("webblen_live_stream_chats")
                .doc(model.webblenLiveStream.id)
                .collection("messages")
                .where('timePostedInMilliseconds', isGreaterThan: model.startChatAfterTimeInMilliseconds)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              try {
                model.scrollToChatMessage(_scrollController);
              } catch (e) {}
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Container();
              return ListView.builder(
                controller: _scrollController,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  Map<String, dynamic> snapshotData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  String? uid = snapshotData['senderUID'];
                  String username = '@' + snapshotData['username'];
                  String? message = snapshotData['message'];
                  String? userImgURL = snapshotData['userImgURL'];
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
                          onTap: () => model.customNavigationService.navigateToUserView(uid!),
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
                                      imageUrl: userImgURL!,
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
                                      width: screenWidth(context) * 0.40,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        message!,
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
}

class _LandscapeBottomBar extends HookViewModelWidget<LiveStreamViewerViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, LiveStreamViewerViewModel model) {
    return !model.isInAgoraChannel
        ? Container()
        : Container(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(top: 8),
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
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
                    horizontalSpaceSmall,
                    model.checkedIn
                        ? AltCheckInFloatingAction(
                            checkOutAction: () => model.checkInCheckoutOfStream(),
                          )
                        : CheckInFloatingAction(
                            checkInAction: () => model.checkInCheckoutOfStream(),
                          ),
                  ],
                ),
              ),
            ),
          );
  }
}
