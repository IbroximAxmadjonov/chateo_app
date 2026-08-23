import 'package:chateo_app/core/domain/routing/app_routes_path.dart';
import 'package:chateo_app/generated/assets.dart';
import 'package:chateo_app/generated/locale_keys.g.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';


import '../widgets/more_profile_card.dart';
import '../widgets/more_settings_group.dart';
import '../widgets/more_settings_group_item.dart';

class MoreListPage extends StatelessWidget {
  const MoreListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Registers this widget as a dependent of EasyLocalization so it rebuilds on locale change.
    EasyLocalization.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.more_title.tr())),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MoreProfileCard(onTap: () => context.push(AppRoutesPath.profile)),

            SizedBox(height: 16.h),

            /// Settings list
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                children: [
                  MoreSettingsGroup(
                    items: [
                      MoreSettingsGroupItem(
                        asset: Assets.icons.user,
                        title: LocaleKeys.more_account.tr(),
                        onPressed: () => context.push(AppRoutesPath.account),
                      ),
                      MoreSettingsGroupItem(
                        asset: Assets.icons.messageCircle,
                        title: LocaleKeys.more_settingChats.tr(),
                        onPressed: () => context.push(AppRoutesPath.settingChats),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  MoreSettingsGroup(
                    items: [
                      MoreSettingsGroupItem(
                        asset: Assets.icons.sun,
                        title: LocaleKeys.more_appearance.tr(),
                        onPressed: () => context.push(AppRoutesPath.appearance),
                      ),
                      MoreSettingsGroupItem(
                        asset: Assets.icons.notification,
                        title: LocaleKeys.more_notification.tr(),
                        onPressed: () => context.push(AppRoutesPath.notification),
                      ),
                      MoreSettingsGroupItem(
                        asset: Assets.icons.outlinePrivacyTip,
                        title: LocaleKeys.more_privacy.tr(),
                        onPressed: () => context.push(AppRoutesPath.privacy),
                      ),
                      MoreSettingsGroupItem(
                        asset: Assets.icons.folder,
                        title: LocaleKeys.more_dataUsage.tr(),
                        onPressed: () => context.push(AppRoutesPath.dataUsage),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  MoreSettingsGroup(
                    items: [
                      MoreSettingsGroupItem(
                        asset: Assets.icons.helpCircle,
                        title: LocaleKeys.more_help.tr(),
                        onPressed: () => context.push(AppRoutesPath.help),
                      ),
                      MoreSettingsGroupItem(
                        asset: Assets.icons.mail,
                        title: LocaleKeys.more_inviteYourFriends.tr(),
                        onPressed: () => context.push(AppRoutesPath.inviteYourFriends),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
