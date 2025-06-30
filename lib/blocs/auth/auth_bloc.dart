import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fintrack/repositories/auth_repository.dart';
import 'package:fintrack/services/storage_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<GuestLoginRequested>(_onGuestLoginRequested);
    on<RegisterFromGuestRequested>(_onRegisterFromGuestRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    try {
      final token = await SecureStorage.getToken();
      if (token != null) {
        emit(AuthAuthenticated(token));
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      debugPrint("Ошибка загрузки токена: ${e.toString()}");
      emit(AuthFailure(_getErrorMessage(e)));
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.login(event.username, event.password);
      final token = await SecureStorage.getToken();
      debugPrint("✅ Полученный токен из хранилища: $token");

      if (token != null) {
        emit(AuthAuthenticated(token));
      } else {
        emit(AuthFailure("Ошибка: Токен не был сохранен"));
      }
    } catch (e) {
      debugPrint("❌ Ошибка входа: ${e.toString()}");
      emit(AuthFailure(_getErrorMessage(e)));
    }
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.register(event.username, event.email, event.password);
      debugPrint("✅ Регистрация прошла успешно, выполняем вход...");
      final token = await SecureStorage.getToken();

      if (token != null) {
        emit(AuthAuthenticated(token));
      } else {
        emit(AuthFailure("Ошибка: Токен не был сохранен"));
      }
    } catch (e) {
      debugPrint("❌ Ошибка регистрации: ${e.toString()}");
      emit(AuthFailure(_getErrorMessage(e)));
    }
  }

  Future<void> _onForgotPasswordRequested(ForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.forgotPassword(event.email);
      emit(PasswordResetEmailSent());
    } catch (e) {
      debugPrint("❌ Ошибка при отправке письма: ${e.toString()}");
      emit(AuthFailure("Ошибка при отправке письма"));
    }
  }


  Future<void> _onResetPasswordRequested(ResetPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.resetPassword(event.token, event.newPassword);
      emit(PasswordResetSuccess());
    } catch (e) {
      debugPrint("❌ Ошибка смены пароля: ${e.toString()}");
      emit(AuthFailure("Ошибка смены пароля"));
    }
  }

  Future<void> _onValidateToken(
      ValidateResetToken event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      final isValid = await _authRepository.validateResetToken(event.token);
      if (isValid) {
        emit(TokenValid());
      } else {
        emit(TokenInvalid("Невалидный или истёкший токен"));
      }
    } catch (e) {
      emit(TokenInvalid(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      debugPrint('🔵 Обработка запроса на выход...');
      await _authRepository.logout();
      debugPrint('✅ Выход выполнен успешно');
      emit(AuthLoggedOut());
    } catch (e) {
      debugPrint('❌ Ошибка при выходе: $e');
      emit(AuthFailure(_getErrorMessage(e)));
      // После ошибки все равно переходим в начальное состояние
      emit(AuthLoggedOut());
    }
  }

  Future<void> _onGoogleSignInRequested(GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.signInWithGoogle();
      final token = await SecureStorage.getToken();
      debugPrint("✅ Получен токен после Google Sign-In: $token");

      if (token != null) {
        emit(AuthAuthenticated(token));
      } else {
        emit(AuthFailure("Ошибка: Токен не был сохранен"));
      }
    } catch (e) {
      debugPrint("❌ Ошибка входа через Google: ${e.toString()}");
      emit(AuthFailure(_getErrorMessage(e)));
    }
  }

  Future<void> _onGuestLoginRequested(GuestLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.createGuest();
      final token = await SecureStorage.getToken();
      debugPrint("✅ Вход как гость выполнен успешно");

      if (token != null) {
        emit(AuthAuthenticated(token));
      } else {
        emit(AuthFailure("Ошибка: Токен не был сохранен"));
      }
    } catch (e) {
      debugPrint("❌ Ошибка входа как гость: ${e.toString()}");
      emit(AuthFailure(_getErrorMessage(e)));
    }
  }

  Future<void> _onRegisterFromGuestRequested(RegisterFromGuestRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.registerFromGuest(event.username, event.email, event.password);
      debugPrint("✅ Регистрация из гостя прошла успешно");
      final token = await SecureStorage.getToken();

      if (token != null) {
        emit(AuthSuccess("Регистрация успешно завершена"));
        emit(AuthAuthenticated(token));
      } else {
        emit(AuthFailure("Ошибка: Токен не был сохранен"));
      }
    } catch (e) {
      debugPrint("❌ Ошибка регистрации из гостя: ${e.toString()}");
      emit(AuthFailure(_getErrorMessage(e)));
    }
  }

  /// **Обновлённая обработка ошибок**
  String _getErrorMessage(dynamic error) {
    // Если ошибка уже содержит переведенное сообщение, возвращаем его
    if (error is Exception) {
      String message = error.toString();
      if (message.startsWith('Exception: ')) {
        return message.substring(10); // Убираем 'Exception: ' из начала
      }
    }

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return "Сервер не отвечает. Проверьте интернет-соединение";

        case DioExceptionType.badResponse:
          if (error.response?.statusCode == 401) {
            return "Неверное имя пользователя или пароль";
          } else if (error.response?.statusCode == 500) {
            return "Ошибка сервера. Попробуйте позже";
          }
          // Проверяем, есть ли сообщение об ошибке в ответе
          final data = error.response?.data;
          if (data != null && data['message'] != null) {
            return data['message'];
          }
          return "Ошибка сервера. Попробуйте еще раз";

        case DioExceptionType.cancel:
          return "Запрос был отменен. Попробуйте снова";

        case DioExceptionType.connectionError:
          return "Нет подключения к интернету";

        case DioExceptionType.unknown:
        default:
          return error.message ?? "Произошла неизвестная ошибка. Проверьте соединение";
      }
    }

    if (error is SocketException) {
      return "Нет подключения к интернету";
    }

    if (error.toString().contains("FormatException")) {
      return "Ошибка обработки данных. Попробуйте снова";
    }

    return "Произошла ошибка. Попробуйте еще раз";
  }
}
