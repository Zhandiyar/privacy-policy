import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_event.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../transaction/models/localized_transaction_response.dart';
import '../blocs/dashboard_bloc.dart';
import '../blocs/dashboard_event.dart';
import '../blocs/dashboard_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedYear = DateTime.now().year;
  int? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<DashboardBloc>().add(
      LoadDashboard(year: _selectedYear, month: _selectedMonth),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOut) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          elevation: 0.5,
          title: const Text(
            'Fintrack',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
            ),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButton<int>(
                            value: _selectedYear,
                            isExpanded: true,
                            onChanged: (value) {
                              setState(() => _selectedYear = value!);
                              _loadData();
                            },
                            items: [2023, 2024, 2025]
                                .map((year) => DropdownMenuItem(
                              value: year,
                              child: Text('$year'),
                            ))
                                .toList(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButton<int?>(
                            value: _selectedMonth,
                            isExpanded: true,
                            hint: const Text('Месяц'),
                            onChanged: (value) {
                              setState(() => _selectedMonth = value);
                              _loadData();
                            },
                            items: List.generate(12, (index) => index + 1)
                                .map((month) => DropdownMenuItem(
                              value: month,
                              child: Text(DateFormat.MMMM('ru').format(DateTime(0, month))),
                            ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: switch (state) {
                      DashboardLoading() => const Center(
                          child: CircularProgressIndicator()),
                      DashboardLoaded(:final data) => RefreshIndicator(
                        onRefresh: () async => _loadData(),
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          children: [
                            _BalanceCard(
                              balance: data.balance,
                              income: data.totalIncome,
                              expense: data.totalExpense,
                            ),
                            const SizedBox(height: 20),
                            _PeriodSummary(data: data),
                            const SizedBox(height: 24),
                            _RecentTransactions(
                              transactions: data.recentTransactions,
                            ),
                          ],
                        ),
                      ),
                      DashboardError(:final message) =>
                          Center(child: Text(message)),
                      _ => const SizedBox.shrink(),
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expense;

  const _BalanceCard({
    required this.balance,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined,
                    size: 30, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  '₸${_format(balance)}',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MiniSummary(label: 'Доходы', value: income, color: Colors.green),
                _MiniSummary(label: 'Расходы', value: expense, color: Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniSummary extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MiniSummary({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        Text(
          '₸${_format(value)}',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _PeriodSummary extends StatelessWidget {
  final dynamic data;

  const _PeriodSummary({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 18),
            const SizedBox(width: 8),
            Text(data.periodLabel,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ChangeColumn(
                  amount: '+₸${_format(data.currentPeriodIncome)}',
                  percent: '▼${data.incomeChange.toStringAsFixed(1)}%',
                  label: 'Доходы',
                  color: Colors.green,
                ),
                _ChangeColumn(
                  amount: '-₸${_format(data.currentPeriodExpense)}',
                  percent: '▲${data.expenseChange.toStringAsFixed(1)}%',
                  label: 'Расходы',
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChangeColumn extends StatelessWidget {
  final String amount;
  final String percent;
  final String label;
  final Color color;

  const _ChangeColumn({
    required this.amount,
    required this.percent,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(amount,
            style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        const SizedBox(height: 4),
        Text(percent,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  final List<LocalizedTransactionResponseDto> transactions;

  const _RecentTransactions({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history, size: 20),
            const SizedBox(width: 8),
            Text('Последние транзакции',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        if (transactions.isEmpty)
          const Text('Нет транзакций за этот период',
              style: TextStyle(color: Colors.grey)),
        ...transactions.map((tx) => Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Icon(
              tx.type.name == 'EXPENSE'
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: tx.type.name == 'EXPENSE'
                  ? Colors.red
                  : Colors.green,
            ),
            title: Text(tx.categoryName),
            subtitle: Text(DateFormat('d MMM', 'ru').format(tx.date)),
            trailing: Text(
              '${tx.type.name == 'EXPENSE' ? '-' : '+'}₸${_format(tx.amount)}',
              style: TextStyle(
                color: tx.type.name == 'EXPENSE'
                    ? Colors.red
                    : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.pushNamed(context, '/transactions'),
            child: const Text('Посмотреть все ➔'),
          ),
        )
      ],
    );
  }
}

String _format(double value) => NumberFormat('#,##0', 'ru').format(value);
