enum TransactionType {
  deposit,
  transfer,
  withdrawal,
  purchase,
}

class TransactionTypeConverter {
  static TransactionType stringToTransactionType(String transactionType) {
    if (transactionType == 'deposit') {
      return TransactionType.deposit;
    } else if (transactionType == 'transfer') {
      return TransactionType.transfer;
    } else if (transactionType == 'withdrawal') {
      return TransactionType.withdrawal;
    } else {
      return TransactionType.purchase;
    }
  }

  static String transactionTypeToString(TransactionType transactionType) {
    if (transactionType == TransactionType.deposit) {
      return 'deposit';
    } else if (transactionType == TransactionType.transfer) {
      return 'transfer';
    } else if (transactionType == TransactionType.withdrawal) {
      return 'withdrawal';
    } else {
      return 'purchase';
    }
  }
}
