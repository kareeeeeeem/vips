import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../design_system/atoms/app_colors.dart';
import '../controllers/success_account_controller.dart';

class SuccessAccountView extends GetView<SuccessAccountController> {
  const SuccessAccountView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),

              // Animation de succès
              _buildSuccessAnimation(),

              SizedBox(height: 40.h),

              // Titre
              _buildTitle(),

              SizedBox(height: 16.h),

              // Description
              _buildDescription(),

              Spacer(),

              // Bouton
              _buildButton(),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 600),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.elasticOut,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle, size: 80.sp, color: Colors.green),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return Text(
      'Account Created!',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      'Your account has been created successfully.\nYou can now start using the app.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 15.sp,
        color: Colors.grey.shade600,
        height: 1.6,
      ),
    );
  }

  Widget _buildButton() {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: controller.goToHome,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.AppPrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: Text(
          'Get Started',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
