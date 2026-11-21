import 'package:chateo_app/core/data/network/form_status.dart';
import 'package:chateo_app/core/domain/routing/app_routes_path.dart';
import 'package:chateo_app/core/presentation/widgets/app_icon.dart';
import 'package:chateo_app/core/utils/theme_extension.dart';
import 'package:chateo_app/core/utils/themes/app_colors.dart';
import 'package:chateo_app/generated/assets.dart';
import 'package:chateo_app/generated/locale_keys.g.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../manager/auth_bloc.dart';

class VerifyOtpPage extends StatefulWidget {
  /// Номер телефона, на который был отправлен код (для отображения)
  final String phoneNumber;
  final String maskPhoneNumber;

  const VerifyOtpPage({
    super.key,
    required this.phoneNumber,
    required this.maskPhoneNumber,
  });

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  static const int _otpLength = 4;

  late final PinInputController _pinController;

  @override
  void initState() {
    super.initState();
    _pinController = PinInputController();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _submitCode([String? code]) {
    final verificationCode = code ?? _pinController.text;
    context.read<AuthBloc>().add(
      AuthVerifyOtpRequested(phone: widget.phoneNumber, code: verificationCode),
    );
  }

  void _resendCode() {
    _pinController.clear();
    context.read<AuthBloc>().add(
      AuthSendOtpRequested(phoneNumber: widget.phoneNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = context.appTextStyle;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = context.appColors.primary;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.lastAction == AuthAction.verifyOtp) {
          if (state.status == FormStatus.failure) {
            _pinController.clear();
            _pinController.triggerError();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ?? LocaleKeys.auth_verify_otp_invalid_code.tr(),
                ),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state.status == FormStatus.authenticated) {
            // Токены сохранены в AuthBloc — навигация на нужный экран
            if (state.isNewUser) {
              context.push(AppRoutesPath.profile, extra: {'isNewUser': true});
            } else {
              context.go(AppRoutesPath.chats);
            }
          }
        }
        if (state.lastAction == AuthAction.sendOtp &&
            state.status == FormStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(LocaleKeys.auth_verify_otp_code_resent.tr()),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == FormStatus.loading;
        final inactiveColor = isDark ? NeutralColor.weak : NeutralColor.active;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: AppIcon(Assets.icons.chevronLeft),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // ── Content ──────────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 40.h),

                        // Title
                        Text(
                          LocaleKeys.auth_verify_otp_enter_code.tr(),
                          style: textStyle.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.h),

                        // Subtitle with phone number
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            LocaleKeys.auth_verify_otp_sent_sms.tr(
                              namedArgs: {"phone": widget.maskPhoneNumber},
                            ),
                            style: textStyle.titleSmall?.copyWith(
                              color: isDark ? NeutralColor.weak : NeutralColor.body,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 48.h),

                        // ── OTP input (pin_code_fields) ───────────────────
                        PinInput(
                          length: _otpLength,
                          pinController: _pinController,
                          autoFocus: true,
                          keyboardType: TextInputType.number,
                          onCompleted: (pin) => _submitCode(pin),
                          builder: (context, cells) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: cells.map((cell) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                                  child: SizedBox(
                                    width: 40.w,
                                    height: 52.h,
                                    child: Center(
                                      child: cell.isFilled && cell.character != null
                                          ? Text(
                                              cell.character!,
                                              style: textStyle.displaySmall?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            )
                                          : Container(
                                              width: 16.w,
                                              height: 16.h,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: inactiveColor,
                                              ),
                                            ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),

                        SizedBox(height: 40.h),

                        // ── Loading indicator ─────────────────────────────
                        if (isLoading)
                          SizedBox(
                            height: 24.h,
                            width: 24.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: primaryColor,
                            ),
                          ),

                        SizedBox(height: isLoading ? 16.h : 48.h),

                        // ── Resend code ───────────────────────────────────
                        GestureDetector(
                          onTap: isLoading ? null : _resendCode,
                          child: Text(
                            LocaleKeys.auth_verify_otp_resend_code.tr(),
                            style: textStyle.titleMedium?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
