import 'package:chateo_app/core/domain/use_case/use_case.dart';
import 'package:chateo_app/core/utils/errors/failure.dart';
import 'package:chateo_app/features/chats/domain/repositories/chats_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class CreatePrivateChatUseCase extends UseCase<void, CreatePrivateChatParams> {
  final ChatsRepository chatsRepository;

  CreatePrivateChatUseCase({required this.chatsRepository});

  @override
  Future<Either<Failure, void>> call(CreatePrivateChatParams params) async {
    return await chatsRepository.createPrivateChat(params.otherUserId);
  }
}

class CreatePrivateChatParams extends Equatable {
  final String otherUserId;

  const CreatePrivateChatParams({required this.otherUserId});

  @override
  List<Object?> get props => [otherUserId];
}
