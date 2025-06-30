import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/analytics_repository.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepository repository;

  AnalyticsBloc(this.repository) : super(AnalyticsInitial()) {
    on<LoadAnalyticsSummary>(_onLoadAnalyticsSummary);
    on<LoadCategoryDetails>(_onLoadCategoryDetails);
    on<LoadCategoryExpenses>(_onLoadCategoryExpenses);
  }

  Future<void> _onLoadAnalyticsSummary(
    LoadAnalyticsSummary event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      emit(AnalyticsLoading());
      
      final summary = await repository.getSummary(
        periodType: event.periodType,
        year: event.year,
        month: event.month,
        day: event.day,
      );
      
      emit(AnalyticsSummaryLoaded(
        summary: summary,
        periodType: event.periodType,
      ));
    } catch (e) {
      print('Ошибка при загрузке аналитики: $e');
      emit(AnalyticsError(e.toString()));
    }
  }

  Future<void> _onLoadCategoryDetails(
    LoadCategoryDetails event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      emit(AnalyticsLoading());
      final details = await repository.getCategoryDetails(
        periodType: event.periodType,
        year: event.year,
        month: event.month,
      );
      emit(CategoryDetailsLoaded(details));
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }

  Future<void> _onLoadCategoryExpenses(
    LoadCategoryExpenses event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      emit(AnalyticsLoading());
      final expenses = await repository.getCategoryExpenses(
        category: event.category,
        page: event.page,
        size: event.size,
      );
      emit(CategoryExpensesLoaded(expenses));
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }
} 