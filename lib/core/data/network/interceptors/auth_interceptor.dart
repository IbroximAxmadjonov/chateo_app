import 'dart:async' show Completer;
import 'dart:io';

import 'package:chateo_app/core/domain/routing/router.dart';
import 'package:chateo_app/core/domain/routing/routes.dart';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../storage/auth_storage.dart';

class Auth2Interceptor implements Interceptor {
  final AuthStorage _authStorage;
  final Dio _dio;
  Completer<bool>? _refreshCompleter;

  Auth2Interceptor({required AuthStorage authStorage, required Dio dio})
    : _authStorage = authStorage,
      _dio = dio;

  /// ==================== Методы Interceptor ====================

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        !_isPublicAuthEndpoint(err.requestOptions.path)) {
      if (!_authStorage.hasToken()) {
        return handler.next(err);
      }

      final refreshed = await _tryRefresh();
      if (refreshed) {
        final newToken = _authStorage.getAccessToken;
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        try {
          final retryResponse = await _dio.fetch(err.requestOptions);
          return handler.resolve(retryResponse);
        } on DioException catch (retryErr) {
          return handler.next(retryErr);
        }
      } else {
        _handleLogout();
        return handler.next(err);
      }
    }
    handler.next(err);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locale = prefs.getString('locale') ?? 'ru';
      options.headers['x-lang'] = locale;
    } catch (_) {
      options.headers['x-lang'] = 'ru';
    }

    if (_isPublicAuthEndpoint(options.path)) {
      return handler.next(options);
    }

    final accessToken = _authStorage.getAccessToken;

    // No token at all — send request as-is (will be rejected by server with 401,
    // which is handled in onError).
    if (accessToken == null || accessToken.isEmpty) {
      return handler.next(options);
    }

    if (!_isExpired(accessToken)) {
      // Token is still valid — attach it and proceed.
      options.headers[HttpHeaders.authorizationHeader] = 'Bearer $accessToken';
      return handler.next(options);
    }

    // Token is expired — try to refresh proactively.
    final refreshed = await _tryRefresh();
    if (refreshed) {
      final newToken = _authStorage.getAccessToken;
      if (newToken != null) {
        options.headers['Authorization'] = 'Bearer $newToken';
      }
      return handler.next(options);
    } else {
      _handleLogout();
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.cancel,
          error: 'Session expired',
        ),
      );
    }
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  /// ==================== Внутренние методы ====================

  void _handleLogout() {
    _authStorage.deleteTokens();
    debugPrint('🔒 Session expired — redirecting to login');
    router.go(AppRoutes.sentOtp);
  }

  bool _isPublicAuthEndpoint(String path) {
    return path.contains('/auth/send-otp') ||
        path.contains('/auth/verify-otp') ||
        path.contains('/auth/refresh');
  }

  bool _isExpired(String? token) {
    if (token == null || token.isEmpty) return true;
    try {
      final jwt = JWT.decode(token);
      final exp = jwt.payload['exp'] as int?;
      if (exp == null) return false;

      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expiry.subtract(const Duration(seconds: 30)));
    } catch (_) {
      return true;
    }
  }

  Future<bool> _tryRefresh({int retryCount = 0}) async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }
    _refreshCompleter = Completer<bool>();

    try {
      final refreshToken = _authStorage.getRefreshToken;

      if (!_authStorage.hasToken()) {
        debugPrint('🔑 No refresh token stored — forcing login');
        _refreshCompleter?.complete(false);
        return false;
      }
      debugPrint('🔄 Attempting token refresh...');

      final response = await _dio.post(
        '/api/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      debugPrint('🔄 Refresh response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] as Map<String, dynamic>? ?? responseData;
        // Try reading nested tokens object first, then fallback to direct properties
        final tokens = data['tokens'] as Map<String, dynamic>?;
        final newAccessToken =
            (tokens != null ? tokens['accessToken'] : data['accessToken'])
                as String?;
        final newRefreshToken =
            (tokens != null ? tokens['refreshToken'] : data['refreshToken'])
                as String?;

        if (newAccessToken != null && newRefreshToken != null) {
          await _authStorage.saveTokens(newAccessToken, newRefreshToken);
          debugPrint('✅ Tokens refreshed successfully');
          _refreshCompleter?.complete(true);
          return true;
        }

        debugPrint('❌ Refresh response missing tokens: $data');
        _refreshCompleter?.complete(false);
        return false;
      }

      debugPrint('❌ Refresh failed with status: ${response.statusCode}');
      _refreshCompleter?.complete(false);
      return false;
    } on DioException catch (e) {
      if (e.response == null && retryCount < 2) {
        debugPrint(
          '⚠️ Refresh network error (attempt ${retryCount + 1}/3), retrying in 4s...',
        );
        _refreshCompleter?.complete(false);
        await Future.delayed(const Duration(seconds: 4));
        return _tryRefresh(retryCount: retryCount + 1);
      }
      debugPrint(
        '❌ Refresh DioException: ${e.response?.statusCode} — ${e.response?.data}',
      );
      _refreshCompleter?.complete(false);
      _refreshCompleter = null;
      return false;
    } catch (e) {
      debugPrint('❌ Refresh unexpected error: $e');
      _refreshCompleter?.complete(false);
      return false;
    }
    finally {
      _refreshCompleter = null;
    }
  }
}
