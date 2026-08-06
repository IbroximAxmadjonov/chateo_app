import 'dart:async';

import 'package:chateo_app/core/utils/errors/exception.dart';
import 'package:chateo_app/core/utils/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

abstract class Repository {
  Future<Either<Failure, T>> performResponse<T>(Future<T> Function() operation) async {
    try {
      final result = await operation();

      return Right(result);
    } catch (error) {
      return Left(_mapExceptionToFailure(error));
    }
  }

  /// Оборачивает поток данных в Either-поток.
  ///
  /// Гарантии:
  /// - Ошибки превращаются в [Left(Failure)] и продолжают идти в поток
  ///   (стрим НЕ закрывается после ошибки).
  /// - Если нижележащий polling-стрим завершился (onDone), контроллер
  ///   также завершится только если сам отменён (onCancel). В противном
  ///   случае стрим перезапускается автоматически.
  Stream<Either<Failure, T>> performResponseStream<T>(
    Stream<T> Function() operation,
  ) {
    // Используем broadcast-совместимый StreamController без autoCancel,
    // чтобы стрим оставался живым между подписчиками.
    final controller = StreamController<Either<Failure, T>>();

    StreamSubscription<T>? subscription;
    bool cancelled = false;

    void subscribe() {
      if (cancelled) return;

      try {
        subscription = operation().listen(
          (data) {
            if (!controller.isClosed) controller.add(Right(data));
          },
          onError: (Object error, StackTrace st) {
            // Превращаем ошибку в Left — стрим продолжает работу
            if (!controller.isClosed) {
              controller.add(Left(_mapExceptionToFailure(error)));
            }
          },
          // Если нижележащий polling-стрим завершился (onDone),
          // не закрываем контроллер — перезапускаем подписку.
          onDone: () {
            if (!cancelled && !controller.isClosed) {
              // Небольшая задержка чтобы не спамить сразу после onDone
              Future.delayed(const Duration(seconds: 1), subscribe);
            }
          },
          cancelOnError: false,
        );
      } catch (error) {
        // Синхронная ошибка при создании стрима
        if (!controller.isClosed) {
          controller.add(Left(_mapExceptionToFailure(error)));
        }
      }
    }

    controller.onListen = subscribe;
    controller.onCancel = () {
      cancelled = true;
      subscription?.cancel();
    };

    return controller.stream;
  }

  Failure _mapExceptionToFailure(Object error) {
    if (error is ServerException) {
      debugPrint('Server Exception: ${error.message}');
      return ServerFailure(message: error.message);
    }

    if (error is UnauthorizedException) {
      debugPrint('Unauthorized Exception: ${error.message}');
      return UnauthorizedFailure(message: error.message);
    }

    if (error is NoInternetException) {
      debugPrint('NoInternet Exception: ${error.message}');
      return NoInternetFailure(message: error.message);
    }

    if (error is CacheException) {
      debugPrint('Cache Exception: ${error.message}');
      return CacheFailure(message: error.message);
    }

    if (error is UnknownException) {
      debugPrint('Unknown Exception: ${error.message}');
      return UnknownFailure(message: error.message);
    }

    debugPrint('Unexpected Error: $error');
    return UnknownFailure(message: 'Произошла неизвестная ошибка');
  }

  // Future<Either<Failure, T>> performResponse<T>(
  //   Future<T> Function() operation,
  // ) async {
  //   try {
  //     final result = await operation();
  //     return Right(result);
  //   } on ServerException catch (e) {
  //     debugPrint('Server Exception: ${e.message}');
  //     return Left(ServerFailure(message: e.message));
  //   } on UnauthorizedException catch (e) {
  //     debugPrint('Unauthorized Exception: ${e.message}');
  //     return Left(UnauthorizedFailure(message: e.message));
  //   } on NoInternetException catch (e) {
  //     debugPrint('NoInternet Exception: ${e.message}');
  //     return Left(NoInternetFailure(message: e.message));
  //   } on CacheException catch (e) {
  //     debugPrint('Cache Exception: ${e.message}');
  //     return Left(CacheFailure(message: e.message));
  //   } on UnknownException catch (e) {
  //     debugPrint('Unknown Exception: ${e.message}');
  //     return Left(UnknownFailure(message: e.message));
  //   } catch (e) {
  //     debugPrint('Unexpected Error: $e');
  //     return Left(UnknownFailure(message: 'Произошла неизвестная ошибка'));
  //   }
  // }
}
