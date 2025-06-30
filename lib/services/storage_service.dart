import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';

class SecureStorage {
  static const _tokenKey = 'jwt_token';
  static const _isGuestKey = 'is_guest';
  static final _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> removeToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _isGuestKey);
  }

  static Future<void> saveIsGuest(bool isGuest) async {
    await _storage.write(key: _isGuestKey, value: isGuest.toString());
  }

  static Future<bool> isGuest() async {
    final token = await getToken();
    if (token == null) return false;

    final isGuest = await _storage.read(key: _isGuestKey);
    if (isGuest == 'true') return true;

    Map<String, dynamic> payload = Jwt.parseJwt(token);
    List roles = payload['roles'] ?? [];
    final hasGuestRole = roles.contains('ROLE_GUEST');
    
    // Синхронизируем статус гостя с токеном
    if (hasGuestRole) {
      await saveIsGuest(true);
    }
    
    return hasGuestRole;
  }
}