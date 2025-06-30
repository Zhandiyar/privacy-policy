// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_expense_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryExpenseDetails _$CategoryExpenseDetailsFromJson(
        Map<String, dynamic> json) =>
    CategoryExpenseDetails(
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      lastTransactions: (json['lastTransactions'] as List<dynamic>?)
              ?.map((e) => Expense.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$CategoryExpenseDetailsToJson(
        CategoryExpenseDetails instance) =>
    <String, dynamic>{
      'category': instance.category,
      'amount': instance.amount,
      'percentage': instance.percentage,
      'lastTransactions': instance.lastTransactions,
    };
