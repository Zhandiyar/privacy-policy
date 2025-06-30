import 'package:json_annotation/json_annotation.dart';

import 'expense_category.dart';
part 'expense.g.dart';

@JsonSerializable()
class Expense {
  final int? id;
  @JsonKey(fromJson: ExpenseCategory.fromString, toJson: _expenseCategoryToString)
  final ExpenseCategory category;
  final double amount;
  final DateTime date;
  @JsonKey(includeIfNull: true)
  final String? description;


  Expense({
    this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.description,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseToJson(this);

  static String _expenseCategoryToString(ExpenseCategory category) {
    return category.name;
  }

  Expense copyWith({
    int? id,
    ExpenseCategory? category,
    double? amount,
    DateTime? date,
    String? description,
  }) {
    return Expense(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }
}