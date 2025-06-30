// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
      id: (json['id'] as num?)?.toInt(),
      category: ExpenseCategory.fromString(json['category'] as String),
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
      'id': instance.id,
      'category': Expense._expenseCategoryToString(instance.category),
      'amount': instance.amount,
      'date': instance.date.toIso8601String(),
      'description': instance.description,
    };
