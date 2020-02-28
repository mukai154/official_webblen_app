import 'package:flutter/material.dart';

import 'package:webblen/styles/fonts.dart';

class ShowAmountOfWebblen extends StatelessWidget {
  final String amount;
  final Color textColor;
  final double textSize;
  final double iconSize;
  final VoidCallback onTap;

  ShowAmountOfWebblen({
    this.amount,
    this.textColor,
    this.textSize,
    this.iconSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Image.asset(
            'assets/images/webblen_coin.png',
            height: iconSize,
            width: iconSize,
            fit: BoxFit.contain,
          ),
          Container(
            width: 4.0,
          ),
          MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.0,
            ),
            child: Fonts().textW500(
              amount,
              textSize,
              textColor,
              TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
