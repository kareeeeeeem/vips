import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/admin_theme.dart';
import '../controllers/admin_splash_controller.dart';

/// Adapted from `lib/appuser/modules/splash/views/splash_view.dart`.
/// Same elastic logo animation and loading indicator; recoloured to the
/// console's navy and captioned so it is obvious which app booted.
class AdminSplashView extends GetView<AdminSplashController> {
  const AdminSplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            _buildAnimatedLogo(),
            SizedBox(height: 24.h),
            Text(
              'VIPs Admin',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AdminColors.primary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Platform console',
              style: TextStyle(fontSize: 13.sp, color: AdminColors.textMuted),
            ),
            const Spacer(),
            _buildLoadingIndicator(),
            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 1),
      tween: Tween(begin: 0.5, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AdminColors.primary, AdminColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(32.r),
              boxShadow: [
                BoxShadow(
                  color: AdminColors.primary.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                color: Colors.white,
                width: 72.w,
                height: 72.h,
                // The consumer splash assumes this asset always resolves;
                // a missing logo here would leave a bare gradient box.
                errorBuilder: (_, __, ___) => Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.white,
                  size: 60.sp,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 32.w,
      height: 32.h,
      child: CircularProgressIndicator(
        valueColor: const AlwaysStoppedAnimation<Color>(AdminColors.primary),
        strokeWidth: 3.5.w,
      ),
    );
  }
}
