import 'package:chateo_app/core/data/data_sources/remote_data_source.dart';
import 'package:chateo_app/core/data/network/dio_network_manager.dart';
import 'package:chateo_app/core/data/network/network_request.dart';
import 'package:chateo_app/core/utils/errors/exception.dart';

import '../models/dialog_model.dart';

abstract class DialogRemoteDataSource {
  /// GET /api/chats/{chatId}/messages?before=&limit=
  Future<Map<String, dynamic>> getMessages({
    required String chatId,
    String? before,
    int limit = 50,
  });

  /// POST /api/chats/{chatId}/messages
  Future<DialogModel> sendMessage({
    required String chatId,
    required int type,
    String? content,
    String? mediaUrl,
    int? duration,
    String? replyToMessageId,
  });

  /// PUT /api/chats/{chatId}/messages/read
  Future<void> markMessagesRead({
    required String chatId,
    required String upToMessageId,
  });

  /// GET /api/chats/{chatId}/messages/search?query=
  Future<List<DialogModel>> searchMessages({
    required String chatId,
    required String query,
  });
}

class DialogRemoteDataSourceImpl extends RemoteDataSource
    implements DialogRemoteDataSource {
  final DioNetworkManager dioNetworkManager;

  DialogRemoteDataSourceImpl({required this.dioNetworkManager});

  @override
  Future<Map<String, dynamic>> getMessages({
    required String chatId,
    String? before,
    int limit = 50,
  }) async {
    if (chatId.trim().isEmpty) {
      throw ServerException(message: 'chatId не может быть пустым');
    }

    final queryParams = <String, dynamic>{'limit': limit};
    if (before != null && before.isNotEmpty) {
      queryParams['before'] = before;
    }

    final response = await dioNetworkManager.get(
      NetworkRequest(
        path: '/api/chats/$chatId/messages',
        queryParams: queryParams,
      ),
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw ServerException(message: 'Unexpected response format for getMessages');
    }
    return data;
  }

  @override
  Future<DialogModel> sendMessage({
    required String chatId,
    required int type,
    String? content,
    String? mediaUrl,
    int? duration,
    String? replyToMessageId,
  }) async {
    final body = <String, dynamic>{
      'type': type,
      'content': content ?? '',
      'mediaUrl': mediaUrl,
      'duration': duration ?? 0,
      'replyToMessageId':
          (replyToMessageId != null && replyToMessageId.isNotEmpty)
              ? replyToMessageId
              : null,
    };

    final response = await dioNetworkManager.post(
      NetworkRequest(
        path: '/api/chats/$chatId/messages',
        data: body,
      ),
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw ServerException(message: 'Unexpected response format for sendMessage');
    }
    return DialogModel.fromMap(data);
  }

  @override
  Future<void> markMessagesRead({
    required String chatId,
    required String upToMessageId,
  }) async {
    await dioNetworkManager.put(
      NetworkRequest(
        path: '/api/chats/$chatId/messages/read',
        data: {'upToMessageId': upToMessageId},
      ),
    );
  }

  @override
  Future<List<DialogModel>> searchMessages({
    required String chatId,
    required String query,
  }) async {
    final response = await dioNetworkManager.get(
      NetworkRequest(
        path: '/api/chats/$chatId/messages/search',
        queryParams: {'query': query},
      ),
    );

    final data = response.data;
    if (data is List) {
      return data.map((json) {
        if (json is! Map<String, dynamic>) {
          throw ServerException(message: 'Unexpected item in search results');
        }
        return DialogModel.fromMap(json);
      }).toList();
    }
    // Some backends return {messages: [...]}
    if (data is Map<String, dynamic> && data['messages'] is List) {
      final list = data['messages'] as List;
      return list.map((json) {
        if (json is! Map<String, dynamic>) {
          throw ServerException(message: 'Unexpected item in search results');
        }
        return DialogModel.fromMap(json);
      }).toList();
    }
    return [];
  }
}
