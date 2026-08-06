part of 'auth_bloc.dart';

enum AuthAction { none, sendOtp, verifyOtp, logout }

class AuthState extends Equatable {
  final FormStatus status;
  final String? errorMessage;
  final String? successMessage;
  final String? phone;
  final Map<String, dynamic>? responseData;
  final String? otpCode;
  final AuthAction lastAction;
  final bool isNewUser;

  const AuthState({
    this.status = FormStatus.initial,
    this.errorMessage,
    this.successMessage,
    this.phone,
    this.responseData,
    this.otpCode,
    this.lastAction = AuthAction.none,
    this.isNewUser = false,
  });

  AuthState copyWith({
    FormStatus? status,
    String? errorMessage,
    String? successMessage,
    String? phone,
    Map<String, dynamic>? responseData,
    String? otpCode,
    AuthAction? lastAction,
    bool? isNewUser,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      phone: phone ?? this.phone,
      responseData: responseData ?? this.responseData,
      otpCode: otpCode ?? this.otpCode,
      lastAction: lastAction ?? this.lastAction,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    successMessage,
    phone,
    responseData,
    otpCode,
    lastAction,
    isNewUser,
  ];
}
