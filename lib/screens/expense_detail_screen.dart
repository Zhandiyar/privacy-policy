import 'package:fintrack/models/expense.dart';
import 'package:fintrack/models/expense_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/blocs/expense_bloc.dart';
import 'package:fintrack/blocs/expense_event.dart';
import 'package:fintrack/screens/expense_form_screen.dart';
import 'package:fintrack/utils/currency_formatter.dart';
import 'package:intl/intl.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final Expense expense;

  const ExpenseDetailScreen({Key? key, required this.expense}) : super(key: key);

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  late Expense expense;

  @override
  void initState() {
    super.initState();
    expense = widget.expense;
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    return category.icon;
  }

  void _navigateToEdit(BuildContext context) async {
    final updatedExpense = await Navigator.of(context).push<Expense>(
      MaterialPageRoute(
        builder: (_) => ExpenseFormScreen(expense: expense),
      ),
    );

    if (updatedExpense != null) {
      setState(() => expense = updatedExpense);
      context.read<ExpenseBloc>().add(UpdateExpenseEvent(updatedExpense));
    }
  }

  void _deleteExpense(BuildContext context) {
    if (expense.id != null) {
      context.read<ExpenseBloc>().add(DeleteExpenseEvent(expense.id!));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Расход'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteExpense(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: expense.category.color.withOpacity(0.2),
                            child: Icon(
                              _getCategoryIcon(expense.category),
                              color: expense.category.color,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  expense.category.displayName,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  CurrencyFormatter.format(expense.amount, context),
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      _buildDetailRow(
                        context,
                        'Дата',
                        DateFormat('d MMMM y', 'ru_RU').format(expense.date),
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        context,
                        'Время',
                        DateFormat('HH:mm').format(expense.date),
                      ),
                      if (expense.description?.isNotEmpty ?? false) ...[
                        const Divider(height: 32),
                        Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Описание',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            expense.description!,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToEdit(context),
                  icon: const Icon(Icons.edit),
                  label: const Text('Редактировать'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
