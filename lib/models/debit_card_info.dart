class DebitCardInfo {
  String uid;
  String nameOnCard;
  int cardNumber;
  int expMonth;
  int expYear;
  int cvc;

  DebitCardInfo({
    this.uid,
    this.nameOnCard,
    this.cardNumber,
    this.expMonth,
    this.expYear,
    this.cvc,
  });

  DebitCardInfo.fromMap(Map<String, dynamic> data)
      : this(
          uid: data['uid'],
          nameOnCard: data['nameOnCard'],
          cardNumber: data['cardNumber'],
          expMonth: data['expMonth'],
          expYear: data['expYear'],
          cvc: data['cvc'],
        );

  Map<String, dynamic> toMap() => {
        'uid': this.uid,
        'nameOnCard': this.nameOnCard,
        'cardNumber': this.cardNumber,
        'expMonth': this.expMonth,
        'expYear': this.expYear,
        'cvc': this.cvc,
      };
}
