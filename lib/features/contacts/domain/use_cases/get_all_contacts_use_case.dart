import 'package:chateo_app/core/domain/use_case/use_case.dart';
import 'package:chateo_app/core/utils/errors/failure.dart';

import 'package:dartz/dartz.dart';

import '../entities/contacts_entity.dart';
import '../repositories/contacts_repository.dart';

class GetAllContactsUseCase extends UseCase<List<ContactsEntity>, NoParams> {
  final ContactsRepository contactsRepository;

  GetAllContactsUseCase({required this.contactsRepository});

  @override
  Future<Either<Failure, List<ContactsEntity>>> call(NoParams params) async {
    return await contactsRepository.getAllContacts();
  }
}
