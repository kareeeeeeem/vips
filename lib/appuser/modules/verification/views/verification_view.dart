import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../../../design_system/atoms/app_colors.dart';
import '../controllers/verification_controller.dart';

class VerificationView extends GetView<VerificationController> {
  const VerificationView(this.fromReset, {Key? key}) : super(key: key);
  final bool fromReset;

  @override
  Widget build(BuildContext context) {
    Get.put(VerificationController());
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
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20.h),

              // Icône
              _buildIcon(),

              SizedBox(height: 32.h),

              // Titre et description
              _buildHeader(),

              SizedBox(height: 48.h),

              // Pinput
              _buildPinput(),

              SizedBox(height: 32.h),

              // Bouton de vérification
              _buildVerifyButton(),

              SizedBox(height: 24.h),

              // Lien de renvoi
              _buildResendLink(),

              Spacer(),
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
        color: AppColors.AppPrimaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.email_outlined,
        size: 40.sp,
        color: AppColors.AppPrimaryColor,
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Verify Your Email',
          style: TextStyle(
            fontSize: 28.sp,
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
                TextSpan(text: 'Enter the 6-digit code sent to\n'),
                TextSpan(
                  text: controller.email.value,
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
      width: 75.w,
      height: 75.h,
      textStyle: TextStyle(
        fontSize: 24.sp,
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

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.AppPrimaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.AppPrimaryColor, width: 1.5),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red, width: 1.5),
      ),
    );

    return Obx(
      () => Pinput(
        controller: controller.pinController,
        focusNode: controller.focusNode,
        length: 5,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: focusedPinTheme,
        submittedPinTheme: submittedPinTheme,
        errorPinTheme: errorPinTheme,
        enabled: !controller.isVerifying.value,
        showCursor: true,
        cursor: Container(
          width: 2,
          height: 24.h,
          color: AppColors.AppPrimaryColor,
        ),
        onCompleted: (pin) {
          controller.verifyCode(pin, fromReset);
        },
      ),
    );
  }

  Widget _buildVerifyButton() {
    return Obx(() {
      final isLoading = controller.isVerifying.value;
      final hasCode = controller.pinController.text.length == 6;

      return SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed:
              hasCode && !isLoading
                  ? () => controller.verifyCode(
                    controller.pinController.text,
                    fromReset,
                  )
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.AppPrimaryColor,
            disabledBackgroundColor: Colors.grey.shade300,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 0,
          ),
          child:
              isLoading
                  ? SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : Text(
                    'Verify Code',
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

  Widget _buildResendLink() {
    return Obx(() {
      final canResend = controller.resendTimer.value == 0;

      return GestureDetector(
        onTap: canResend ? controller.resendCode : null,
        child: RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
            children: [
              TextSpan(text: "Didn't receive the code? "),
              TextSpan(
                text:
                    canResend
                        ? 'Resend'
                        : 'Resend in ${controller.resendTimer.value}s',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color:
                      canResend
                          ? AppColors.AppPrimaryColor
                          : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
