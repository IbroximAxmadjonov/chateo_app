import 'package:chateo_app/core/domain/repository/repository.dart';
import 'package:chateo_app/core/utils/errors/failure.dart';
import 'package:dartz/dartz.dart';

import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';

class AuthRepositoryImpl extends Repository implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;

  AuthRepositoryImpl({required this.authRemoteDataSource});

  @override
  Future<Either<Failure, void>> sendOtp({
    required String phoneNumber,
  }) {
    return performResponse(() async {
      await authRemoteDataSource.sendOtp(phoneNumber: phoneNumber);
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> verifyOtp({
    required String phone,
    required String code,
  }) {
    return performResponse(() async {
      return await authRemoteDataSource.verifyOtp(phone: phone, code: code);
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> refreshToken({
    required String refreshToken,
  }) {
    return performResponse(() async {
      return await authRemoteDataSource.refreshToken(refreshToken: refreshToken);
    });
  }

  @override
  Future<Either<Failure, void>> logout() {
    return performResponse(() async {
      return await authRemoteDataSource.logout();
    });
  }

  @override
  Future<Either<Failure, void>> deleteAccount() {
    return performResponse(() async {
      return await authRemoteDataSource.deleteAccount();
    });
  }
}
