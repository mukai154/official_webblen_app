class UserBankingInfo {
  String accountHolderName;
  String accountHolderType;
  String bankName;
  String last4;

  UserBankingInfo({
    this.accountHolderName,
    this.accountHolderType,
    this.bankName,
    this.last4,
  });

  UserBankingInfo.fromMap(Map<String, dynamic> data)
      : this(
          accountHolderName: data['accountHolderName'],
          accountHolderType: data['accountHolderType'],
          bankName: data['bankName'],
          last4: data['last4'],
        );

  Map<String, dynamic> toMap() => {
        'accountHolderName': this.accountHolderName,
        'accountHolderType': this.accountHolderType,
        'bankName': this.bankName,
        'last4': this.last4,
      };
}

class UserCardInfo {
  String brand;
  String expMonth;
  String expYear;
  String cardType;
  String last4;

  UserCardInfo({
    this.brand,
    this.expMonth,
    this.expYear,
    this.cardType,
    this.last4,
  });

  UserCardInfo.fromMap(Map<String, dynamic> data)
      : this(
          brand: data['brand'],
          expMonth: data['expMonth'],
          expYear: data['expYear'],
          cardType: data['funding'],
          last4: data['last4'],
        );

  Map<String, dynamic> toMap() => {
        'brand': this.brand,
        'expMonth': this.expMonth,
        'expYear': this.expYear,
        'funding': this.cardType,
        'last4': this.last4,
      };
}

class UserStripeInfo {
  double availableBalance;
  UserBankingInfo userBankingInfo;
  UserCardInfo userCardInfo;
  double pendingBalance;
  String stripeUID;
  String verified;

  UserStripeInfo({
    this.availableBalance,
    this.userBankingInfo,
    this.userCardInfo,
    this.pendingBalance,
    this.stripeUID,
    this.verified,
  });

  UserStripeInfo.fromMap(Map<String, dynamic> data)
      : this(
          availableBalance: data['availableBalance'],
          userBankingInfo: data['bankInfo'] == null ? null : UserBankingInfo.fromMap(data['bankInfo']),
          userCardInfo: data['cardInfo'] == null ? null : UserCardInfo.fromMap(data['cardInfo']),
          pendingBalance: data['pendingBalance'],
          stripeUID: data['stripeUID'],
          verified: data['verified'],
        );

  Map<String, dynamic> toMap() => {
        'availableBalance': this.availableBalance,
        'bankInfo': this.userBankingInfo.toMap(),
        'cardInfo': this.userCardInfo.toMap(),
        'pendingBalance': this.pendingBalance,
        'stripeUID': this.stripeUID,
        'verified': this.verified,
      };
}
