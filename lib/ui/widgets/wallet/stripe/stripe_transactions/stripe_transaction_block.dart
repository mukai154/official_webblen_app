import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/models/stripe_transaction.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/utils/time_calc.dart';

class StripeTransactionBlock extends StatelessWidget {
  final StripeTransaction transaction;

  StripeTransactionBlock({
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return transaction.isValid()
        ? Container(
            constraints: BoxConstraints(
              maxWidth: 500,
            ),
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            padding: EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                width: 0.5,
                color: appBorderColorAlt(),
              )),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                CustomText(
                  text: transaction.description,
                  textAlign: TextAlign.left,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: appFontColor(),
                ),
                SizedBox(height: 4.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    CustomText(
                      text: TimeCalc().getPastTimeFromMilliseconds(transaction.timePosted!),
                      textAlign: TextAlign.left,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: appFontColorAlt(),
                    ),
                    CustomText(
                      text: transaction.description!.toLowerCase().contains("payout") ? "- ${transaction.value ?? "\$0.00"}" : transaction.value ?? "\$0.00",
                      textAlign: TextAlign.right,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: transaction.description!.toLowerCase().contains("payout") ? appFontColor() : CustomColors.darkMountainGreen,
                    ),
                  ],
                ),
              ],
            ),
          )
        : Container();
  }
}
