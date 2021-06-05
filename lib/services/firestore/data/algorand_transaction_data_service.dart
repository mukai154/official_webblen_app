import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:webblen/models/algorand_transaction.dart';

class AlgorandTransactionDataService {
  final CollectionReference algorandTransactionRef =
      FirebaseFirestore.instance.collection("algorand_transactions");

  Future createAlgorandTransaction(
      {required AlgorandTransaction algorandTransaction}) async {
    await algorandTransactionRef
        .doc(algorandTransaction.txid.toString())
        .set(algorandTransaction.toMap())
        .catchError((e) {
      return e.message;
    });
  }

  Future saveAlgorandTransaction({
    required int txid,
    required String senderAlgorandAddress,
    required String receiverAlgorandAddress,
  }) async {
    // Save transaction into collection
    final algorandTransaction = AlgorandTransaction(
      txid: txid,
      senderAlgorandAddress: senderAlgorandAddress,
      receiverAlgorandAddress: receiverAlgorandAddress,
      creationTimeInMilliseconds: DateTime.now().millisecondsSinceEpoch,
    );
    await createAlgorandTransaction(
      algorandTransaction: algorandTransaction,
    );
  }
}
