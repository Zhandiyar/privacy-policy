enum TransactionType { INCOME, EXPENSE }

TransactionType transactionTypeFromString(String type) =>
    TransactionType.values.firstWhere((e) => e.name == type);

String transactionTypeToString(TransactionType type) => type.name;
