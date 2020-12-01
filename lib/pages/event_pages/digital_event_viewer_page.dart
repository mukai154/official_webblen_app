import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wakelock/wakelock.dart';
import 'package:webblen/firebase/data/chat_data.dart';
import 'package:webblen/firebase/data/event_data.dart';
import 'package:webblen/firebase/data/gift_donations_data.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/models/event_chat_message.dart';
import 'package:webblen/models/gift_donation.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/in_app_purchases/in_app_purchases.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';
import 'package:webblen/widgets/events/check_in_count_box.dart';
import 'package:webblen/widgets/events/live_now_box.dart';
import 'package:webblen/widgets/events/viewer_count_box.dart';
import 'package:webblen/widgets/widgets_home/check_in_floating_action.dart';

enum BottomSheetMode {
  rewards,
  refill,
}

class DigitalEventViewerPage extends StatefulWidget {
  final WebblenUser currentUser;
  final WebblenEvent event;

  const DigitalEventViewerPage({Key key, this.currentUser, this.event}) : super(key: key);

  @override
  _DigitalEventViewerPageState createState() => _DigitalEventViewerPageState();
}

class _DigitalEventViewerPageState extends State<DigitalEventViewerPage> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  AppLifecycleState _lastLifecycleState;
  //STREAMING
  String agoraAppID = 'f10ecda2344b4c039df6d33953a3f598';
  RtcEngine agoraRtcEngine;
  bool detaching = false;
  static final _users = <int>[];
  bool muted = false;
  bool isLoggedIntoAgoraRtm = true;
  bool isInAgoraChannel = true;
  var tryingToEnd = false;

  final messageFieldController = TextEditingController();
  ScrollController chatViewController = ScrollController();
  int startChatAfterTimeInMilliseconds = DateTime.now().millisecondsSinceEpoch;

  WebblenUser host;
  int viewerCount;
  bool showWaitingRoom = true;
  bool showGift = true;
  bool isLoading = true;

  //Messaging
  bool isCommenting = false;
  String newMessage;
  GlobalKey messageFieldKey = GlobalKey<FormState>();

  //In-App Purchases
  BottomSheetMode bottomSheetMode = BottomSheetMode.rewards;
  bool completingPurchase = false;
  StreamSubscription _purchaseUpdatedSubscription;
  StreamSubscription _purchaseErrorSubscription;
  StreamSubscription _conectionSubscription;
  final List<String> _productLists = ['webblen_1', 'webblen_5', 'webblen_25', 'webblen_50', 'webblen_100'];
  String _platformVersion = 'Unknown';
  List<IAPItem> _items = [];
  List<PurchasedItem> _purchases = [];

  //Gift Animation
  AnimationController giftAnimationController;
  Animation giftAnimation;

  void checkIntoEvent() async {
    ShowAlertDialogService().showLoadingInfoDialog(context, "Checking Into Stream...");
    EventDataService()
        .checkInAndUpdateEventPayout(
      widget.event.id,
      widget.currentUser.uid,
      widget.currentUser.ap,
    )
        .then((result) {
      ChatDataService().checkIntoStream(
        widget.event.id,
        widget.currentUser.uid,
        widget.currentUser.username,
      );
      Navigator.of(context).pop();
      HapticFeedback.mediumImpact();
    });
  }

  void checkoutOfEvent() async {
    ShowAlertDialogService().showLoadingInfoDialog(context, "Checking Out of Stream...");
    EventDataService()
        .checkoutAndUpdateEventPayout(
      widget.event.id,
      widget.currentUser.uid,
    )
        .then((result) {
      ChatDataService().checkoutOfStream(
        widget.event.id,
        widget.currentUser.uid,
        widget.currentUser.username,
      );
      Navigator.of(context).pop();
      setState(() {});
      HapticFeedback.mediumImpact();
    });
  }

  void giftStreamer(int giftID, double giftAmount) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
    GiftDonation giftDonation = GiftDonation(
      senderUID: widget.currentUser.uid,
      receiverUID: host.uid,
      giftAmount: giftAmount,
      giftID: giftID,
      senderUsername: "@${widget.currentUser.username}",
      timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
    );
    GiftDonationsDataService().sendGift(widget.event.id, widget.currentUser.uid, giftDonation).then((error) {
      if (error == null) {
        GiftDonationsDataService()
            .updateEventGiftLog(widget.event.id, widget.currentUser.uid, widget.currentUser.username, widget.currentUser.profile_pic, giftDonation);
      } else if (error == "insufficient") {
        ShowAlertDialogService().showFailureDialog(context, "Error", "Insufficient Funds");
      } else {
        ShowAlertDialogService().showFailureDialog(context, "Error", error);
      }
    });
  }

  void purchaseProduct(String prodID) {
    completingPurchase = true;
    ShowAlertDialogService().showLoadingDialog(context);
    setState(() {});
    FlutterInappPurchase.instance.requestPurchase(prodID);
  }

  void _getItems() async {
    List<IAPItem> items = await FlutterInappPurchase.instance.getProducts(_productLists);
    for (var item in items) {
      this._items.add(item);
    }
  }

  Future _getProduct() async {
    List<IAPItem> items = await FlutterInappPurchase.instance.getProducts(_productLists);
    for (var item in items) {
      print('${item.toString()}');
      this._items.add(item);
    }

    setState(() {
      this._items = items;
      this._purchases = [];
    });
  }

  Future _getPurchases() async {
    List<PurchasedItem> items = await FlutterInappPurchase.instance.getAvailablePurchases();
    for (var item in items) {
      this._purchases.add(item);
    }

    setState(() {
      this._items = [];
      this._purchases = items;
    });
  }

  Future _getPurchaseHistory() async {
    List<PurchasedItem> items = await FlutterInappPurchase.instance.getPurchaseHistory();
    for (var item in items) {
      print('${item.toString()}');
      this._purchases.add(item);
    }

    setState(() {
      this._items = [];
      this._purchases = items;
    });
  }

  //VIDEO STREAM WIDGETS
  Widget commentField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      width: MediaQuery.of(context).size.width * 0.65,
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(16)), color: Colors.black45),
      child: TextFormField(
        controller: messageFieldController,
        minLines: 1,
        maxLines: 5,
        maxLengthEnforced: true,
        onTap: () {
          isCommenting = true;
          setState(() {});
        },
        cursorColor: Colors.white,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (val) {
          String text = val.trim();
          if (text.isNotEmpty) {
            EventChatMessage message = EventChatMessage(
              senderUID: widget.currentUser.uid,
              userImgURL: widget.currentUser.profile_pic,
              username: widget.currentUser.username,
              message: text,
              timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
            );
            ChatDataService().sendEventChatMessage(widget.event.id, message);
          }
          messageFieldController.clear();
          isCommenting = false;
          setState(() {});
        },
        inputFormatters: [
          LengthLimitingTextInputFormatter(75),
        ],
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Comment",
          hintStyle: TextStyle(color: Colors.white54),
          border: InputBorder.none,
        ),
      ),
    );
  }

  void initializeFlutterIAP() async {
    String platformVersion;
    try {
      platformVersion = await FlutterInappPurchase.instance.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    var result = await FlutterInappPurchase.instance.initConnection;
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });

    // refresh items for android
    try {
      String msg = await FlutterInappPurchase.instance.consumeAllItems;
      print('consumeAllItems: $msg');
    } catch (err) {
      print('consumeAllItems error: $err');
    }

    _conectionSubscription = FlutterInappPurchase.connectionUpdated.listen((connected) {
      print('connected: $connected');
    });

    _purchaseUpdatedSubscription = FlutterInappPurchase.purchaseUpdated.listen((productItem) {
      String productID = productItem.productId;
      FlutterInappPurchase.instance.finishTransaction(productItem);
      InAppPurchaseService().completeInAppPurchase(productID, widget.currentUser.uid).then((error) {
        if (error != null) {
          print(error);
        }
        if (completingPurchase) {
          Navigator.of(context).pop();
          HapticFeedback.mediumImpact();
          completingPurchase = false;
          setState(() {});
        }
      });
      print('purchase-updated: $productItem');
    });

    _purchaseErrorSubscription = FlutterInappPurchase.purchaseError.listen((purchaseError) {
      if (completingPurchase) {
        Navigator.of(context).pop();
        completingPurchase = false;
        setState(() {});
      }
      print('purchase-error: $purchaseError');
    });
    _getItems();
    _getPurchases();
    _getPurchaseHistory();
  }

  initialize() async {
//    int agoraUID = int.parse(randomNumeric(10));
//    String agoraToken = await AgoraService().retrieveAgoraToken(widget.event, agoraUID);
    await initializeAgoraRtc();
    host = await WebblenUserData().getUserByID(widget.event.authorID);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(MediaQuery.of(context).size.height.round(), MediaQuery.of(context).size.width.round());
    configuration.frameRate = VideoFrameRate.Fps30;
    await agoraRtcEngine.setVideoEncoderConfiguration(configuration);
    await agoraRtcEngine.joinChannel(null, widget.event.id, null, 0);
    setAgoraRtcEventHandlers();
    isLoading = false;
    setState(() {});
  }

  /// Create agora sdk instance and initialize
  initializeAgoraRtc() async {
    agoraRtcEngine = await RtcEngine.create(agoraAppID);
    await agoraRtcEngine.enableVideo();
    await agoraRtcEngine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await agoraRtcEngine.setClientRole(ClientRole.Audience);
  }

  setAgoraRtcEventHandlers() {
    agoraRtcEngine.setEventHandler(RtcEngineEventHandler(error: (code) {
      setState(() {
        print('Error: $code');
      });
    }, joinChannelSuccess: (channel, uid, elapsed) async {
      await Wakelock.enable();
    }, leaveChannel: (stats) {
      setState(() {
        _users.clear();
      });
    }, userJoined: (uid, elapsed) {
      setState(() {
        showWaitingRoom = false;
        _users.add(uid);
      });
    }, userOffline: (uid, elapsed) {
      setState(() {
        showWaitingRoom = true;
        _users.remove(uid);
      });
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      setState(() {
        showWaitingRoom = false;
      });
    }));
  }

  Future<bool> _willPopCallback() async {
    setState(() {
      tryingToEnd = !tryingToEnd;
    });
    return false; // return true if the route to be popped
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[_expandedVideoRow(views.sublist(0, 2)), _expandedVideoRow(views.sublist(2, 3))],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[_expandedVideoRow(views.sublist(0, 2)), _expandedVideoRow(views.sublist(2, 4))],
        ));
      default:
    }
    return Container();
  }

  Widget _awardIcon(int giftID, double giftAmount) {
    return GestureDetector(
      onTap: () => giftStreamer(giftID, giftAmount),
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
          SizedBox(height: 4),
          Text(
            giftID == 1
                ? 'Love'
                : giftID == 2
                    ? 'More Love'
                    : giftID == 3
                        ? 'Confetti'
                        : giftID == 4
                            ? 'Party'
                            : giftID == 5
                                ? 'Wolf'
                                : giftID == 6
                                    ? 'Eagle'
                                    : giftID == 7
                                        ? 'Much Love'
                                        : 'Webblen',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Text(
                giftID == 1
                    ? '0.10'
                    : giftID == 2
                        ? '0.50'
                        : giftID == 3
                            ? '5'
                            : giftID == 4
                                ? '25'
                                : giftID == 5
                                    ? '50'
                                    : giftID == 6
                                        ? '100'
                                        : giftID == 7
                                            ? '500'
                                            : '1',
                style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w300),
              ),
              SizedBox(width: 4),
              Container(
                height: 15,
                width: 15,
                child: Image.asset(
                  'assets/images/webblen_coin.png',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gridItem(int itemNum, String prodID) {
    return GestureDetector(
      onTap: () => purchaseProduct(prodID),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 20,
                  width: 20,
                  child: Image.asset(
                    'assets/images/webblen_coin.png',
                  ),
                ),
                SizedBox(width: 2),
                Text(
                  itemNum == 1
                      ? '1'
                      : itemNum == 2
                          ? '5'
                          : itemNum == 3
                              ? '25'
                              : itemNum == 4
                                  ? '50'
                                  : '100',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              itemNum == 1
                  ? '\$0.99'
                  : itemNum == 2
                      ? '\$4.99'
                      : itemNum == 3
                          ? '\$24.99'
                          : itemNum == 4
                              ? '\$49.99'
                              : '\$99.99',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w300,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget streamHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16.0),
      child: Column(
        children: [
          Container(
            //height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Row(
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 4.0),
                          CachedNetworkImage(
                            imageUrl: widget.event.imageURL,
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
                      SizedBox(width: 8.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.event.title,
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          host == null
                              ? Container()
                              : GestureDetector(
                                  onTap: () => PageTransitionService(
                                    context: context,
                                    currentUser: widget.currentUser,
                                    webblenUser: host,
                                  ).transitionToUserPage(),
                                  child: Text(
                                    "Hosted by: @${host.username}",
                                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                                  ),
                                ),
                        ],
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      tryingToEnd = true;
                    });
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    child: Center(
                      child: Icon(
                        FontAwesomeIcons.times,
                        color: Colors.white60,
                        size: 24.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.0),
          Container(
            height: 40,
            child: Row(
              children: [
                showWaitingRoom ? OffAirBox() : LiveNowBox(),
                SizedBox(width: 8.0),
                StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("event_chats").doc(widget.event.id).snapshots(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (!snapshot.hasData) return Container();
                    var streamData = snapshot.data.data();
                    List activeMembers = streamData['activeMembers'] == null ? [widget.currentUser.uid] : streamData['activeMembers'];
                    return ViewerCountBox(viewCount: activeMembers.length);
                  },
                ),
                SizedBox(width: 8.0),
                StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("events").doc(widget.event.id).snapshots(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (!snapshot.hasData) return Container();
                    var eventData = snapshot.data.data();
                    List attendees = eventData['d']['attendees'];
                    return CheckInCountBox(checkInCount: attendees.length);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget leaveStream() {
    return Container(
      color: Colors.black87,
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text(
                'Are you sure you want to leave this stream?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
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
                    child: RaisedButton(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          'Leave',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      elevation: 2.0,
                      color: Colors.red,
                      onPressed: () async {
                        await Wakelock.disable();
                        agoraRtcEngine.leaveChannel();
                        agoraRtcEngine.destroy();
                        ChatDataService().leaveChatStream(widget.event.id, widget.currentUser.uid, false, widget.currentUser.username);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0, right: 8.0, top: 8.0, bottom: 8.0),
                    child: RaisedButton(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      elevation: 2.0,
                      color: Colors.grey,
                      onPressed: () {
                        setState(() {
                          tryingToEnd = false;
                        });
                      },
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

  /// Toolbar layout
  Widget _bottomBar() {
    return Container(
      alignment: Alignment.bottomRight,
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
                    maxLengthEnforced: true,
                    cursorColor: Colors.white,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (val) {
                      String text = val.trim();
                      if (text.isNotEmpty) {
                        EventChatMessage message = EventChatMessage(
                          userImgURL: widget.currentUser.profile_pic,
                          senderUID: widget.currentUser.uid,
                          username: widget.currentUser.username,
                          message: text,
                          timePostedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
                        );
                        ChatDataService().sendEventChatMessage(widget.event.id, message);
                      }
                      messageFieldController.clear();
                      setState(() {});
                    },
                    style: TextStyle(color: Colors.white),
                    controller: messageFieldController,
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
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.black87,
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              height: 400,
                              child: bottomSheetMode == BottomSheetMode.rewards
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 16),
                                        Text(
                                          'Gifts',
                                          style: TextStyle(
                                            fontSize: 32,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(height: 32),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            _awardIcon(1, 0.10),
                                            _awardIcon(2, 0.50),
                                            _awardIcon(3, 5.0001),
                                            _awardIcon(4, 25.0001),
                                          ],
                                        ),
                                        SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            _awardIcon(5, 50.0001),
                                            _awardIcon(6, 100.0001),
                                            _awardIcon(7, 500.0001),
                                            _awardIcon(8, 1.0001),
                                          ],
                                        ),
                                        SizedBox(height: 32),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  height: 15,
                                                  width: 15,
                                                  child: Image.asset(
                                                    'assets/images/webblen_coin.png',
                                                  ),
                                                ),
                                                SizedBox(width: 4),
                                                StreamBuilder(
                                                  stream: FirebaseFirestore.instance.collection("webblen_user").doc(widget.currentUser.uid).snapshots(),
                                                  builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                                                    if (!userSnapshot.hasData)
                                                      return Text(
                                                        "Loading...",
                                                      );
                                                    var userData = userSnapshot.data.data();
                                                    double availablePoints = userData['d']["eventPoints"] * 1.00;
                                                    return Padding(
                                                      padding: EdgeInsets.all(4.0),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Text(
                                                            availablePoints.toStringAsFixed(2),
                                                            style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w300),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                            GestureDetector(
                                              child: Text(
                                                'Get More Webblen',
                                                style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w300),
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  bottomSheetMode = BottomSheetMode.refill;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: 100,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 15,
                                                    width: 15,
                                                    child: Image.asset(
                                                      'assets/images/webblen_coin.png',
                                                    ),
                                                  ),
                                                  SizedBox(width: 4),
                                                  StreamBuilder(
                                                    stream: FirebaseFirestore.instance.collection("webblen_user").doc(widget.currentUser.uid).snapshots(),
                                                    builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                                                      if (!userSnapshot.hasData)
                                                        return Text(
                                                          "...",
                                                        );
                                                      var userData = userSnapshot.data.data();
                                                      double availablePoints = userData['d']["eventPoints"] * 1.00;
                                                      return Padding(
                                                        padding: EdgeInsets.all(4.0),
                                                        child: Row(
                                                          children: <Widget>[
                                                            Text(
                                                              availablePoints.toStringAsFixed(2),
                                                              style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w300),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: 100,
                                              child: Text(
                                                'Refill',
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  color: Colors.white,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Container(
                                              width: 100,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 32),
                                        GridView.count(
                                          childAspectRatio: 3 / 2,
                                          shrinkWrap: true,
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 8,
                                          mainAxisSpacing: 18,
                                          children: [
                                            _gridItem(1, 'webblen_1'),
                                            _gridItem(2, 'webblen_5'),
                                            _gridItem(3, 'webblen_25'),
                                            _gridItem(4, 'webblen_50'),
                                            _gridItem(5, 'webblen_100'),
                                          ],
                                        ),
                                        SizedBox(height: 32),
                                        GestureDetector(
                                          child: Text(
                                            'Back',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                          onTap: () {
                                            setState(() {
                                              bottomSheetMode = BottomSheetMode.rewards;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                            );
                          },
                        );
                      },
                    );
                  },
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
              StreamBuilder(
                stream: FirebaseFirestore.instance.collection("events").doc(widget.event.id).snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (!snapshot.hasData) return Container();
                  var eventData = snapshot.data.data();
                  List attendees = eventData['d']['attendees'];
                  return showWaitingRoom
                      ? Container(height: 0)
                      : attendees.contains(widget.currentUser.uid)
                          ? AltCheckInFloatingAction(
                              checkInAvailable: true,
                              isVirtualEventCheckIn: true,
                              checkInAction: () => checkoutOfEvent(),
                            )
                          : CheckInFloatingAction(
                              checkInAvailable: true,
                              isVirtualEventCheckIn: true,
                              checkInAction: () => checkIntoEvent(),
                            );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  scrollToChatMessage() async {
    if (chatViewController.position.pixels == chatViewController.position.maxScrollExtent) {
      await Future.delayed(Duration(milliseconds: 500));
      if (chatViewController.hasClients) {
        chatViewController.jumpTo(chatViewController.position.maxScrollExtent);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    startChatAfterTimeInMilliseconds = DateTime.now().millisecondsSinceEpoch;
    setState(() {});
    initialize();
    initializeFlutterIAP();
    ChatDataService().joinChatStream(
      widget.event.id,
      widget.currentUser.uid,
      false,
      widget.currentUser.username,
    );
  }

  @override
  void dispose() {
    super.dispose();
    // clear users
    _users.clear();
    WidgetsBinding.instance.removeObserver(this);
    giftAnimationController.dispose();
    // destroy sdk
    agoraRtcEngine.leaveChannel();
    agoraRtcEngine.destroy();
    chatViewController.dispose();
    messageFieldController.dispose();
    if (_conectionSubscription != null) {
      _conectionSubscription.cancel();
      _conectionSubscription = null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (detaching) {
        ChatDataService().joinChatStream(widget.event.id, widget.currentUser.uid, false, widget.currentUser.username);
      }
      detaching = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) => scrollToChatMessage());

    Widget messageList() {
      return Container(
        margin: EdgeInsets.only(bottom: 50),
        alignment: Alignment.bottomLeft,
        child: FractionallySizedBox(
          heightFactor: 0.3,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("event_chats")
                  .doc(widget.event.id)
                  .collection("messages")
                  .where('timePostedInMilliseconds', isGreaterThan: startChatAfterTimeInMilliseconds)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData || snapshot.data.docs.isEmpty) return Container();
                return ListView.builder(
                  controller: chatViewController,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    scrollToChatMessage();
                    String username = '@' + snapshot.data.docs[index].data()['username'];
                    String message = snapshot.data.docs[index].data()['message'];
                    String userImgURL = snapshot.data.docs[index].data()['userImgURL'];
                    return username == '@system'
                        ? Container(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            padding: EdgeInsets.only(left: 8.0),
                            child: Fonts().textW700(
                              '$message',
                              14.0,
                              Colors.white54,
                              TextAlign.left,
                            ))
                        : Container(
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
                          );
                  },
                );
              },
            ),
          ),
        ),
      );
    }

    Widget giftsAndDonationsStream() {
      return Container(
        margin: EdgeInsets.only(bottom: 50),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          heightFactor: 0.3,
          child: Container(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("gift_donations")
                  .doc(widget.event.id)
                  .collection("gift_donations")
                  .where('timePostedInMilliseconds', isGreaterThan: DateTime.now().millisecondsSinceEpoch - 30000)
                  .orderBy("timePostedInMilliseconds", descending: false)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData || snapshot.data.docs.isEmpty) return Container();
                return ListView.builder(
                  //controller: chatViewController,
                  itemCount: 1, //snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    String senderUsername = snapshot.data.docs.last.data()['senderUsername'];
                    int giftID = snapshot.data.docs.last.data()['giftID'];
                    String giftAmount = snapshot.data.docs.last.data()['giftAmount'].toStringAsFixed(2);
                    giftAnimationController.forward();
                    return FadeTransition(
                      opacity: giftAnimation,
                      child: Container(
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
                            Fonts().textW700(
                              '$senderUsername gifted $giftAmount Webblen',
                              25.0,
                              Colors.white,
                              TextAlign.left,
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

    return WillPopScope(
      child: SafeArea(
        child: Scaffold(
          body: Container(
            color: Colors.black,
            child: Center(
              child: Stack(
                children: <Widget>[
                  showWaitingRoom
                      ? Container(
                          color: Colors.grey,
                          child: Center(
                            child: CustomText(
                              context: context,
                              text: "Host is Currently Offline",
                              textColor: Colors.white,
                              textAlign: TextAlign.left,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : _viewRows(), // Video Widget
                  if (tryingToEnd == false) streamHeader(),
                  if (tryingToEnd == false) giftsAndDonationsStream(),
                  if (tryingToEnd == false) messageList(),
                  if (tryingToEnd == false) _bottomBar(), // send message
                  if (tryingToEnd == true) leaveStream(), // view message
                ],
              ),
            ),
          ),
        ),
      ),
      onWillPop: _willPopCallback,
    );
  }
}
