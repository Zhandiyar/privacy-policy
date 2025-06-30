import 'package:equatable/equatable.dart';
import '../../models/expense_summary.dart';
import '../../models/category_expense_details.dart';
import '../../models/expense.dart';

abstract class ReportsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class SummaryLoaded extends ReportsState {
  final ExpenseSummary summary;

  SummaryLoaded(this.summary);

  @override
  List<Object> get props => [summary];
}

class CategoryDetailsLoaded extends ReportsState {
  final List<CategoryExpenseDetails> details;

  CategoryDetailsLoaded(this.details);

  @override
  List<Object> get props => [details];
}

class CategoryExpensesLoaded extends ReportsState {
  final List<Expense> expenses;

  CategoryExpensesLoaded(this.expenses);

  @override
  List<Object> get props => [expenses];
}

class ReportsError extends ReportsState {
  final String message;

  ReportsError(this.message);

  @override
  List<Object> get props => [message];
} 