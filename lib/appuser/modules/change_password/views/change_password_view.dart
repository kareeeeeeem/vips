import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../design_system/atoms/app_colors.dart';
import '../controllers/change_password_controller.dart';

class ChangePasswordView extends GetView<ChangePasswordController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: controller.goBack,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              _buildIcon(),
              SizedBox(height: 32.h),
              _buildHeader(),
              SizedBox(height: 40.h),
              _buildPasswordFields(),
              SizedBox(height: 32.h),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Center(
      child: Container(
        width: 80.w,
        height: 80.h,
        decoration: BoxDecoration(
          color: AppColors.AppPrimaryColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.lock_reset_rounded,
          size: 40.sp,
          color: AppColors.AppPrimaryColor,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Change Password',
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Enter your current password, then set a new one.',
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordFields() {
    return Column(
      children: [
        _buildPasswordField(
          label: 'Current Password',
          controller: controller.currentPasswordController,
          isVisible: controller.isCurrentPasswordVisible,
          onToggle: controller.toggleCurrentPasswordVisibility,
        ),
        SizedBox(height: 20.h),
        _buildPasswordField(
          label: 'New Password',
          controller: controller.passwordController,
          isVisible: controller.isPasswordVisible,
          onToggle: controller.togglePasswordVisibility,
          isValid: controller.isPasswordValid,
          helperText: 'At least 8 characters, 1 uppercase, 1 number',
        ),
        SizedBox(height: 20.h),
        _buildPasswordField(
          label: 'Confirm New Password',
          controller: controller.confirmPasswordController,
          isVisible: controller.isConfirmPasswordVisible,
          onToggle: controller.toggleConfirmPasswordVisibility,
          isValid: controller.isPasswordConfirmed,
          helperText: 'Passwords must match',
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required RxBool isVisible,
    required VoidCallback onToggle,
    RxBool? isValid,
    String? helperText,
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
            obscureText: !isVisible.value,
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: (isValid?.value ?? false)
                    ? AppColors.AppPrimaryColor
                    : Colors.grey.shade400,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isValid?.value ?? false)
                    Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
                  IconButton(
                    icon: Icon(
                      isVisible.value ? Icons.visibility : Icons.visibility_off,
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
        if (helperText != null) ...[
          SizedBox(height: 6.h),
          Text(
            helperText,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      final isLoading = controller.isSubmitting.value;

      return SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: isLoading ? null : controller.changePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.AppPrimaryColor,
            disabledBackgroundColor: Colors.grey.shade300,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? SizedBox(
                  width: 24.w,
                  height: 24.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Change Password',
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
}
