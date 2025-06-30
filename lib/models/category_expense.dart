import 'package:json_annotation/json_annotation.dart';
import 'expense_category.dart';

part 'category_expense.g.dart';

@JsonSerializable()
class CategoryExpense {
  @JsonKey(fromJson: ExpenseCategory.fromString, toJson: _expenseCategoryToString)
  final ExpenseCategory category;
  
  @JsonKey(defaultValue: 0.0)
  final double amount;
  
  @JsonKey(defaultValue: 0.0)
  final double percentage;

  CategoryExpense({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  factory CategoryExpense.fromJson(Map<String, dynamic> json) {
    try {
      return _$CategoryExpenseFromJson(json);
    } catch (e) {
      print('Ошибка при разборе CategoryExpense: $e');
      print('JSON данные: $json');
      return CategoryExpense(
        category: ExpenseCategory.OTHER,
        amount: 0.0,
        percentage: 0.0,
      );
    }
  }
  
  Map<String, dynamic> toJson() => _$CategoryExpenseToJson(this);

  static String _expenseCategoryToString(ExpenseCategory category) {
    return category.name;
  }
} 