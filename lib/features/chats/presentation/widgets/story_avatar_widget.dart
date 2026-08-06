import 'package:chateo_app/core/utils/theme_extension.dart';
import 'package:chateo_app/core/utils/themes/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class StoryAvatarWidget extends StatelessWidget {
  const StoryAvatarWidget({
    super.key,
    required this.username,
    this.avatarUrl,
    this.hasStory = false,
  });

  final String username;
  final String? avatarUrl;
  final bool hasStory;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar with story ring
        Container(
          width: 56.w,
          height: 56.h,
          padding: EdgeInsets.all(2.r),
          decoration: hasStory
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  gradient: GradientColor.variant1,
                )
              : null,
          child: Container(
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: BorderRadius.circular(14.r),
            ),
            padding: EdgeInsets.all(2.r),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? Image.network(
                      avatarUrl!,
                      width: 48.w,
                      height: 48.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildInitialsPlaceholder(context),
                    )
                  : _buildInitialsPlaceholder(context),
            ),
          ),
        ),
        SizedBox(height: 6.h),
        SizedBox(
          width: 56.w,
          child: Text(
            username,
            style: context.appTextStyle.titleSmall?.copyWith(
              color: context.appColors.secondary,
              fontSize: 11.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildInitialsPlaceholder(BuildContext context) {
    final initials = _getInitials(username);
    return Container(
      width: 48.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: context.appColors.primary,
        borderRadius: BorderRadius.circular(12.r),
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
    final cleanName = name.replaceAll(RegExp(r'\.\.\.'), '').trim();
    final parts = cleanName.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '';
  }
}
