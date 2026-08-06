import 'dart:async';

import 'package:chateo_app/core/data/network/form_status.dart';
import 'package:chateo_app/core/domain/use_case/use_case.dart';
import 'package:chateo_app/core/data/storage/auth_storage.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/use_cases/delete_account_use_case.dart';
import '../../domain/use_cases/logout_use_case.dart';
import '../../domain/use_cases/send_otp_use_case.dart';
import '../../domain/use_cases/verify_otp_use_case.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final LogoutUseCase logoutUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;
  final AuthStorage authStorage;

  AuthBloc({
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
    required this.logoutUseCase,
    required this.deleteAccountUseCase,
    required this.authStorage,
  }) : super(const AuthState()) {
    on<AuthSendOtpRequested>(_onSendOtpRequested);
    on<AuthVerifyOtpRequested>(_onVerifyOtpRequested);
    on<AuthCheckStatusRequested>(_onCheckStatusRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthDeleteAccountRequested>(_onDeleteAccountRequested);
  }

  FutureOr<void> _onSendOtpRequested(
    AuthSendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      AuthState(
        status: FormStatus.loading,
        phone: event.phoneNumber,
        lastAction: AuthAction.sendOtp,
      ),
    );

    final result = await sendOtpUseCase(
      SendOtpParams(phoneNumber: event.phoneNumber),
    );

    result.fold(
      (failure) {
        debugPrint('_onSendOtpRequested: ${failure.message}');
        emit(
          AuthState(
            status: FormStatus.failure,
            phone: event.phoneNumber,
            errorMessage: failure.message,
            lastAction: AuthAction.sendOtp,
          ),
        );
      },
      (_) {
        // Сервер вернул 204 No Content — OTP отправлен успешно.
        emit(
          AuthState(
            status: FormStatus.success,
            phone: event.phoneNumber,
            successMessage: 'OTP-код успешно отправлен',
            lastAction: AuthAction.sendOtp,
          ),
        );
      },
    );
  }

  FutureOr<void> _onVerifyOtpRequested(
    AuthVerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: FormStatus.loading,
        errorMessage: null,
        successMessage: null,
        lastAction: AuthAction.verifyOtp,
      ),
    );

    final result = await verifyOtpUseCase.call(
      VerifyOtpParams(phone: event.phone, code: event.code),
    );

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            status: FormStatus.failure,
            errorMessage: failure.message,
            lastAction: AuthAction.verifyOtp,
          ),
        );
      },
      (data) async {
        final accessToken = data['accessToken'] as String?;
        final refreshToken = data['refreshToken'] as String?;
        final isNewUser = data['isNewUser'] as bool? ?? false;

        if (accessToken == null || refreshToken == null) {
          debugPrint('❌ verifyOtp: tokens missing in response: $data');
          emit(
            state.copyWith(
              status: FormStatus.failure,
              errorMessage: 'Serverdan token kelmadi',
              lastAction: AuthAction.verifyOtp,
            ),
          );
          return;
        }

        await authStorage.saveTokens(accessToken, refreshToken);
        debugPrint('✅ verifyOtp success. isNewUser: $isNewUser');

        emit(
          state.copyWith(
            status: FormStatus.authenticated,
            lastAction: AuthAction.verifyOtp,
            isNewUser: isNewUser,
          ),
        );
      },
    );
  }

  FutureOr<void> _onCheckStatusRequested(
    AuthCheckStatusRequested event,
    Emitter<AuthState> emit,
  ) {
    final token = authStorage.getAccessToken;
    if (token != null && token.isNotEmpty) {
      emit(state.copyWith(status: FormStatus.authenticated));
    } else {
      emit(const AuthState(status: FormStatus.unauthenticated));
    }
  }

  FutureOr<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: FormStatus.loading));
    try {
      await logoutUseCase(NoParams());
    } catch (_) {}
    await authStorage.deleteTokens();
    emit(const AuthState(status: FormStatus.unauthenticated));
  }

  FutureOr<void> _onDeleteAccountRequested(
    AuthDeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: FormStatus.loading));
    final result = await deleteAccountUseCase(NoParams());
    await result.fold(
      (failure) async {
        emit(
          state.copyWith(status: FormStatus.failure, errorMessage: failure.message),
        );
      },
      (_) async {
        await authStorage.deleteTokens();
        emit(const AuthState(status: FormStatus.unauthenticated));
      },
    );
  }

  // AuthBloc() : super(const AuthInitial()) {
  //   on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  //   on<SignInWithGoogleEvent>(_onSignInWithGoogle);
  //   on<SignOutEvent>(_onSignOut);
  // }
  //
  // AuthRepository get _repository => serviceLocator<AuthRepository>();
  //
  // Future<void> _onCheckAuthStatus(
  //     CheckAuthStatusEvent event,
  //     Emitter<AuthState> emit,
  //     ) async {
  //   emit(const AuthLoading());
  //
  //   final result = await _repository.getCurrentUser();
  //   result.fold((failure) => emit(AuthError(failure.runtimeType.toString())), (
  //       user,
  //       ) {
  //     if (user == null) {
  //       emit(const AuthUnauthenticated());
  //       return;
  //     }
  //     emit(AuthAuthenticated(user));
  //   });
  // }
  //
  // Future<void> _onSignInWithGoogle(
  //     SignInWithGoogleEvent event,
  //     Emitter<AuthState> emit,
  //     ) async {
  //   emit(const AuthLoading());
  //
  //   final useCase = google_uc.SignInWithGoogleUseCase(_repository);
  //   final result = await useCase(google_uc.NoParams());
  //
  //   result.fold((failure) => emit(AuthError(failure.runtimeType.toString())), (
  //       user,
  //       ) {
  //     if (user == null) {
  //       emit(const AuthUnauthenticated());
  //       return;
  //     }
  //     emit(AuthAuthenticated(user));
  //   });
  // }
  //
  // Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
  //   emit(const AuthLoading());
  //
  //   final useCase = sign_out_uc.SignOutUseCase(_repository);
  //   await useCase(sign_out_uc.NoParams());
  //
  //   emit(const AuthUnauthenticated());
  // }
}
