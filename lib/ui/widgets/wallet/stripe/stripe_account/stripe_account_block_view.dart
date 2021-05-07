import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/ui/widgets/wallet/stripe/stripe_account/stripe_account_block_view_model.dart';

class StripeAccountBlockView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<StripeAccountBlockViewModel>.reactive(
      viewModelBuilder: () => StripeAccountBlockViewModel(),
      onModelReady: (model) => model.initialize(),
      builder: (context, model, child) => model.isBusy
          ? Align(
              child: CustomCircleProgressIndicator(
                size: 10,
                color: appActiveColor(),
              ),
            )
          : model.userStripeInfo!.verified != "verified"
              ? _StripeAccountPendingBlock(
                  actionRequired: model.userStripeInfo!.actionRequired == null ? false : model.userStripeInfo!.actionRequired!,
                  onPressed: model.userStripeInfo!.actionRequired! ? () => model.completeCreatingStripeEarningsAccount() : () => model.showPendingAlert(),
                  loadingAccountStatus: model.retrievingAccountStatus,
                )
              : _StripeAccountBlock(
                  usdBalance: model.userStripeInfo!.availableBalance!,
                  pendingBalance: model.userStripeInfo!.pendingBalance!,
                  updatingData: model.performingInstantPayout || model.retrievingAccountStatus ? true : false,
                  onPressed: () => model.showStripeAccountMenu(),
                ),
    );
  }
}

class _StripeAccountPendingBlock extends StatelessWidget {
  final bool loadingAccountStatus;
  final bool actionRequired;
  final VoidCallback onPressed;

  _StripeAccountPendingBlock({required this.loadingAccountStatus, required this.actionRequired, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 75.0,
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: appBackgroundColor(),
          borderRadius: BorderRadius.all(Radius.circular(16)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: appShadowColor(),
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Earnings Account Pending',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: appFontColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "\$XXX.XX",
                      style: TextStyle(fontSize: 16.0, color: appFontColor(), fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 2),
                    loadingAccountStatus
                        ? Container(
                            decoration: BoxDecoration(
                              color: CustomColors.webblenMatteBlue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            child: Text(
                              'Retrieving Account Status...',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : actionRequired
                            ? Container(
                                decoration: BoxDecoration(
                                  color: appActiveColor(),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                child: Text(
                                  'ACTION REQUIRED',
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: CustomColors.webblenMatteBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                child: Text(
                                  'View Account Status',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StripeAccountBlock extends StatelessWidget {
  final double usdBalance;
  final double pendingBalance;
  final bool updatingData;
  final VoidCallback onPressed;
  _StripeAccountBlock({required this.usdBalance, required this.pendingBalance, required this.updatingData, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 75.0,
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: appBackgroundColor(),
          borderRadius: BorderRadius.all(Radius.circular(16)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: appShadowColor(),
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'USD Balance',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: appFontColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                updatingData
                    ? Container(
                        margin: EdgeInsets.only(right: 8),
                        child: CustomCircleProgressIndicator(
                          size: 10,
                          color: appActiveColor(),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "\$${usdBalance.toStringAsFixed(2)}",
                            style: TextStyle(fontSize: 18.0, color: appFontColor(), fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '\$${pendingBalance.toStringAsFixed(2)} pending',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: appFontColorAlt(),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
