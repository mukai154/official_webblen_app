import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/user_stripe_info.dart';
import 'package:webblen/ui/views/earnings/payout_methods/payout_methods_view_model.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/ui/widgets/wallet/payout_methods/payout_methods_block_view.dart';

class PayoutMethodsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PayoutMethodsViewModel>.reactive(
      onModelReady: (model) => model.initialize(),
      viewModelBuilder: () => PayoutMethodsViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: CustomAppBar().basicAppBar(
          title: "Payout Methods",
          showBackButton: true,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          color: appBackgroundColor(),
          child: SafeArea(
            child: Container(
              child: model.isBusy
                  ? Center(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Center(
                            child: CustomCircleProgressIndicator(
                              size: 10,
                              color: appActiveColor(),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      shrinkWrap: true,
                      children: [
                        _PayoutMethodBody(
                          userBankingInfo: model.userStripeInfo!.userBankingInfo == null ? UserBankingInfo() : model.userStripeInfo!.userBankingInfo!,
                          userCardInfo: model.userStripeInfo!.userCardInfo == null ? UserCardInfo() : model.userStripeInfo!.userCardInfo!,
                          updateUserBankingInfoAction: () => model.customNavigationService.navigateToSetUpDirectDepositView(),
                          updateUserCardInfoAction: () => model.customNavigationService.navigateToSetUpInstantDepositView(),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PayoutMethodBody extends StatelessWidget {
  final UserBankingInfo userBankingInfo;
  final UserCardInfo userCardInfo;
  final VoidCallback updateUserBankingInfoAction;
  final VoidCallback updateUserCardInfoAction;

  _PayoutMethodBody({
    required this.userBankingInfo,
    required this.userCardInfo,
    required this.updateUserBankingInfoAction,
    required this.updateUserCardInfoAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        !userBankingInfo.isValid()
            ? PayoutMethodBlockView(
                header: "Direct Deposit",
                subHeader: "Direct deposit is not set up. Please fill out your banking information in order to receive direct deposits",
                updateAction: updateUserBankingInfoAction,
                isSetUp: false,
              )
            : PayoutMethodBlockView(
                header: "Direct Deposit",
                subHeader: "Free weekly transfers are sent each Monday to account ending in ${userBankingInfo.last4}. "
                    "Payments may take 2-3"
                    " days to arrive "
                    "in your account.",
                updateAction: updateUserBankingInfoAction,
                isSetUp: true,
              ),
        !userCardInfo.isValid()
            ? PayoutMethodBlockView(
                header: "Instant Deposit",
                subHeader: "Instant deposit is not set up. Please fill out your card information in order to receive instant deposits.",
                updateAction: updateUserCardInfoAction,
                isSetUp: false,
              )
            : PayoutMethodBlockView(
                header: "Instant Deposit",
                subHeader: "Instant deposit is set up. Earnings are transferred to Debit Card ending in ${userCardInfo.last4} "
                    "upon request.",
                updateAction: updateUserCardInfoAction,
                isSetUp: true,
              ),
      ],
    );
  }
}
