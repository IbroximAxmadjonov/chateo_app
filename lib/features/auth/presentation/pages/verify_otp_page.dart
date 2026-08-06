import 'package:chateo_app/core/data/network/form_status.dart';
import 'package:chateo_app/core/domain/routing/routes.dart';
import 'package:chateo_app/core/presentation/widgets/app_icon.dart';
import 'package:chateo_app/core/utils/theme_extension.dart';
import 'package:chateo_app/core/utils/themes/app_colors.dart';
import 'package:chateo_app/generated/assets.dart';
import 'package:chateo_app/generated/locale_keys.g.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

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

  final _codeController = TextEditingController();
  final _codeFocusNode = FocusNode();

  String get _code => _codeController.text;

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  void _submitCode() {
    context.read<AuthBloc>().add(
      AuthVerifyOtpRequested(phone: widget.phoneNumber, code: _code),
    );
  }

  void _resendCode() {
    _codeController.clear();
    context.read<AuthBloc>().add(
      AuthSendOtpRequested(phoneNumber: widget.phoneNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = context.appTextStyle;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.lastAction == AuthAction.verifyOtp) {
          if (state.status == FormStatus.failure) {
            _codeController.clear();
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
              context.push(AppRoutes.profile, extra: {'isNewUser': true});
            } else {
              context.go(AppRoutes.chats);
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

                        // ── OTP dots: тап открывает системную клавиатуру ─────────────
                        GestureDetector(
                          onTap: () => _codeFocusNode.requestFocus(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_otpLength, (i) {
                              return _OtpCell(
                                index: i,
                                code: _code,
                                isDark: isDark,
                                textStyle: textStyle,
                              );
                            }),
                          ),
                        ),

                        // Скрытый TextField — принимает ввод с системной клавиатуры (полностью невидимый)
                        Opacity(
                          opacity: 0.0,
                          child: SizedBox(
                            width: 1,
                            height: 1,
                            child: TextField(
                              controller: _codeController,
                              focusNode: _codeFocusNode,
                              autofocus: true,
                              showCursor: false,
                              style: const TextStyle(color: Colors.transparent),
                              keyboardType: TextInputType.number,
                              maxLength: _otpLength,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (value) {
                                setState(() {});
                                if (value.length == _otpLength) {
                                  _submitCode();
                                }
                              },
                              decoration: const InputDecoration(
                                counterText: '',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 40.h),

                        // ── Loading indicator ─────────────────────────────
                        if (isLoading)
                          SizedBox(
                            height: 24.h,
                            width: 24.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.appColors.primary,
                            ),
                          ),

                        SizedBox(height: isLoading ? 16.h : 48.h),

                        // ── Resend code ───────────────────────────────────
                        GestureDetector(
                          onTap: isLoading ? null : _resendCode,
                          child: Text(
                            LocaleKeys.auth_verify_otp_resend_code.tr(),
                            style: textStyle.titleMedium?.copyWith(
                              color: context.appColors.primary,
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

/// Одна ячейка OTP — либо показывает цифру, либо пустой кружок
class _OtpCell extends StatelessWidget {
  const _OtpCell({
    required this.index,
    required this.code,
    required this.isDark,
    required this.textStyle,
  });

  final int index;
  final String code;
  final bool isDark;
  final TextTheme textStyle;

  @override
  Widget build(BuildContext context) {
    final isFilled = index < code.length;
    final digit = isFilled ? code[index] : null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: SizedBox(
        width: 40.w,
        height: 52.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (digit != null)
              Text(
                digit,
                style: textStyle.displaySmall?.copyWith(fontWeight: FontWeight.w700),
              )
            else
              Container(
                width: 16.w,
                height: 16.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? NeutralColor.weak : NeutralColor.active,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
