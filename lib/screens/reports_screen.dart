import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../blocs/analytics/analytics_bloc.dart';
import '../blocs/analytics/analytics_event.dart';
import '../blocs/analytics/analytics_state.dart';
import '../models/analytics_summary.dart';
import '../models/category_expense_details.dart';
import '../models/expense_category.dart';
import '../utils/currency_formatter.dart';
import 'package:intl/intl.dart';

import 'category_expenses_screen.dart';
import 'widgets/period_selector.dart';
import 'widgets/date_selector.dart';
import 'widgets/average_expense_card.dart';
import 'widgets/category_expenses_list.dart';
import 'widgets/analytics_chart.dart';

const double _kPadding = 16.0;
const double _kSpacing = 8.0;
const int _kStartYear = 2020;
const int _kEndYear = 2025;

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime selectedDate = DateTime.now();
  PeriodType selectedPeriod = PeriodType.MONTH;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<AnalyticsBloc>().add(LoadAnalyticsSummary(
      periodType: selectedPeriod,
      year: selectedDate.year,
      month: selectedPeriod != PeriodType.YEAR ? selectedDate.month : null,
      day: selectedPeriod == PeriodType.WEEK ? selectedDate.day : null,
    ));
  }

  void _onPeriodChanged(PeriodType type) {
    setState(() {
      selectedPeriod = type;
      _loadData();
    });
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      selectedDate = date;
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Отчеты по расходам'),
      ),
      body: Column(
        children: [
          PeriodSelector(
            selectedPeriod: selectedPeriod,
            onPeriodChanged: _onPeriodChanged,
          ),
          DateSelector(
            selectedDate: selectedDate,
            selectedPeriod: selectedPeriod,
            startYear: _kStartYear,
            endYear: _kEndYear,
            onDateChanged: _onDateChanged,
          ),
          Expanded(
            child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
              builder: (context, state) {
                if (state is AnalyticsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AnalyticsSummaryLoaded) {
                  return _buildContent(state.summary);
                }

                if (state is AnalyticsError) {
                  return _buildError(state.message);
                }

                return const Center(
                  child: Text('Выберите период для просмотра отчета'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: _kSpacing),
          Text(
            'Произошла ошибка',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: _kSpacing),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: _kSpacing * 2),
          FilledButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Повторить'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AnalyticsSummary summary) {
    if (summary.categoryExpenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: _kSpacing),
            Text(
              'Нет данных за выбранный период',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(_kPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AverageExpenseCard(summary: summary),
          const SizedBox(height: _kSpacing * 2),
          CategoryExpensesList(
            expenses: summary.categoryExpenses,
            onCategorySelected: (category, amount) {
              _onCategorySelected(category, amount);
            },
          ),
          const SizedBox(height: _kSpacing * 2),
          if (summary.chartData.isNotEmpty)
            AnalyticsChart(
              chartData: summary.chartData,
              selectedPeriod: selectedPeriod,
              selectedDate: selectedDate,
              totalAmount: summary.totalAmount,
              categoryExpenses: summary.categoryExpenses,
            ),
        ],
      ),
    );
  }

  void _onCategorySelected(ExpenseCategory category, double amount) {
    context.read<AnalyticsBloc>().add(LoadCategoryExpenses(
      category: category,
      page: 0,
      size: 20,
    ));

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryExpensesScreen(
          category: category,
          totalAmount: amount,
        ),
      ),
    ).then((_) {
      _loadData();
    });
  }
} 