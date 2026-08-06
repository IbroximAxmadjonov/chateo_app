import 'package:chateo_app/core/utils/theme_extension.dart';
import 'package:chateo_app/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppIcon extends StatelessWidget {
  final SvgGenImage asset;
  final double? size;
  final Color? color;

  const AppIcon(this.asset, {super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return asset.svg(
      height: size?.h ?? 24.h,
      width: size?.w ?? 24.w,
      color: color ?? context.appColors.secondary,
    );
  }
}
