class HotWallet {
  String? id;
  String? address;
  String? passphrase;
  double? webblenAmount;
  double? algoAmount;

  HotWallet({
    this.id,
    this.address,
    this.passphrase,
    this.webblenAmount,
    this.algoAmount,
  });

  HotWallet.fromMap(Map<String, dynamic> data)
      : this(
          id: data['id'],
          address: data['address'],
          passphrase: data['passphrase'],
          webblenAmount: data['webblenAmount'],
          algoAmount: data['algoAmount'],
        );

  Map<String, dynamic> toMap() => {
        'id': this.id,
        'address': this.address,
        'passphrase': this.passphrase,
        'webblenAmount': this.webblenAmount,
        'algoAmount': this.algoAmount,
      };
}
