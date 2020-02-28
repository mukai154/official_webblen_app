import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:webblen/firebase_data/user_data.dart';
import 'package:webblen/firebase_data/reward_data.dart';
import 'package:webblen/firebase_data/transaction_data.dart';
import 'package:webblen/models/webblen_reward.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';
import 'package:webblen/widgets/widgets_reward/reward_card.dart';
import 'package:webblen/widgets/widgets_reward/reward_purchase.dart';
import 'package:webblen/widgets/widgets_wallet/wallet_attendance_power_bar.dart';

class WalletPage extends StatefulWidget {
  final WebblenUser currentUser;
  final Key key;

  WalletPage({
    this.currentUser,
    this.key,
  });

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  WebblenUser currentUser;
  List<WebblenReward> walletRewards = [];
  GlobalKey<FormState> paymentFormKey = new GlobalKey<FormState>();
  String formDepositName;
  WebblenReward redeemingReward;
  bool isLoadingRewards = true;

  Future<bool> showRewardDialog(BuildContext context, WebblenReward reward) {
    return showDialog<bool>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return RewardWalletDialog(
            rewardTitle: reward.rewardProviderName,
            rewardDescription: reward.rewardDescription,
            rewardImageURL: reward.rewardImagePath,
            rewardCost: reward.rewardCost.toStringAsFixed(2),
            redeemAction: () => redeemRewardDialog(reward),
            dismissAction: () => dismissPurchaseDialog(context),
          );
        });
  }

  void dismissPurchaseDialog(BuildContext context) {
    Navigator.pop(context);
  }

  Future<bool> redeemRewardDialog(WebblenReward reward) {
    return showDialog<bool>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return RewardRedemptionDialog(
            rewardTitle: reward.rewardProviderName,
            rewardDescription: reward.rewardDescription,
            rewardImageURL: reward.rewardImagePath,
            rewardCost: reward.rewardCost.toStringAsFixed(2),
            confirmAction: () => redeemReward(reward),
            cancelAction: () => dismissPurchaseDialog(context),
          );
        });
  }

  redeemSuccessDialog(String header, String body) {
    Navigator.pop(context);
    ShowAlertDialogService().showSuccessDialog(
      context,
      header,
      body,
    );
  }

  redeemFailedDialog(String header, String body) {
    Navigator.pop(context);
    ShowAlertDialogService().showFailureDialog(
      context,
      header,
      body,
    );
  }

  void redeemReward(WebblenReward reward) async {
    Navigator.of(context).pop();
    setState(() {
      redeemingReward = reward;
    });
    if (reward.rewardUrl.isEmpty) {
      walletRewards.remove(reward);
      setState(() {});
      PageTransitionService(
        context: context,
        reward: redeemingReward,
        currentUser: widget.currentUser,
      ).transitionToRewardPayoutPage();
    } else if (await canLaunch(reward.rewardUrl)) {
      await launch(reward.rewardUrl);
    } else {
      redeemFailedDialog(
        "Could Not Open Url",
        "Please Check Your Internet Connection",
      );
    }
  }

  validatePaymentForm() {
    final form = paymentFormKey.currentState;
    form.save();
    ShowAlertDialogService().showLoadingDialog(context);
    if (formDepositName.isNotEmpty) {
      TransactionDataService()
          .submitTransaction(
        widget.currentUser.uid,
        null,
        redeemingReward.rewardType,
        formDepositName,
        redeemingReward.rewardDescription,
      )
          .then((error) {
        if (error.isEmpty) {
          redeemSuccessDialog(
            "Payment Now Processing",
            "Please Allow 2-3 Days for Your Payment to be Deposited into Your Account",
          );
        } else {
          redeemFailedDialog(
            "Payment Failed",
            "There was an issue processing your payment, please try again",
          );
        }
      });
    } else {
      redeemFailedDialog(
        "Payment Failed",
        "There was an issue processing your payment, please try again",
      );
    }
  }

  Widget buildWalletRewards() {
    if (walletRewards.isNotEmpty) {
      return rewardsList(walletRewards);
    } else {
      return noRewardsList();
    }
  }

  Widget rewardsList(List<WebblenReward> walletRewards) {
    return Container(
      height: 115,
      child: GridView.count(
        crossAxisCount: 1,
        scrollDirection: Axis.horizontal,
        children: new List<Widget>.generate(walletRewards.length, (index) {
          return GridTile(
            child: RewardCard(
              walletRewards[index],
              () => redeemRewardDialog(walletRewards[index]),
              true,
            ),
          );
        }),
      ),
    );
  }

  Widget noRewardsList() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 16.0,
          ),
          Fonts().textW400(
            'You Currently Have No Rewards',
            18.0,
            Colors.black38,
            TextAlign.center,
          ),
          SizedBox(
            height: 16.0,
          ),
        ],
      ),
    );
  }

  Future<Null> loadRewards() async {
    isLoadingRewards = true;
    walletRewards = [];
    setState(() {});
    UserDataService().getUserByID(currentUser.uid).then((result) {
      currentUser = result;
      if (currentUser.rewards.length > 0) {
        currentUser.rewards.forEach((reward) {
          String rewardID = reward.toString();
          RewardDataService().findRewardByID(rewardID).then((userReward) {
            if (userReward != null) {
              walletRewards.add(userReward);
              if (reward == currentUser.rewards.last) {
                if (this.mounted) {
                  isLoadingRewards = false;
                  setState(() {});
                }
              }
            }
          });
        });
      } else {
        isLoadingRewards = false;
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    currentUser = widget.currentUser;
    loadRewards();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: StreamBuilder(
          stream: Firestore.instance
              .collection("webblen_user")
              .document(widget.currentUser.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData)
              return Text(
                "Loading...",
              );
            var userData = userSnapshot.data;
            double webblenBalance = userData['d']['eventPoints'] * 1.00;
            double ap = userData['d']['ap'] * 1.00;
            int apLvl = userData['d']['apLvl'];
            return Column(
              children: <Widget>[
                Container(
                  height: 70,
                  margin: EdgeInsets.only(
                    left: 16,
                    top: 35,
                    right: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          textScaleFactor: 1.0,
                        ),
                        child: Fonts().textW700(
                          'Wallet',
                          40,
                          Colors.black,
                          TextAlign.left,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => PageTransitionService(
                          context: context,
                          currentUser: currentUser,
                        ).transitionToShopPage(),
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: 16.0,
                            bottom: 8.0,
                          ),
                          child: Material(
                            borderRadius: BorderRadius.circular(24.0),
                            color: FlatColors.darkMountainGreen,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.shoppingCart,
                                    color: Colors.white,
                                    size: 14.0,
                                  ),
                                  SizedBox(
                                    width: 8.0,
                                  ),
                                  Fonts().textW600(
                                    'Shop',
                                    14.0,
                                    Colors.white,
                                    TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    left: 16,
                    top: 8,
                    right: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Fonts().textW700(
                        '${webblenBalance.toStringAsFixed(2)}',
                        34,
                        Colors.black,
                        TextAlign.left,
                      ),
                      Fonts().textW600(
                        'Webblen Balance',
                        18,
                        Colors.black,
                        TextAlign.left,
                      ),
                      SizedBox(
                        height: 4.0,
                      ),
                      Fonts().textW400(
                        "Webblen are tokens that can be transferred or traded at anytime.  You need Webblen in order to create new events and communities.",
                        14,
                        Colors.black87,
                        TextAlign.left,
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                      AttendancePowerBar(
                        currentAP: ap,
                        apLvl: apLvl,
                      ),
                      SizedBox(
                        height: 2.0,
                      ),
                      Fonts().textW600(
                        "Attendance Power",
                        18,
                        Colors.black87,
                        TextAlign.left,
                      ),
                      SizedBox(
                        height: 4.0,
                      ),
                      Fonts().textW400(
                        "A multiplier that increases the value of the events you attend. The higher your AP, the more your attendance is worth. Increase your AP by attending events regularly.",
                        14,
                        Colors.black87,
                        TextAlign.left,
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                      Row(
                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Fonts().textW700(
                            'Rewards',
                            28,
                            Colors.black,
                            TextAlign.center,
                          ),
                          isLoadingRewards
                              ? Container()
                              : Padding(
                                  padding: EdgeInsets.only(
                                    top: 4.0,
                                  ),
                                  child: IconButton(
                                    onPressed: () => loadRewards(),
                                    icon: Icon(
                                      FontAwesomeIcons.syncAlt,
                                      size: 16.0,
                                      color: Colors.black45,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                      //SizedBox(height: 8.0),
                      isLoadingRewards
                          ? Center(
                              child: CustomCircleProgress(
                                30.0,
                                30.0,
                                30.0,
                                30.0,
                                Colors.black26,
                              ),
                            )
                          : buildWalletRewards()
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }
}
