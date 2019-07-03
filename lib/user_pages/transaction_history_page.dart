import 'package:flutter/material.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/widgets_data_streams/stream_user_transactions.dart';
import 'package:webblen/widgets_common/common_appbar.dart';
import 'package:webblen/firebase_services/transaction_data.dart';


class TransactionHistoryPage extends StatefulWidget {

  final WebblenUser currentUser;
  TransactionHistoryPage({this.currentUser});

  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {

  @override
  void initState() {
    super.initState();
    TransactionDataService().updateUnseenTransactions(widget.currentUser.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().basicAppBar('Transaction History'),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: StreamUserTransactions(uid: widget.currentUser.uid),
      ),
    );
  }
}
