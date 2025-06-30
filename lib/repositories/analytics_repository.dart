import 'package:dio/dio.dart';
import 'package:fintrack/services/api_expense_client.dart';
import '../services/api_client.dart';
import '../models/analytics_summary.dart';
import '../models/category_expense_details.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../services/storage_service.dart';

class AnalyticsRepository {
  final ApiExpenseClient _apiClient;

  AnalyticsRepository(this._apiClient);

  Future<AnalyticsSummary> getSummary({
    required PeriodType periodType,
    required int year,
    int? month,
    int? day,
  }) async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      throw Exception('Отсутствует токен авторизации');
    }

    try {
      final queryParams = {
        'periodType': periodType.name,
        'year': year.toString(),
        if (month != null) 'month': month.toString(),
        if (day != null) 'day': day.toString(),
      };

      final response = await _apiClient.dio.get(
        '/expenses/analytics/summary',
        queryParameters: queryParams,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      return AnalyticsSummary.fromJson(response.data);
    } catch (e) {
      print('Ошибка при получении сводки: $e');
      if (e is DioException) {
        print('Статус код: ${e.response?.statusCode}');
        print('Данные ответа: ${e.response?.data}');
      }
      rethrow;
    }
  }

  Future<List<CategoryExpenseDetails>> getCategoryDetails({
    required PeriodType periodType,
    required int year,
    int? month,
    int? day,
  }) async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      throw Exception('Отсутствует токен авторизации');
    }

    try {
      final queryParams = {
        'periodType': periodType.name,
        'year': year.toString(),
        if (month != null) 'month': month.toString(),
        if (day != null) 'day': day.toString(),
      };

      final response = await _apiClient.dio.get(
        '/expenses/analytics/summary/categories',
        queryParameters: queryParams,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => CategoryExpenseDetails.fromJson(json)).toList();
    } catch (e) {
      print('Ошибка при получении деталей по категориям: $e');
      if (e is DioException) {
        print('Статус код: ${e.response?.statusCode}');
        print('Данные ответа: ${e.response?.data}');
      }
      rethrow;
    }
  }

  Future<List<Expense>> getCategoryExpenses({
    required ExpenseCategory category,
    int page = 0,
    int size = 20,
  }) async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      throw Exception('Отсутствует токен авторизации');
    }

    try {
      final queryParams = {
        'category': category.name,
        'page': page.toString(),
        'size': size.toString(),
      };

      final response = await _apiClient.dio.get(
        '/expenses/analytics/category',
        queryParameters: queryParams,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => Expense.fromJson(json)).toList();
    } catch (e) {
      print('Ошибка при получении расходов по категории: $e');
      if (e is DioException) {
        print('Статус код: ${e.response?.statusCode}');
        print('Данные ответа: ${e.response?.data}');
      }
      rethrow;
    }
  }
} 