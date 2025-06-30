import 'package:json_annotation/json_annotation.dart';
import 'category_expense.dart';

part 'expense_summary.g.dart';

@JsonSerializable()
class ExpenseSummary {
  @JsonKey(name: 'totalExpenses', defaultValue: 0.0)
  final double totalExpenses;
  
  @JsonKey(name: 'dailyExpenses', defaultValue: 0.0)
  final double dailyExpenses;
  
  @JsonKey(name: 'weeklyExpenses', defaultValue: 0.0)
  final double weeklyExpenses;
  
  @JsonKey(name: 'monthlyExpenses', defaultValue: 0.0)
  final double monthlyExpenses;
  
  @JsonKey(name: 'yearlyExpenses', defaultValue: 0.0)
  final double yearlyExpenses;
  
  @JsonKey(name: 'averageDaily', defaultValue: 0.0)
  final double averageDaily;
  
  @JsonKey(name: 'averageMonthly', defaultValue: 0.0)
  final double averageMonthly;
  
  @JsonKey(name: 'categoryExpenses', defaultValue: [])
  final List<CategoryExpense> categoryExpenses;

  ExpenseSummary({
    required this.totalExpenses,
    required this.dailyExpenses,
    required this.weeklyExpenses,
    required this.monthlyExpenses,
    required this.yearlyExpenses,
    required this.averageDaily,
    required this.averageMonthly,
    required this.categoryExpenses,
  });

  factory ExpenseSummary.fromJson(Map<String, dynamic> json) {
    print('Разбор JSON для ExpenseSummary:');
    print('totalExpenses: ${json['totalExpenses']} (${json['totalExpenses'].runtimeType})');
    print('dailyExpenses: ${json['dailyExpenses']} (${json['dailyExpenses'].runtimeType})');
    print('weeklyExpenses: ${json['weeklyExpenses']} (${json['weeklyExpenses'].runtimeType})');
    print('monthlyExpenses: ${json['monthlyExpenses']} (${json['monthlyExpenses'].runtimeType})');
    print('yearlyExpenses: ${json['yearlyExpenses']} (${json['yearlyExpenses'].runtimeType})');
    print('averageDaily: ${json['averageDaily']} (${json['averageDaily'].runtimeType})');
    print('averageMonthly: ${json['averageMonthly']} (${json['averageMonthly'].runtimeType})');
    
    try {
      return ExpenseSummary(
        totalExpenses: _parseDouble(json['totalExpenses']),
        dailyExpenses: _parseDouble(json['dailyExpenses']),
        weeklyExpenses: _parseDouble(json['weeklyExpenses']),
        monthlyExpenses: _parseDouble(json['monthlyExpenses']),
        yearlyExpenses: _parseDouble(json['yearlyExpenses']),
        averageDaily: _parseDouble(json['averageDaily']),
        averageMonthly: _parseDouble(json['averageMonthly']),
        categoryExpenses: _parseCategoryExpenses(json['categoryExpenses']),
      );
    } catch (e, stackTrace) {
      print('Ошибка при разборе JSON: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static List<CategoryExpense> _parseCategoryExpenses(dynamic value) {
    if (value == null) return [];
    if (value is! List) return [];
    
    try {
      return value
          .map((e) => CategoryExpense.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Ошибка при разборе categoryExpenses: $e');
      return [];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'totalExpenses': totalExpenses,
      'dailyExpenses': dailyExpenses,
      'weeklyExpenses': weeklyExpenses,
      'monthlyExpenses': monthlyExpenses,
      'yearlyExpenses': yearlyExpenses,
      'averageDaily': averageDaily,
      'averageMonthly': averageMonthly,
      'categoryExpenses': categoryExpenses.map((e) => e.toJson()).toList(),
    };
  }

  static double _parseDouble(dynamic value) {
    try {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.parse(value);
      print('Неизвестный тип для _parseDouble: ${value.runtimeType}');
      return 0.0;
    } catch (e) {
      print('Ошибка в _parseDouble для значения $value: $e');
      return 0.0;
    }
  }
} 