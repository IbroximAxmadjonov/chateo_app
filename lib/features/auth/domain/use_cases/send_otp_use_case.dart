import 'package:chateo_app/core/domain/use_case/use_case.dart';
import 'package:chateo_app/core/utils/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../repositories/auth_repository.dart';

class SendOtpUseCase implements UseCase<void, SendOtpParams> {
  final AuthRepository authRepository;

  SendOtpUseCase({required this.authRepository});

  @override
  Future<Either<Failure, void>> call(
    SendOtpParams params,
  ) async {
    return await authRepository.sendOtp(phoneNumber: params.phoneNumber);
  }
}

class SendOtpParams extends Equatable {
  final String phoneNumber;

  const SendOtpParams({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}
