class WebblenTransaction {
  String status;
  int dateSubmittedInMilliseconds;
  String transactionType;
  String transactionDescription;
  double transactionAmount;
  String depositAccountName;
  String transactionUserUid;
  bool isNew;

  WebblenTransaction({
    this.status,
    this.dateSubmittedInMilliseconds,
    this.transactionType,
    this.transactionDescription,
    this.transactionAmount,
    this.depositAccountName,
    this.transactionUserUid,
    this.isNew,
  });

  WebblenTransaction.fromMap(Map<String, dynamic> data)
      : this(
          status: data['status'],
          dateSubmittedInMilliseconds: data['dateSubmittedInMilliseconds'],
          transactionType: data['transactionType'],
          transactionDescription: data['transactionDescription'],
          transactionAmount: data['transactionAmount'],
          depositAccountName: data['depositAccountName'],
          transactionUserUid: data['transactionUserUid'],
          isNew: data['isNew'],
        );

  Map<String, dynamic> toMap() => {
        'status': this.status,
        'dateSubmittedInMilliseconds': this.dateSubmittedInMilliseconds,
        'transactionType': this.transactionType,
        'transactionDescription': this.transactionDescription,
        'transactionAmount': this.transactionAmount,
        'depositAccountName': this.depositAccountName,
        'transactionUserUid': this.transactionUserUid,
        'isNew': this.isNew,
      };
}
