import 'package:chateo_app/core/utils/theme_extension.dart';
import 'package:chateo_app/core/utils/themes/app_colors.dart';
import 'package:chateo_app/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class AppInputPhoneNumber extends StatelessWidget {
  const AppInputPhoneNumber({
    super.key,
    required this.controller,
    required this.maskTextInputFormatter,
    required this.onChanged,
    this.width,
    this.height,
  });

  final TextEditingController controller;
  final MaskTextInputFormatter maskTextInputFormatter;
  final ValueChanged<String> onChanged;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 327.w,
      height: height ?? 36.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Country Code Container (+998) ──────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? NeutralColor.dark
                  : NeutralColor.offWhite,
              borderRadius: BorderRadius.circular(8.r),
            ),
            alignment: Alignment.center,
            child: Text('+998', style: context.appTextStyle.titleMedium),
          ),
          SizedBox(width: 8.w),

          // ── Phone Input Field ──────────────────────────────────────────
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              autofocus: true,
              style: context.appTextStyle.titleMedium,
              textAlignVertical: TextAlignVertical.center,
              inputFormatters: [maskTextInputFormatter],
              onChanged: onChanged,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 8.h,
                ),
                hintText: LocaleKeys.auth_phoneNumberHint.tr(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
