import 'package:chateo_app/core/domain/repository/repository.dart';
import 'package:chateo_app/core/utils/errors/failure.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../data_sources/profile_remote_data_source.dart';

class ProfileRepositoryImpl extends Repository implements ProfileRepository {
  final ProfileRemoteDataSource profileRemoteDataSource;

  ProfileRepositoryImpl({required this.profileRemoteDataSource});

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    return performResponse(() async {
      final result = await profileRemoteDataSource.getProfile();
      return result.toEntity;
    });
  }

  @override
  Future<Either<Failure, void>> putProfile({
    required String firstName,
    required String lastName,
    String? avatarUrl,
  }) async {
    return await performResponse(() async {
      await profileRemoteDataSource.putProfile(
        firstName: firstName,
        lastName: lastName,
        avatarUrl: avatarUrl,
      );
    });
  }
}
