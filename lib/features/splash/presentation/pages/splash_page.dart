import 'package:chateo_app/core/data/storage/auth_storage.dart';
import 'package:chateo_app/core/domain/routing/app_routes_name.dart';
import 'package:chateo_app/generated/assets.dart';
import 'package:chateo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _animationController.forward();

    // Navigate to appropriate screen after splash
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final authStorage = sl<AuthStorage>();
        if (authStorage.hasToken()) {
          context.goNamed(AppRoutesName.chats);
        } else {
          context.goNamed(AppRoutesName.walkThrough);
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: isDark
                ? Assets.images.chateoLogoDark.image(height: 80.h)
                : Assets.images.chateoLogoLight.image(height: 80.h),
          ),
        ),
      ),
    );
  }
}
