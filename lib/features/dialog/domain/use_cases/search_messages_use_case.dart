import 'package:chateo_app/core/utils/errors/failure.dart';
import 'package:chateo_app/features/dialog/domain/entities/dialog_entity.dart';
import 'package:chateo_app/features/dialog/domain/repositories/dialog_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class SearchMessagesUseCase {
  final DialogRepository dialogRepository;

  SearchMessagesUseCase({required this.dialogRepository});

  Future<Either<Failure, List<DialogEntity>>> call(
      SearchMessagesParams params) {
    return dialogRepository.searchMessages(
      chatId: params.chatId,
      query: params.query,
    );
  }
}

class SearchMessagesParams extends Equatable {
  final String chatId;
  final String query;

  const SearchMessagesParams({required this.chatId, required this.query});

  @override
  List<Object?> get props => [chatId, query];
}
