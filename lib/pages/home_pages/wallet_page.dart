import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/stripe/stripe_payment.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/utils/open_url.dart';
import 'package:webblen/widgets/common/buttons/custom_color_button.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';
import 'package:webblen/widgets/wallet/usd_balance_block.dart';
import 'package:webblen/widgets/wallet/webblen_balance_block.dart';

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
  CollectionReference userRef = FirebaseFirestore.instance.collection("users");
  WebblenUser currentUser;
  GlobalKey<FormState> paymentFormKey = new GlobalKey<FormState>();
  bool isLoading = true;
  String currentUID;
  bool dismissedNotice = false;
  String stripeConnectURL;
  bool stripeAccountIsSetup = false;
  String stripeUID;

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

  Widget optionRow(Icon icon, String optionName, Color optionColor, VoidCallback onTap) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0),
        height: 48.0,
        color: Colors.transparent,
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                left: 8.0,
                right: 16.0,
                top: 4.0,
                bottom: 4.0,
              ),
              child: icon,
            ),
            MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: 1.0,
              ),
              child: Fonts().textW400(
                optionName,
                16.0,
                optionColor,
                TextAlign.left,
              ),
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }

  checkAccountVerificationRequirements() {
    ShowAlertDialogService().showLoadingDialog(context);
    StripePaymentService().checkAccountVerificationStatus(currentUID).then((res) {
      Navigator.of(context).pop();
      List eventuallyDue = res['eventually_due'];
      List pending = res['pending_verification'];
      if (pending.isNotEmpty) {
        ShowAlertDialogService().showInfoDialog(context, "Account Is Under Review", "Verification Can Take Up to 24 Hours. Please Check Again Later");
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
          if (val.toString().contains("verification.doc")) {
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
          if (status == 'verified') {
            ShowAlertDialogService().showActionSuccessDialog(
                context, "Your Account Has Been Approved!", "Please Provide Your Banking Information to Begin Receiving Payouts", () {});
          } else {
            ShowAlertDialogService().showInfoDialog(context, "Account Is Under Review", "Verification Can Take Up to 24 Hours. Please Check Again Later");
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
          .showFailureDialog(context, "Instant Payout Unavailable", "You Need At Least \$10.00 USD in Your Account to Perform an Instant Payout.");
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

  showStripeAcctBottomSheet(String verificationStatus, double balance) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: 300,
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Row(
                          children: [
                            Text(
                              'USD Balance: \$${balance.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.0),
                  stripeAccountMenu(verificationStatus, balance),
                ],
              ),
            );
          },
        );
      },
    );
  }

  showWebblenBottomSheet(double webblenBalance) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: 150,
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/webblen_coin.png',
                              height: 20,
                              width: 20,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "${webblenBalance.toStringAsFixed(2)}",
                              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => PageTransitionService(context: context).transitionToHowWebblenWorksPage(),
                        icon: Icon(FontAwesomeIcons.questionCircle, color: Colors.black),
                      ),
                    ],
                  ),
                  // SizedBox(height: 8.0),
                  // CustomColorButton(
                  //   text: "Transaction History",
                  //   textColor: Colors.black,
                  //   backgroundColor: Colors.white,
                  //   width: 300.0,
                  //   height: 45.0,
                  //   onPressed: null,
                  // ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentUser = widget.currentUser;
    currentUID = widget.currentUser.uid;
    stripeConnectURL = "https://us-central1-webblen-events.cloudfunctions.net/connectStripeCustomAccount?uid=$currentUID";
    StripePaymentService().getStripeUID(currentUID).then((res) {
      if (res != null) {
        stripeUID = res;
        stripeAccountIsSetup = true;
        setState(() {});
        StripePaymentService().updateAccountVerificationStatus(currentUID).then((res) {
          StripePaymentService().getStripeAccountBalance(currentUID, stripeUID).then((res) {
            if (this.mounted) {
              isLoading = false;
              setState(() {});
            }
          });
        });
      } else {
        isLoading = false;
        setState(() {});
      }
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
            stream: FirebaseFirestore.instance.collection("webblen_user").doc(widget.currentUser.uid).snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
              if (!userSnapshot.hasData) return Container();
              var userData = userSnapshot.data.data();
              double webblenBalance = userData['d']['eventPoints'] * 1.00;
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
                              double balance = 0.001;
                              double pendingBalance = 0.001;
                              String verificationStatus = "pending";
                              if (userData.data != null) {
                                balance = userData.data['availableBalance'] * 1.000001;
                                pendingBalance = userData.data['pendingBalance'] * 1.000001;
                                verificationStatus = userData.data['verified'];
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(height: 8.0),
                                  USDBalanceBlock(
                                    balance: balance,
                                    pendingBalance: pendingBalance,
                                    onPressed: () => showStripeAcctBottomSheet(verificationStatus, balance),
                                  ),
                                  //stripeAccountMenu(verificationStatus, balance),
                                ],
                              );
                            },
                          ),
                        )
                      : Container(),
                  SizedBox(height: 16.0),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: WebblenBalanceBlock(
                      balance: webblenBalance,
                      onPressed: () => showWebblenBottomSheet(webblenBalance),
                    ),
                  ),
                  SizedBox(height: 32.0),
                  optionRow(
                    Icon(FontAwesomeIcons.shoppingCart, color: CustomColors.blackPearl, size: 18.0),
                    'Shop',
                    CustomColors.blackPearl,
                    () => PageTransitionService(
                      context: context,
                      currentUser: currentUser,
                    ).transitionToShopPage(),
                  ),
                  SizedBox(height: 8.0),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.black12,
                    height: 0.5,
                  ),
                  SizedBox(height: 8.0),
                  optionRow(
                    Icon(FontAwesomeIcons.trophy, color: CustomColors.blackPearl, size: 18.0),
                    'Reward History',
                    CustomColors.blackPearl,
                    () => PageTransitionService(context: context, currentUser: currentUser).transitionToRedeemedRewardsPage(),
                  ),
                  SizedBox(height: 8.0),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.black12,
                    height: 0.5,
                  ),
                  SizedBox(height: 8.0),
                  optionRow(
                    Icon(FontAwesomeIcons.ticketAlt, color: CustomColors.blackPearl, size: 18.0),
                    'My Tickets',
                    CustomColors.blackPearl,
                    () => PageTransitionService(context: context).transitionToUserTicketsPage(),
                  ),
                  SizedBox(height: 8.0),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.black12,
                    height: 0.5,
                  ),
                  SizedBox(height: 8.0),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance.collection("stripe").doc(widget.currentUser.uid).snapshots(),
                    builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (!snapshot.hasData) return Container();
                      var stripeAccountExists = snapshot.data.exists;
                      return !stripeAccountExists
                          ? Container(
                              child: Column(
                                children: [
                                  SizedBox(height: 16.0),
                                  Container(
                                    color: Colors.black12,
                                    height: 0.5,
                                  ),
                                  SizedBox(height: 8.0),
                                  optionRow(
                                    Icon(FontAwesomeIcons.briefcase, color: CustomColors.blackPearl, size: 18.0),
                                    'Create Earnings Account',
                                    CustomColors.blackPearl,
                                    () => OpenUrl().launchInWebViewOrVC(context, stripeConnectURL),
                                  ),
                                ],
                              ),
                            )
                          : Container();
                    },
                  ),
                  SizedBox(height: 8.0),
                  optionRow(
                    Icon(FontAwesomeIcons.lightbulb, color: CustomColors.blackPearl, size: 18.0),
                    'Give Feedback',
                    CustomColors.blackPearl,
                    () => PageTransitionService(context: context, currentUser: currentUser).transitionToFeedbackPage(),
                  ),
                  SizedBox(height: 8.0),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.black12,
                    height: 0.5,
                  ),
                  SizedBox(height: 8.0),
                  optionRow(
                    Icon(FontAwesomeIcons.questionCircle, color: CustomColors.blackPearl, size: 18.0),
                    'Help/FAQ',
                    CustomColors.blackPearl,
                    () => OpenUrl().launchInWebViewOrVC(context, 'https://www.webblen.io/faq'),
                  ),
                  SizedBox(height: 8.0),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.black12,
                    height: 0.5,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
