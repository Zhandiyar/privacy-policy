import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'analytics_summary.g.dart';

enum PeriodType {
  @JsonValue("YEAR")
  YEAR,
  @JsonValue("MONTH")
  MONTH,
  @JsonValue("WEEK")
  WEEK
}

@JsonSerializable()
class ChartDataPoint extends Equatable {
  final String label;
  final double amount;

  const ChartDataPoint({
    required this.label,
    required this.amount,
  });

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) => 
    _$ChartDataPointFromJson(json);
  
  Map<String, dynamic> toJson() => _$ChartDataPointToJson(this);

  @override
  List<Object?> get props => [label, amount];
}

@JsonSerializable()
class CategoryExpense extends Equatable {
  final String category;
  final double amount;
  final double percentage;

  const CategoryExpense({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  factory CategoryExpense.fromJson(Map<String, dynamic> json) => 
    _$CategoryExpenseFromJson(json);
  
  Map<String, dynamic> toJson() => _$CategoryExpenseToJson(this);

  @override
  List<Object?> get props => [category, amount, percentage];
}

@JsonSerializable()
class AnalyticsSummary extends Equatable {
  final double totalAmount;
  final double average;
  final String averageLabel;
  final List<ChartDataPoint> chartData;
  final List<CategoryExpense> categoryExpenses;

  const AnalyticsSummary({
    required this.totalAmount,
    required this.average,
    required this.averageLabel,
    required this.chartData,
    required this.categoryExpenses,
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) => 
    _$AnalyticsSummaryFromJson(json);
  
  Map<String, dynamic> toJson() => _$AnalyticsSummaryToJson(this);

  @override
  List<Object?> get props => [
    totalAmount,
    average,
    averageLabel,
    chartData,
    categoryExpenses,
  ];
} 