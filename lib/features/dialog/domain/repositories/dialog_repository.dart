import 'package:chateo_app/core/utils/errors/failure.dart';
import 'package:chateo_app/features/dialog/domain/entities/dialog_entity.dart';
import 'package:dartz/dartz.dart';

abstract class DialogRepository {
  Future<Either<Failure, List<DialogEntity>>> getMessages({
    required String chatId,
    String? before,
    int limit = 50,
  });

  Future<Either<Failure, DialogEntity>> sendMessage({
    required String chatId,
    required int type,
    String? content,
    String? mediaUrl,
    int? duration,
    String? replyToMessageId,
  });

  Future<Either<Failure, void>> markMessagesRead({
    required String chatId,
    required String upToMessageId,
  });

  Future<Either<Failure, List<DialogEntity>>> searchMessages({
    required String chatId,
    required String query,
  });
}
