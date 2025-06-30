import 'package:flutter/material.dart';
import '../../models/analytics_summary.dart';
import '../../models/expense_category.dart';
import '../../utils/currency_formatter.dart';

const double _kPadding = 16.0;
const double _kSpacing = 8.0;

class CategoryExpensesList extends StatelessWidget {
  final List<CategoryExpense> expenses;
  final Function(ExpenseCategory, double) onCategorySelected;

  const CategoryExpensesList({
    Key? key,
    required this.expenses,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: _kPadding),
      child: Column(
        children: [
          ListTile(
            title: Text(
              'Все расходы',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: Text(
              CurrencyFormatter.format(
                expenses.fold(0.0, (sum, e) => sum + e.amount),
                context,
              ),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(),
          ...expenses.map((category) {
            final expenseCategory = ExpenseCategory.fromString(category.category);
            return InkWell(
              onTap: () => onCategorySelected(expenseCategory, category.amount),
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
    );
  }
} 