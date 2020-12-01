import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black12,
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
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                Container(
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
                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
