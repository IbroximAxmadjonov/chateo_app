import 'package:chateo_app/core/domain/use_case/use_case.dart';
import 'package:chateo_app/core/utils/errors/failure.dart';
import 'package:dartz/dartz.dart';


import '../repositories/contacts_repository.dart';

class PutContactUseCase extends UseCase<void, PutContactUseCaseParams> {
  final ContactsRepository contactsRepository;

  PutContactUseCase({required this.contactsRepository});

  @override
  Future<Either<Failure, void>> call(PutContactUseCaseParams params) async {
    return await contactsRepository.putContact(
      firstName: params.firstName,
      lastName: params.lastName,
      phoneNumber: params.phoneNumber,
    );
  }
}

class PutContactUseCaseParams {
  final String firstName;
  final String lastName;
  final String phoneNumber;

  PutContactUseCaseParams({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
  });
}
