import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/firebase/data/event_data.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/firebase_data/reward_data.dart';
import 'package:webblen/firebase_data/transaction_data.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:webblen/models/event_ticket.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_reward.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/stripe/stripe_payment.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/utils/open_url.dart';
import 'package:webblen/widgets/common/buttons/custom_color_button.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';
import 'package:webblen/widgets/events/event_block.dart';
import 'package:webblen/widgets/widgets_reward/reward_card.dart';
import 'package:webblen/widgets/widgets_reward/reward_purchase.dart';

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
  CollectionReference userRef = Firestore().collection("users");
  WebblenUser currentUser;
  List<WebblenReward> walletRewards = [];
  GlobalKey<FormState> paymentFormKey = new GlobalKey<FormState>();
  String formDepositName;
  WebblenReward redeemingReward;
  bool isLoadingRewards = true;
  bool isLoading = true;
  String currentUID;
  bool dismissedNotice = false;
  String stripeConnectURL;
  bool stripeAccountIsSetup = false;
  String stripeUID;
  List<WebblenEvent> events = [];
  List<String> loadedEvents = [];
  Map<String, dynamic> ticsPerEvent = {};

  organizeNumOfTicketsByEvent(List<EventTicket> eventTickets) {
    eventTickets.forEach((ticket) async {
      if (!loadedEvents.contains(ticket.eventID)) {
        loadedEvents.add(ticket.eventID);
        WebblenEvent event = await EventDataService().getEvent(ticket.eventID);
        if (event != null) {
          events.add(event);
        }
      }
      if (ticsPerEvent[ticket.eventID] == null) {
        ticsPerEvent[ticket.eventID] = 1;
      } else {
        ticsPerEvent[ticket.eventID] += 1;
      }
    });
  }

  Widget ticketEventGrid() {
    return ResponsiveGridList(
      scroll: false,
      desiredItemWidth: 260,
      minSpacing: 10,
      children: events
          .map((e) => EventTicketBlock(
                eventDescHeight: 120,
                event: e,
                shareEvent: () => Share.share("https://app.webblen.io/#/event?id=${e.id}"),
                numOfTicsForEvent: ticsPerEvent[e.id],
                viewEventDetails: null,
                viewEventTickets: () => PageTransitionService(context: context, eventID: e.id, currentUser: currentUser)
                    .transitionToEventTicketsPage(), //() => e.navigateToWalletTickets(e.id),
              ))
          .toList(),
    );
  }

  Widget createEarningsAccountNotice() {
    return dismissedNotice
        ? Container()
        : Container(
            height: 35,
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: CustomColors.textFieldGray,
              border: Border(
                bottom: BorderSide(
                  color: Colors.black12,
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(),
                Row(
                  children: <Widget>[
                    CustomText(
                      context: context,
                      text: "Interested in Selling Tickets through Webblen for FREE? Create an Earnings Account to Get Started!",
                      textColor: Colors.black,
                      textAlign: TextAlign.left,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(width: 8.0),
                    GestureDetector(
                      onTap: () => OpenUrl().launchInWebViewOrVC(context, stripeConnectURL),
                      child: CustomText(
                        context: context,
                        text: "Create Earnings Account",
                        textColor: Colors.blueAccent,
                        textAlign: TextAlign.left,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        underline: true,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    dismissedNotice = true;
                    setState(() {});
                  },
                  child: Icon(
                    FontAwesomeIcons.times,
                    color: Colors.black45,
                    size: 14.0,
                  ),
                ),
              ],
            ),
          );
  }

  checkAccountVerificationRequirements() {
    ShowAlertDialogService().showLoadingDialog(context);
    StripePaymentService().checkAccountVerificationStatus(currentUID).then((res) {
      Navigator.of(context).pop();
      List eventuallyDue = res['eventually_due'];
      List pending = res['pending_verification'];
      if (pending.isNotEmpty) {
        ShowAlertDialogService().showInfoDialog(context, "Account Is Under Review", "Verifcation Can Take Up to 24 Hours. Please Check Again Later");
      } else if (eventuallyDue.length > 1) {
        bool needsToFillForm = false;
        bool photoNeeded = false;
        bool socialSecurityNeeded = false;
        if (eventuallyDue.length > 3) {
          needsToFillForm = true;
        }
        eventuallyDue.forEach((val) {
          if (val.toString().contains("individual.id_number")) {
            socialSecurityNeeded = true;
          }
          if (val.toString().contains("verification.document")) {
            photoNeeded = true;
          }
        });
        if (needsToFillForm == true) {
          OpenUrl().launchInWebViewOrVC(context, stripeConnectURL);
        } else if (socialSecurityNeeded) {
          ShowAlertDialogService().showCustomActionDialog(
              context, "Social Security Number Required", "Please Provide A Valid SSN to Continue the Account Verification Process", "Continue", () {
            OpenUrl().launchInWebViewOrVC(context, stripeConnectURL);
          });
        } else if (photoNeeded) {
          ShowAlertDialogService().showCustomActionDialog(
              context, "Photo ID Required", "Please Provide A Valid Photo ID to Continue the Account Verification Process", "Continue", () {
            OpenUrl().launchInWebViewOrVC(context, stripeConnectURL);
          });
        }
      } else {
        StripePaymentService().updateAccountVerificationStatus(currentUID).then((status) {
          print(status);
          if (status == 'verified') {
            ShowAlertDialogService().showActionSuccessDialog(
                context, "Your Account Has Been Approved!", "Please Provide Your Banking Information to Begin Receiving Payouts", () {});
          } else {
            ShowAlertDialogService().showInfoDialog(context, "Account Is Under Review", "Verifcation Can Take Up to 24 Hours. Please Check Again Later");
          }
        });
      }
    });
  }

  void performInstantPayout(double availableBalance) {
    ShowAlertDialogService().showLoadingDialog(context);
    if (availableBalance == null || availableBalance < 10) {
      Navigator.of(context).pop();
      ShowAlertDialogService()
          .showFailureDialog(context, "Instant Payout Unavailbe", "You Need At Least \$10.00 USD in Your Account to Perform an Instant Payout.");
    } else {
      StripePaymentService().performInstantStripePayout(currentUID, stripeUID).then((res) {
        Navigator.of(context).pop();
        if (res == "passed") {
          ShowAlertDialogService().showSuccessDialog(context, "Payout Success!", "Funds will Be Available on Your Account within 30 minutes to 1 hour");
        } else {
          ShowAlertDialogService().showFailureDialog(context, "Instant Payout Failed", "There was a problem issuing your payout. Please Try Again Later.");
        }
      });
    }
  }

  Widget stripeActionButton(String verificationStatus, double availableBalance) {
    return verificationStatus == "verified"
        ? CustomColorButton(
            onPressed: () => performInstantPayout(availableBalance),
            text: "Instant Payout",
            textColor: Colors.white,
            backgroundColor: CustomColors.darkMountainGreen,
            textSize: 14.0,
            height: 35,
            width: MediaQuery.of(context).size.width - 32,
          )
        : CustomColorButton(
            onPressed: () => checkAccountVerificationRequirements(), //() => validateAndSubmitForm(),
            text: "Check Account Status",
            textColor: Colors.black,
            backgroundColor: Colors.white,
            textSize: 14.0,
            height: 35,
            width: MediaQuery.of(context).size.width - 32,
          );
  }

  Widget stripeAccountMenu(String verificationStatus, double availableBalance) {
    return Container(
      child: Column(
        children: [
          stripeActionButton(verificationStatus, availableBalance),
          SizedBox(height: 8.0),
          CustomColorButton(
            onPressed: () => PageTransitionService(context: context)
                .transitionToPaymentHistoryPage(), //() => locator<NavigationService>().navigateTo(WalletPaymentsHistoryRoute),
            text: "Payment History",
            textColor: Colors.black,
            backgroundColor: Colors.white,
            textSize: 14.0,
            height: 35,
            width: MediaQuery.of(context).size.width - 32,
          ),
          SizedBox(height: 8.0),
          CustomColorButton(
            onPressed: () =>
                PageTransitionService(context: context, currentUser: widget.currentUser).transitionToPayoutMethodsPage(), //() => validateAndSubmitForm(),
            text: "Payout Methods",
            textColor: Colors.black,
            backgroundColor: Colors.white,
            textSize: 14.0,
            height: 35,
            width: MediaQuery.of(context).size.width - 32,
          ),
          SizedBox(height: 8.0),
          CustomColorButton(
            onPressed: () => PageTransitionService(context: context)
                .transitionToEarningsInfoPage(), //() => locator<NavigationService>().navigateTo(WalletEarningsGuideRoute), //() => validateAndSubmitForm(),
            text: "How Do Earnings Work?",
            textColor: Colors.black,
            backgroundColor: Colors.white,
            textSize: 14.0,
            height: 35,
            width: MediaQuery.of(context).size.width - 32,
          ),
        ],
      ),
    );
  }

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
    // TODO: implement initState
    super.initState();
    currentUser = widget.currentUser;
    currentUID = widget.currentUser.uid;
    loadRewards();
    stripeConnectURL = "https://us-central1-webblen-events.cloudfunctions.net/connectStripeCustomAccount?uid=${currentUID}";
    EventDataService().getPurchasedTickets(currentUID).then((res) {
      organizeNumOfTicketsByEvent(res);
      StripePaymentService().getStripeUID(currentUID).then((res) {
        if (res != null) {
          stripeUID = res;
          stripeAccountIsSetup = true;
          StripePaymentService().updateAccountVerificationStatus(currentUID).then((res) {
            StripePaymentService().getStripeAccountBalance(currentUID, stripeUID).then((res) {
              isLoading = false;
              setState(() {});
            });
          });
        } else {
          isLoading = false;
          setState(() {});
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
      color: Colors.white,
      child: ListView(
        shrinkWrap: true,
        children: [
          StreamBuilder(
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
                  children: <Widget>[
                    Container(
                      height: 70,
                      margin: EdgeInsets.only(
                        left: 16,
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
                    stripeAccountIsSetup
                        ? Container(
                            margin: EdgeInsets.symmetric(horizontal: 16.0),
                            child: StreamBuilder(
                              stream: WebblenUserData().streamStripeAccount(currentUID),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return Container();
                                var userData = snapshot;
                                double availableBalance = 0.001;
                                double pendingBalance = 0.001;
                                String verificationStatus = "pending";
                                if (userData.data != null) {
                                  availableBalance = userData.data['availableBalance'] * 1.000001;
                                  pendingBalance = userData.data['pendingBalance'] * 1.000001;
                                  verificationStatus = userData.data['verified'];
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    SizedBox(height: 8.0),
                                    CustomText(
                                      context: context,
                                      text: '\$' + availableBalance.toStringAsFixed(2),
                                      textColor: Colors.black,
                                      textAlign: TextAlign.left,
                                      fontSize: 40.0,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    Row(
                                      children: [
                                        CustomText(
                                          context: context,
                                          text: 'USD Balance',
                                          textColor: Colors.black,
                                          textAlign: TextAlign.left,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        SizedBox(width: 8.0),
                                        GestureDetector(
                                          onTap: () => ShowAlertDialogService().showInfoDialog(context, "USD Balance",
                                              "Your USD balance is the amount of money you've earned via ticket sales or stream donations."),
                                          child: Icon(
                                            FontAwesomeIcons.questionCircle,
                                            color: Colors.black38,
                                            size: 18.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 6.0),
                                    CustomText(
                                      context: context,
                                      text: '\$' + pendingBalance.toStringAsFixed(2),
                                      textColor: Colors.black38,
                                      textAlign: TextAlign.left,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    CustomText(
                                      context: context,
                                      text: 'Pending Balance',
                                      textColor: Colors.black38,
                                      textAlign: TextAlign.left,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    SizedBox(height: 12.0),
                                    stripeAccountMenu(verificationStatus, availableBalance),
                                  ],
                                );
                              },
                            ),
                          )
                        : Container(),
                    Container(
                      margin: EdgeInsets.only(
                        left: 16,
                        top: stripeAccountIsSetup ? 32 : 16,
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
                          Row(
                            children: [
                              CustomText(
                                context: context,
                                text: 'Webblen Balance',
                                textColor: Colors.black,
                                textAlign: TextAlign.left,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w700,
                              ),
                              SizedBox(width: 8.0),
                              GestureDetector(
                                onTap: () => ShowAlertDialogService().showInfoDialog(context, "What is Webblen?",
                                    "Webblen are tokens you earn for attending events, streaming, and building your community. Webblen can be used to buy rewards in our shop."),
                                child: Icon(
                                  FontAwesomeIcons.questionCircle,
                                  color: Colors.black38,
                                  size: 16.0,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 32.0,
                          ),
                          CustomText(
                            context: context,
                            text: 'My Tickets',
                            textColor: Colors.black,
                            textAlign: TextAlign.left,
                            fontSize: 28.0,
                            fontWeight: FontWeight.w700,
                          ),
                          isLoading
                              ? Container(
                                  child: CustomText(
                                    context: context,
                                    text: "Loading Tickets...",
                                    textColor: Colors.black,
                                    textAlign: TextAlign.left,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              : events.isEmpty
                                  ? Container(
                                      child: CustomText(
                                        context: context,
                                        text: "You Do Not Have Any Tickets",
                                        textColor: Colors.black,
                                        textAlign: TextAlign.left,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  : ticketEventGrid(),
                          SizedBox(height: 32.0),
                        ],
                      ),
                    ),
                  ],
                );
              }),
        ],
      ),
    );
  }
}
