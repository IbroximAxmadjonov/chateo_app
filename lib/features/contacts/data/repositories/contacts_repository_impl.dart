import 'package:chateo_app/core/domain/repository/repository.dart';
import 'package:chateo_app/core/utils/errors/failure.dart';

import 'package:dartz/dartz.dart';

import '../../domain/entities/contacts_entity.dart';
import '../../domain/repositories/contacts_repository.dart';
import '../data_sources/contacts_remote_data_source.dart';

class ContactsRepositoryImpl extends Repository implements ContactsRepository {
  final ContactsRemoteDataSource contactsRemoteDataSource;

  ContactsRepositoryImpl({required this.contactsRemoteDataSource});

  /// ── Futures ──────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<ContactsEntity>>> getAllContacts() {
    return performResponse(() async {
      final models = await contactsRemoteDataSource.getAllContacts();
      return models.map((e) => e.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, List<ContactsEntity>>> searchContacts(String query) {
    return performResponse(() async {
      final models = await contactsRemoteDataSource.searchContacts(query);
      return models.map((e) => e.toEntity).toList();
    });
  }

  @override
  Future<Either<Failure, void>> putContact({
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) {
    return performResponse(
      () async => await contactsRemoteDataSource.putContact(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> removeContact(String contactId) {
    return performResponse(
      () async => await contactsRemoteDataSource.removeContact(contactId),
    );
  }

  /// ── Streams ──────────────────────────────────────────────────────────────

  @override
  Stream<Either<Failure, List<ContactsEntity>>> watchContacts() {
    return performResponseStream(() {
      return contactsRemoteDataSource.watchContacts().map(
        (models) => models.map((e) => e.toEntity).toList(),
      );
    });
  }
}
