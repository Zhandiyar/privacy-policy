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

const double _kPadding = 16.0;
const double _kSpacing = 8.0;

class CategoryChartScreen extends StatefulWidget {
  final AnalyticsSummary summary;
  final DateTime selectedDate;
  final PeriodType selectedPeriod;

  const CategoryChartScreen({
    Key? key,
    required this.summary,
    required this.selectedDate,
    required this.selectedPeriod,
  }) : super(key: key);

  @override
  State<CategoryChartScreen> createState() => _CategoryChartScreenState();
}

class _CategoryChartScreenState extends State<CategoryChartScreen> {
  late DateTime selectedDate;
  late PeriodType selectedPeriod;
  int? touchedIndex;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
    selectedPeriod = widget.selectedPeriod;
    _loadData();
  }

  void _loadData() {
    context.read<AnalyticsBloc>().add(LoadCategoryDetails(
      year: selectedDate.year,
      month: selectedPeriod != PeriodType.YEAR ? selectedDate.month : null,
      periodType: selectedPeriod,
    ));
  }

  void _onPeriodChanged(PeriodType type) {
    setState(() {
      selectedPeriod = type;
      _loadData();
    });
  }

  void _onCategoryTapped(CategoryExpenseDetails category) {
    final expenseCategory = ExpenseCategory.fromString(category.category);

    context.read<AnalyticsBloc>().add(LoadCategoryExpenses(
      category: expenseCategory,
      page: 0,
      size: 20,
    ));

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryExpensesScreen(
          category: expenseCategory,
          totalAmount: category.amount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Расходы по категориям'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(_kPadding),
            child: Padding(
              padding: const EdgeInsets.all(_kPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPeriodButton(PeriodType.WEEK, 'Неделя'),
                  _buildPeriodButton(PeriodType.MONTH, 'Месяц'),
                  _buildPeriodButton(PeriodType.YEAR, 'Год'),
                ],
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
              builder: (context, state) {
                if (state is AnalyticsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is CategoryDetailsLoaded) {
                  return _buildContent(state.details);
                }

                if (state is AnalyticsError) {
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
                          state.message,
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

                return _buildContent(widget.summary.categoryExpenses);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(PeriodType type, String label) {
    final isSelected = selectedPeriod == type;
    return FilledButton(
      onPressed: () => _onPeriodChanged(type),
      style: FilledButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceVariant,
        foregroundColor: isSelected
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      child: Text(label),
    );
  }

  Widget _buildContent(List<dynamic> expenses) {
    final List<CategoryExpenseDetails> categoryExpenses;
    if (expenses[0] is CategoryExpenseDetails) {
      categoryExpenses = expenses.cast<CategoryExpenseDetails>();
    } else {
      categoryExpenses = expenses.map((e) => CategoryExpenseDetails(
        category: e.category,
        amount: e.amount,
        percentage: e.percentage,
        lastTransactions: [],
      )).toList();
    }

    if (categoryExpenses.isEmpty) {
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

    // Находим максимальную сумму для масштабирования графика
    final maxAmount = categoryExpenses.fold<double>(
      0,
      (max, category) => category.amount > max ? category.amount : max,
    );

    // Функция для форматирования больших чисел
    String formatLargeNumber(double value) {
      if (value >= 1000000000) {
        return '${(value / 1000000000).toStringAsFixed(1)}B';
      } else if (value >= 1000000) {
        return '${(value / 1000000).toStringAsFixed(1)}M';
      } else if (value >= 1000) {
        return '${(value / 1000).toStringAsFixed(1)}K';
      }
      return value.toStringAsFixed(1);
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(_kPadding),
            child: Padding(
              padding: const EdgeInsets.all(_kPadding),
              child: SizedBox(
                height: 300,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxAmount,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipRoundedRadius: 8,
                        tooltipPadding: const EdgeInsets.all(8),
                        tooltipMargin: 8,
                        fitInsideHorizontally: true,
                        fitInsideVertically: true,
                        tooltipBorder: BorderSide(color: Colors.black87),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final category = categoryExpenses[groupIndex];
                          return BarTooltipItem(
                            CurrencyFormatter.format(category.amount, context),
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value < 0 || value >= categoryExpenses.length) {
                              return const SizedBox();
                            }
                            final category = categoryExpenses[value.toInt()];
                            final expenseCategory = ExpenseCategory.fromString(category.category);
                            return Icon(
                              expenseCategory.icon,
                              color: expenseCategory.color,
                              size: 24,
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              formatLargeNumber(value),
                              style: Theme.of(context).textTheme.bodySmall,
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true,
                      horizontalInterval: maxAmount / 5,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        );
                      },
                    ),
                    barGroups: categoryExpenses.asMap().entries.map((entry) {
                      final index = entry.key;
                      final category = entry.value;
                      final expenseCategory = ExpenseCategory.fromString(category.category);
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: category.amount,
                            color: expenseCategory.color,
                            width: 16,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: _kSpacing),
          Card(
            margin: const EdgeInsets.all(_kPadding),
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    'Все расходы',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  trailing: Text(
                    CurrencyFormatter.format(
                      categoryExpenses.fold<double>(
                        0,
                        (sum, category) => sum + category.amount,
                      ),
                      context,
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                ...categoryExpenses.map((category) {
                  final expenseCategory = ExpenseCategory.fromString(category.category);
                  return InkWell(
                    onTap: () => _onCategoryTapped(category),
                    child: Padding(
                      padding: const EdgeInsets.all(_kPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                expenseCategory.icon,
                                color: expenseCategory.color,
                                size: 24,
                              ),
                              const SizedBox(width: _kSpacing),
                              Expanded(
                                child: Text(
                                  expenseCategory.displayName,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              Text(
                                CurrencyFormatter.format(category.amount, context),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: _kSpacing),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: category.percentage / 100,
                              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                              valueColor: AlwaysStoppedAnimation<Color>(expenseCategory.color),
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 