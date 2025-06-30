import 'package:equatable/equatable.dart';
import '../../models/analytics_summary.dart';
import '../../models/expense_category.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAnalyticsSummary extends AnalyticsEvent {
  final PeriodType periodType;
  final int year;
  final int? month;
  final int? day;

  const LoadAnalyticsSummary({
    required this.periodType,
    required this.year,
    this.month,
    this.day,
  });

  @override
  List<Object?> get props => [periodType, year, month, day];
}

class LoadCategoryDetails extends AnalyticsEvent {
  final int year;
  final int? month;
  final PeriodType periodType;

  const LoadCategoryDetails({
    required this.year,
    this.month,
    required this.periodType,
  });

  @override
  List<Object?> get props => [year, month, periodType];
}

class LoadCategoryExpenses extends AnalyticsEvent {
  final ExpenseCategory category;
  final int page;
  final int size;

  const LoadCategoryExpenses({
    required this.category,
    required this.page,
    required this.size,
  });

  @override
  List<Object?> get props => [category, page, size];
} 