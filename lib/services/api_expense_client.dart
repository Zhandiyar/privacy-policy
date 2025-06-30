import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class ApiExpenseClient {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  ApiExpenseClient({Dio? dio, FlutterSecureStorage? secureStorage})
      : dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://api.fin-track.pro/api',
            )),
        secureStorage = secureStorage ?? const FlutterSecureStorage() {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await secureStorage.read(key: 'jwt_token');
        print("⚡ Отправляемый токен: $token");

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (DioError error, handler) async {
        if (error.response?.statusCode == 401) {
          try {
            final newToken = await _refreshToken();
            await secureStorage.write(key: 'jwt_token', value: newToken);

            final retryRequest = error.requestOptions;
            retryRequest.headers['Authorization'] = 'Bearer $newToken';

            final response = await dio.fetch(retryRequest);
            return handler.resolve(response);
          } catch (_) {
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
      return response.data['access_token'];
    }
    throw Exception('Failed to refresh token');
  }
}
