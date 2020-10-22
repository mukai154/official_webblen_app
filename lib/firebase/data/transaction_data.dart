import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/models/webblen_transaction.dart';

class TransactionDataService {
  final CollectionReference transactionRef = FirebaseFirestore.instance.collection("transactions");

  Future<String> submitTransaction(String uid, double transAmount, String transType, String depositAccountName, String transDesc) async {
    String error;
    WebblenTransaction newTransaction = WebblenTransaction(
      status: "pending",
      transactionType: transType,
      transactionAmount: transAmount,
      transactionDescription: transDesc,
      depositAccountName: depositAccountName,
      dateSubmittedInMilliseconds: DateTime.now().millisecondsSinceEpoch,
      transactionUserUid: uid,
      isNew: true,
    );
    await transactionRef.doc().set(newTransaction.toMap()).then((doc) {
      error = "";
    }).catchError((e) {
      error = e;
    });
    return error;
  }

  Future<List<WebblenTransaction>> findTransactionsByUserUid(String uid) async {
    List<WebblenTransaction> userTransactions = [];
    QuerySnapshot querySnapshot = await transactionRef
        .where(
          'transactionUserUid',
          isEqualTo: uid,
        )
        .getDocuments();
    var transactionDocs = querySnapshot.docs;
    transactionDocs.forEach((transDoc) {
      WebblenTransaction webblenTransaction = WebblenTransaction.fromMap(transDoc.data());
      userTransactions.add(webblenTransaction);
    });
    userTransactions.sort((t1, t2) {
      t1.dateSubmittedInMilliseconds.compareTo(t2.dateSubmittedInMilliseconds);
    });
    return userTransactions;
  }

  Future<Null> updateUnseenTransactions(String uid) async {
    QuerySnapshot querySnapshot = await transactionRef
        .where(
          'transactionUserUid',
          isEqualTo: uid,
        )
        .where(
          'isNew',
          isEqualTo: true,
        )
        .getDocuments();
    querySnapshot.docs.forEach((transDoc) {
      transactionRef.doc(transDoc.id).updateData({'isNew': false}).whenComplete(() {}).catchError((e) {});
    });
  }
}
