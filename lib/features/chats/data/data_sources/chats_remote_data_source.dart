import 'dart:async';

import 'package:chateo_app/core/data/data_sources/remote_data_source.dart';
import 'package:chateo_app/core/data/network/dio_network_manager.dart';
import 'package:chateo_app/core/data/network/network_request.dart';
import 'package:chateo_app/core/utils/errors/exception.dart';
import 'package:flutter/foundation.dart';

import '../models/chats_model.dart';

abstract class ChatsRemoteDataSource {
  Future<List<ChatsModel>> getAllChats();

  Future<void> createPrivateChat(String otherUserId);

  Future<List<ChatsModel>> searchChats(String query);

  Future<void> removeChat(String chatId);

  Stream<List<ChatsModel>> watchChats();
}

class ChatsRemoteDataSourceImpl extends RemoteDataSource
    implements ChatsRemoteDataSource {
  final DioNetworkManager dioNetworkManager;

  ChatsRemoteDataSourceImpl({required this.dioNetworkManager});

  @override
  Future<List<ChatsModel>> getAllChats() async {
    final response = await performRequest<List>(() async {
      final response = await dioNetworkManager.get(
        NetworkRequest(path: '/api/chats'),
      );
      return response.data;
    });

    return response.map((json) {
      if (json is! Map<String, dynamic>) {
        throw ServerException(message: 'Некорректный элемент списка контактов');
      }
      return ChatsModel.fromJson(json);
    }).toList();
  }

  @override
  Future<void> createPrivateChat(String otherUserId) async {
    await performRequest<void>(() async {
      final response = await dioNetworkManager.post(
        NetworkRequest(
          path: '/api/chats/private',
          data: {'otherUserId': otherUserId},
        ),
      );
      return response.data;
    });
  }

  @override
  Future<List<ChatsModel>> searchChats(String query) async {
    final response = await performRequest<List>(() async {
      final response = await dioNetworkManager.get(
        NetworkRequest(path: '/api/Search/users', queryParams: {'query': query}),
      );
      return response.data;
    });

    return response.map((json) {
      if (json is! Map<String, dynamic>) {
        throw ServerException(message: 'Некорректный элемент списка контактов');
      }
      return ChatsModel.fromJson(json);
    }).toList();
  }

  /// Эмулирует real-time обновления через периодический polling,
  /// пока backend не предоставит WebSocket / SSE.
  ///
  /// Первый список чатов приходит мгновенно при подписке,
  /// затем обновляется каждые [_pollInterval].
  static const _pollInterval = Duration(minutes: 10);

  @override
  Stream<List<ChatsModel>> watchChats() {
    late StreamController<List<ChatsModel>> controller;
    Timer? timer;

    Future<void> fetchAndEmit() async {
      try {
        final response = await dioNetworkManager.get(
          NetworkRequest(path: '/api/chats'),
        );
        if (controller.isClosed) return;

        if (response.data != null && response.data is List) {
          final list = response.data as List;
          final models = list
              .map((json) => ChatsModel.fromJson(json as Map<String, dynamic>))
              .toList();
          controller.add(models);
        } else {
          // Пустой или неожиданный ответ — не эмитим ничего, ждём следующего тика
          debugPrint('⚠️ watchChats remoteDataSource: unexpected response format');
        }
      } catch (e) {
        // Передаём ошибку в стрим — catchOrReturnStream преобразует в Left(Failure)
        // и продолжает жить (cancelOnError: false)
        if (!controller.isClosed) {
          controller.addError(
            ServerException(message: 'Ошибка получения чатов: $e'),
          );
        }
      }
    }

    controller = StreamController<List<ChatsModel>>(
      onListen: () async {
        await fetchAndEmit();
        timer = Timer.periodic(_pollInterval, (_) => fetchAndEmit());
      },
      onCancel: () => timer?.cancel(),
    );

    return controller.stream;
  }

  @override
  Future<void> removeChat(String chatId) {
    // пока не реализовано в backend
    throw UnimplementedError();
  }

  /// ============= ВАРИНАТ С performRequest ===========

  /// Эмулирует real-time обновления через периодический polling,
  /// пока backend не предоставит WebSocket / SSE.
  ///
  /// Первый список чатов приходит мгновенно при подписке,
  /// затем обновляется каждые [_pollInterval].
  // static const _pollInterval = Duration(minutes: 10);
  //
  // @override
  // Stream<List<ChatsModel>> watchChats() {
  //   late StreamController<List<ChatsModel>> controller;
  //
  //   Future<void> fetchAndEmit() async {
  //     // try {
  //     //   final response = await dioClient.get(url: '/api/chats');
  //     //   if (response.data != null && response.data is List) {
  //     //     final list = response.data as List;
  //     //     final models = list
  //     //         .map((json) => ChatsModel.fromJson(json as Map<String, dynamic>))
  //     //         .toList();
  //     //     if (!controller.isClosed) controller.add(models);
  //     //   } else {
  //     //     // Если сервер вернул пустой / неожиданный ответ — эмитим fallback
  //     //     if (!controller.isClosed) controller.add(_test);
  //     //   }
  //     // } on AppException {
  //     //   rethrow;
  //     // } catch (e) {
  //     //   //catch (e, stackTrace) {
  //     //   // Логирование:
  //     //   // talker.error(
  //     //   //   'Contacts parsing error',
  //     //   //   e,
  //     //   //   stackTrace,
  //     //   // );
  //     //   throw ServerException(
  //     //     message: 'Не корректный ответ сервера ${e.toString()}',
  //     //   );
  //     // }
  //     final response = await performRequest<List>(() async {
  //       final response = await dioClient.get(url: '/api/chats');
  //       return response.data;
  //     });
  //
  //     final models = response.map((json) {
  //       if (json is! Map<String, dynamic>) {
  //         throw ServerException(message: 'Некорректный элемент списка контактов');
  //       }
  //       return ChatsModel.fromJson(json);
  //     }).toList();
  //     if (!controller.isClosed) controller.add(models);
  //   }
  //
  //   Timer? timer;
  //
  //   controller = StreamController<List<ChatsModel>>(
  //     onListen: () async {
  //       // Первая загрузка — немедленно
  //       await fetchAndEmit();
  //       // Последующие — по таймеру
  //       timer = Timer.periodic(_pollInterval, (_) => fetchAndEmit());
  //     },
  //     onCancel: () {
  //       timer?.cancel();
  //     },
  //   );
  //
  //   return controller.stream;
  // }
}

