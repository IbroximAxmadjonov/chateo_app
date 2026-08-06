import 'package:chateo_app/core/domain/routing/routes.dart';
import 'package:chateo_app/core/utils/theme_extension.dart';
import 'package:chateo_app/generated/assets.dart';
import 'package:chateo_app/generated/locale_keys.g.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class WalkThrough extends StatelessWidget {
  const WalkThrough({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = context.appTextStyle;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final illustration = isDark
        ? Assets.images.illustrationDark
        : Assets.images.illustrationLight;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0.w),
          child: Column(
            children: [
              const Spacer(),
              illustration.svg(width: 262.w, height: 271.h),
              SizedBox(height: 42.h),
              SizedBox(
                width: 280.w,
                child: Text(
                  LocaleKeys.onBoarding_connect.tr(),
                  style: textStyle.displaySmall,
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: context.appColors.secondary,
                  textStyle: textStyle.titleSmall,
                  minimumSize: Size.zero,
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  LocaleKeys.onBoarding_termsAndPrivacy.tr(),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 18.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push(AppRoutes.sentOtp),
                  child: Text(LocaleKeys.onBoarding_startMessaging.tr()),
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
