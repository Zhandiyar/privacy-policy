import 'package:equatable/equatable.dart';
import '../../models/expense_category.dart';

abstract class ReportsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSummary extends ReportsEvent {
  final int year;
  final int month;
  final int day;

  LoadSummary({
    required this.year,
    required this.month,
    required this.day,
  });

  @override
  List<Object> get props => [year, month, day];
}

class LoadCategoryDetails extends ReportsEvent {
  final int year;
  final int month;
  final int day;

  LoadCategoryDetails({
    required this.year,
    required this.month,
    required this.day,
  });

  @override
  List<Object> get props => [year, month, day];
}

class LoadCategoryExpenses extends ReportsEvent {
  final ExpenseCategory category;
  final int page;
  final int size;

  LoadCategoryExpenses(this.category, {this.page = 0, this.size = 10});

  @override
  List<Object> get props => [category, page, size];
} 