import 'package:flutter/material.dart';
import '../../models/analytics_summary.dart';
import '../../utils/currency_formatter.dart';

const double _kPadding = 16.0;
const double _kSpacing = 8.0;

class AverageExpenseCard extends StatelessWidget {
  final AnalyticsSummary summary;

  const AverageExpenseCard({
    Key? key,
    required this.summary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(_kPadding),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.trending_up,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: _kSpacing * 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Средний расход',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    summary.averageLabel,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Text(
              CurrencyFormatter.format(summary.average, context),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 