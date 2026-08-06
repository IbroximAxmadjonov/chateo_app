
import 'package:chateo_app/core/utils/theme_extension.dart';
import 'package:chateo_app/core/utils/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Cell extends StatelessWidget {
  const Cell({
    super.key,
    required this.dataTitle,
    required this.dataDate,
    this.dataUrlAvatar,
    this.isOnline = false,
    this.hasStory = false,
  });

  final String dataTitle;
  final String dataDate;
  final String? dataUrlAvatar;
  final bool isOnline;
  final bool hasStory;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 327.w,
        height: 56.h,
        child: Row(
          children: [
            // Avatar (56x56 area to align text X-offset consistently)
            _buildAvatar(context),
            SizedBox(width: 16.w),
            // Text Column (Name & Status)
            Expanded(
              child: SizedBox(
                height: 56.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dataTitle,
                      style: context.appTextStyle.headlineSmall?.copyWith(
                        color: context.appColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      dataDate,
                      style: context.appTextStyle.bodyLarge?.copyWith(
                        color: context.appColors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    Widget avatarContent;
    if (dataUrlAvatar != null && dataUrlAvatar!.isNotEmpty) {
      avatarContent = Image.network(
        dataUrlAvatar!,
        width: 48.w,
        height: 48.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildInitialsPlaceholder(context),
      );
    } else {
      avatarContent = _buildInitialsPlaceholder(context);
    }

    avatarContent = ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: avatarContent,
    );

    if (hasStory) {
      avatarContent = Container(
        width: 56.w,
        height: 56.h,
        decoration: BoxDecoration(
          border: Border.all(color: context.appColors.primary, width: 2.r),
          borderRadius: BorderRadius.circular(20.r),
        ),
        padding: EdgeInsets.all(2.r),
        child: avatarContent,
      );
    } else {
      avatarContent = SizedBox(width: 48.w, height: 48.h, child: avatarContent);
    }

    return SizedBox(
      width: 56.w,
      height: 56.h,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          avatarContent,
          if (isOnline)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 14.r,
                height: 14.r,
                decoration: BoxDecoration(
                  color: AccentColor.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.appColors.surface, width: 2.r),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInitialsPlaceholder(BuildContext context) {
    final initials = _getInitials(dataTitle);
    return Container(
      width: 48.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: context.appColors.primary,
        borderRadius: BorderRadius.circular(16.r),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: context.appTextStyle.headlineSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}
