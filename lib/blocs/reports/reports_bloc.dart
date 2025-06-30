import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/expense_summary.dart';
import '../../models/category_expense_details.dart';
import '../../models/expense.dart';
import '../../models/expense_category.dart';
import '../../repositories/reports_repository.dart';
import 'reports_event.dart';
import 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ReportsRepository _reportsRepository;

  ReportsBloc({required ReportsRepository reportsRepository})
      : _reportsRepository = reportsRepository,
        super(ReportsInitial()) {
    on<LoadSummary>(_onLoadSummary);
    on<LoadCategoryDetails>(_onLoadCategoryDetails);
    on<LoadCategoryExpenses>(_onLoadCategoryExpenses);
  }

  Future<void> _onLoadSummary(
    LoadSummary event,
    Emitter<ReportsState> emit,
  ) async {
    try {
      emit(ReportsLoading());
      final summary = await _reportsRepository.getExpenseSummary(
        year: event.year,
        month: event.month,
        day: event.day,
      );
      emit(SummaryLoaded(summary));
    } catch (e) {
      print('Ошибка при загрузке сводки: $e');
      emit(ReportsError(e.toString()));
    }
  }

  Future<void> _onLoadCategoryDetails(
    LoadCategoryDetails event,
    Emitter<ReportsState> emit,
  ) async {
    try {
      emit(ReportsLoading());
      final details = await _reportsRepository.getCategoryDetails(
        year: event.year,
        month: event.month,
        day: event.day,
      );
      emit(CategoryDetailsLoaded(details));
    } catch (e) {
      print('Ошибка при загрузке категорий: $e');
      emit(ReportsError(e.toString()));
    }
  }

  Future<void> _onLoadCategoryExpenses(
    LoadCategoryExpenses event,
    Emitter<ReportsState> emit,
  ) async {
    try {
      emit(ReportsLoading());
      final expenses = await _reportsRepository.getExpensesByCategory(
        event.category,
        page: event.page,
        size: event.size,
      );
      emit(CategoryExpensesLoaded(expenses));
    } catch (e) {
      print('Ошибка при загрузке расходов по категории: $e');
      emit(ReportsError(e.toString()));
    }
  }
} 