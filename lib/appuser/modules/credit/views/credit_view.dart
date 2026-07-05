import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../design_system/atoms/app_colors.dart';
import '../controllers/credit_controller.dart';

class CreditView extends GetView<CreditController> {
  const CreditView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(CreditController());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),

                SizedBox(height: 32.h),

                // VIPS Input Card
                _buildVipsInputCard(),

                SizedBox(height: 32.h),

                // Payment Methods
                _buildPaymentMethodsSection(),

                SizedBox(height: 32.h),

                // Proceed Button
                _buildProceedButton(),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18.sp,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Text(
          'Buy VIPS Credits',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildVipsInputCard() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.AppPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.AppPrimaryColor,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'VIPS Amount',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Input avec bordure pointillée
          DottedBorder(
            padding: EdgeInsets.zero,
            color: AppColors.AppPrimaryColor,
            strokeWidth: 2,
            dashPattern: [8, 4],
            radius: Radius.circular(16.r),
            borderType: BorderType.RRect,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Text(
                    'VPS',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.AppPrimaryColor,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextField(
                      controller: controller.vipsNumberController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: '100',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade300,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                    ),
                  ),
                  Obx(
                    () =>
                        controller.isVipsNumberValid.value
                            ? Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                              size: 24.sp,
                            )
                            : SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Info message
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.blue.shade100, width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16.sp,
                  color: Colors.blue.shade700,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Minimum: ',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        TextSpan(
                          text: '100 VPS = 10 TND',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 16.h),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header cliquable
              GestureDetector(
                onTap: () {
                  controller.isExpanded.value = !controller.isExpanded.value;
                },
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.credit_card_rounded,
                          color: Colors.blue.shade700,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Bank Card',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      Spacer(),
                      Obx(
                        () => Icon(
                          controller.isExpanded.value
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey.shade600,
                          size: 24.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Liste des cartes
              Obx(() {
                if (!controller.isExpanded.value) return SizedBox.shrink();

                return Column(
                  children: [
                    Divider(height: 1, color: Colors.grey.shade200),
                    ...controller.bankCards.map(
                      (card) => _buildCardOption(card),
                    ),
                    _buildAddCardOption(),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardOption(BankCard card) {
    return Obx(() {
      final isSelected = controller.selectedPaymentMethod.value == card.id;

      return GestureDetector(
        onTap: () => controller.selectCard(card.id),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? AppColors.AppPrimaryColor.withOpacity(0.05)
                    : Colors.transparent,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
          ),
          child: Row(
            children: [
              // Radio button
              Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isSelected
                          ? AppColors.AppPrimaryColor
                          : Colors.transparent,
                  border: Border.all(
                    color:
                        isSelected
                            ? AppColors.AppPrimaryColor
                            : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child:
                    isSelected
                        ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                        : null,
              ),

              SizedBox(width: 16.w),

              // Card info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.bankName,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      card.maskedNumber,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              // Default badge
              if (card.isDefault)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'Default',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAddCardOption() {
    return GestureDetector(
      onTap: controller.showAddCardSheet,
      child: Container(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: AppColors.AppPrimaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: Colors.white, size: 16.sp),
            ),
            SizedBox(width: 16.w),
            Text(
              'Add New Card',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.AppPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProceedButton() {
    return Obx(() {
      final isValid = controller.isFormValid;

      return GestureDetector(
        onTap: isValid ? controller.proceedToPayment : null,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 18.h),
          decoration: BoxDecoration(
            gradient:
                isValid
                    ? LinearGradient(
                      colors: [
                        AppColors.AppPrimaryColor,
                        AppColors.AppPrimaryColor.withOpacity(0.8),
                      ],
                    )
                    : LinearGradient(
                      colors: [Colors.grey.shade300, Colors.grey.shade300],
                    ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow:
                isValid
                    ? [
                      BoxShadow(
                        color: AppColors.AppPrimaryColor.withOpacity(0.3),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ]
                    : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Proceed to Payment',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ],
          ),
        ),
      );
    });
  }
}
