import 'package:chateo_app/core/presentation/widgets/app_icon.dart';
import 'package:chateo_app/core/utils/theme_extension.dart';
import 'package:chateo_app/generated/assets.dart';
import 'package:chateo_app/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';


class NavigationPage extends StatelessWidget {
  const NavigationPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    // ValueKey on locale forces IndexedStack branch pages to rebuild when locale changes.
    return Scaffold(
      key: ValueKey(context.locale),
      body: navigationShell,
      bottomNavigationBar: Container(
        height: 83.h + MediaQuery.of(context).padding.bottom,
        decoration: BoxDecoration(
          color: context.appColors.surface,
          border: Border(
            top: BorderSide(color: context.appColors.onSurfaceVariant, width: 1.r),
          ),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              index: 0,
              icon: Assets.icons.contacts,
              labelText: LocaleKeys.contacts_title.tr(),
              context: context,
            ),
            _buildNavItem(
              index: 1,
              icon: Assets.icons.messageCircle,
              labelText: LocaleKeys.chats_title.tr(),
              context: context,
            ),
            _buildNavItem(
              index: 2,
              icon: Assets.icons.more,
              labelText: LocaleKeys.more_title.tr(),
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required SvgGenImage icon,
    required String labelText,
    required BuildContext context,
  }) {
    final isSelected = navigationShell.currentIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => navigationShell.goBranch(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected) ...[
              Text(labelText, style: context.appTextStyle.titleMedium),
              SizedBox(height: 4.h),
              Container(
                width: 4.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: context.appColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
            ] else ...[
              AppIcon(icon),
            ],
          ],
        ),
      ),
    );
  }
}
