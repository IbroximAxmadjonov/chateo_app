import 'package:chateo_app/core/domain/repository/repository.dart';
import 'package:chateo_app/core/utils/errors/failure.dart';
import 'package:chateo_app/features/dialog/domain/entities/dialog_entity.dart';
import 'package:chateo_app/features/dialog/domain/repositories/dialog_repository.dart';
import 'package:dartz/dartz.dart';

import '../data_sources/dialog_remote_data_source.dart';
import '../models/dialog_model.dart';

class DialogRepositoryImpl extends Repository implements DialogRepository {
  final DialogRemoteDataSource dialogRemoteDataSource;

  DialogRepositoryImpl({required this.dialogRemoteDataSource});

  @override
  Future<Either<Failure, List<DialogEntity>>> getMessages({
    required String chatId,
    String? before,
    int limit = 50,
  }) {
    return performResponse(() async {
      final responseMap = await dialogRemoteDataSource.getMessages(
        chatId: chatId,
        before: before,
        limit: limit,
      );
      final raw = responseMap['messages'];
      if (raw is! List) return <DialogEntity>[];
      return raw.map((json) {
        if (json is! Map<String, dynamic>) return null;
        return DialogModel.fromMap(json).toEntity;
      }).whereType<DialogEntity>().toList();
    });
  }

  @override
  Future<Either<Failure, DialogEntity>> sendMessage({
    required String chatId,
    required int type,
    String? content,
    String? mediaUrl,
    int? duration,
    String? replyToMessageId,
  }) {
    return performResponse(() async {
      final model = await dialogRemoteDataSource.sendMessage(
        chatId: chatId,
        type: type,
        content: content,
        mediaUrl: mediaUrl,
        duration: duration,
        replyToMessageId: replyToMessageId,
      );
      return model.toEntity;
    });
  }

  @override
  Future<Either<Failure, void>> markMessagesRead({
    required String chatId,
    required String upToMessageId,
  }) {
    return performResponse(() async {
      await dialogRemoteDataSource.markMessagesRead(
        chatId: chatId,
        upToMessageId: upToMessageId,
      );
    });
  }

  @override
  Future<Either<Failure, List<DialogEntity>>> searchMessages({
    required String chatId,
    required String query,
  }) {
    return performResponse(() async {
      final models = await dialogRemoteDataSource.searchMessages(
        chatId: chatId,
        query: query,
      );
      return models.map((m) => m.toEntity).toList();
    });
  }
}
