import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/locator.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/views/home/tabs/wallet/wallet_view_model.dart';
import 'package:webblen/ui/widgets/wallet/usd_balance_block.dart';
import 'package:webblen/ui/widgets/wallet/webblen_balance_block.dart';
import 'package:webblen/utils/url_handler.dart';

class WalletView extends StatelessWidget {
  final WebblenUser user;
  final VoidCallback addContentAction;
  WalletView({this.user, this.addContentAction});

  Widget head(WalletViewModel model) {
    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Wallet",
            style: TextStyle(
              color: appFontColor(),
              fontWeight: FontWeight.bold,
              fontSize: 30.0,
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: addContentAction,
                  icon: Icon(
                    FontAwesomeIcons.plus,
                    color: appIconColor(),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget optionRow(BuildContext context, Icon icon, String optionName,
      Color optionColor, VoidCallback onTap) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0),
        height: 48.0,
        color: Colors.transparent,
        width: screenWidth(context),
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
            Text(
              optionName,
              style: TextStyle(
                fontSize: 16,
                color: appFontColor(),
              ),
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<WalletViewModel>.reactive(
      disposeViewModel: false,
      initialiseSpecialViewModelsOnce: true,
      onModelReady: (model) => model.initialize(user),
      viewModelBuilder: () => WalletViewModel(),
      builder: (context, model, child) => Container(
        height: MediaQuery.of(context).size.height,
        color: appBackgroundColor(),
        child: SafeArea(
          child: Container(
            child: Column(
              children: [
                head(model),
                model.stripeAccountIsSetup
                    ? Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 8.0),
                            USDBalanceBlock(
                              onPressed: () {},
                              balance:
                                  model.userStripeInfo.availableBalance ?? 0.00,
                              pendingBalance:
                                  model.userStripeInfo.pendingBalance ?? 0.00,
                              // onPressed: () => showStripeAcctBottomSheet(
                              //     verificationStatus, balance),
                            ),
                            //stripeAccountMenu(verificationStatus, balance),
                          ],
                        ),
                      )
                    // ),
                    : Container(),
                SizedBox(height: 16.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: WebblenBalanceBlock(
                    balance: user.WBLN,
                    onPressed: () {},
                    // balance: webblenBalance,
                    // onPressed: () => showWebblenBottomSheet(webblenBalance),
                  ),
                ),
                SizedBox(height: 32.0),
                optionRow(
                  context,
                  Icon(
                    FontAwesomeIcons.shoppingCart,
                    color: appIconColor(),
                    size: 18.0,
                  ),
                  'Shop',
                  appFontColor(),
                  () => model.navigateToShopView(user),
                ),
                SizedBox(height: 8.0),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  color: appDividerColor(),
                  height: 0.5,
                ),
                SizedBox(height: 8.0),
                optionRow(
                  context,
                  Icon(
                    FontAwesomeIcons.trophy,
                    color: appIconColor(),
                    size: 18.0,
                  ),
                  'Reward History',
                  appFontColor(),
                  () => model.navigateToRedeemedRewardsView(user),
                ),
                SizedBox(height: 8.0),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  color: appDividerColor(),
                  height: 0.5,
                ),
                SizedBox(height: 8.0),
                optionRow(
                  context,
                  Icon(
                    FontAwesomeIcons.ticketAlt,
                    color: appIconColor(),
                    size: 18.0,
                  ),
                  'My Tickets',
                  appFontColor(),
                  () => model.navigateToUserTicketsView(user),
                ),
                SizedBox(height: 8.0),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  color: appDividerColor(),
                  height: 0.5,
                ),
                SizedBox(height: 8.0),
                //   StreamBuilder(
                //     stream: FirebaseFirestore.instance.collection("stripe").doc(widget.currentUser.uid).snapshots(),
                //     builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                //       if (!snapshot.hasData) return Container();
                //       var stripeAccountExists = snapshot.data.exists;
                //       return !stripeAccountExists
                //           ? Container(
                //               child: Column(
                //                 children: [
                //                   SizedBox(height: 16.0),
                //                   Container(
                //                     color: Colors.black12,
                //                     height: 0.5,
                //                   ),
                //                   SizedBox(height: 8.0),
                //                   optionRow(
                //                     Icon(FontAwesomeIcons.briefcase, color: CustomColors.blackPearl, size: 18.0),
                //                     'Create Earnings Account',
                //                     CustomColors.blackPearl,
                //                     () => OpenUrl().launchInWebViewOrVC(context, stripeConnectURL),
                //                   ),
                //                 ],
                //               ),
                //             )
                //           : Container();
                //     },
                //   ),
                optionRow(
                  context,
                  Icon(
                    FontAwesomeIcons.lightbulb,
                    color: appIconColor(),
                    size: 18.0,
                  ),
                  'Give Feedback',
                  appFontColor(),
                  // () => PageTransitionService(
                  //   context: context,
                  //   currentUser: currentUser,
                  // ).transitionToFeedbackPage(),
                  () {},
                ),
                SizedBox(height: 8.0),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  color: appDividerColor(),
                  height: 0.5,
                ),
                SizedBox(height: 8.0),
                optionRow(
                  context,
                  Icon(FontAwesomeIcons.questionCircle,
                      color: appIconColor(), size: 18.0),
                  'Help/FAQ',
                  appFontColor(),
                  () => UrlHandler().launchInWebViewOrVC(
                    context,
                    'https://www.webblen.io/faq',
                  ),
                ),
                SizedBox(height: 8.0),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  color: appDividerColor(),
                  height: 0.5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
