class EscrowHotWallet {
  String? id;
  String? activeEventId;
  String? address;
  String? passphrase;
  double? webblenAmount;
  double? algoAmount;

  EscrowHotWallet({
    this.id,
    this.activeEventId,
    this.address,
    this.passphrase,
    this.webblenAmount,
    this.algoAmount,
  });

  EscrowHotWallet.fromMap(Map<String, dynamic> data)
      : this(
          id: data['id'],
          activeEventId: data['activeEventId'],
          address: data['address'],
          passphrase: data['passphrase'],
          webblenAmount: data['webblenAmount'].toDouble(),
          algoAmount: data['algoAmount'].toDouble(),
        );

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'activeEventId': this.activeEventId,
        'address': this.address,
        'passphrase': this.passphrase,
        'webblenAmount': this.webblenAmount,
        'algoAmount': this.algoAmount,
      };
}
