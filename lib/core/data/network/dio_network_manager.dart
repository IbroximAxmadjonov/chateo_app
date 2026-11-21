import 'dart:io';

import 'package:chateo_app/core/utils/api_constant.dart';
import 'package:chateo_app/core/utils/errors/dio_exception_handler.dart';
import 'package:chateo_app/core/utils/errors/exception.dart';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:talker_dio_logger/talker_dio_logger_interceptor.dart';
import 'package:talker_dio_logger/talker_dio_logger_settings.dart';

import 'interceptors/auth_interceptor.dart';
import 'network_request.dart';

class DioNetworkManager {
  final Dio _dio;
  final AuthInterceptor _auth2interceptor;
  final Map<String, dynamic> _headers = {
    HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
  };

  DioNetworkManager({required Dio dio, required AuthInterceptor auth2interceptor})
    : _dio = dio,
      _auth2interceptor = auth2interceptor {
    _addBaseUrl();
    _addInterceptors();
  }

  // ==================== Внешние методы ====================

  Future<Response> get(NetworkRequest request) =>
      _request(method: 'GET', request: request);

  Future<Response> post(NetworkRequest request) =>
      _request(method: 'POST', request: request);

  Future<Response> put(NetworkRequest request) =>
      _request(method: 'PUT', request: request);

  Future<Response> delete(NetworkRequest request) =>
      _request(method: 'DELETE', request: request);

  Future<Response> patch(NetworkRequest request) =>
      _request(method: 'PATCH', request: request);

  void addAuth(String accessToken) {
    _headers[HttpHeaders.authorizationHeader] = 'Bearer $accessToken';
    _dio.options.headers.addAll(_headers);
  }

  // ==================== Внутренние методы ====================

  void _addBaseUrl() {
    _dio.options = BaseOptions(
      baseUrl: ApiConstant.mainBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      responseType: ResponseType.json,
    );
  }

  void _addInterceptors() {
    _dio.interceptors.add(_auth2interceptor);
    _dio.interceptors.add(
      TalkerDioLogger(
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: true,
          printRequestData: true,
          printResponseData: true,
          printErrorData: true,
        ),
      ),
    );
  }

  Future<Response> _request({
    required String method,
    required NetworkRequest request,
  }) async {
    try {
      return await _dio.request(
        request.path,
        data: request.data,
        queryParameters: request.queryParams,
        options: Options(method: method),
      );
    } on DioException catch (dioError) {
      throw dioExceptionHandler(dioError);
    } catch (error, stackTrace) {
      debugPrint('============================================');
      debugPrint('Обычный debugPrint с ошибкой: $error внутри DioNetworkManager');
      debugPrintStack(
        label: 'DioNetworkManager с debugPrintStack',
        maxFrames: 10,
        stackTrace: stackTrace,
      );
      debugPrint('============================================');
      throw ServerException(message: 'Произошла непредвиденная ошибка');
    }
  }
}
