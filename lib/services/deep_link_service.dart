import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'dart:developer' as developer;
import 'package:flutter/services.dart' show PlatformException;

/// Сервис для обработки deep links в приложении
class DeepLinkService {
  /// Ключ навигатора для управления роутингом
  final GlobalKey<NavigatorState> navigatorKey;
  
  /// Экземпляр AppLinks для обработки deep links
  late final AppLinks _appLinks;
  
  /// Флаг, указывающий, инициализирован ли сервис
  bool _isInitialized = false;

  DeepLinkService({required this.navigatorKey}) {
    _init();
  }

  /// Инициализация сервиса
  Future<void> _init() async {
    if (_isInitialized) {
      developer.log('DeepLinkService уже инициализирован', name: 'DeepLinkService');
      return;
    }

    try {
      _appLinks = AppLinks();
      
      // Проверяем initial link при запуске приложения
      final uri = await _appLinks.getInitialAppLink();
      if (uri != null) {
        developer.log(
          'Получен initial deep link: ${uri.toString()}',
          name: 'DeepLinkService',
        );
        _handleDeepLink(uri);
      }
      
      // Слушаем входящие deep links
      _appLinks.uriLinkStream.listen(
        (Uri? uri) {
          if (uri != null) {
            _handleDeepLink(uri);
          }
        },
        onError: (err) {
          developer.log(
            'Ошибка при получении deep link',
            error: err,
            name: 'DeepLinkService',
          );
        },
      );
      
      _isInitialized = true;
      developer.log('DeepLinkService успешно инициализирован', name: 'DeepLinkService');
    } on PlatformException catch (e) {
      developer.log(
        'Ошибка при инициализации DeepLinkService',
        error: e,
        name: 'DeepLinkService',
      );
    }
  }

  /// Обработка deep link
  void _handleDeepLink(Uri uri) {
    developer.log(
      'Обработка deep link: ${uri.toString()}',
      name: 'DeepLinkService',
    );

    try {
      final path = _normalizePath(uri.path);
      _processDeepLink(path, uri);
    } catch (e, stackTrace) {
      developer.log(
        'Ошибка при обработке deep link',
        error: e,
        stackTrace: stackTrace,
        name: 'DeepLinkService',
      );
    }
  }

  /// Нормализация пути deep link
  String _normalizePath(String path) {
    return path.trim().toLowerCase().replaceAll(RegExp(r'^/+|/+$'), '');
  }

  /// Обработка различных типов deep links
  void _processDeepLink(String path, Uri uri) {
    switch (path) {
      case 'reset-password':
        _handleResetPassword(uri);
        break;
      default:
        developer.log(
          'Неизвестный путь deep link: $path',
          name: 'DeepLinkService',
        );
    }
  }

  /// Обработка deep link для сброса пароля
  void _handleResetPassword(Uri uri) {
    final token = uri.queryParameters['token'];
    if (token == null || token.isEmpty) {
      developer.log(
        'Токен отсутствует в deep link для сброса пароля',
        name: 'DeepLinkService  ',
      );
      return;
    }

    developer.log(
      'Переход на экран сброса пароля с токеном: $token',
      name: 'DeepLinkService',
    );

    // Используем Future.delayed чтобы дать приложению время инициализироваться
    Future.delayed(const Duration(seconds: 1), () {
      if (navigatorKey.currentState == null) {
        developer.log('❌ navigatorKey пустой (ещё не инициализировался)');
      } else {
        developer.log('✅ navigatorKey готов, переходим на reset-password');
        navigatorKey.currentState?.pushNamed(
          '/reset-password',
          arguments: token,
        );
      }
    });
  }

  /// Освобождение ресурсов
  void dispose() {
    _isInitialized = false;
    developer.log('DeepLinkService освобожден', name: 'DeepLinkService');
  }
} 