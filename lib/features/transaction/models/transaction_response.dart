

import 'transaction_type.dart';

class TransactionResponseDto {
  final int id;
  final double amount;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? comment;
  final TransactionType type;
  final int categoryId;
  final String categoryNameRu;
  final String categoryNameEn;

  TransactionResponseDto({
    required this.id,
    required this.amount,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.comment,
    required this.type,
    required this.categoryId,
    required this.categoryNameRu,
    required this.categoryNameEn,
  });

  factory TransactionResponseDto.fromJson(Map<String, dynamic> json) =>
      TransactionResponseDto(
        id: json['id'],
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.parse(json['date']),
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        comment: json['comment'],
        type: transactionTypeFromString(json['type']),
        categoryId: json['categoryId'],
        categoryNameRu: json['categoryNameRu'],
        categoryNameEn: json['categoryNameEn'],
      );
}
