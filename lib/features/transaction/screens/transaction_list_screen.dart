// transaction_list_screen.dart

import 'package:fintrack/features/transaction/screens/transaction_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../blocs/transaction_bloc.dart';
import '../blocs/transaction_event.dart';
import '../blocs/transaction_state.dart';
import '../models/transaction_response.dart';
import '../models/transaction_type.dart';


class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({Key? key}) : super(key: key);

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(const LoadTransactions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Транзакции'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<TransactionBloc>().add(const LoadTransactions()),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TransactionLoaded) {
            final transactions = state.transactions;
            if (transactions.isEmpty) return _buildEmptyState();
            final grouped = _groupByDate(transactions);
            final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

            return ListView.builder(
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                final items = grouped[date]!;
                final total = items.fold<double>(0, (sum, tx) => sum + tx.amount);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateHeader(date, total),
                    ...items.map((tx) => _buildCard(tx)).toList(),
                  ],
                );
              },
            );
          } else if (state is TransactionError) {
            return Center(child: Text('Ошибка: ${state.message}'));
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Map<DateTime, List<TransactionResponseDto>> _groupByDate(List<TransactionResponseDto> list) {
    return list.fold({}, (map, tx) {
      final key = DateTime(tx.date.year, tx.date.month, tx.date.day);
      map[key] = [...(map[key] ?? []), tx];
      return map;
    });
  }

  Widget _buildDateHeader(DateTime date, double total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat('d MMMM y', 'ru').format(date),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            '${total.toStringAsFixed(2)} ₸',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(TransactionResponseDto tx) {
    final isExpense = tx.type == TransactionType.EXPENSE;
    final color = isExpense ? Colors.red : Colors.green;
    final sign = isExpense ? '-' : '+';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(isExpense ? Icons.arrow_downward : Icons.arrow_upward, color: color),
        ),
        title: Text(
          tx.categoryNameRu,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(DateFormat('HH:mm').format(tx.date)),
        trailing: Text(
          '$sign${tx.amount.toStringAsFixed(2)} ₸',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        onTap: () {
          // TODO: Переход к экрану деталей
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('Нет транзакций'),
    );
  }
}
