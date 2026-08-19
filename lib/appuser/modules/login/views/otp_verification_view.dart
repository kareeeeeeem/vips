import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../../../design_system/atoms/app_colors.dart';
import '../controllers/login_controller.dart';

class OtpVerificationView extends GetView<LoginController> {
  const OtpVerificationView({super.key});

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20.h),
              _buildIcon(),
              SizedBox(height: 32.h),
              _buildHeader(),
              SizedBox(height: 48.h),
              _buildPinput(),
              SizedBox(height: 32.h),
              _buildLoadingIndicator(),
              SizedBox(height: 24.h),
              _buildResendLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 80.w,
      height: 80.h,
      decoration: BoxDecoration(
        color: AppColors.AppPrimaryColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.sms_outlined,
        size: 40.sp,
        color: AppColors.AppPrimaryColor,
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Verify Your Phone',
          style: TextStyle(
            fontSize: 26.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 12.h),
        Obx(
          () => RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'Enter the code sent to\n'),
                TextSpan(
                  text: controller.otpPhoneNumber.value,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.AppPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinput() {
    final defaultPinTheme = PinTheme(
      width: 55.w,
      height: 60.h,
      textStyle: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.AppPrimaryColor, width: 2),
      ),
    );

    return Obx(
      () => Pinput(
        length: 6,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: focusedPinTheme,
        enabled: !controller.isLoading.value,
        showCursor: true,
        onCompleted: (pin) => controller.verifyPhoneOtp(pin),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Obx(() {
      if (!controller.isLoading.value) {
        return Text(
          'Enter the 6-digit code above to verify automatically',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
        );
      }
      return SizedBox(
        width: 28.w,
        height: 28.h,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.AppPrimaryColor),
        ),
      );
    });
  }

  Widget _buildResendLink() {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      return GestureDetector(
        onTap: isLoading ? null : controller.resendPhoneOtp,
        child: RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
            children: [
              const TextSpan(text: "Didn't receive the code? "),
              TextSpan(
                text: 'Resend',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.AppPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
