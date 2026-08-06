import 'package:chateo_app/core/utils/errors/failure.dart';

import 'package:dartz/dartz.dart';

import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile();

  Future<Either<Failure, void>> putProfile({
    required String firstName,
    required String lastName,
    String? avatarUrl,
  });
}
