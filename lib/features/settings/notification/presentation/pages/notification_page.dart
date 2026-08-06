import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/utils/theme_extension.dart';
import '../../../../../../generated/locale_keys.g.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.more_notification.tr()),
        centerTitle: true,
      ),
      body: Center(
        child: Text(LocaleKeys.more_notification.tr(), style: context.appTextStyle.titleMedium),
      ),
    );
  }
}
