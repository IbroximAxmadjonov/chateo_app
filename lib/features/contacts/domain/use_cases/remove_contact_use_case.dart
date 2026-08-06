import 'package:chateo_app/core/domain/use_case/use_case.dart';
import 'package:chateo_app/core/utils/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';


import '../repositories/contacts_repository.dart';

class RemoveContactUseCase extends UseCase<void, RemoveContactParams> {
  final ContactsRepository contactsRepository;

  RemoveContactUseCase({required this.contactsRepository});

  @override
  Future<Either<Failure, void>> call(RemoveContactParams params) async {
    return await contactsRepository.removeContact(params.contactId);
  }
}

class RemoveContactParams extends Equatable {
  final String contactId;

  const RemoveContactParams({required this.contactId});

  @override
  List<Object?> get props => [contactId];
}
