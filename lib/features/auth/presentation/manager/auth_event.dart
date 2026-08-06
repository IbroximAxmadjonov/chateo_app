part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthSendOtpRequested extends AuthEvent {
  final String phoneNumber;

  const AuthSendOtpRequested({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

class AuthVerifyOtpRequested extends AuthEvent {
  final String phone;
  final String code;

  const AuthVerifyOtpRequested({required this.phone, required this.code});

  @override
  List<Object?> get props => [phone, code];
}

class AuthCheckStatusRequested extends AuthEvent {
  const AuthCheckStatusRequested();
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthDeleteAccountRequested extends AuthEvent {
  const AuthDeleteAccountRequested();
}

// class CheckAuthStatusEvent extends AuthEvent {
//   const CheckAuthStatusEvent();
// }
//
// class SignInWithGoogleEvent extends AuthEvent {
//   const SignInWithGoogleEvent();
// }
//
// class SignOutEvent extends AuthEvent {
//   const SignOutEvent();
// }
