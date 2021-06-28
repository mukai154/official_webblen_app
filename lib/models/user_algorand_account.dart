class AssetId {
  int? assetId;
  int? amount;

  AssetId({
    this.assetId,
    this.amount,
  });

  AssetId.fromMap(Map<String, dynamic> data)
      : this(
          assetId: data['assetId'],
          amount: data['amount'],
        );

  Map<String, dynamic> toMap() => {
        'assetId': assetId,
        'amount': amount,
      };
}

class UserAlgorandAccount {
  String? id;
  String? uid;
  String? address;
  String? passphrase;
  double? webblenAmount;
  double? algoAmount;
  List<AssetId>? assetIds;

  UserAlgorandAccount({
    this.id,
    this.uid,
    this.address,
    this.passphrase,
    this.webblenAmount,
    this.algoAmount,
    this.assetIds,
  });

  UserAlgorandAccount.fromMap(Map<String, dynamic> data)
      : this(
          id: data['id'],
          uid: data['uid'],
          address: data['address'],
          passphrase: data['passphrase'],
          webblenAmount: data['webblenAmount'].toDouble(),
          algoAmount: data['algoAmount'].toDouble(),
          assetIds: data['certifications'] != null
              ? data['assetIds']
                  .map((cert) => AssetId.fromMap(cert))
                  .cast<AssetId>()
                  .toList()
              : [],
        );

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'uid': this.uid,
        'address': this.address,
        'passphrase': this.passphrase,
        'webblenAmount': this.webblenAmount,
        'algoAmount': this.algoAmount,
        'assetIds': assetIds != null
            ? assetIds!.map((cert) => cert.toMap()).toList()
            : [],
      };
}
