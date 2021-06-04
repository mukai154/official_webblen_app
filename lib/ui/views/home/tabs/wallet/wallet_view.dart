import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/views/home/tabs/wallet/wallet_view_model.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/ui/widgets/wallet/stripe/create_earnings_account/create_earnings_account_block_view.dart';
import 'package:webblen/ui/widgets/wallet/stripe/stripe_account/stripe_account_block_view.dart';
import 'package:webblen/ui/widgets/wallet/webblen_balance_block.dart';

class WalletView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<WalletViewModel>.reactive(
      disposeViewModel: false,
      initialiseSpecialViewModelsOnce: true,
      onModelReady: (model) => model.initialize(),
      viewModelBuilder: () => WalletViewModel(),
      builder: (context, model, child) => Container(
        height: screenHeight(context),
        color: appBackgroundColor(),
        child: SafeArea(
          child: Container(
            child: model.appBaseViewModel.isBusy
                ? Center(
                    child: CustomCircleProgressIndicator(
                      color: appActiveColor(),
                      size: 32,
                    ),
                  )
                : Column(
                    children: [
                      _WalletHead(),
                      _WalletBody(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _WalletHead extends HookViewModelWidget<WalletViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, WalletViewModel model) {
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
                  onPressed: () => model.customBottomSheetService.showAddContentOptions(),
                  icon: Icon(FontAwesomeIcons.plus, color: appIconColor(), size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletBody extends HookViewModelWidget<WalletViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, WalletViewModel model) {
    return Expanded(
      child: Container(
        child: Column(
          children: [
            model.isBusy
                ? Container()
                : model.stripeAccountIsSetup
                    ? Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 8.0),
                            StripeAccountBlockView(),
                          ],
                        ),
                      )
                    // ),
                    : !model.dismissedSetupAccountNotice
                        ? CreateEarningsAccountBlockView(
                            dismissNotice: () => model.dismissCreateStripeAccountNotice(),
                          )
                        : Container(),
            SizedBox(height: 16.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: WebblenBalanceBlock(
                balance: model.user.WBLN,
                onPressed: () => model.customDialogService.showComingSoonDialog(),
              ),
            ),
            SizedBox(height: 32.0),
            _WalletMenuOption(
              icon: Icon(
                FontAwesomeIcons.ticketAlt,
                color: appIconColor(),
                size: 18.0,
              ),
              name: "My Tickets",
              color: appFontColor(),
              onPressed: () => model.customNavigationService.navigateToMyTicketsView(),
            ),
            SizedBox(height: 8.0),
            _WalletMenuOption(
              icon: Icon(
                FontAwesomeIcons.shoppingCart,
                color: appInActiveColorAlt(),
                size: 18.0,
              ),
              name: "Shop (coming soon)",
              color: appInActiveColorAlt(),
              onPressed: () => model.customDialogService.showComingSoonDialog(),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletMenuOption extends StatelessWidget {
  final Icon icon;
  final String name;
  final Color color;
  final VoidCallback onPressed;
  _WalletMenuOption({required this.icon, required this.name, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
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
              name,
              style: TextStyle(
                fontSize: 16,
                color: color,
              ),
            ),
          ],
        ),
      ),
      onTap: onPressed,
    );
  }
}
