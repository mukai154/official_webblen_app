import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';

import 'create_earnings_account_block_view_model.dart';

class CreateEarningsAccountBlockView extends StatelessWidget {
  final VoidCallback dismissNotice;

  CreateEarningsAccountBlockView({required this.dismissNotice});
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CreateEarningsAccountBlockViewModel>.reactive(
      viewModelBuilder: () => CreateEarningsAccountBlockViewModel(),
      builder: (context, model, child) => Container(
        height: 65,
        margin: EdgeInsets.only(top: 8),
        padding: EdgeInsets.only(top: 8, left: 16, right: 16),
        decoration: BoxDecoration(color: appTextFieldContainerColor(), borderRadius: BorderRadius.circular(8)),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  CustomText(
                    text: "Interested in Earning Money from Streams and Events for Free?\nCreate an Earnings Account to Get Started!",
                    color: appFontColor(),
                    textAlign: TextAlign.center,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 3.0),
                  GestureDetector(
                    onTap: () {
                      model.createStripeConnectAccount();
                      dismissNotice();
                    },
                    child: CustomText(
                      text: "Create Earnings Account",
                      color: Colors.blueAccent,
                      textAlign: TextAlign.center,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: dismissNotice,
                child: Icon(
                  FontAwesomeIcons.times,
                  color: Colors.black45,
                  size: 14.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
