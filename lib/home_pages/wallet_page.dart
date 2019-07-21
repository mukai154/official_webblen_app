import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'dart:async';
import 'package:webblen/firebase_data/reward_data.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:webblen/models/webblen_reward.dart';
import 'package:webblen/firebase_data/transaction_data.dart';
import 'package:webblen/widgets_reward/reward_card.dart';
import 'package:webblen/widgets_reward/reward_purchase.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WalletPage extends StatefulWidget {

  final WebblenUser currentUser;
  final Key key;
  WalletPage({this.currentUser, this.key});

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {

  List<WebblenReward> walletRewards = [];
  GlobalKey<FormState> paymentFormKey = new GlobalKey<FormState>();
  String formDepositName;
  WebblenReward redeemingReward;

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

  void dismissPurchaseDialog(BuildContext context){
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
            rewardCost: reward.rewardCost.toStringAsFixed(2) ,
            confirmAction: () => redeemReward(reward),
            cancelAction: () => dismissPurchaseDialog(context),
          );
        });
  }

  redeemSuccessDialog(String header, String body){
    Navigator.pop(context);
    ShowAlertDialogService().showSuccessDialog(context, header, body);
  }

  redeemFailedDialog(String header, String body){
    Navigator.pop(context);
    ShowAlertDialogService().showFailureDialog(context, header, body);
  }

  void redeemReward(WebblenReward reward) async {
    Navigator.of(context).pop();
    setState(() {
      redeemingReward = reward;
    });
    if (reward.rewardUrl.isEmpty){
      walletRewards.remove(reward);
      setState(() {});
      PageTransitionService(context: context, reward: redeemingReward, currentUser: widget.currentUser).transitionToRewardPayoutPage();
    } else if (await canLaunch(reward.rewardUrl)) {
      await launch(reward.rewardUrl);
    } else {
      redeemFailedDialog("Could Not Open Url", "Please Check Your Internet Connection");
    }
  }

  validatePaymentForm(){
    final form = paymentFormKey.currentState;
    form.save();
    ShowAlertDialogService().showLoadingDialog(context);
    if (formDepositName.isNotEmpty){
      TransactionDataService().submitTransaction(widget.currentUser.uid, null, redeemingReward.rewardType, formDepositName, redeemingReward.rewardDescription).then((error){
        if (error.isEmpty){
          redeemSuccessDialog("Payment Now Processing", "Please Allow 2-3 Days for Your Payment to be Deposited into Your Account");
        } else {
          redeemFailedDialog("Payment Failed", "There was an issue processing your payment, please try again");
        }
      });
    } else {
      redeemFailedDialog("Payment Failed", "There was an issue processing your payment, please try again");
    }
  }

  Widget buildWalletRewards(){
    if (walletRewards.isNotEmpty){
      return rewardsList(walletRewards);
    } else {
      return noRewardsList();
    }
  }

  Widget rewardsList(List<WebblenReward> walletRewards)  {
    return Container(
      height: 150,
      child: GridView.count(
        crossAxisCount: 1,
        scrollDirection: Axis.horizontal,
        children: new List<Widget>.generate(walletRewards.length, (index) {
          return GridTile(
            child: RewardCard(
                walletRewards[index],
                    () => redeemRewardDialog(walletRewards[index]),
                true
            ),
          );
        }),
      ),
    );
  }

  Widget noRewardsList()  {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          SizedBox(height: 16.0),
          Fonts().textW400('You Currently Have No Rewards', 18.0, Colors.black38, TextAlign.center),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.currentUser.rewards.forEach((reward){
      String rewardID = reward.toString();
      RewardDataService().findRewardByID(rewardID).then((userReward){
        if (userReward != null){
          walletRewards.add(userReward);
          if (reward == widget.currentUser.rewards.last){
            if (this.mounted){
              setState(() {});
            }
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: StreamBuilder(
          stream: Firestore.instance.collection("users").document(widget.currentUser.uid).snapshots(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) return Text("Loading...");
            var userData = userSnapshot.data;
            double webblenBalance = userData['eventPoints'];
            return Column(
              children: <Widget>[
                Container(
                  height: 70,
                  margin: EdgeInsets.only(left: 16, top: 30, right: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Fonts().textW700('Wallet', 40, Colors.black, TextAlign.left),
//                      IconButton(
//                        onPressed: () => ShowAlertDialogService().showInfoDialog(context, "Webblen is Currently Unavailable for Purchase", "Someday... But That Day is Not Today"),
//                        icon: Icon(FontAwesomeIcons.plus, size: 18.0, color: Colors.black),
//                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 16, top: 24, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                        Fonts().textW700(
                            '${webblenBalance.toStringAsFixed(2)}',
                            34,
                            Colors.black,
                            TextAlign.left
                        ),
                        Fonts().textW300(
                            'Webblen Balance',
                            12,
                            FlatColors.webblenRed,
                            TextAlign.left
                        ),
                        SizedBox(height: 8.0),
                        Fonts().textW500(
                            "Webblen are tokens that can be transferred or traded at anytime.  You need Webblen in order to create new events and communities.",
                            12,
                            Colors.black,
                            TextAlign.left
                        ),
                        SizedBox(height: 16.0),
                        Fonts().textW700(
                            'x1.00',
                            34,
                            Colors.black,
                            TextAlign.left
                        ),
                        Fonts().textW300(
                            "Attendance Power",
                            12,
                            FlatColors.webblenRed,
                            TextAlign.left
                        ),
                        SizedBox(height: 8.0),
                        Fonts().textW500(
                            "A multiplier that increases the value of the events you attend. The higher your AP, the more your attendance is worth. Increase your AP by attending events regularly.",
                            12,
                            Colors.black,
                            TextAlign.left
                        ),
                        SizedBox(height: 16.0),
                        Row(
                          children: <Widget>[
                            Fonts().textW700(
                                'Rewards',
                                28,
                                Colors.black,
                                TextAlign.left
                            ),
                            IconButton(
                              onPressed:  () => PageTransitionService(context: context, currentUser: widget.currentUser).transitionToShopPage(),
                              icon: Icon(FontAwesomeIcons.plusCircle, size: 18.0, color: FlatColors.darkMountainGreen),
                            )
                          ],
                        ),
                        SizedBox(height: 16.0),
                        buildWalletRewards()
                    ],
                  ),
                ),
              ],
            );
          }
      ),
    );
  }
}