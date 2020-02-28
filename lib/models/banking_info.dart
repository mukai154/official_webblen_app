class BankingInfo {
  String accountHolderName;
  String routingNumber;
  String last4;
  String bankName;
  //bool verified;

  BankingInfo({
    this.accountHolderName,
    this.routingNumber,
    this.last4,
    this.bankName,
    //this.verified,
  });

  BankingInfo.fromMap(Map<String, dynamic> data)
      : this(
          accountHolderName: data['accountHolderName'],
          routingNumber: data['routingNumber'],
          last4: data['last4'],
          bankName: data['bankName'],
          //verified: data['verified'],
        );

  Map<String, dynamic> toMap() => {
        'accountHolderName': this.accountHolderName,
        'routingNumber': this.routingNumber,
        'last4': this.last4,
        'bankName': this.bankName,
        //'verified': this.verified
      };
}
