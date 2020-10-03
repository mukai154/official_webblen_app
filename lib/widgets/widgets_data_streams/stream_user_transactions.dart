import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:webblen/models/webblen_transaction.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets/widgets_icons/icon_transaction_receipt.dart';
import 'package:webblen/widgets/widgets_transactions/transaction_row.dart';

class StreamUserTransactions extends StatelessWidget {
  final String uid;

  StreamUserTransactions({
    this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("transactions")
          .where(
            'transactionUserUid',
            isEqualTo: uid,
          )
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> tSnapshot) {
        if (!tSnapshot.hasData) return Container();
        if (tSnapshot.data.docs.isEmpty)
          return Column(
            children: <Widget>[
              SizedBox(
                height: 32.0,
              ),
              Fonts().textW300(
                'You Have No Recent Transactions',
                18.0,
                FlatColors.darkGray,
                TextAlign.center,
              ),
            ],
          );
        return ListView(
          shrinkWrap: true,
          children: tSnapshot.data.docs.map((DocumentSnapshot tDoc) {
            WebblenTransaction tData = WebblenTransaction.fromMap(tDoc.data());
            return TransactionRow(transaction: tData);
          }).toList(),
        );
      },
    );
  }
}

class StreamUserTransactionsIcon extends StatelessWidget {
  final String uid;
  final VoidCallback onTapAction;

  StreamUserTransactionsIcon({
    this.uid,
    this.onTapAction,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("transactions")
          .where(
            'transactionUserUid',
            isEqualTo: uid,
          )
          .where(
            'isNew',
            isEqualTo: true,
          )
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> tSnapshot) {
        if (!tSnapshot.hasData || tSnapshot.data.docs.isEmpty)
          return TransactionReceiptIcon(
            hasNewTransactions: false,
            onTapAction: onTapAction,
          );
        return TransactionReceiptIcon(
          hasNewTransactions: true,
          onTapAction: onTapAction,
        );
      },
    );
  }
}
