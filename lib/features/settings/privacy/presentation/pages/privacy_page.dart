import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/utils/theme_extension.dart';
import '../../../../../../generated/locale_keys.g.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.more_privacy.tr()), centerTitle: true),
      body: Center(
        child: Text(
          LocaleKeys.more_privacy.tr(),
          style: context.appTextStyle.titleMedium,
        ),
      ),
    );
  }
}
