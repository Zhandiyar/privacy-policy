import 'package:json_annotation/json_annotation.dart';
import 'expense.dart';

part 'category_expense_details.g.dart';

@JsonSerializable()
class CategoryExpenseDetails {
  final String category;
  final double amount;
  final double percentage;
  @JsonKey(name: 'lastTransactions', defaultValue: [])
  final List<Expense> lastTransactions;

  CategoryExpenseDetails({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.lastTransactions,
  });

  factory CategoryExpenseDetails.fromJson(Map<String, dynamic> json) => 
    _$CategoryExpenseDetailsFromJson(json);
  
  Map<String, dynamic> toJson() => _$CategoryExpenseDetailsToJson(this);
} 