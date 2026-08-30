import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../controllers/admin_auth_controller.dart';

/// Adapted from `lib/appuser/modules/login/views/login_view.dart`.
///
/// Kept: the layout, the filled rounded inputs, the visibility toggle, the
/// loading button. Removed on purpose: social sign-in, phone sign-in,
/// "Continue as Guest" and the sign-up link — an admin account exists only
/// because another admin (or the create-admin script) made it, so every one
/// of those would have been a button that could never work here.
class AdminLoginView extends GetView<AdminAuthController> {
  const AdminLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              // The console is expected to run on a tablet as often as a
              // phone; without a cap the form stretches to a full-width
              // ribbon on a large screen.
              constraints: BoxConstraints(maxWidth: 460.w),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLogo(),
                    SizedBox(height: 32.h),
                    _buildWelcomeText(),
                    SizedBox(height: 32.h),
                    _buildEmailInput(),
                    SizedBox(height: 16.h),
                    _buildPasswordInput(),
                    SizedBox(height: 28.h),
                    _buildSignInButton(),
                    SizedBox(height: 24.h),
                    _buildFooterNote(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 84.w,
      height: 84.w,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AdminColors.primary, AdminColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Center(
        child: Image.asset(
          'assets/images/logo.png',
          color: Colors.white,
          width: 48.w,
          height: 48.w,
          errorBuilder: (_, __, ___) => Icon(
            Icons.admin_panel_settings_rounded,
            color: Colors.white,
            size: 40.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'Admin Sign In',
          style: TextStyle(
            fontSize: 26.sp,
            fontWeight: FontWeight.w800,
            color: AdminColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'VIPs platform console',
          style: TextStyle(fontSize: 14.sp, color: AdminColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildEmailInput() {
    return TextField(
      controller: controller.emailController,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      textInputAction: TextInputAction.next,
      style: TextStyle(fontSize: 15.sp, color: AdminColors.textPrimary),
      decoration: _fieldDecoration(
        hint: 'Admin email',
        icon: Icons.alternate_email_rounded,
      ),
    );
  }

  Widget _buildPasswordInput() {
    return Obx(
      () => TextField(
        controller: controller.passwordController,
        obscureText: !controller.isPasswordVisible.value,
        autofillHints: const [AutofillHints.password],
        textInputAction: TextInputAction.done,
        // Submitting from the keyboard runs the same path as the button, so
        // the return key is not a dead end on a hardware keyboard.
        onSubmitted: (_) => controller.login(),
        style: TextStyle(fontSize: 15.sp, color: AdminColors.textPrimary),
        decoration: _fieldDecoration(
          hint: 'Password',
          icon: Icons.lock_outline_rounded,
          suffix: IconButton(
            icon: Icon(
              controller.isPasswordVisible.value
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AdminColors.textMuted,
              size: 20.sp,
            ),
            onPressed: controller.togglePasswordVisibility,
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 15.sp, color: AdminColors.textMuted),
      prefixIcon: Icon(icon, color: AdminColors.primary, size: 20.sp),
      suffixIcon: suffix,
      filled: true,
      fillColor: AdminColors.background,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AdminColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AdminColors.primary, width: 1.6),
      ),
    );
  }

  Widget _buildSignInButton() {
    return Obx(() => AdminButton(
          label: 'Sign In',
          icon: Icons.login_rounded,
          isLoading: controller.isLoading.value,
          onPressed: controller.login,
        ));
  }

  Widget _buildFooterNote() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AdminColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AdminColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18.sp, color: AdminColors.textMuted),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Console access is granted by an existing administrator. '
              'There is no self-service sign-up — contact your platform '
              'administrator if you need an account.',
              style: TextStyle(
                fontSize: 11.5.sp,
                height: 1.45,
                color: AdminColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
