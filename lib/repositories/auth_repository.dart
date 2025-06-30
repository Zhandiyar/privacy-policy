import 'package:fintrack/services/api_client.dart';
import 'package:fintrack/services/storage_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '663807920764-i8k5osbt3ug04iotrr1cu4mgpfrbjb45.apps.googleusercontent.com',
    clientId: defaultTargetPlatform == TargetPlatform.iOS 
      ? '663807920764-fqsf7p68appvnlm7j2ig3sj46cklrdfr.apps.googleusercontent.com'
      : null,
    forceCodeForRefreshToken: true,
  );

  AuthRepository(this._apiClient);

  Future<void> login(String username, String password) async {
    try {
      final response = await _apiClient.dio.post('/api/auth/login', data: {
        "username": username,
        "password": password,
      });
      
      if (response.data['success'] == false) {
        throw DioException(
          requestOptions: RequestOptions(path: '/api/auth/login'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/auth/login'),
            statusCode: 401,
            data: response.data
          )
        );
      }
      
      await SecureStorage.saveToken(response.data['data']);
      debugPrint("✅ Успешная авторизация. Токен: ${response.data['data']}");
    } on DioException catch (e) {
      debugPrint("❌ Ошибка DIO при входе: ${e.response?.data}");
      throw Exception(_handleDioException(e));
    } catch (e) {
      debugPrint("❌ Общая ошибка при входе: $e");
      throw Exception("Ошибка при входе в систему");
    }
  }

  Future<void> register(String username, String email, String password) async {
    try {
      final response = await _apiClient.dio.post('/api/auth/register', data: {
        "username": username,
        "email": email,
        "password": password,
      });

      if (response.data['success'] == false) {
        throw DioException(
          requestOptions: RequestOptions(path: '/api/auth/register'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/auth/register'),
            statusCode: 400,
            data: response.data
          )
        );
      }

      await SecureStorage.saveToken(response.data['data']);
      debugPrint("✅ Успешная регистрация. Токен: ${response.data['data']}");
    } on DioException catch (e) {
      debugPrint("❌ Ошибка DIO при регистрации: ${e.response?.data}");
      throw Exception(_handleRegistrationError(e));
    } catch (e) {
      debugPrint("❌ Общая ошибка при регистрации: $e");
      throw Exception("Ошибка при регистрации");
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/forgot-password',
        data: {"email": email},
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
        ),
      );
      final Map<String, dynamic> data = response.data;

      if (data['success'] == true) {
        debugPrint("📧 Email отправлен: ${data['message']}");
      } else {
        throw Exception(data['message'] ?? "Ошибка при отправке письма");
      }
    } on DioException catch (e) {
      debugPrint("❌ Ошибка при отправке письма: ${e.message}");
      if (e.response?.statusCode == 500 && email.toLowerCase().endsWith('@mail.ru')) {
        throw Exception("В данный момент отправка на почтовые ящики mail.ru может быть недоступна. Пожалуйста, используйте другой email или попробуйте позже.");
      }
      throw Exception(_handleDioException(e));
    } catch (e) {
      debugPrint("❌ Общая ошибка при отправке письма: $e");
      throw Exception("Ошибка при отправке письма. Попробуйте позже.");
    }
  }


  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _apiClient.dio.post('/api/auth/reset-password', data: {
        "token": token,
        "newPassword": newPassword,
      });
    } on DioException catch (e) {
      throw Exception(_handleDioException(e));
    }
  }


  Future<bool> validateResetToken(String token) async {
    try {
      final response = await _apiClient.dio.get('/api/auth/reset-password',
        queryParameters: {'token': token},
      );
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }


  Future<void> logout() async {
    try {
      await SecureStorage.removeToken();
      
      final isSignedIn = await _googleSignIn.isSignedIn();
      if (isSignedIn) {
        await _googleSignIn.signOut();
        
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          await _googleSignIn.disconnect();
        }
      }
    } catch (e) {
      debugPrint('❌ Ошибка при выходе: $e');
      throw Exception('Ошибка при выходе из системы');
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      debugPrint('🔵 Начинаем вход через Google...');
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Вход отменён пользователем');
      }

      debugPrint('✅ Успешная авторизация: ${googleUser.email}');
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      
      if (idToken == null) {
        throw Exception('Не удалось получить токен Google');
      }
      
      final response = await _apiClient.dio.post('/api/auth/google-signin', data: {
        "idToken": idToken,
        "platform": defaultTargetPlatform.toString(),
      });

      if (response.data == null || response.data['success'] == false) {
        throw Exception(response.data?['message'] ?? 'Ошибка при входе через Google');
      }
      
      await SecureStorage.saveToken(response.data['data']);
      
    } on DioException catch (e) {
      debugPrint('❌ Ошибка сети: ${e.response?.statusCode}');
      throw Exception(_handleDioException(e));
    } catch (e) {
      debugPrint('❌ Ошибка: ${e.toString()}');
      throw Exception('Ошибка входа через Google: ${e.toString()}');
    }
  }

  String _handleDioException(DioException e) {
    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;
      
      if (data != null && data['message'] != null) {
        return data['message'];
      }
      
      switch (statusCode) {
        case 401:
          return "Неверный логин или пароль";
        case 403:
          return "Нет доступа. Попробуйте войти заново";
        case 400:
          return "Неверные данные для входа";
        case 404:
          return "Пользователь не найден";
        case 500:
          return "Ошибка сервера. Попробуйте позже";
        default:
          return "Ошибка при входе в систему";
      }
    }
    
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return "Превышено время ожидания. Проверьте подключение к интернету";
    }
    
    if (e.type == DioExceptionType.connectionError) {
      return "Нет подключения к интернету";
    }

    return "Ошибка сети. Проверьте подключение.";
  }

  String _handleRegistrationError(DioException e) {
    if (e.response?.data != null && e.response?.data['message'] != null) {
      final errorMessage = e.response?.data['message'];

      // Проверяем, содержит ли сообщение определенный текст
      if (errorMessage.contains('Password must be')) {
        return "Пароль должен быть от 6 до 100 символов";
      }

      if (errorMessage.contains('Username already exists')) {
        return "Это имя пользователя уже занято";
      }

      // Переводим сообщения об ошибках на русский
      switch(errorMessage) {
        case 'Invalid email address':
          return "Неверный формат email адреса";
        case 'Email already exists':
          return "Этот email уже зарегистрирован";
        case 'Username already exists':
          return "Это имя пользователя уже занято";
        case 'Password is too short':
          return "Пароль слишком короткий";
        case 'Password is too weak':
          return "Пароль слишком простой";
        case 'Password must be 6-100 characters':
          return "Пароль должен быть от 6 до 100 символов";
        default:
          // Если сообщение не распознано, возвращаем общую ошибку
          return "Проверьте правильность введенных данных";
      }
    }

    // Обработка по статус кодам
    switch (e.response?.statusCode) {
      case 400:
        return "Проверьте правильность введенных данных";
      case 409:
        return "Пользователь с таким именем уже существует";
      case 500:
        return "Ошибка сервера. Попробуйте позже";
      default:
        return "Ошибка при регистрации. Попробуйте позже";
    }
  }

  Future<void> createGuest() async {
    try {
      final response = await _apiClient.dio.post('/api/auth/guest');
      
      if (response.data['success'] == false) {
        throw DioException(
          requestOptions: RequestOptions(path: '/api/auth/guest'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/auth/guest'),
            statusCode: 400,
            data: response.data
          )
        );
      }

      await SecureStorage.saveToken(response.data['data']);
      await SecureStorage.saveIsGuest(true);
      debugPrint("✅ Успешное создание гостя. Токен: ${response.data['data']}");
    } on DioException catch (e) {
      debugPrint("❌ Ошибка DIO при создании гостя: ${e.response?.data}");
      throw Exception(_handleDioException(e));
    } catch (e) {
      debugPrint("❌ Общая ошибка при создании гостя: $e");
      throw Exception("Ошибка при создании гостевого аккаунта");
    }
  }

  Future<void> registerFromGuest(String username, String email, String password) async {
    try {
      debugPrint("📤 Отправка запроса регистрации из гостя...");

      final currentToken = await SecureStorage.getToken();
      if (currentToken == null) {
        debugPrint("❗ Ошибка: Токен отсутствует перед регистрацией из гостя");
        throw Exception('Отсутствует токен гостя. Пожалуйста, войдите снова.');
      }

      final response = await _apiClient.dio.post(
        '/api/auth/register-from-guest',
        data: {
          "username": username,
          "email": email,
          "password": password
        }
      );

      debugPrint("📥 Ответ: ${response.data}");

      if (response.data['success'] == false) {
        throw DioException(
          requestOptions: RequestOptions(path: '/api/auth/register-from-guest'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/auth/register-from-guest'),
            statusCode: 400,
            data: response.data
          )
        );
      }

      final newToken = response.data['data'];
      await SecureStorage.saveToken(newToken);
      await SecureStorage.saveIsGuest(false);
      debugPrint("✅ Успешная регистрация из гостя. Новый токен: $newToken");
    } on DioException catch (e) {
      debugPrint("❌ Ошибка DIO при регистрации из гостя: ${e.response?.data}");
      throw Exception(_handleRegistrationError(e));
    } catch (e) {
      debugPrint("❌ Общая ошибка при регистрации из гостя: $e");
      throw Exception("Ошибка при регистрации. Попробуйте позже");
    }
  }
}
