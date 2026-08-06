import 'package:chateo_app/core/presentation/widgets/app_icon.dart';
import 'package:chateo_app/core/utils/theme_extension.dart';
import 'package:chateo_app/generated/assets.dart';
import 'package:chateo_app/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 327.w,
      height: 36.h,
      child: SearchBar(
        controller: controller,
        onChanged: onChanged,
        hintText: LocaleKeys.search_title.tr(),
        textStyle: WidgetStateProperty.all(context.appTextStyle.titleSmall),
        leading: AppIcon(Assets.icons.search),
        trailing: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: onClear,
                child: AppIcon(Assets.icons.closeSmall),
              );
            },
          ),
        ],
      ),
    );
  }
}
