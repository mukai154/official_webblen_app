enum CardType {
  debit,
  credit,
}

class CardTypeConverter {
  static CardType stringToCardType(String cardType) {
    if (cardType == 'debit') {
      return CardType.debit;
    } else {
      return CardType.credit;
    }
  }

  static String cardTypeToString(CardType cardType) {
    if (cardType == CardType.debit) {
      return 'debit';
    } else {
      return 'credit';
    }
  }
}