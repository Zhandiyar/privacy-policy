import 'package:equatable/equatable.dart';
import '../../models/analytics_summary.dart';
import '../../models/category_expense_details.dart';
import '../../models/expense.dart';

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsSummaryLoaded extends AnalyticsState {
  final AnalyticsSummary summary;
  final PeriodType periodType;

  const AnalyticsSummaryLoaded({
    required this.summary,
    required this.periodType,
  });

  @override
  List<Object> get props => [summary, periodType];
}

class CategoryDetailsLoaded extends AnalyticsState {
  final List<CategoryExpenseDetails> details;

  const CategoryDetailsLoaded(this.details);

  @override
  List<Object?> get props => [details];
}

class CategoryExpensesLoaded extends AnalyticsState {
  final List<Expense> expenses;

  const CategoryExpensesLoaded(this.expenses);

  @override
  List<Object?> get props => [expenses];
}

class AnalyticsError extends AnalyticsState {
  final String message;

  const AnalyticsError(this.message);

  @override
  List<Object> get props => [message];
} 