import 'package:chateo_app/core/utils/theme_extension.dart';
import 'package:chateo_app/core/utils/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Переиспользуемая числовая клавиатура.
///
/// [onKeyTap]  — вызывается при нажатии цифры (передаётся строка "0"–"9").
/// [onBackspace] — вызывается при нажатии кнопки удаления.
class AppCustomKeyboard extends StatelessWidget {
  const AppCustomKeyboard({
    super.key,
    required this.onKeyTap,
    required this.onBackspace,
  });

  final void Function(String value) onKeyTap;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textStyle = context.appTextStyle;

    return Container(
      color: isDark ? NeutralColor.dark : NeutralColor.offWhite,
      padding: EdgeInsets.only(top: 16.h, bottom: 20.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRow(['1', '2', '3'], context, textStyle),
            SizedBox(height: 8.h),
            _buildRow(['4', '5', '6'], context, textStyle),
            SizedBox(height: 8.h),
            _buildRow(['7', '8', '9'], context, textStyle),
            SizedBox(height: 8.h),
            Row(
              children: [
                const Expanded(child: SizedBox()),
                _buildDigitKey('0', context, textStyle),
                _buildBackspaceKey(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<String> keys, BuildContext context, TextTheme textStyle) {
    return Row(
      children: keys.map((k) => _buildDigitKey(k, context, textStyle)).toList(),
    );
  }

  Widget _buildDigitKey(String value, BuildContext context, TextTheme textStyle) {
    return Expanded(
      child: InkWell(
        onTap: () => onKeyTap(value),
        borderRadius: BorderRadius.circular(30.r),
        child: Container(
          height: 48.h,
          alignment: Alignment.center,
          child: Text(
            value,
            style: textStyle.displaySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onBackspace,
        borderRadius: BorderRadius.circular(30.r),
        child: Container(
          height: 48.h,
          alignment: Alignment.center,
          child: Icon(
            Icons.backspace_outlined,
            color: context.appColors.secondary,
            size: 24.sp,
          ),
        ),
      ),
    );
  }
}
