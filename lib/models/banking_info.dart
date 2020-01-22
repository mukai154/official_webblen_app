class BankingInfo {
  String uid;
  String nameOnAccount;
  int routingNumber;
  int accountNumber;
  String bankName;
  bool verified;

  BankingInfo({
    this.uid,
    this.nameOnAccount,
    this.routingNumber,
    this.accountNumber,
    this.bankName,
    this.verified,
  });

  BankingInfo.fromMap(Map<String, dynamic> data)
      : this(
          uid: data['uid'],
          nameOnAccount: data['nameOnAccount'],
          routingNumber: data['routingNumber'],
          accountNumber: data['accountNumber'],
          bankName: data['bankName'],
          verified: data['verified'],
        );

  Map<String, dynamic> toMap() => {
        'uid': this.uid,
        'nameOnAccount': this.nameOnAccount,
        'routingNumber': this.routingNumber,
        'accountNumber': this.accountNumber,
        'bankName': this.bankName,
        'verified': this.verified
      };
}
