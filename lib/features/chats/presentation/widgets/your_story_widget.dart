import 'package:chateo_app/core/presentation/widgets/app_icon.dart';
import 'package:chateo_app/core/utils/theme_extension.dart';
import 'package:chateo_app/generated/assets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class YourStoryWidget extends StatelessWidget {
  const YourStoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56.w,
          height: 56.h,
          decoration: BoxDecoration(
            color: context.appColors.surfaceContainer,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: context.appColors.onSurfaceVariant,
              width: 1.r,
            ),
          ),
          child: Center(child: AppIcon(Assets.icons.plus)),
        ),
        SizedBox(height: 6.h),
        Text(
          'Your Story',
          style: context.appTextStyle.bodyMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
