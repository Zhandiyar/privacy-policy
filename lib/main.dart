import 'package:fintrack/features/category/blocs/category_event.dart';
import 'package:fintrack/features/transaction/repository/transaction_repository.dart';
import 'package:fintrack/features/transaction/screens/transaction_form_screen.dart';
import 'package:fintrack/ui/scaffolds/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'features/category/blocs/category_bloc.dart';
import 'features/category/repository/category_repository.dart';
import 'features/dashboard/blocs/dashboard_bloc.dart';
import 'features/dashboard/blocs/dashboard_event.dart';
import 'features/dashboard/repository/dashboard_repository.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/transaction/blocs/transaction_bloc.dart';
import 'features/transaction/blocs/transaction_event.dart';
import 'features/transaction/screens/transaction_list_screen.dart';
import 'services/deep_link_service.dart';
import 'services/api_client.dart';
import 'services/api_expense_client.dart';

import 'repositories/auth_repository.dart';
import 'repositories/expense_repository.dart';
import 'repositories/settings_repository.dart';
import 'repositories/analytics_repository.dart';
import 'repositories/reports_repository.dart';

import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/expense_bloc.dart';
import 'blocs/expense_event.dart';
import 'blocs/theme/theme_bloc.dart';
import 'blocs/theme/theme_state.dart';
import 'blocs/currency/currency_bloc.dart';
import 'blocs/settings/settings_bloc.dart';
import 'blocs/analytics/analytics_bloc.dart';
import 'blocs/reports/reports_bloc.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/expense_list_screen.dart';
import 'screens/reports_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru_RU', null);

  final prefs = await SharedPreferences.getInstance();
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'jwt_token');

  runApp(FinTrackApp(
    prefs: prefs,
    isAuthenticated: token != null,
  ));
}

class FinTrackApp extends StatefulWidget {
  final SharedPreferences prefs;
  final bool isAuthenticated;

  const FinTrackApp({
    Key? key,
    required this.prefs,
    required this.isAuthenticated,
  }) : super(key: key);

  @override
  State<FinTrackApp> createState() => _FinTrackAppState();
}

class _FinTrackAppState extends State<FinTrackApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final DeepLinkService _deepLinkService;

  @override
  void initState() {
    super.initState();
    _deepLinkService = DeepLinkService(navigatorKey: _navigatorKey);
  }

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();
    final apiExpenseClient = ApiExpenseClient();

    final authRepository = AuthRepository(apiClient);
    final transactionRepository = TransactionRepository(apiClient);
    final categoryRepository = CategoryRepository(apiClient);
    final dashboardRepository = DashboardRepository(apiClient);
    final expenseRepository = ExpenseRepository(apiExpenseClient);
    final settingsRepository = SettingsRepository(apiExpenseClient);
    final analyticsRepository = AnalyticsRepository(apiExpenseClient);
    final reportsRepository = ReportsRepository(apiExpenseClient);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(authRepository: authRepository)..add(AppStarted())),
        BlocProvider(create: (_) => ExpenseBloc(expenseRepository)..add(LoadExpenses())),
        BlocProvider(create: (_) => TransactionBloc(transactionRepository)..add(LoadTransactions())),
        BlocProvider(create: (_) => CategoryBloc(categoryRepository)),
        BlocProvider(create: (_) => DashboardBloc(dashboardRepository)..add(LoadDashboard()),),
        BlocProvider(create: (_) => SettingsBloc(settingsRepository)),
        BlocProvider(create: (_) => AnalyticsBloc(analyticsRepository)),
        BlocProvider(create: (_) => ReportsBloc(reportsRepository: reportsRepository)),
        BlocProvider(create: (_) => ThemeBloc(widget.prefs)),
        BlocProvider(create: (_) => CurrencyBloc(widget.prefs)),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            navigatorKey: _navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'FinTrack',
            theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.light),
            darkTheme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
            themeMode: themeState.themeMode,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('ru')],
            locale: const Locale('ru'),
            initialRoute: widget.isAuthenticated ? '/main' : '/login',
            onGenerateInitialRoutes: (String initialRouteName) {
              return [
                MaterialPageRoute(
                  builder: (context) =>
                  widget.isAuthenticated ? MainScaffold() : LoginScreen(),
                ),
              ];
            },
            routes: {
              '/login': (context) => LoginScreen(),
              '/register': (context) => RegisterScreen(),
              '/forgot-password': (context) => ForgotPasswordScreen(),
              '/reset-password': (context) => ResetPasswordScreen(),
              '/expenses': (context) => ExpenseListScreen(),
              '/transactions': (context) => TransactionListScreen(),
              '/reports': (context) => ReportsScreen(),
              '/dashboard': (context) =>  DashboardScreen(),
              '/main': (context) => const MainScaffold(),
            },
          );
        },
      ),
    );
  }
}
