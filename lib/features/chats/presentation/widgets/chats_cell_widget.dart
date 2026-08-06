import 'package:chateo_app/core/utils/theme_extension.dart';
import 'package:chateo_app/core/utils/themes/app_colors.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatsCell extends StatelessWidget {
  const ChatsCell({
    super.key,
    required this.username,
    required this.lastMessage,
    required this.avatarUrl,
    required this.isOnline,
    required this.lastSeen,
    required this.unreadCount,
  });

  final String username;
  final String lastMessage;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime? lastSeen;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 327.w,
        height: 56.h,
        child: Row(
          children: [
            // ── Avatar with online indicator ───────────────────────────────
            _buildAvatar(context),
            SizedBox(width: 12.w),

            // ── Name + Last message ────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    username,
                    style: context.appTextStyle.headlineSmall?.copyWith(
                      color: context.appColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    lastMessage,
                    style: context.appTextStyle.bodyLarge?.copyWith(
                      color: context.appColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            // ── Date + Unread badge ────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatDate(lastSeen),
                  style: context.appTextStyle.bodyLarge?.copyWith(
                    color: context.appColors.onSurface,
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                if (unreadCount > 0)
                  Container(
                    width: 20.r,
                    height: 20.r,
                    decoration: BoxDecoration(
                      color: context.appColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$unreadCount',
                        style: TextStyle(
                          color: context.appColors.onPrimary,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(height: 20.r),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    Widget avatarContent;
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      avatarContent = Image.network(
        avatarUrl!,
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

    return SizedBox(
      width: 56.w,
      height: 56.h,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          SizedBox(width: 48.w, height: 48.h, child: avatarContent),
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
    final initials = _getInitials(username);
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
          color: NeutralColor.white,
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

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);

    if (dateDay == today) {
      final hourStr = date.hour.toString().padLeft(2, '0');
      final minuteStr = date.minute.toString().padLeft(2, '0');
      return '$hourStr:$minuteStr';
    }

    final dayStr = date.day.toString().padLeft(2, '0');
    final monthStr = date.month.toString().padLeft(2, '0');
    return '$dayStr/$monthStr';
  }
}
