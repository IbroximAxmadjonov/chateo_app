import 'package:chateo_app/core/utils/theme_extension.dart';
import 'package:chateo_app/core/utils/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'more_settings_group_item.dart';

class MoreSettingsGroup extends StatelessWidget {
  const MoreSettingsGroup({super.key, required this.items});

  final List<MoreSettingsGroupItem> items;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.appColors.surface,
      borderRadius: BorderRadius.circular(16.r),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: NeutralColor.line, width: 1),
        ),
        child: Column(children: items),
      ),
    );
  }
}