// final List<ChatsModel> _test = [
//   ChatsModel(
//     chatId: 'ertyujnm',
//     type: 1,
//     chatAvatarUrl: '',
//     participantCount: 0,
//     createdAt: '2005-02-02T01:05:05.080Z',
//     chatName: 'Данные не получены 1',
//     isOnline: true,
//     unreadCount: 2,
//     lastMessage: ChatsEntityField(
//       messageId: 'ertyuio',
//       senderId: 'rtyuiop',
//       senderFirstName: 'My sender 1',
//       type: 0,
//       content: 'какашка?',
//       createdAt: '2005-02-02T01:05:05.080Z',
//     ),
//   ),
//   ChatsModel(
//     chatId: 'ertyujnm-2',
//     type: 1,
//     chatAvatarUrl: '',
//     participantCount: 0,
//     createdAt: '2005-02-02T01:05:05.080Z',
//     chatName: 'Данные не получены 2',
//     isOnline: true,
//     unreadCount: 2,
//     lastMessage: ChatsEntityField(
//       messageId: 'ertyuio',
//       senderId: 'rtyuiop',
//       senderFirstName: 'My sender 2',
//       type: 0,
//       content: 'какашка?',
//       createdAt: '2005-02-02T01:05:05.080Z',
//     ),
//   ),
// ];
