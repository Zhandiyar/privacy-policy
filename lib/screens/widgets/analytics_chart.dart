import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/analytics_summary.dart';
import '../../models/expense_category.dart';
import '../../utils/currency_formatter.dart';
import '../../blocs/analytics/analytics_state.dart';

const double _kPadding = 16.0;
const double _kSpacing = 8.0;

enum ChartType {
  bar,
  line,
  pie,
}

class AnalyticsChart extends StatefulWidget {
  final List<ChartDataPoint> chartData;
  final PeriodType selectedPeriod;
  final DateTime selectedDate;
  final double totalAmount;
  final List<CategoryExpense> categoryExpenses;

  const AnalyticsChart({
    Key? key,
    required this.chartData,
    required this.selectedPeriod,
    required this.selectedDate,
    required this.totalAmount,
    required this.categoryExpenses,
  }) : super(key: key);

  @override
  State<AnalyticsChart> createState() => _AnalyticsChartState();
}

class _AnalyticsChartState extends State<AnalyticsChart> {
  ChartType _selectedType = ChartType.bar;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
  }

  String _formatLabel(String label) {
    switch (widget.selectedPeriod) {
      case PeriodType.WEEK:
        final weekDays = {
          'monday': 'Пн',
          'tuesday': 'Вт',
          'wednesday': 'Ср',
          'thursday': 'Чт',
          'friday': 'Пт',
          'saturday': 'Сб',
          'sunday': 'Вс',
          'mon': 'Пн',
          'tue': 'Вт',
          'wed': 'Ср',
          'thu': 'Чт',
          'fri': 'Пт',
          'sat': 'Сб',
          'sun': 'Вс',
          'пн': 'Пн',
          'вт': 'Вт',
          'ср': 'Ср',
          'чт': 'Чт',
          'пт': 'Пт',
          'сб': 'Сб',
          'вс': 'Вс',
        };
        return weekDays[label.toLowerCase()] ?? label;
      case PeriodType.MONTH:
        final match = RegExp(r'\d+').firstMatch(label);
        return match?.group(0) ?? label;
      case PeriodType.YEAR:
        final months = {
          'jan': 'Янв',
          'feb': 'Фев',
          'mar': 'Мар',
          'apr': 'Апр',
          'may': 'Май',
          'jun': 'Июн',
          'jul': 'Июл',
          'aug': 'Авг',
          'sep': 'Сен',
          'oct': 'Окт',
          'nov': 'Ноя',
          'dec': 'Дек',
        };
        return months[label.toLowerCase()] ?? label;
    }
  }

  Widget _buildChartTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildChartTypeButton(
            ChartType.bar,
            Icons.bar_chart,
          ),
          const SizedBox(width: 4),
          _buildChartTypeButton(
            ChartType.pie,
            Icons.pie_chart,
          ),
        ],
      ),
    );
  }

  Widget _buildChartTypeButton(ChartType type, IconData icon) {
    final isSelected = _selectedType == type;
    return Material(
      color: isSelected
          ? Theme.of(context).colorScheme.primary
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedType = type;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Icon(
            icon,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    final maxY = (widget.chartData.isEmpty
        ? 1000.0
        : widget.chartData.map((e) => e.amount).reduce((a, b) => a > b ? a : b)).toDouble();

    // Определяем интервал для сетки в зависимости от максимального значения
    double getInterval(double maxValue) {
      if (maxValue >= 1000000000) return 100000000; // 100M для миллиардов
      if (maxValue >= 100000000) return 10000000;   // 10M для сотен миллионов
      if (maxValue >= 10000000) return 1000000;     // 1M для десятков миллионов
      if (maxValue >= 1000000) return 100000;       // 100K для миллионов
      if (maxValue >= 100000) return 10000;         // 10K для сотен тысяч
      if (maxValue >= 10000) return 1000;           // 1K для десятков тысяч
      return 100;                                   // 100 для остальных случаев
    }

    // Форматирование больших чисел с учетом локали
    String formatLargeNumber(double value) {
      if (value >= 1000000000) {
        return '${(value / 1000000000).toStringAsFixed(1)}B ₸';
      } else if (value >= 1000000) {
        final millions = (value / 1000000).toStringAsFixed(1);
        return '$millions млн ₸';
      } else if (value >= 1000) {
        final thousands = (value / 1000).toStringAsFixed(0);
        return '$thousands тыс ₸';
      }
      return '${value.toStringAsFixed(0)} ₸';
    }

    final interval = getInterval(maxY);

    final commonData = FlTitlesData(
      show: true,
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            if (value < 0 || value >= widget.chartData.length) {
              return const SizedBox();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _formatLabel(widget.chartData[value.toInt()].label),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 120,
          interval: interval,
          getTitlesWidget: (value, meta) {
            return Container(
              margin: const EdgeInsets.only(right: 12.0),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                formatLargeNumber(value),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.right,
              ),
            );
          },
        ),
      ),
    );

    if (_selectedType == ChartType.pie) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: PieChart(
              PieChartData(
                sections: widget.categoryExpenses.map((data) {
                  final percent = data.percentage;
                  final category = ExpenseCategory.fromString(data.category);
                  final isTouched = widget.categoryExpenses.indexOf(data) == _touchedIndex;
                  return PieChartSectionData(
                    color: category.color,
                    value: data.amount,
                    title: '${percent.toStringAsFixed(1)}%',
                    radius: isTouched ? 90 : 80,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    badgeWidget: null,
                    showTitle: true,
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      setState(() {
                        _touchedIndex = -1;
                      });
                      return;
                    }
                    setState(() {
                      _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
              ),
            ),
          ),
          if (_touchedIndex != -1 && _touchedIndex < widget.categoryExpenses.length)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        ExpenseCategory.fromString(widget.categoryExpenses[_touchedIndex].category).icon,
                        color: ExpenseCategory.fromString(widget.categoryExpenses[_touchedIndex].category).color,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ExpenseCategory.fromString(widget.categoryExpenses[_touchedIndex].category).displayName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(widget.categoryExpenses[_touchedIndex].amount, context),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: ExpenseCategory.fromString(widget.categoryExpenses[_touchedIndex].category).color,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      );
    } else if (_selectedType == ChartType.bar) {
      return BarChart(
        BarChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context).colorScheme.outlineVariant,
                strokeWidth: 0.5,
                dashArray: [5, 5],
              );
            },
          ),
          titlesData: commonData,
          borderData: FlBorderData(show: false),
          barGroups: widget.chartData.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: data.amount.toDouble(),
                  width: 24,
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.zero,
                ),
              ],
            );
          }).toList(),
          maxY: maxY * 1.1, // Добавляем 10% сверху для лучшего отображения
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
                final data = widget.chartData[groupIndex];
                return BarTooltipItem(
                  '${data.label}\n${CurrencyFormatter.format(data.amount, context)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
      );
    } else {
      return LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1000,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context).colorScheme.outlineVariant,
                strokeWidth: 0.5,
                dashArray: [5, 5],
              );
            },
          ),
          titlesData: commonData,
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: widget.chartData.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.amount.toDouble());
              }).toList(),
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
            ),
          ],
          maxY: maxY,
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipRoundedRadius: 8,
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              tooltipBorder: BorderSide(color: Colors.black87),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final data = widget.chartData[spot.x.toInt()];
                  return LineTooltipItem(
                    '${data.label}\n${CurrencyFormatter.format(data.amount, context)}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(_kPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _selectedType == ChartType.pie 
                          ? Icons.pie_chart 
                          : Icons.calendar_today_outlined,
                      size: 20
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Всего: ${CurrencyFormatter.format(widget.totalAmount, context)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (_selectedType != ChartType.pie) Text(
                  widget.selectedDate.year.toString(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: _kSpacing),
            Center(child: _buildChartTypeSelector()),
            const SizedBox(height: _kSpacing * 2),
            SizedBox(
              height: 300,
              child: _buildChart(),
            ),
          ],
        ),
      ),
    );
  }
} 