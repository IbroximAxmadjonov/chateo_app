import 'package:dartz/dartz.dart';

import 'package:chateo_app/core/utils/errors/failure.dart';

import '../entities/contacts_entity.dart';

abstract class ContactsRepository {
  // Загрузка контактов
  Future<Either<Failure, List<ContactsEntity>>> getAllContacts();

  // Поиск пользователей в контакты
  Future<Either<Failure, List<ContactsEntity>>> searchContacts(String query);

  // Добавление пользователя в контакты
  Future<Either<Failure, void>> putContact({
    required String firstName,
    required String lastName,
    required String phoneNumber,
  });

  // Удаление контакта
  Future<Either<Failure, void>> removeContact(String contactId);

  // Stream'ы для реального времени
  Stream<Either<Failure, List<ContactsEntity>>> watchContacts();
}
