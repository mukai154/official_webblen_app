import 'package:flutter/material.dart';
import 'package:webblen/firebase/data/transaction_data.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';

class TransactionHistoryPage extends StatefulWidget {
  final WebblenUser currentUser;

  TransactionHistoryPage({
    this.currentUser,
  });

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
      appBar: WebblenAppBar().basicAppBar(
        'Transaction History',
        context,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Container(),
      ),
    );
  }
}
