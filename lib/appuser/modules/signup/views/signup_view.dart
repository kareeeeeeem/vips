import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appuser/modules/signup/controllers/signup_controller.dart';

import '../../../core/constants/app_assets.dart';
import '../../../design_system/atoms/app_colors.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40.h),

              // Logo simple
              _buildSimpleLogo(),

              SizedBox(height: 60.h),

              // Titre simple
              _buildTitle(),

              SizedBox(height: 40.h),

              // Formulaire
              _buildForm(),

              SizedBox(height: 30.h),

              // Lien connexion
              _buildSignInLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleLogo() {
    return Center(
      child: Image.asset(
        AppImages.Logo,
        width: 50.w,
        height: 50.h,
        color: AppColors.AppPrimaryColor,
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Sign up to get started',
          style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        // Full Name
        _buildTextField(
          controller: controller.fullNameController,
          label: 'Full Name',
          hint: 'John Doe',
          keyboardType: TextInputType.name,
          isValid: controller.isFullNameValid,
        ),

        SizedBox(height: 20.h),

        // Phone
        _buildTextField(
          controller: controller.phoneController,
          label: 'Phone Number',
          hint: '+1234567890',
          keyboardType: TextInputType.phone,
          isValid: controller.isPhoneValid,
        ),

        SizedBox(height: 20.h),

        // Email
        _buildTextField(
          controller: controller.emailController,
          label: 'Email',
          hint: 'your@email.com',
          keyboardType: TextInputType.emailAddress,
          isValid: controller.isEmailValid,
        ),

        SizedBox(height: 20.h),

        // Password
        Obx(
          () => _buildPasswordField(
            controller: controller.passwordController,
            label: 'Password',
            hint: '••••••••',
            isVisible: controller.isPasswordVisible.value,
            onToggle: controller.togglePasswordVisibility,
            isValid: controller.isPasswordValid,
          ),
        ),

        SizedBox(height: 20.h),

        // Confirm Password
        Obx(
          () => _buildPasswordField(
            controller: controller.confirmPasswordController,
            label: 'Confirm Password',
            hint: '••••••••',
            isVisible: controller.isConfirmPasswordVisible.value,
            onToggle: controller.toggleConfirmPasswordVisibility,
            isValid: controller.isPasswordConfirmed,
          ),
        ),

        SizedBox(height: 32.h),

        // Button
        _buildButton(),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextInputType keyboardType,
    required RxBool isValid,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(
          () => TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              suffixIcon:
                  isValid.value
                      ? Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20.sp,
                      )
                      : null,
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppColors.AppPrimaryColor,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggle,
    required RxBool isValid,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(
          () => TextField(
            controller: controller,
            obscureText: !isVisible,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isValid.value)
                    Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
                  IconButton(
                    icon: Icon(
                      isVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: onToggle,
                  ),
                ],
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppColors.AppPrimaryColor,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton() {
    return Obx(() {
      return SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.createAccount,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.AppPrimaryColor,
            disabledBackgroundColor: Colors.grey.shade300,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 0,
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      );
    });
  }

  Widget _buildSignInLink() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Already have an account? ',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
          ),
          GestureDetector(
            onTap: controller.navigateToSignIn,
            child: Text(
              'Sign In',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.AppPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
