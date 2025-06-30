import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/blocs/expense_event.dart';
import 'package:fintrack/blocs/expense_state.dart';
import 'package:fintrack/repositories/expense_repository.dart';
import 'package:fintrack/models/expense.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository repository;
  final Map<DateTime, List<Expense>> _groupedExpenses = {};

  ExpenseBloc(this.repository) : super(ExpenseLoading()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpenseEvent>(_onAddExpense);
    on<UpdateExpenseEvent>(_onUpdateExpense);
    on<DeleteExpenseEvent>(_onDeleteExpense);
  }

  void _groupExpenses(List<Expense> expenses) {
    _groupedExpenses.clear();
    for (var expense in expenses) {
      final date = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      if (!_groupedExpenses.containsKey(date)) {
        _groupedExpenses[date] = [];
      }
      _groupedExpenses[date]!.add(expense);
    }
  }

  Map<DateTime, List<Expense>> get groupedExpenses => _groupedExpenses;

  Future<void> _onLoadExpenses(
    LoadExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseLoading());
      final expenses = await repository.fetchExpenses();
      _groupExpenses(expenses);
      emit(ExpenseLoaded(expenses));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onAddExpense(
    AddExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      final addedExpense = await repository.addExpense(event.expense);
      if (state is ExpenseLoaded) {
        final currentState = state as ExpenseLoaded;
        final updatedExpenses = [...currentState.expenses, addedExpense];
        _groupExpenses(updatedExpenses);
        emit(ExpenseLoaded(updatedExpenses));
      }
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onUpdateExpense(
    UpdateExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      final updatedExpense = await repository.updateExpense(event.expense);
      if (state is ExpenseLoaded) {
        final currentState = state as ExpenseLoaded;
        final updatedExpenses = currentState.expenses.map((expense) {
          return expense.id == updatedExpense.id ? updatedExpense : expense;
        }).toList();
        _groupExpenses(updatedExpenses);
        emit(ExpenseLoaded(updatedExpenses));
      }
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onDeleteExpense(
    DeleteExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      await repository.deleteExpense(event.id);
      if (state is ExpenseLoaded) {
        final currentState = state as ExpenseLoaded;
        final updatedExpenses = currentState.expenses
            .where((expense) => expense.id != event.id)
            .toList();
        _groupExpenses(updatedExpenses);
        emit(ExpenseLoaded(updatedExpenses));
      }
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }
}
