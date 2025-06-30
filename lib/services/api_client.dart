import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  ApiClient({Dio? dio, FlutterSecureStorage? secureStorage})
      : dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://api.fin-track.pro',
              validateStatus: (status) => status != null && status < 500,
            )),
        secureStorage = secureStorage ?? const FlutterSecureStorage() {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await secureStorage.read(key: 'jwt_token');
        final isGuest = await secureStorage.read(key: 'is_guest') == 'true';
        debugPrint("📤 Отправка запроса: ${options.method} ${options.path}");
        debugPrint("📤 Данные запроса: ${options.data}");
        debugPrint("⚡ Отправляемый токен: $token");
        debugPrint("👤 Статус гостя: $isGuest");

        if (!options.headers.containsKey('Accept')) {
          options.headers['Accept'] = 'application/json';
        }
        if (!options.headers.containsKey('Content-Type')) {
          options.headers['Content-Type'] = 'application/json';
        }

        if (token != null && !options.headers.containsKey('Authorization')) {
          options.headers['Authorization'] = 'Bearer $token';
        } else {
          debugPrint('⚠️ Нет токена, Authorization не установлен');
        }

        debugPrint("📤 Заголовки запроса: ${options.headers}");
        
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint("📥 Ответ получен: ${response.statusCode}");
        debugPrint("📥 Данные ответа: ${response.data}");
        handler.next(response);
      },
      onError: (DioException error, handler) async {
        debugPrint("❌ Ошибка запроса: ${error.type}");
        debugPrint("❌ Статус код: ${error.response?.statusCode}");
        debugPrint("❌ Данные ошибки: ${error.response?.data}");
        
        if (error.response?.statusCode == 401) {
          try {
            debugPrint("🔄 Пробуем обновить токен...");
            final newToken = await _refreshToken();
            await secureStorage.write(key: 'jwt_token', value: newToken);
            debugPrint("✅ Токен обновлен");

            final retryRequest = error.requestOptions;
            retryRequest.headers['Authorization'] = 'Bearer $newToken';

            debugPrint("🔄 Повторяем запрос с новым токеном");
            final response = await dio.fetch(retryRequest);
            return handler.resolve(response);
          } catch (e) {
            debugPrint("❌ Ошибка обновления токена: $e");
            return handler.reject(error);
          }
        }
        handler.next(error);
      },
    ));
  }

  Future<String> _refreshToken() async {
    final refreshToken = await secureStorage.read(key: 'jwt_token');
    if (refreshToken == null) {
      throw Exception('Refresh token is missing');
    }
    final response =
        await dio.post('/refresh-token', data: {'refresh_token': refreshToken});
    if (response.statusCode == 200) {
      return response.data['data'];
    }
    throw Exception('Failed to refresh token');
  }
}
