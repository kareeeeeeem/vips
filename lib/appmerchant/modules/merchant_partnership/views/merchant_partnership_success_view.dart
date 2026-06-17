import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import '../controllers/merchant_partnership_controller.dart';

class MerchantPartnershipSuccessView extends GetView<MerchantPartnershipController> {
  const MerchantPartnershipSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          if (!controller.showFinalStep.value) {
            return _buildCongratsScreen();
          } else {
            return _buildReadyScreen();
          }
        }),
      ),
    );
  }

  // SCREEN 5: Congrats!
  Widget _buildCongratsScreen() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140.w,
            height: 140.h,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 80.sp,
            ),
          ),
          SizedBox(height: 40.h),
          Text(
            'Congrats!',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF10B981),
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Account Registred\nSuccessfully',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              color: const Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          SizedBox(height: 80.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.showFinalStep.value = true,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
              child: Text(
                'Get Started',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SCREEN 6: Loyalty Points is Ready
  Widget _buildReadyScreen() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 40.h),
          // Illustration Placeholder
          Container(
            height: 180.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: const Center(
              child: Icon(
                Icons.card_membership_rounded,
                size: 80,
                color: Color(0xFFF59E0B),
              ),
            ),
          ),
          SizedBox(height: 32.h),

          Text(
            'Loyalty Points is Ready to us',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF10B981),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Points will start getting added to the parties.',
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 32.h),

          // Benefits List
          _buildBenefitItem(1, 'Award Points', 'Your customers get points for their purchases.'),
          _buildBenefitItem(2, 'Customers Redeem', 'The points can be redeemed at later transactions.'),
          _buildBenefitItem(3, 'Increased Business', 'Your customers keep coming back to you to get more points and claim discounts.'),

          const Spacer(),

          // Actions
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.offNamed(MerchantRoutes.LOGIN);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
              child: Text(
                'Complete Business Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Get.toNamed(MerchantRoutes.ONBOARDING),
                  icon: const Icon(Icons.play_circle_outline, color: Color(0xFFEF4444)),
                  label: const Text('Watch Video', style: TextStyle(color: Color(0xFFEF4444))),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.toNamed(MerchantRoutes.BUSINESS_REGISTRATION),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B7280),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    elevation: 0,
                  ),
                  child: const Text('Help', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(int index, String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20.w,
            height: 20.h,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF6B7280)),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
