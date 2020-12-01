import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/firebase/data/reward_data.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/models/webblen_reward.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/rewards/reward_block.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';

class ShopPage extends StatefulWidget {
  final WebblenUser currentUser;

  ShopPage({
    this.currentUser,
  });

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  bool isAdmin = false;
  bool isLoading = true;
  bool purchaseIsLoading = false;
  List<WebblenReward> availableRewards = [];
  List<WebblenReward> globalRewards = [];
  List<WebblenReward> merchRewards = [];
  List<WebblenReward> cashRewards = [];
  List<WebblenReward> charityRewards = [];

  void dismissPurchaseDialog(BuildContext context) {
    Navigator.pop(context);
  }

  showCharityDialog(BuildContext context) {}

  purchaseSuccessDialog(String header, String body) {
    setState(() {
      purchaseIsLoading = false;
    });
    Navigator.pop(context);
    ShowAlertDialogService().showSuccessDialog(
      context,
      header,
      body,
    );
  }

  purchaseFailedDialog(String header, String body) {
    setState(() {
      purchaseIsLoading = false;
    });
    Navigator.pop(context);
    ShowAlertDialogService().showFailureDialog(
      context,
      header,
      body,
    );
  }

  // void purchaseReward(WebblenReward reward) async {
  //   setState(() {
  //     purchaseIsLoading = true;
  //   });
  //   RewardDataService()
  //       .purchaseReward(
  //     widget.currentUser.uid,
  //     reward.id,
  //     reward.cost,
  //   )
  //       .then((e) {
  //     if (e.isNotEmpty) {
  //       purchaseFailedDialog(
  //         "Purchase Failed",
  //         e,
  //       );
  //     } else {
  //       purchaseSuccessDialog(
  //         "Reward Purchased!",
  //         "Your Reward is Now in Your Wallet",
  //       );
  //     }
  //   });
  // }

  Widget rewardsGrid(List<WebblenReward> rewards) {
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: RewardBlock(
            reward: rewards[index],
            action: () => PageTransitionService(context: context, reward: rewards[index], currentUser: widget.currentUser).transitionToShopItemPage(),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WebblenUserData().isAdmin(widget.currentUser.uid).then((res) {
      isAdmin = res;
      RewardDataService().findWebblenMerchRewards().then((res) {
        merchRewards = res;
        RewardDataService().findCashRewards().then((res) {
          cashRewards = res;
          isLoading = false;
          setState(() {});
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // ** APP BAR
    final appBar = AppBar(
      elevation: 0.5,
      brightness: Brightness.light,
      backgroundColor: Color(0xFFF9F9F9),
      title: GestureDetector(
        onDoubleTap: isAdmin ? () => PageTransitionService(context: context).transitionToCreateShopItemPage() : null,
        child: Text(
          "Shop",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
      ),
      //Text('Shop', style: Fonts.dashboardTitleStyle),
      leading: BackButton(
        color: Colors.black,
      ),
      actions: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 4.0,
          ),
          child: StreamBuilder(
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
                    Image.asset(
                      'assets/images/webblen_coin.png',
                      height: 24.0,
                      width: 24.0,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 4.0),
                    Fonts().textW500(
                      availablePoints.toStringAsFixed(2),
                      16.0,
                      Colors.black,
                      TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: isLoading
          ? CustomLinearProgress(progressBarColor: CustomColors.webblenRed)
          : Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  SizedBox(
                    height: 200.0,
                    width: 350.0,
                    child: Carousel(
                      boxFit: BoxFit.contain,
                      images: [
                        NetworkImage(
                            'https://firebasestorage.googleapis.com/v0/b/webblen-events.appspot.com/o/app_images%2Fcash%20in%20.PNG?alt=media&token=9989465e-35db-4782-9e08-0fe75351569a'),
                      ],
                      dotSize: 4.0,
                      dotSpacing: 15.0,
                      showIndicator: false,
                      autoplayDuration: Duration(seconds: 5),
                      dotColor: CustomColors.webblenRed,
                      indicatorBgPadding: 5.0,
                      dotBgColor: Colors.white,
                      borderRadius: false,
                    ),
                  ),
                  //WEBBLEN MERCH
                  SizedBox(height: 16.0),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "Webblen Merch",
                      textAlign: TextAlign.left,
                      style: TextStyle(color: Colors.black, fontSize: 24.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.25,
                    child: rewardsGrid(merchRewards),
                  ),
                  //CASH
                  SizedBox(height: 16.0),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "Cash Rewards",
                      textAlign: TextAlign.left,
                      style: TextStyle(color: Colors.black, fontSize: 24.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.25,
                    child: rewardsGrid(cashRewards),
                  ),
                ],
              ),
            ),
    );
  }
}
