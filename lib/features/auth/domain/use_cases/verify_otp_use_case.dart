import 'package:chateo_app/core/domain/use_case/use_case.dart';
import 'package:chateo_app/core/utils/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';


import '../repositories/auth_repository.dart';

class VerifyOtpUseCase
    implements UseCase<Map<String, dynamic>, VerifyOtpParams> {
  final AuthRepository authRepository;

  VerifyOtpUseCase({required this.authRepository});

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    VerifyOtpParams params,
  ) async {
    return await authRepository.verifyOtp(
      phone: params.phone,
      code: params.code,
      // deviceId: params.deviceId,
    );
  }
}

class VerifyOtpParams extends Equatable {
  final String phone;
  final String code;
  // final String deviceId;

  const VerifyOtpParams({
    required this.phone,
    required this.code,
    // required this.deviceId,
  });

  @override
  List<Object?> get props => [phone, code, ];
}
