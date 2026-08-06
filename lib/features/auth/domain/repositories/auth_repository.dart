import 'package:chateo_app/core/utils/errors/failure.dart';
import 'package:dartz/dartz.dart';


abstract class AuthRepository {
  Future<Either<Failure, void>> sendOtp({
    required String phoneNumber,
  });

  Future<Either<Failure, Map<String, dynamic>>> verifyOtp({
    required String phone,
    required String code,
    // required String deviceId,
  });

  Future<Either<Failure, Map<String, dynamic>>> refreshToken({
    required String refreshToken,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, void>> deleteAccount();
}
