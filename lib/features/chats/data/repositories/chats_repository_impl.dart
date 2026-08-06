import 'dart:async';

import 'package:chateo_app/core/domain/repository/repository.dart';
import 'package:chateo_app/core/utils/errors/failure.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/chats_entity.dart';
import '../../domain/repositories/chats_repository.dart';
import '../data_sources/chats_remote_data_source.dart';

class ChatsRepositoryImpl extends Repository implements ChatsRepository {
  final ChatsRemoteDataSource chatsRemoteDataSource;

  ChatsRepositoryImpl({required this.chatsRemoteDataSource});

  // ── Futures ──────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<ChatsEntity>>> getAllChats() {
    return performResponse(() async {
      final models = await chatsRemoteDataSource.getAllChats();
      return models.map((e) => e.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, void>> createPrivateChat(otherUserId) {
    return performResponse(
      () async => await chatsRemoteDataSource.createPrivateChat(otherUserId),
    );
  }

  @override
  Future<Either<Failure, List<ChatsEntity>>> searchChats(String query) {
    return performResponse(() async {
      final models = await chatsRemoteDataSource.searchChats(query);
      return models.map((e) => e.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, void>> removeChat(String chatId) {
    return performResponse(() async => await chatsRemoteDataSource.removeChat(chatId));
  }

  // ── Streams ──────────────────────────────────────────────────────────────

  // @override
  // Stream<Either<Failure, List<ChatsEntity>>> watchChats() {
  //   // Оборачиваем source-стрим чтобы stream errors (addError)
  //   // превращались в Left(Failure) — иначе BLoC получает unhandled exception.
  //   final controller = StreamController<Either<Failure, List<ChatsEntity>>>();
  //
  //   final subscription = chatsRemoteDataSource.watchChats().listen(
  //     (models) {
  //       if (!controller.isClosed) {
  //         controller.add(Right(models));
  //       }
  //     },
  //     onError: (Object e) {
  //       if (!controller.isClosed) {
  //         controller.add(Left(CacheFailure(message: 'Ошибка получения чатов: $e')));
  //       }
  //     },
  //     onDone: () {
  //       if (!controller.isClosed) controller.close();
  //     },
  //     cancelOnError: false, // продолжаем polling даже после ошибки
  //   );
  //
  //   controller.onCancel = () => subscription.cancel();
  //
  //   return controller.stream;
  // }
  @override
  Stream<Either<Failure, List<ChatsEntity>>> watchChats() {
    return performResponseStream(() {
      return chatsRemoteDataSource.watchChats().map(
        (models) => models.map((e) => e.toEntity).toList(),
      );
    });
  }
}
