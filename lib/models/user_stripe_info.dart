class UserBankingInfo {
  String? accountHolderName;
  String? accountHolderType;
  String? bankName;
  String? last4;

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

  //checks if obj is valid
  bool isValid() {
    bool isValid = true;
    if (last4 == null) {
      isValid = false;
    }
    return isValid;
  }
}

class UserCardInfo {
  String? brand;
  String? expMonth;
  String? expYear;
  String? cardType;
  String? last4;

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

  //checks if obj is valid
  bool isValid() {
    bool isValid = true;
    if (last4 == null) {
      isValid = false;
    }
    return isValid;
  }
}

class UserStripeInfo {
  double? availableBalance;
  UserBankingInfo? userBankingInfo;
  UserCardInfo? userCardInfo;
  double? pendingBalance;
  String? stripeUID;
  String? verified;
  bool? actionRequired;

  UserStripeInfo({
    this.availableBalance,
    this.userBankingInfo,
    this.userCardInfo,
    this.pendingBalance,
    this.stripeUID,
    this.verified,
    this.actionRequired,
  });

  UserStripeInfo.fromMap(Map<String, dynamic> data)
      : this(
          availableBalance: data['availableBalance'] == null ? null : data['availableBalance'].toDouble(),
          userBankingInfo: data['bankInfo'] == null ? null : UserBankingInfo.fromMap(data['bankInfo']),
          userCardInfo: data['cardInfo'] == null ? null : UserCardInfo.fromMap(data['cardInfo']),
          pendingBalance: data['pendingBalance'] == null ? null : data['pendingBalance'].toDouble(),
          stripeUID: data['stripeUID'],
          verified: data['verified'],
          actionRequired: data['actionRequired'],
        );

  Map<String, dynamic> toMap() => {
        'availableBalance': this.availableBalance,
        'bankInfo': this.userBankingInfo!.toMap(),
        'cardInfo': this.userCardInfo!.toMap(),
        'pendingBalance': this.pendingBalance,
        'stripeUID': this.stripeUID,
        'verified': this.verified,
        'actionRequired': this.actionRequired,
      };

  //checks if obj is valid
  bool isValid() {
    bool isValid = true;
    if (stripeUID == null) {
      isValid = false;
    }
    return isValid;
  }
}
