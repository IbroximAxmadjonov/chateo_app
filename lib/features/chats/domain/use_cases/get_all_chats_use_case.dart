import 'package:chateo_app/core/domain/use_case/use_case.dart';
import 'package:chateo_app/core/utils/errors/failure.dart';
import 'package:dartz/dartz.dart';

import '../entities/chats_entity.dart';
import '../repositories/chats_repository.dart';

class GetAllChatsUseCase extends UseCase<List<ChatsEntity>, NoParams> {
  final ChatsRepository chatsRepository;

  GetAllChatsUseCase({required this.chatsRepository});

  @override
  Future<Either<Failure, List<ChatsEntity>>> call(NoParams params) async {
    return await chatsRepository.getAllChats();
  }
}
