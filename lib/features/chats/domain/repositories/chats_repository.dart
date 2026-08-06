import 'package:chateo_app/core/utils/errors/failure.dart';
import 'package:dartz/dartz.dart';

import '../entities/chats_entity.dart';

abstract class ChatsRepository {
  // Загрузка чатов
  Future<Either<Failure, List<ChatsEntity>>> getAllChats();

  // Создание чата
  Future<Either<Failure, void>> createPrivateChat(String otherUserId);

  // Поиск чатов
  Future<Either<Failure, List<ChatsEntity>>> searchChats(String query);

  // Удаление чата
  Future<Either<Failure, void>> removeChat(String chatId);

  // Stream для реального времени
  Stream<Either<Failure, List<ChatsEntity>>> watchChats();
}
