// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChartDataPoint _$ChartDataPointFromJson(Map<String, dynamic> json) =>
    ChartDataPoint(
      label: json['label'] as String,
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$ChartDataPointToJson(ChartDataPoint instance) =>
    <String, dynamic>{
      'label': instance.label,
      'amount': instance.amount,
    };

CategoryExpense _$CategoryExpenseFromJson(Map<String, dynamic> json) =>
    CategoryExpense(
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$CategoryExpenseToJson(CategoryExpense instance) =>
    <String, dynamic>{
      'category': instance.category,
      'amount': instance.amount,
      'percentage': instance.percentage,
    };

AnalyticsSummary _$AnalyticsSummaryFromJson(Map<String, dynamic> json) =>
    AnalyticsSummary(
      totalAmount: (json['totalAmount'] as num).toDouble(),
      average: (json['average'] as num).toDouble(),
      averageLabel: json['averageLabel'] as String,
      chartData: (json['chartData'] as List<dynamic>)
          .map((e) => ChartDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      categoryExpenses: (json['categoryExpenses'] as List<dynamic>)
          .map((e) => CategoryExpense.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AnalyticsSummaryToJson(AnalyticsSummary instance) =>
    <String, dynamic>{
      'totalAmount': instance.totalAmount,
      'average': instance.average,
      'averageLabel': instance.averageLabel,
      'chartData': instance.chartData,
      'categoryExpenses': instance.categoryExpenses,
    };
