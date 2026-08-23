import 'package:chateo_app/core/utils/theme_extension.dart';
import 'package:customized_keyboard/customized_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppNumericKeyboard extends CustomKeyboard {
  @override
  String get name => 'numeric';

  @override
  double get height => 308.h;

  @override
  Widget build(BuildContext context) {
    final values = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];
    return Material(
      color: context.appColors.surfaceContainer,
      child: GridView.count(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 14.w),
        crossAxisCount: 3,
        childAspectRatio: 1.6,
        children: [
          for (final value in values)
            CustomKeyboardKey(
              keyEvent: CustomKeyboardEvent.character(value),
              child: Center(
                child: Text(value, style: context.appTextStyle.displaySmall),
              ),
            ),
          CustomKeyboardKey(
            keyEvent: const CustomKeyboardEvent.submit(),
            child: const Icon(Icons.keyboard_alt),
          ),
          CustomKeyboardKey(
            keyEvent: CustomKeyboardEvent.character('0'),
            child: Center(
              child: Text('0', style: context.appTextStyle.displaySmall),
            ),
          ),
          CustomKeyboardKey(
            keyEvent: const CustomKeyboardEvent.deleteOne(),
            child: const Icon(Icons.backspace_outlined),
          ),
        ],
      ),
    );
  }
}
