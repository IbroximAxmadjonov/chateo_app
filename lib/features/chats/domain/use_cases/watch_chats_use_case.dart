import 'package:chateo_app/core/domain/use_case/use_case.dart';
import 'package:chateo_app/core/utils/errors/failure.dart';
import 'package:dartz/dartz.dart';


import '../entities/chats_entity.dart';
import '../repositories/chats_repository.dart';

class WatchChatsUseCase {
  final ChatsRepository chatsRepository;

  WatchChatsUseCase({required this.chatsRepository});

  Stream<Either<Failure, List<ChatsEntity>>> call(NoParams params) {
    return chatsRepository.watchChats();
  }
}
