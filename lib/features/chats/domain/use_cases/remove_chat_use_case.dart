import 'package:chateo_app/core/domain/use_case/use_case.dart';
import 'package:chateo_app/core/utils/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';


import '../repositories/chats_repository.dart';

class RemoveChatUseCase extends UseCase<void, RemoveChatParams> {
  final ChatsRepository chatsRepository;

  RemoveChatUseCase({required this.chatsRepository});

  @override
  Future<Either<Failure, void>> call(RemoveChatParams params) async {
    return await chatsRepository.removeChat(params.chatId);
  }
}

class RemoveChatParams extends Equatable {
  final String chatId;

  const RemoveChatParams({required this.chatId});

  @override
  List<Object?> get props => [chatId];
}
