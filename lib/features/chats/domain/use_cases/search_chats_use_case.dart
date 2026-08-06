import 'package:chateo_app/core/domain/use_case/use_case.dart';
import 'package:chateo_app/core/utils/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';


import '../entities/chats_entity.dart';
import '../repositories/chats_repository.dart';

class SearchChatsUseCase extends UseCase<List<ChatsEntity>, SearchChatsParams> {
  final ChatsRepository chatsRepository;

  SearchChatsUseCase({required this.chatsRepository});

  @override
  Future<Either<Failure, List<ChatsEntity>>> call(SearchChatsParams params) async {
    return await chatsRepository.searchChats(params.query);
  }
}

class SearchChatsParams extends Equatable {
  final String query;

  const SearchChatsParams({required this.query});

  @override
  List<Object?> get props => [query];
}
