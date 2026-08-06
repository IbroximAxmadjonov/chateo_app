import 'package:chateo_app/core/utils/errors/exception.dart';
import 'package:flutter/material.dart';

abstract class RemoteDataSource {
  Future<T> performRequest<T>(Future<dynamic> Function() operation) async {
    try {
      final response = await operation();

      final isEmpty204 =
          response == null || (response is String && response.isEmpty);

      if (isEmpty204) {
        if (null is T) return null as T;
        throw ServerException(message: 'Пустой ответ сервера');
      }

      if (response is! T) {
        throw ServerException(message: 'Сервер вернул неожиданный формат данных');
      }

      return response;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('=================================================');
      debugPrint('Error: $e');
      debugPrint('debugPrintStack внутри remoteDataSource');
      debugPrintStack(stackTrace: stackTrace);
      debugPrint('=================================================');
      throw ServerException(message: 'Некорректный ответ сервера: ${e.toString()}');
    }
  }
}
