import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:webblen/constants/app_colors.dart';

class USDBalanceBlock extends StatelessWidget {
  final double balance;
  final double pendingBalance;
  final VoidCallback onPressed;
  USDBalanceBlock({this.balance, this.pendingBalance, this.onPressed});

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "\$${balance.toStringAsFixed(2)}",
                      style: TextStyle(
                          fontSize: 18.0,
                          color: appFontColor(),
                          fontWeight: FontWeight.w500),
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
