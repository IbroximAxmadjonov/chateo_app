import 'package:chateo_app/core/domain/use_case/use_case.dart';
import 'package:chateo_app/core/utils/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';


import '../entities/contacts_entity.dart';
import '../repositories/contacts_repository.dart';

class SearchContactsUseCase extends UseCase<List<ContactsEntity>, SearchContactsParams> {
  final ContactsRepository contactsRepository;

  SearchContactsUseCase({required this.contactsRepository});

  @override
  Future<Either<Failure, List<ContactsEntity>>> call(SearchContactsParams params) async {
    return contactsRepository.searchContacts(params.query);
  }
}

class SearchContactsParams extends Equatable {
  final String query;

  const SearchContactsParams({required this.query});

  @override
  List<Object?> get props => [query];
}
