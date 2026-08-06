import 'package:chateo_app/core/domain/use_case/use_case.dart';
import 'package:chateo_app/core/utils/errors/failure.dart';
import 'package:dartz/dartz.dart';

import '../repositories/profile_repository.dart';

class PutProfileUseCase extends UseCase<void, PutProfileUseCaseParams> {
  final ProfileRepository profileRepository;

  PutProfileUseCase({required this.profileRepository});

  @override
  Future<Either<Failure, void>> call(PutProfileUseCaseParams params) async {
    return await profileRepository.putProfile(
      firstName: params.firstName,
      lastName: params.lastName,
      avatarUrl: params.avatarUrl,
    );
  }
}

class PutProfileUseCaseParams {
  final String firstName;
  final String lastName;
  final String? avatarUrl;

  PutProfileUseCaseParams({
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
  });
}
