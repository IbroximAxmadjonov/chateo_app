import 'package:chateo_app/core/presentation/widgets/app_icon.dart';

import 'package:chateo_app/core/utils/theme_extension.dart';
import 'package:chateo_app/core/utils/themes/app_colors.dart';
import 'package:chateo_app/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../settings/profile/domain/entities/profile_entity.dart';
import '../../../settings/profile/presentation/manager/profile_bloc.dart';

class MoreProfileCard extends StatefulWidget {
  const MoreProfileCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<MoreProfileCard> createState() => _MoreProfileCardState();
}

class _MoreProfileCardState extends State<MoreProfileCard> {
  @override
  void initState() {
    super.initState();
    // Trigger load if profile data is not yet available
    _ensureLoaded();
  }

  void _ensureLoaded() {
    final state = context.read<ProfileBloc>().state;
    final hasData =
        state is ProfileLoaded ||
        state is ProfileCacheLoaded ||
        state is ProfileUpdated;

    if (!hasData) {
      context.read<ProfileBloc>().add(const LoadProfileRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        ProfileEntity? profile;
        if (state is ProfileCacheLoaded) {
          profile = state.profileEntity;
        } else if (state is ProfileLoaded) {
          profile = state.profileEntity;
        } else if (state is ProfileUpdated) {
          profile = state.profileEntity;
        }

        final String name = profile != null
            ? '${profile.firstName} ${profile.lastName}'.trim()
            : '';
        final String displayName = name.isNotEmpty ? name : 'Пользователь';
        final String phone = profile?.phoneNumber ?? '';

        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 24.w),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: NeutralColor.line, width: 1),
            ),
            child: Row(
              children: [
                /// Avatar
                CircleAvatar(
                  radius: 25.r,
                  backgroundColor: context.appColors.onSurfaceVariant,
                  backgroundImage:
                      (profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty)
                      ? NetworkImage(profile.avatarUrl!)
                      : null,
                  child: (profile?.avatarUrl == null || profile!.avatarUrl!.isEmpty)
                      ? AppIcon(Assets.icons.user)
                      : null,
                ),

                SizedBox(width: 12.w),

                /// Name & phone
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: context.appTextStyle.headlineSmall?.copyWith(
                          color: context.appColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (phone.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          phone,
                          style: context.appTextStyle.bodyLarge?.copyWith(
                            color: context.appColors.onSurface,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                AppIcon(Assets.icons.chevronRight),
              ],
            ),
          ),
        );
      },
    );
  }
}
