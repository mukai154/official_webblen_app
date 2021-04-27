import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/views/home/tabs/wallet/wallet_view_model.dart';
import 'package:webblen/ui/widgets/wallet/usd_balance_block.dart';
import 'package:webblen/ui/widgets/wallet/webblen_balance_block.dart';

class WalletView extends StatelessWidget {
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
                  onPressed: () => model.showAddContentOptions(),
                  icon: Icon(FontAwesomeIcons.plus, color: appIconColor(), size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget optionRow(BuildContext context, Icon icon, String optionName, Color optionColor, VoidCallback onTap) {
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
      onModelReady: (model) => model.initialize(),
      viewModelBuilder: () => WalletViewModel(),
      builder: (context, model, child) => Container(
        height: MediaQuery.of(context).size.height,
        color: appBackgroundColor(),
        child: SafeArea(
          child: Container(
            child: Column(
              children: [
                head(model),
                model.isBusy
                    ? Container()
                    : model.stripeAccountIsSetup
                        ? Container(
                            margin: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: 8.0),
                                USDBalanceBlock(
                                  onPressed: () {},
                                  balance: model.userStripeInfo!.availableBalance ?? 0.00,
                                  pendingBalance: model.userStripeInfo!.pendingBalance ?? 0.00,
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
                    balance: model.webblenBaseViewModel!.user!.WBLN,
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
                  // () => PageTransitionService(
                  //   context: context,
                  //   currentUser: currentUser,
                  // ).transitionToShopPage(),
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
                  Icon(
                    FontAwesomeIcons.trophy,
                    color: appIconColor(),
                    size: 18.0,
                  ),
                  'Reward History',
                  appFontColor(),
                  // () => PageTransitionService(
                  //   context: context,
                  //   currentUser: currentUser,
                  // ).transitionToRedeemedRewardsPage(),
                  () => model.navigateToRedeemedRewardsView(),
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
                  // () => PageTransitionService(context: context)
                  //     .transitionToUserTicketsPage(),
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
                  Icon(FontAwesomeIcons.questionCircle, color: appIconColor(), size: 18.0),
                  'Help/FAQ',
                  appFontColor(),
                  // () => OpenUrl().launchInWebViewOrVC(
                  //   context,
                  //   'https://www.webblen.io/faq',
                  // ),
                  () {},
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
