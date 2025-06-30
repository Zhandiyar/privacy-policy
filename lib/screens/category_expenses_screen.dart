import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/analytics/analytics_bloc.dart';
import '../blocs/analytics/analytics_event.dart';
import '../blocs/analytics/analytics_state.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../utils/currency_formatter.dart';
import 'package:intl/intl.dart';
import 'expense_form_screen.dart';

class CategoryExpensesScreen extends StatefulWidget {
  final ExpenseCategory category;
  final double totalAmount;

  const CategoryExpensesScreen({
    Key? key,
    required this.category,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<CategoryExpensesScreen> createState() => _CategoryExpensesScreenState();
}

class _CategoryExpensesScreenState extends State<CategoryExpensesScreen> {
  static const int _pageSize = 20;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMoreData = true;
  List<Expense> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasMoreData) {
        _loadData();
      }
    }
  }

  Future<void> _loadData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final expenses = await context.read<AnalyticsBloc>().repository.getCategoryExpenses(
        category: widget.category,
        page: _currentPage,
        size: _pageSize,
      );

      setState(() {
        _expenses.addAll(expenses);
        _currentPage++;
        _hasMoreData = expenses.length == _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при загрузке данных: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _navigateToEdit(BuildContext context, Expense expense) async {
    final result = await Navigator.of(context).push<Expense>(
      MaterialPageRoute(
        builder: (_) => ExpenseFormScreen(expense: expense),
      ),
    );

    if (result != null) {
      setState(() {
        final index = _expenses.indexWhere((e) => e.id == result.id);
        if (index != -1) {
          _expenses[index] = result;
        }
      });
      _loadData(); // Перезагружаем данные, чтобы обновить список
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: widget.category.color.withOpacity(0.2),
              child: Icon(
                widget.category.icon,
                color: widget.category.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.category.displayName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  CurrencyFormatter.format(widget.totalAmount, context),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: _expenses.isEmpty && !_isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.category.icon,
                    size: 48,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Нет расходов в этой категории',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _expenses.length + (_hasMoreData ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _expenses.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final expense = _expenses[index];
                return Card(
                  child: ListTile(
                    title: Text(
                      expense.description ?? 'Без описания',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      DateFormat('d MMMM y, HH:mm', 'ru').format(expense.date),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: Text(
                      CurrencyFormatter.format(expense.amount, context),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => _navigateToEdit(context, expense),
                  ),
                );
              },
            ),
    );
  }
} 