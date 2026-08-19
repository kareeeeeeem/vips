import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../design_system/atoms/app_colors.dart';
import '../controllers/login_controller.dart';

class PhoneLoginView extends GetView<LoginController> {
  const PhoneLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: Get.back,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),
              Icon(
                Icons.phone_iphone_rounded,
                size: 48.sp,
                color: AppColors.AppPrimaryColor,
              ),
              SizedBox(height: 24.h),
              Text(
                'Sign in with Phone',
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Enter your phone number and we\'ll send you a verification code.',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
              ),
              SizedBox(height: 32.h),
              TextField(
                controller: controller.otpPhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '+20 123 456 7890',
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                    color: AppColors.AppPrimaryColor,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              Obx(() {
                final isLoading = controller.isLoading.value;
                return SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () => controller.sendPhoneOtp(controller.otpPhoneController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.AppPrimaryColor,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 24.w,
                            height: 24.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Send Code',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
