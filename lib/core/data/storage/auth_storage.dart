import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  final _storage = const FlutterSecureStorage();
  String? _cachedAccessToken;
  String? _cachedRefreshToken;

  Future<void> init() async {
    _cachedAccessToken = await _storage.read(key: 'access_token');
    _cachedRefreshToken = await _storage.read(key: 'refresh_token');
  }

  // Получение токенов
  String? get getAccessToken => _cachedAccessToken;

  String? get getRefreshToken => _cachedRefreshToken;

  // Сохранение токенов
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    _cachedAccessToken = accessToken;
    _cachedRefreshToken = refreshToken;
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  // Удаление токенов при выходе
  Future<void> deleteTokens() async {
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  bool hasToken() {
    final token = getAccessToken;
    final reToken = getRefreshToken;
    return token != null &&
        token.isNotEmpty &&
        reToken != null &&
        reToken.isNotEmpty;
  }

  /// Extracts the current user ID (`sub` claim) from the JWT access token.
  String? getUserId() {
    final token = getAccessToken;
    if (token == null || token.isEmpty) return null;
    try {
      final jwt = JWT.decode(token);
      return jwt.payload['sub'] as String? ??
          jwt.payload['nameId'] as String? ??
          jwt.payload['userId'] as String?;
    } catch (_) {
      return null;
    }
  }
}
