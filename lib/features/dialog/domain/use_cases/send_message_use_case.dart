import 'package:chateo_app/core/utils/errors/failure.dart';
import 'package:chateo_app/features/dialog/domain/entities/dialog_entity.dart';
import 'package:chateo_app/features/dialog/domain/repositories/dialog_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class SendMessageUseCase {
  final DialogRepository dialogRepository;

  SendMessageUseCase({required this.dialogRepository});

  Future<Either<Failure, DialogEntity>> call(SendMessageParams params) {
    return dialogRepository.sendMessage(
      chatId: params.chatId,
      type: params.type,
      content: params.content,
      mediaUrl: params.mediaUrl,
      duration: params.duration,
      replyToMessageId: params.replyToMessageId,
    );
  }
}

class SendMessageParams extends Equatable {
  final String chatId;
  final int type;
  final String? content;
  final String? mediaUrl;
  final int? duration;
  final String? replyToMessageId;

  const SendMessageParams({
    required this.chatId,
    required this.type,
    this.content,
    this.mediaUrl,
    this.duration,
    this.replyToMessageId,
  });

  @override
  List<Object?> get props =>
      [chatId, type, content, mediaUrl, duration, replyToMessageId];
}
