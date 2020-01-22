import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webblen/firebase_data/reward_data.dart';
import 'package:webblen/firebase_data/transaction_data.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:webblen/models/webblen_reward.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/widgets_common/common_appbar.dart';
import 'package:webblen/widgets/widgets_common/common_button.dart';
import 'package:webblen/widgets/widgets_reward/reward_card.dart';
import 'package:webblen/widgets/widgets_reward/reward_purchase.dart';

class EarningsPage extends StatefulWidget {
  final WebblenUser currentUser;

  EarningsPage({
    this.currentUser,
  });

  @override
  _EarningsPageState createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
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
    return Scaffold(
      appBar: WebblenAppBar().actionAppBar(
        'Earnings',
        Row(
          children: <Widget>[
            IconButton(
              icon: Icon(FontAwesomeIcons.piggyBank, color: FlatColors.darkGray, size: 24.0),
              onPressed: () => PageTransitionService(context: context, currentUser: currentUser).transitionToPayoutMethodsPage(),
            ),
            IconButton(
              icon: Icon(FontAwesomeIcons.questionCircle, color: FlatColors.darkGray, size: 24.0),
              onPressed: () => PageTransitionService(context: context).transitionToEarningsInfoPage(),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: StreamBuilder(
            stream: Firestore.instance.collection("webblen_user").document(widget.currentUser.uid).snapshots(),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 32.0),
                  Fonts().textW700(
                    '\$' + '${webblenBalance.toStringAsFixed(2)}',
                    34,
                    Colors.black,
                    TextAlign.center,
                  ),
                  Fonts().textW600(
                    'Account Balance',
                    18,
                    Colors.black,
                    TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CustomColorButton(
                        text: 'Instant Deposit',
                        textSize: 18.0,
                        height: 35.0,
                        width: 175.0,
                        backgroundColor: FlatColors.darkMountainGreen,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                  SizedBox(height: 32.0),
                  Divider(
                    indent: 18.0,
                    endIndent: 18.0,
                    thickness: 1.0,
                  ),
                  Fonts().textW300(
                    "You Don't Have Any Recent Transactions",
                    18,
                    Colors.black45,
                    TextAlign.center,
                  ),
                ],
              );
            }),
      ),
    );
  }
}
