import 'package:chateo_app/core/utils/theme_extension.dart';
import 'package:chateo_app/features/dialog/domain/entities/dialog_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

/// A single message bubble.
/// [isMe] — whether the message belongs to the current user.
class MessageBubbleWidget extends StatelessWidget {
  const MessageBubbleWidget({
    super.key,
    required this.message,
    required this.isMe,
    this.replyToMessage,
  });

  final DialogEntity message;
  final bool isMe;

  /// If not null, shows a reply quote inside the bubble.
  final DialogEntity? replyToMessage;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 280.w),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: isMe ? context.appColors.primary : context.appColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(isMe ? 16.r : 4.r),
            bottomRight: Radius.circular(isMe ? 4.r : 16.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Reply quote ────────────────────────────────────────────────
            if (replyToMessage != null) _buildReplyQuote(context),

            // ── Content: text / image / audio ──────────────────────────────
            _buildContent(context),

            // ── Timestamp + status ─────────────────────────────────────────
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  // ── Reply quote ─────────────────────────────────────────────────────────────

  Widget _buildReplyQuote(BuildContext context) {
    final reply = replyToMessage!;
    final textColor =
        isMe ? Colors.white.withValues(alpha: 0.9) : context.appColors.secondary;
    final borderColor =
        isMe ? Colors.white.withValues(alpha: 0.6) : context.appColors.primary;

    return Container(
      margin: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 0),
      padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 6.h),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: borderColor, width: 3.w),
        ),
        color: (isMe ? Colors.white : context.appColors.primary)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.horizontal(right: Radius.circular(8.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reply.senderFirstName.isNotEmpty ? reply.senderFirstName : 'You',
            style: context.appTextStyle.bodySmall?.copyWith(
              color: borderColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            reply.content ?? '',
            style:
                context.appTextStyle.bodyLarge?.copyWith(color: textColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Main content ────────────────────────────────────────────────────────────

  Widget _buildContent(BuildContext context) {
    switch (message.type) {
      case 2: // Image
        return _buildImageContent(context);
      case 3: // Audio
        return _buildAudioContent(context);
      default: // Text (1 or 0)
        return _buildTextContent(context);
    }
  }

  Widget _buildTextContent(BuildContext context) {
    final textColor =
        isMe ? Colors.white : context.appColors.secondary;
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 4.h),
      child: Text(
        message.content ?? '',
        style: context.appTextStyle.titleSmall?.copyWith(color: textColor),
      ),
    );
  }

  Widget _buildImageContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.mediaUrl != null && message.mediaUrl!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(16.r),
              bottom: Radius.zero,
            ),
            child: Image.network(
              message.mediaUrl!,
              width: 280.w,
              height: 200.h,
              fit: BoxFit.cover,
              errorBuilder: (ctx, e, s) => Container(
                width: 280.w,
                height: 200.h,
                color: context.appColors.surfaceContainer,
                child: Icon(Icons.broken_image_outlined,
                    color: context.appColors.onSurface),
              ),
            ),
          ),
        if (message.content != null && message.content!.isNotEmpty)
          _buildTextContent(context),
      ],
    );
  }

  Widget _buildAudioContent(BuildContext context) {
    final duration = message.duration ?? 0;
    final minutes = (duration ~/ 60).toString().padLeft(1, '0');
    final seconds = (duration % 60).toString().padLeft(2, '0');
    final timeStr = '0:$minutes:$seconds'.replaceFirst('0:', '');

    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 4.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play button
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: isMe
                  ? Colors.white.withValues(alpha: 0.3)
                  : context.appColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              color: isMe ? Colors.white : context.appColors.primary,
              size: 22.r,
            ),
          ),
          SizedBox(width: 8.w),
          // Duration + Waveform bars
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Simulated waveform
                _buildWaveform(context),
                SizedBox(height: 2.h),
                Text(
                  timeStr,
                  style: context.appTextStyle.bodyLarge?.copyWith(
                    color: isMe
                        ? Colors.white.withValues(alpha: 0.7)
                        : context.appColors.onSurface,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform(BuildContext context) {
    const barHeights = [
      0.4, 0.7, 0.5, 1.0, 0.8, 0.6, 0.9, 0.5, 0.7, 0.4, 0.8, 0.6,
      1.0, 0.5, 0.7, 0.9, 0.4, 0.6, 0.8, 0.5,
    ];
    final barColor =
        isMe ? Colors.white.withValues(alpha: 0.8) : context.appColors.primary;

    return SizedBox(
      height: 24.h,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: barHeights.map((h) {
          return Container(
            width: 2.5.w,
            height: 24.h * h,
            margin: EdgeInsets.only(right: 2.w),
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(1.r),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Footer: time + status ───────────────────────────────────────────────────

  Widget _buildFooter(BuildContext context) {
    final timeStr = DateFormat('HH:mm').format(message.createdAt.toLocal());
    final metaColor = isMe
        ? Colors.white.withValues(alpha: 0.7)
        : context.appColors.onSurface;

    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 2.h, 12.w, 8.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            timeStr,
            style: context.appTextStyle.bodyMedium?.copyWith(color: metaColor),
          ),
          if (isMe) ...[
            SizedBox(width: 4.w),
            Text(
              message.myStatus == 1 ? 'Read' : 'Sent',
              style:
                  context.appTextStyle.bodyMedium?.copyWith(color: metaColor),
            ),
          ],
        ],
      ),
    );
  }
}

/// Date separator widget shown between messages of different days.
class DateSeparatorWidget extends StatelessWidget {
  const DateSeparatorWidget({super.key, required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(date.year, date.month, date.day);

    String label;
    if (msgDay == today) {
      label = 'Today';
    } else if (today.difference(msgDay).inDays == 1) {
      label = 'Yesterday';
    } else {
      label = DateFormat('EEE, d/MM').format(date);
    }

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: context.appColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          label,
          style: context.appTextStyle.bodyLarge?.copyWith(
            color: context.appColors.onSurface,
          ),
        ),
      ),
    );
  }
}
