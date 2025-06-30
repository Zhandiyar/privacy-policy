// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseSummary _$ExpenseSummaryFromJson(Map<String, dynamic> json) =>
    ExpenseSummary(
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0.0,
      dailyExpenses: (json['dailyExpenses'] as num?)?.toDouble() ?? 0.0,
      weeklyExpenses: (json['weeklyExpenses'] as num?)?.toDouble() ?? 0.0,
      monthlyExpenses: (json['monthlyExpenses'] as num?)?.toDouble() ?? 0.0,
      yearlyExpenses: (json['yearlyExpenses'] as num?)?.toDouble() ?? 0.0,
      averageDaily: (json['averageDaily'] as num?)?.toDouble() ?? 0.0,
      averageMonthly: (json['averageMonthly'] as num?)?.toDouble() ?? 0.0,
      categoryExpenses: (json['categoryExpenses'] as List<dynamic>?)
              ?.map((e) => CategoryExpense.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$ExpenseSummaryToJson(ExpenseSummary instance) =>
    <String, dynamic>{
      'totalExpenses': instance.totalExpenses,
      'dailyExpenses': instance.dailyExpenses,
      'weeklyExpenses': instance.weeklyExpenses,
      'monthlyExpenses': instance.monthlyExpenses,
      'yearlyExpenses': instance.yearlyExpenses,
      'averageDaily': instance.averageDaily,
      'averageMonthly': instance.averageMonthly,
      'categoryExpenses': instance.categoryExpenses,
    };
