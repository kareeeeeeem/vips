import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// Bottom Sheet pour afficher les informations détaillées d'une promotion
class PromotionInfoBottomSheet {
  static void show({
    required String title,
    required String description,
    required String promoCode,
    String? discountText,
  }) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.95,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            SizedBox(height: 20.h),

            // Title
            Text(
              'Promotion Information',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                fontFamily: 'SF Pro Display',
              ),
            ),

            SizedBox(height: 24.h),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Center(
                      child: Container(
                        width: 160.w,
                        height: 60.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBBF24),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Icon(
                          Icons.local_offer,
                          size: 40.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Promotion Title
                    Center(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Description
                    Center(
                      child: Text(
                        description,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: const Color(0xFF6B7280),
                          fontFamily: 'SF Pro Text',
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: 32.h),

                    // Duration
                    _buildInfoSection('Duration :', '01/05/2025 - 31/05/2025'),

                    SizedBox(height: 24.h),

                    // Promo Code
                    _buildInfoSection('Promo Code :', promoCode),

                    SizedBox(height: 24.h),

                    // Applicable Scope
                    _buildInfoSection(
                      'Applicable Scope :',
                      'Applicable to all orders on VIPsApp.',
                    ),

                    SizedBox(height: 24.h),

                    // Discount Amount
                    _buildInfoSection(
                      'Discount Amount :',
                      discountText ?? '100% off shipping (Free shipping).',
                    ),

                    SizedBox(height: 24.h),

                    // Terms and Conditions
                    Text(
                      'Terms and Conditions :',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),

                    SizedBox(height: 12.h),

                    Text(
                      'No minimum order requirement. Applicable for standard shipping within the country.\n\n'
                      'If you Have any difficulties while using the coupon, please contact 12345678 from 9:00 AM to 11 PM or via live chat 24 hours a day.\n\n'
                      'It also confirms that the coupon numbers are confidential numbers specific to the customer only. Please do not share them with anyone or any of the merchants except when receiving the service.\n\n'
                      'If you hand the coupon to the merchant and do not use it, please contact the service us during your visit or within 48 hours at most for assistance.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF6B7280),
                        fontFamily: 'SF Pro Text',
                        height: 1.6,
                      ),
                    ),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  static Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            fontFamily: 'SF Pro Display',
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          content,
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF6B7280),
            fontFamily: 'SF Pro Text',
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
