import 'package:dio/dio.dart';
import 'package:fintrack/models/expense.dart';
import 'package:fintrack/services/api_client.dart';

import '../services/api_expense_client.dart';
import '../services/storage_service.dart';

class ExpenseRepository {
  final ApiExpenseClient _apiClient;
  ExpenseRepository(this._apiClient);

  Future<List<Expense>> fetchExpenses() async {
    final token = await SecureStorage.getToken();

    try {
      final response = await _apiClient.dio.get(
          '/expenses',
          options: Options(headers: {"Authorization": "Bearer $token"}),
    );
      print('Получен список расходов: ${response.data}');
      final data = response.data as List;
      return data.map((json) => Expense.fromJson(json)).toList();
    } on DioException catch (e) {
      print("Ошибка запроса: ${e.response?.data}");
      throw Exception("Ошибка: ${e.response?.statusCode} - ${e.response?.data}");
    }
  }

  Future<Expense> getExpenseById(int id) async {
    final token = await SecureStorage.getToken();
    try {
      final response = await _apiClient.dio.get(
        '/expenses/$id',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      return Expense.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Expense> addExpense(Expense expense) async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      throw Exception('Отсутствует токен авторизации');
    }

    try {
      final expenseJson = expense.toJson();
      expenseJson.remove('id'); // Удаляем id при создании

      print('DEBUG: Данные для создания:');
      print('- Token: ${token.substring(0, 10)}...'); // Показываем только начало токена
      print('- Category: ${expense.category.name}');
      print('- Amount: ${expense.amount}');
      print('- Date: ${expense.date}');
      print('- Description: ${expense.description}');
      print('JSON для отправки: $expenseJson');
      
      final response = await _apiClient.dio.post(
        '/expenses',
        data: expenseJson,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json; charset=UTF-8",
            "Accept": "application/json",
          },
        ),
      );
      
      print('Ответ сервера: ${response.data}');
      
      // Проверяем только наличие ответа
      if (response.data == null) {
        print('Ошибка: Сервер вернул null');
        throw Exception('Ошибка создания расхода: сервер не вернул данные');
      }

      // Получаем список расходов, чтобы найти только что созданный
      final expenses = await fetchExpenses();
      final latestExpense = expenses.lastWhere(
        (e) => e.amount == expense.amount && 
               e.category == expense.category && 
               e.description == expense.description,
        orElse: () => Expense.fromJson(response.data),
      );

      print('Создан расход с ID: ${latestExpense.id}');
      return latestExpense;
    } catch (e) {
      if (e is DioException) {
        print('Ошибка DIO при создании:');
        print('- Status code: ${e.response?.statusCode}');
        print('- Response data: ${e.response?.data}');
        print('- Request data: ${e.requestOptions.data}');
        print('- Headers: ${e.requestOptions.headers}');
      }
      print('Ошибка при сохранении расхода: $e');
      rethrow;
    }
  }

  Future<Expense> updateExpense(Expense expense) async {
    if (expense.id == null) {
      throw Exception('Невозможно обновить расход без ID');
    }

    final token = await SecureStorage.getToken();
    if (token == null) {
      throw Exception('Отсутствует токен авторизации');
    }

    try {
      final expenseJson = expense.toJson();
      
      print('DEBUG: Данные для обновления:');
      print('- Token: ${token.substring(0, 10)}...'); // Показываем только начало токена
      print('- ID: ${expense.id}');
      print('- Category: ${expense.category.name}');
      print('- Amount: ${expense.amount}');
      print('- Date: ${expense.date}');
      print('- Description: ${expense.description}');
      print('JSON для отправки: $expenseJson');
      
      final response = await _apiClient.dio.put(
        '/expenses',
        data: expenseJson,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json; charset=UTF-8",
            "Accept": "application/json",
          },
        ),
      );
      
      print('Ответ сервера: ${response.data}');
      
      // Проверяем только наличие ответа
      if (response.data == null) {
        print('Ошибка: Сервер вернул null');
        throw Exception('Ошибка обновления расхода: сервер не вернул данные');
      }

      final updatedExpense = Expense.fromJson(response.data);
      print('Обновлен расход: ${response.data}');
      return updatedExpense;
    } catch (e) {
      if (e is DioException) {
        print('Ошибка DIO при обновлении:');
        print('- Status code: ${e.response?.statusCode}');
        print('- Response data: ${e.response?.data}');
        print('- Request data: ${e.requestOptions.data}');
        print('- Headers: ${e.requestOptions.headers}');
      }
      print('Ошибка при обновлении расхода: $e');
      rethrow;
    }
  }

  Future<void> deleteExpense(int id) async {
    final token = await SecureStorage.getToken();
    try {
      await _apiClient.dio.delete(
        '/expenses/$id',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
    } catch (e) {
      rethrow;
    }
  }
}