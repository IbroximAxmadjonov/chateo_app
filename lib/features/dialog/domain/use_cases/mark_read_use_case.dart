import 'package:chateo_app/core/utils/errors/failure.dart';
import 'package:chateo_app/features/dialog/domain/repositories/dialog_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class MarkReadUseCase {
  final DialogRepository dialogRepository;

  MarkReadUseCase({required this.dialogRepository});

  Future<Either<Failure, void>> call(MarkReadParams params) {
    return dialogRepository.markMessagesRead(
      chatId: params.chatId,
      upToMessageId: params.upToMessageId,
    );
  }
}

class MarkReadParams extends Equatable {
  final String chatId;
  final String upToMessageId;

  const MarkReadParams({
    required this.chatId,
    required this.upToMessageId,
  });

  @override
  List<Object?> get props => [chatId, upToMessageId];
}
