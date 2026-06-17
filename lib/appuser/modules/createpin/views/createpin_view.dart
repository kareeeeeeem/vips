import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../../../design_system/atoms/app_colors.dart';
import '../controllers/createpin_controller.dart';

class CreatepinView extends GetView<CreatepinController> {
  const CreatepinView({Key? key}) : super(key: key);

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
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40.h),

              // Icône
              _buildIcon(),

              SizedBox(height: 32.h),

              // Titre et description
              _buildHeader(),

              SizedBox(height: 60.h),

              // Pinput
              _buildPinput(),

              SizedBox(height: 40.h),

              // Indicateurs de sécurité
              _buildSecurityInfo(),

              Spacer(),

              // Info supplémentaire
              _buildFooterInfo(),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Obx(
      () => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 80.w,
        height: 80.h,
        decoration: BoxDecoration(
          color:
              controller.isConfirmStep.value
                  ? Colors.green.withOpacity(0.1)
                  : AppColors.AppPrimaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          controller.isConfirmStep.value
              ? Icons.check_circle_outline
              : Icons.lock_outline,
          size: 40.sp,
          color:
              controller.isConfirmStep.value
                  ? Colors.green
                  : AppColors.AppPrimaryColor,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Obx(
      () => Column(
        children: [
          Text(
            controller.isConfirmStep.value
                ? 'Confirm Your PIN'
                : 'Create Your PIN',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            controller.isConfirmStep.value
                ? 'Enter your PIN again to confirm'
                : 'Create a 4-digit PIN to secure your account',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinput() {
    final defaultPinTheme = PinTheme(
      width: 60.w,
      height: 70.h,
      textStyle: TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.AppPrimaryColor, width: 2.5),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.AppPrimaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.AppPrimaryColor, width: 1.5),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red, width: 2),
      ),
    );

    return Obx(() {
      if (controller.isConfirmStep.value) {
        return Column(
          children: [
            // Afficher le premier PIN en points
            _buildPinDots(controller.firstPin.value.length),
            SizedBox(height: 24.h),
            // Champ de confirmation
            Pinput(
              controller: controller.confirmPinController,
              focusNode: controller.confirmPinFocusNode,
              length: 4,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              submittedPinTheme: submittedPinTheme,
              errorPinTheme:
                  controller.hasError.value ? errorPinTheme : submittedPinTheme,
              enabled: !controller.isCreating.value,
              obscureText: true,
              obscuringCharacter: '●',
              showCursor: true,
              cursor: Container(
                width: 2,
                height: 28.h,
                color: AppColors.AppPrimaryColor,
              ),
              onCompleted: controller.onPinCompleted,
            ),
            if (controller.hasError.value) ...[
              SizedBox(height: 12.h),
              Text(
                'PINs do not match. Try again.',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        );
      } else {
        return Pinput(
          controller: controller.pinController,
          focusNode: controller.pinFocusNode,
          length: 4,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: focusedPinTheme,
          submittedPinTheme: submittedPinTheme,
          autofocus: true,
          obscureText: true,
          obscuringCharacter: '●',
          showCursor: true,
          cursor: Container(
            width: 2,
            height: 28.h,
            color: AppColors.AppPrimaryColor,
          ),
          onCompleted: controller.onPinCompleted,
        );
      }
    });
  }

  Widget _buildPinDots(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
        (index) => Container(
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          width: 12.w,
          height: 12.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                index < count
                    ? AppColors.AppPrimaryColor
                    : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Obx(
      () =>
          !controller.isConfirmStep.value
              ? Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Choose a PIN that you can remember easily',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.blue.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : controller.isCreating.value
              ? Center(
                child: Column(
                  children: [
                    SizedBox(
                      width: 24.w,
                      height: 24.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.AppPrimaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Securing your account...',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
              : SizedBox.shrink(),
    );
  }

  Widget _buildFooterInfo() {
    return Text(
      'You will use this PIN to access the app',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
    );
  }
}
