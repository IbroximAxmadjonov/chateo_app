import 'package:chateo_app/core/data/network/form_status.dart';
import 'package:chateo_app/core/domain/routing/routes.dart';
import 'package:chateo_app/core/presentation/widgets/app_icon.dart';
import 'package:chateo_app/core/presentation/widgets/app_input_phone_number.dart';
import 'package:chateo_app/core/utils/theme_extension.dart';
import 'package:chateo_app/generated/assets.dart';
import 'package:chateo_app/generated/locale_keys.g.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../manager/auth_bloc.dart';

class SendOtpPage extends StatefulWidget {
  const SendOtpPage({super.key});

  @override
  State<SendOtpPage> createState() => _SendOtpPageState();
}

class _SendOtpPageState extends State<SendOtpPage> {
  final TextEditingController _controller = TextEditingController();
  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '## ### ## ##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = context.appTextStyle;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == FormStatus.failure &&
            state.lastAction == AuthAction.sendOtp) {
          debugPrint('${state.status}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Error occurred'),
              backgroundColor: Colors.red,
            ),
          );
        }
        if (state.status == FormStatus.success &&
            state.lastAction == AuthAction.sendOtp) {
          debugPrint('OTP Code Sent successfully', wrapWidth: 5);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.otpCode ?? 'OTP Code Sent successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate only after successful response, passing phoneNumber
          context.push(
            AppRoutes.verifyOtp,
            extra: {
              'phoneNumber': state.phone,
              'maskPhoneNumber': '+998 ${_controller.text}',
            },
          );
        }
      },
      builder: (context, state) {
        final isLoading =
            state.status == FormStatus.loading &&
            state.lastAction == AuthAction.sendOtp;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                context.pop();
              },
              icon: AppIcon(Assets.icons.chevronLeft),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Main Scrollable Area for Form
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 40.h),
                        SizedBox(
                          width: 295.w,
                          child: Text(
                            LocaleKeys.auth_enterPhoneNumber.tr(),
                            style: textStyle.displaySmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        SizedBox(
                          width: 295.w,
                          child: Text(
                            LocaleKeys.auth_confirmCountryCode.tr(),
                            style: textStyle.titleSmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 48.h),

                        AppInputPhoneNumber(
                          controller: _controller,
                          maskTextInputFormatter: _phoneMaskFormatter,
                          onChanged: (_) => setState(() {}),
                        ),
                        SizedBox(height: 80.h),

                        // Continue Button
                        ElevatedButton(
                          onPressed: _controller.text.isEmpty || isLoading
                              ? null
                              : () {
                                  final rawPhone = _controller.text.replaceAll(
                                    RegExp(r'\s+'),
                                    '',
                                  );
                                  final fullPhoneNumber = '+998$rawPhone';
                                  context.read<AuthBloc>().add(
                                    AuthSendOtpRequested(
                                      phoneNumber: fullPhoneNumber,
                                    ),
                                  );
                                  debugPrint('+998 ${_controller.text}');
                                  // Navigation is handled in the listener on success
                                },
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(LocaleKeys.auth_continueText.tr()),
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
