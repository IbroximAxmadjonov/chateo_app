import 'package:chateo_app/core/domain/use_case/use_case.dart';
import 'package:chateo_app/core/utils/errors/failure.dart';
import 'package:dartz/dartz.dart';

import '../entities/contacts_entity.dart';
import '../repositories/contacts_repository.dart';

class WatchContactsUseCase {
  final ContactsRepository contactsRepository;

  WatchContactsUseCase({required this.contactsRepository});

  Stream<Either<Failure, List<ContactsEntity>>> call(NoParams params) {
    return contactsRepository.watchContacts();
  }
}
