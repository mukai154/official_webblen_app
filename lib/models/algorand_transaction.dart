import 'package:cloud_firestore/cloud_firestore.dart';

class AlgorandTransaction {
  String? txid;
  String? senderAlgorandAddress;
  String? receiverAlgorandAddress;
  int? creationTimeInMilliseconds;

  AlgorandTransaction({
    this.txid,
    this.senderAlgorandAddress,
    this.receiverAlgorandAddress,
    this.creationTimeInMilliseconds,
  });

  AlgorandTransaction.fromMap(Map<String, dynamic> data)
      : this(
          txid: data['txid'],
          senderAlgorandAddress: data['senderAlgorandAddress'],
          receiverAlgorandAddress: data['receiverAlgorandAddress'],
          creationTimeInMilliseconds: data['creationTimeInMilliseconds'],
        );

  Map<String, dynamic> toMap() => {
        'txid': this.txid,
        'senderAlgorandAddress': this.senderAlgorandAddress,
        'receiverAlgorandAddress': this.receiverAlgorandAddress,
        'creationTimeInMilliseconds': this.creationTimeInMilliseconds,
      };
}
