import 'package:chateo_app/core/domain/use_case/use_case.dart';
import 'package:chateo_app/core/utils/errors/failure.dart';

import 'package:dartz/dartz.dart';

import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase extends UseCase<ProfileEntity, NoParams> {
  final ProfileRepository profileRepository;

  GetProfileUseCase({required this.profileRepository});

  @override
  Future<Either<Failure, ProfileEntity>> call(NoParams params) async {
    return await profileRepository.getProfile();
  }
}
