import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/firebase_data/stripe_data.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/utils/open_url.dart';
import 'package:webblen/utils/time_calc.dart';
import 'package:webblen/widgets/widgets_common/common_appbar.dart';
import 'package:webblen/widgets/widgets_common/common_button.dart';

class EarningsPage extends StatefulWidget {
  final WebblenUser currentUser;

  EarningsPage({
    this.currentUser,
  });

  @override
  _EarningsPageState createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  bool isLoading = false;
  String stripeConnectURL;
  WebblenUser currentUser;
  bool stripeAccountIsSetup = false;
  String stripeUID;

  checkAccountVerificationRequirements() {
    ShowAlertDialogService().showLoadingDialog(context);
    StripeDataService().checkAccountVerificationStatus(currentUser.uid).then((res) {
      Navigator.of(context).pop();
      List eventuallyDue = res['eventually_due'];
      List pending = res['pending_verification'];
      if (pending.isNotEmpty) {
        ShowAlertDialogService().showCustomActionDialog(
            context, "Account Is Under Review", "Verifcation Can Take Up to 24 Hours. Please Check Again Later", "Ok", () => Navigator.of(context).pop());
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
          Navigator.of(context).pop();
          OpenUrl().launchInWebViewOrVC(context, stripeConnectURL);
        } else if (socialSecurityNeeded) {
          ShowAlertDialogService().showCustomActionDialog(
              context, "Social Security Number Required", "Please Provide A Valid SSN to Continue the Account Verification Process", "Continue", () {
            Navigator.of(context).pop();
            OpenUrl().launchInWebViewOrVC(context, stripeConnectURL);
          });
        } else if (photoNeeded) {
          ShowAlertDialogService().showCustomActionDialog(
              context, "Photo ID Required", "Please Provide A Valid Photo ID to Continue the Account Verification Process", "Continue", () {
            Navigator.of(context).pop();
            OpenUrl().launchInWebViewOrVC(context, stripeConnectURL);
          });
        }
      } else {
        StripeDataService().updateAccountVerificationStatus(currentUser.uid).then((status) {
          print(status);
          if (status == 'verified') {
            ShowAlertDialogService().showCustomActionDialog(
                context, "Your Account Has Been Approved!", "Please Provide Your Banking Information to Begin Receiving Payouts", "Add Banking Info", () {
              Navigator.of(context).pop();
              PageTransitionService(context: context, currentUser: currentUser).transitionToPayoutMethodsPage();
            });
          } else {
            ShowAlertDialogService().showInfoDialog(context, "Account Is Under Review", "Verifcation Can Take Up to 24hrs. Please Check Again Later");
          }
        });
      }
    });
  }

  void performInstantPayout() {
    ShowAlertDialogService().showLoadingDialog(context);
    StripeDataService().performInstantStripePayout(currentUser.uid, stripeUID).then((res) {
      Navigator.of(context).pop();
      if (res == "passed") {
        ShowAlertDialogService().showInfoDialog(context, "Payout Success!", "Funds will Be Available on Your Account within 30min to 1hr");
      } else {
        ShowAlertDialogService().showInfoDialog(context, "Instant Payout Failed", "There was a problem issuing your payout. Please Try Again Later.");
      }
    });
  }

  void minRequiredAlert() {
    ShowAlertDialogService()
        .showInfoDialog(context, "Instant Deposit Unavailable", "Your Account Balance Must Be at least \$10.00 to Perform Instant Deposits");
  }

  @override
  void initState() {
    super.initState();
    currentUser = widget.currentUser;
    stripeConnectURL = "https://us-central1-webblen-events.cloudfunctions.net/connectStripeCustomAccount?uid=${currentUser.uid}";
    StripeDataService().getStripeUID(currentUser.uid).then((res) {
      if (res != null) {
        stripeUID = res;
        stripeAccountIsSetup = true;
        StripeDataService().updateAccountVerificationStatus(currentUser.uid).then((res) {
          StripeDataService().getStripeAccountBalance(currentUser.uid, stripeUID).then((res) {});
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance.collection("stripe").document(widget.currentUser.uid).snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData)
            return Scaffold(
              appBar: WebblenAppBar().actionAppBar(
                'Earnings',
                IconButton(
                  icon: Icon(FontAwesomeIcons.questionCircle, color: Colors.black, size: 24.0),
                  onPressed: () => PageTransitionService(context: context).transitionToEarningsInfoPage(),
                ),
              ),
              body: Container(
                color: Colors.white,
              ),
            );
          var userData = userSnapshot.data;
          double availableBalance = 0.001;
          double pendingBalance = 0.001;
          String verificationStatus = "pending";
          if (userData.data != null) {
            availableBalance = userData.data['availableBalance'] * 1.0001;
            pendingBalance = userData.data['pendingBalance'] * 1.0001;
            verificationStatus = userData.data['verified'];
          }
          return Scaffold(
            appBar: WebblenAppBar().actionAppBar(
              'Earnings',
              Row(
                children: <Widget>[
                  userData.data != null
                      ? IconButton(
                          icon: Icon(FontAwesomeIcons.university, color: Colors.black, size: 24.0),
                          onPressed: () => PageTransitionService(context: context, currentUser: currentUser).transitionToPayoutMethodsPage(),
                        )
                      : Container(),
                  IconButton(
                    icon: Icon(FontAwesomeIcons.questionCircle, color: Colors.black, size: 24.0),
                    onPressed: () => PageTransitionService(context: context).transitionToEarningsInfoPage(),
                  ),
                ],
              ),
            ),
            body: Container(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              color: Colors.white,
              child: userData.data == null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(height: 150.0),
                        Fonts().textW400("You're Account Needs to Be Set Up to Receive Payments", 16.0, Colors.black, TextAlign.center),
                        CustomColorButton(
                          text: "Setup Earnings Account",
                          textSize: 16.0,
                          textColor: Colors.black,
                          backgroundColor: Colors.white,
                          height: 45.0,
                          onPressed: () => OpenUrl().launchInWebViewOrVC(context, stripeConnectURL),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(height: 32.0),
                        Fonts().textW700(
                          '\$' + availableBalance.toStringAsFixed(2),
                          34.0,
                          Colors.black,
                          TextAlign.right,
                        ),
                        Fonts().textW600(
                          'Balance',
                          18,
                          Colors.black,
                          TextAlign.right,
                        ),
                        SizedBox(height: 16.0),
                        Fonts().textW400(
                          '\$' + pendingBalance.toStringAsFixed(2),
                          14,
                          Colors.black38,
                          TextAlign.right,
                        ),
                        Fonts().textW400(
                          'Amount Pending',
                          14,
                          Colors.black38,
                          TextAlign.right,
                        ),
                        SizedBox(height: 16.0),
                        Divider(
                          thickness: 1.0,
                        ),
                        verificationStatus == "pending"
                            ? Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Fonts().textW400(
                                  'Payouts Are Disabled Until Your Account Has Been Verified',
                                  12.0,
                                  Colors.black,
                                  TextAlign.center,
                                ),
                              )
                            : userData['bankInfo'] == null && userData['cardInfo'] == null
                                ? Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8.0),
                                    child: Fonts().textW400(
                                      'To Begin Earning on Webblen, Please Add Your Banking Information',
                                      12.0,
                                      Colors.black,
                                      TextAlign.center,
                                    ),
                                  )
                                : StreamBuilder<QuerySnapshot>(
                                    stream: Firestore.instance
                                        .collection("stripe_connect_activity")
                                        .where("uid", isEqualTo: currentUser.uid)
                                        //.orderBy("timePosted", descending: true)
                                        .snapshots(),
                                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (!snapshot.hasData) return Container();

                                      final int activityCount = snapshot.data.documents.length;
                                      print(activityCount);
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: activityCount,
                                        itemBuilder: (_, int index) {
                                          final DocumentSnapshot document = snapshot.data.documents[index];
                                          final dynamic message = document['description'];
                                          final dynamic timePosted = document['timePosted'];
                                          return Container(
                                            margin: EdgeInsets.symmetric(vertical: 4.0),
                                            child: ListTile(
                                              title: Fonts().textW500(
                                                message,
                                                14,
                                                Colors.black,
                                                TextAlign.left,
                                              ),
                                              subtitle: Fonts().textW400(
                                                TimeCalc().getPastTimeFromMilliseconds(timePosted),
                                                12,
                                                Colors.black,
                                                TextAlign.left,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                      ],
                    ),
            ),
            bottomNavigationBar: Container(
              height: 80.0,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: FlatColors.textFieldGray,
                    width: 1.5,
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    userData.data == null
                        ? Container()
                        : verificationStatus == "pending"
                            ? CustomColorButton(
                                text: 'Check Account Status',
                                textSize: 18.0,
                                height: 45.0,
                                backgroundColor: Colors.blue,
                                textColor: Colors.white,
                                onPressed: () => checkAccountVerificationRequirements(),
                              )
                            : userData['bankInfo'] == null && userData['cardInfo'] == null
                                ? CustomColorButton(
                                    text: 'Add Banking Info',
                                    textSize: 18.0,
                                    height: 45.0,
                                    backgroundColor: Colors.white,
                                    textColor: Colors.black,
                                    onPressed: () => PageTransitionService(context: context, currentUser: currentUser).transitionToPayoutMethodsPage(),
                                  )
                                : CustomColorButton(
                                    text: "Instant Deposit",
                                    textSize: 14.0,
                                    textColor: userData['cardInfo'] == null ? Colors.black26 : Colors.white,
                                    backgroundColor: userData['cardInfo'] == null ? FlatColors.textFieldGray : FlatColors.darkMountainGreen,
                                    height: 45.0,
                                    width: MediaQuery.of(context).size.width * 0.9,
                                    onPressed:
                                        userData['cardInfo'] == null ? null : availableBalance < 9.99 ? () => minRequiredAlert() : () => performInstantPayout(),
                                  ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
