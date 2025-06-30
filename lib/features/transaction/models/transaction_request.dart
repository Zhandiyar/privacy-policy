
import 'transaction_type.dart';

class TransactionRequestDto {
  final int? id;
  final double amount;
  final DateTime date;
  final String? comment;
  final TransactionType type;
  final int categoryId;

  TransactionRequestDto({
    this.id,
    required this.amount,
    required this.date,
    this.comment,
    required this.type,
    required this.categoryId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'date': date.toIso8601String(),
    'comment': comment,
    'type': transactionTypeToString(type),
    'categoryId': categoryId,
  };
}
