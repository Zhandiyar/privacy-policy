import 'package:dio/dio.dart';
import '../models/expense_summary.dart';
import '../models/category_expense_details.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../services/api_expense_client.dart';
import '../services/storage_service.dart';

class ReportsRepository {
  final ApiExpenseClient _apiClient;

  ReportsRepository(this._apiClient);

  Future<ExpenseSummary> getExpenseSummary({
    required int year,
    required int month,
    required int day,
  }) async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      throw Exception('Отсутствует токен авторизации');
    }

    try {
      final url = '/expenses/summary?year=$year&month=$month&day=$day';
      print('Запрос сводки расходов: $url');
      
      final response = await _apiClient.dio.get(
        url,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      print('Ответ сервера (сводка): ${response.data}');
      return ExpenseSummary.fromJson(response.data);
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
    required int year,
    required int month,
    required int day,
  }) async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      throw Exception('Отсутствует токен авторизации');
    }

    try {
      final url = '/expenses/summary/categories?year=$year&month=$month&day=$day';
      print('Запрос деталей по категориям: $url');
      
      final response = await _apiClient.dio.get(
        url,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      print('Ответ сервера (категории): ${response.data}');
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

  Future<List<Expense>> getExpensesByCategory(
    ExpenseCategory category, {
    int page = 0,
    int size = 10,
  }) async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      throw Exception('Отсутствует токен авторизации');
    }

    try {
      final response = await _apiClient.dio.get(
        '/expenses/category',
        queryParameters: {
          'category': category.name,
          'page': page,
          'size': size,
        },
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
      rethrow;
    }
  }
} 