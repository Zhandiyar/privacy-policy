import 'package:dio/dio.dart';

import '../services/api_expense_client.dart';
import '../services/storage_service.dart';

class SettingsRepository {
  final ApiExpenseClient _apiClient;
  SettingsRepository(this._apiClient);

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final token = await SecureStorage.getToken();

    try {
      await _apiClient.dio.put(
        '/settings/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Ошибка при изменении пароля');
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _apiClient.dio.delete('/settings/delete-account');
      await SecureStorage.removeToken(); // Удаляем токен после удаления аккаунта
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Ошибка при удалении аккаунта');
    }
  }
} 