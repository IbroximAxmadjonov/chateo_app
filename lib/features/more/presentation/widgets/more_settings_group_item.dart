import 'package:chateo_app/core/presentation/widgets/app_icon.dart';
import 'package:chateo_app/core/utils/theme_extension.dart';
import 'package:chateo_app/generated/assets.dart';
import 'package:flutter/material.dart';

class MoreSettingsGroupItem extends StatelessWidget {
  final SvgGenImage asset;
  final String title;
  final void Function() onPressed;

  const MoreSettingsGroupItem({
    super.key,
    required this.asset,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPressed,
      leading: AppIcon(asset),
      title: Text(title, style: context.appTextStyle.titleMedium),
      trailing: AppIcon(Assets.icons.chevronRight),
    );
  }
}
