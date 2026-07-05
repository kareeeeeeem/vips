import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../design_system/atoms/app_colors.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LoginController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40.h),
                _buildLogo(),
                SizedBox(height: 40.h),
                _buildWelcomeText(),
                SizedBox(height: 40.h),
                _buildLoginForm(),
                SizedBox(height: 30.h),
                _buildSocialLogins(),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: _buildSignUpLink(),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: 70.w,
      height: 70.h,
      child: Center(
        child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          'Please sign in to continue',
          style: TextStyle(fontSize: 16.sp, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        _buildEmailInput(),
        SizedBox(height: 16.h),
        _buildPasswordInput(),
        SizedBox(height: 16.h),
        _buildForgotPasswordLink(),
        SizedBox(height: 24.h),
        _buildLoginButton(),
        SizedBox(height: 24.h),
        _buildLoginAsGuestButton(),
      ],
    );
  }

  Widget _buildEmailInput() {
    return TextField(
      controller: controller.emailController,
      decoration: InputDecoration(
        hintText: 'Email',
        prefixIcon: Icon(
          Icons.email_outlined,
          color: AppColors.AppPrimaryColor,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPasswordInput() {
    return Obx(
      () => TextField(
        controller: controller.passwordController,
        obscureText: !controller.isPasswordVisible,
        decoration: InputDecoration(
          hintText: 'Password',
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            color: AppColors.AppPrimaryColor,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              controller.isPasswordVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.AppPrimaryColor,
            ),
            onPressed: controller.togglePasswordVisibility,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: controller.forgotPassword,
        child: Text(
          'Forgot Password?',
          style: TextStyle(color: AppColors.AppPrimaryColor, fontSize: 14.sp),
        ),
      ),
    );
  }

  Widget _buildLoginAsGuestButton() {
    return OutlinedButton(
      onPressed: controller.guestLogin,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColors.AppPrimaryColor, width: 2),
        minimumSize: Size(double.infinity, 56.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        backgroundColor: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline_rounded,
            color: AppColors.AppPrimaryColor,
            size: 24.sp,
          ),
          SizedBox(width: 10.w),
          Text(
            'Continue as Guest',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.AppPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: controller.emailLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.AppPrimaryColor,
        minimumSize: Size(double.infinity, 56.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
      ),
      child: Text(
        'Sign In',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSocialLogins() {
    return Column(
      children: [
        Text(
          'Or continue with',
          style: TextStyle(color: Colors.grey, fontSize: 14.sp),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              icon: 'assets/icons/Google.svg',
              onTap: controller.googleLogin,
            ),
            SizedBox(width: 16.w),
            _buildSocialButton(
              icon: 'assets/icons/Facebook.svg',
              onTap: controller.facebookLogin,
            ),
            SizedBox(width: 16.w),
            _buildSocialButton(
              icon: 'assets/icons/apple.svg',
              onTap: controller.appleLogin,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: IconButton(
        icon: SvgPicture.asset(icon, width: 24.w, height: 24.h),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account? ',
          style: TextStyle(color: Colors.grey, fontSize: 14.sp),
        ),
        GestureDetector(
          onTap: controller.navigateToSignUp,
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: AppColors.AppPrimaryColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
