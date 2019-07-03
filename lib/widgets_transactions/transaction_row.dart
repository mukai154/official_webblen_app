import 'package:flutter/material.dart';
import 'package:webblen/models/webblen_transaction.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/utils/time_calc.dart';

class TransactionRow extends StatelessWidget {

  final WebblenTransaction transaction;
  TransactionRow({this.transaction});

  @override
  Widget build(BuildContext context) {

    final transactionStatusDot = Icon(
      FontAwesomeIcons.solidCircle,
      size: 12.0,
      color: transaction.status == 'pending'
        ? FlatColors.vibrantYellow
        : transaction.status == 'approved' || transaction.status == 'complete'
          ? FlatColors.lightCarribeanGreen : Colors.red,
    );

    final transactionCardContent = new Container(
      padding: new EdgeInsets.only(left: 8.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(height: 8.0),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  transactionStatusDot,
                  Fonts().textW700(transaction.transactionDescription,
                      18.0,
                      FlatColors.darkGray,
                      TextAlign.right
                  ),
                ],
              ),
              Fonts().textW500(transaction.depositAccountName,
                  12.0,
                  FlatColors.darkGray,
                  TextAlign.right
              ),
              Fonts().textW500('status: ' + transaction.status,
                  12.0,
                  FlatColors.darkGray,
                  TextAlign.right
              ),
              Fonts().textW500(TimeCalc().getPastTimeFromMilliseconds(transaction.dateSubmittedInMilliseconds) ,
                  12.0,
                  Colors.black38,
                  TextAlign.right
              ),

            ],
          ),
        ],
      ),
    );

    final transactionCard = new Container(
      height: 80.0,
      child: transactionCardContent,
    );

    return Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ),
        child: new Stack(
          children: <Widget>[
            transactionCard,
          ],
        )
    );
  }

}