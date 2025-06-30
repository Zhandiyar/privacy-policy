// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryExpense _$CategoryExpenseFromJson(Map<String, dynamic> json) =>
    CategoryExpense(
      category: ExpenseCategory.fromString(json['category'] as String),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$CategoryExpenseToJson(CategoryExpense instance) =>
    <String, dynamic>{
      'category': CategoryExpense._expenseCategoryToString(instance.category),
      'amount': instance.amount,
      'percentage': instance.percentage,
    };
