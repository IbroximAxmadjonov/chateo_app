import 'package:chateo_app/core/utils/errors/failure.dart';
import 'package:chateo_app/features/dialog/domain/entities/dialog_entity.dart';
import 'package:chateo_app/features/dialog/domain/repositories/dialog_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class GetMessagesUseCase {
  final DialogRepository dialogRepository;

  GetMessagesUseCase({required this.dialogRepository});

  Future<Either<Failure, List<DialogEntity>>> call(GetMessagesParams params) {
    return dialogRepository.getMessages(
      chatId: params.chatId,
      before: params.before,
      limit: params.limit,
    );
  }
}

class GetMessagesParams extends Equatable {
  final String chatId;
  final String? before;
  final int limit;

  const GetMessagesParams({
    required this.chatId,
    this.before,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [chatId, before, limit];
}
