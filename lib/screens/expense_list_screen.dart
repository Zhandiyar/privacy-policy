import 'package:fintrack/blocs/expense_bloc.dart';
import 'package:fintrack/blocs/expense_state.dart';
import 'package:fintrack/models/expense.dart';
import 'package:fintrack/models/expense_category.dart';
import 'package:fintrack/screens/expense_detail_screen.dart';
import 'package:fintrack/screens/expense_form_screen.dart';
import 'package:fintrack/screens/reports_screen.dart';
import 'package:fintrack/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../blocs/currency/currency_bloc.dart';
import '../blocs/currency/currency_state.dart';
import '../blocs/expense_event.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import 'SettingsScreen.dart';
import 'package:fintrack/widgets/guest_banner.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  static const double _kBottomNavHeight = 70.0;
  static const double _kBottomNavPadding = 4.0;
  static const double _kIconSize = 24.0;
  static const double _kLabelFontSize = 11.0;
  static const double _kIconLabelSpacing = 2.0;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await initializeDateFormatting('ru_RU');
    if (mounted) {
      context.read<ExpenseBloc>().add(LoadExpenses());
    }
  }

  void _navigateToAddExpense(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const ExpenseFormScreen(),
    ));
  }

  void _navigateToDetail(BuildContext context, Expense expense) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ExpenseDetailScreen(expense: expense),
    ));
  }

  void _navigateToReports(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ReportsScreen(),
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    return category.icon;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Список расходов',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(LogoutRequested());
              },
            ),
          ],
          elevation: 0,
        ),
        body: BlocBuilder<CurrencyBloc, CurrencyState>(
          builder: (context, currencyState) {
            return BlocBuilder<ExpenseBloc, ExpenseState>(
              builder: (context, state) {
                if (state is ExpenseLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ExpenseLoaded) {
                  return _buildExpenseList(context, state);
                } else if (state is ExpenseError) {
                  return _buildErrorState(context, state);
                }
                return const SizedBox.shrink();
              },
            );
          },
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  Widget _buildExpenseList(BuildContext context, ExpenseLoaded state) {
    final groupedExpenses = context.read<ExpenseBloc>().groupedExpenses;
    final sortedDates = groupedExpenses.keys.toList()..sort((a, b) => b.compareTo(a));

    if (groupedExpenses.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        const GuestBanner(),
        Expanded(
          child: ListView.builder(
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              final dateExpenses = groupedExpenses[date]!;
              final totalAmount = dateExpenses.fold<double>(
                0,
                (sum, expense) => sum + expense.amount,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateHeader(context, date, totalAmount),
                  ...dateExpenses.map((expense) => _buildExpenseCard(context, expense)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateHeader(BuildContext context, DateTime date, double totalAmount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat('d MMMM y', 'ru_RU').format(date),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            CurrencyFormatter.format(totalAmount, context),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(BuildContext context, Expense expense) {
    return Dismissible(
      key: Key(expense.id?.toString() ?? DateTime.now().toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Theme.of(context).colorScheme.error,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 32,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Подтверждение'),
              content: const Text('Вы уверены, что хотите удалить этот расход?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'Удалить',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        if (expense.id != null) {
          context.read<ExpenseBloc>().add(DeleteExpenseEvent(expense.id!));
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: expense.category.color.withOpacity(0.2),
            child: Icon(
              _getCategoryIcon(expense.category),
              color: expense.category.color,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                expense.category.displayName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                CurrencyFormatter.format(expense.amount, context),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('HH:mm').format(expense.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (expense.description != null && expense.description!.isNotEmpty)
                Text(
                  expense.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          onTap: () => _navigateToDetail(context, expense),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Нет расходов',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ExpenseError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Ошибка: ${state.message}',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: _kBottomNavPadding,
      child: SizedBox(
        height: _kBottomNavHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              context,
              icon: Icons.bar_chart,
              label: 'Отчеты',
              onTap: () => _navigateToReports(context),
            ),
            _buildNavItem(
              context,
              icon: Icons.add_circle_outline,
              label: 'Добавить',
              onTap: () => _navigateToAddExpense(context),
            ),
            _buildNavItem(
              context,
              icon: Icons.settings,
              label: 'Настройки',
              onTap: () => _navigateToSettings(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: _kBottomNavPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: _kIconSize,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: _kIconLabelSpacing),
              Text(
                label,
                style: TextStyle(
                  fontSize: _kLabelFontSize,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}