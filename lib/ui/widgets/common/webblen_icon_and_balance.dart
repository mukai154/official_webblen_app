import 'package:flutter/material.dart';
import 'package:webblen/constants/app_colors.dart';

class WebblenIconAndBalance extends StatelessWidget {
  final double balance;
  final double fontSize;

  WebblenIconAndBalance({this.balance, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Image.asset(
            'assets/images/webblen_coin.png',
            height: 20,
            width: 20,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 4),
          Text(
            "${balance.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: fontSize,
              color: appFontColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
