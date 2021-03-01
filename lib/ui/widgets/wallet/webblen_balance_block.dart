import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/widgets/common/webblen_icon_and_balance.dart';

class WebblenBalanceBlock extends StatelessWidget {
  final double balance;
  final VoidCallback onPressed;
  WebblenBalanceBlock({this.balance, this.onPressed});

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
                  'WBLN Balance',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: appFontColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                WebblenIconAndBalance(
                  balance: balance, fontSize: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
