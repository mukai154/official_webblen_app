enum TransactionCurrency {
  USD,
  WBLN,
}

class TransactionCurrencyConverter {
  static TransactionCurrency stringToTransactionCurrency(String transactionCurrency) {
    if (transactionCurrency == 'USD') {
      return TransactionCurrency.USD;
    } else {
      return TransactionCurrency.WBLN;
    }
  }

  static String transactionCurrencyToString(TransactionCurrency transactionCurrency) {
    if (transactionCurrency == TransactionCurrency.USD) {
      return 'USD';
    } else {
      return 'WBLN';
    }
  }
}