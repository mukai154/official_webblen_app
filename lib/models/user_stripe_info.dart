import 'package:webblen/enums/card_type.dart';
import 'package:webblen/enums/verified_status.dart';

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
  CardType cardType;
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
          cardType: CardTypeConverter.stringToCardType(data['funding']),
          last4: data['last4'],
        );

  Map<String, dynamic> toMap() => {
        'brand': this.brand,
        'expMonth': this.expMonth,
        'expYear': this.expYear,
        'funding': CardTypeConverter.cardTypeToString(this.cardType),
        'last4': this.last4,
      };
}

class UserStripeInfo {
  double availableBalance;
  UserBankingInfo userBankingInfo;
  UserCardInfo userCardInfo;
  double pendingBalance;
  String stripeUID;
  VerifiedStatus verifiedStatus;

  UserStripeInfo({
    this.availableBalance,
    this.userBankingInfo,
    this.userCardInfo,
    this.pendingBalance,
    this.stripeUID,
    this.verifiedStatus,
  });

  UserStripeInfo.fromMap(Map<String, dynamic> data)
      : this(
          availableBalance: data['availableBalance'],
          userBankingInfo: UserBankingInfo.fromMap(data['bankInfo']),
          userCardInfo: UserCardInfo.fromMap(data['cardInfo']),
          pendingBalance: data['pendingBalance'],
          stripeUID: data['stripeUID'],
          verifiedStatus:
              VerifiedStatusConverter.stringToVerifiedStatus(data['verified']),
        );

  Map<String, dynamic> toMap() => {
        'availableBalance': this.availableBalance,
        'bankInfo': this.userBankingInfo.toMap(),
        'cardInfo': this.userCardInfo.toMap(),
        'pendingBalance': this.pendingBalance,
        'stripeUID': this.stripeUID,
        'verified':
            VerifiedStatusConverter.verifiedStatusToString(this.verifiedStatus),
      };
}
