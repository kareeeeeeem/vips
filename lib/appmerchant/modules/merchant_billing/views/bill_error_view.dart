import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';

class BillErrorView extends StatelessWidget {
  const BillErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    // The reason the caller actually failed on. This screen used to print the
    // fixed string "Sorry Insufficient Approved -814" no matter what went
    // wrong — a merchant who simply mistyped their PIN was told their plan
    // was insufficient and pushed at the upgrade screen.
    final args = Get.arguments;
    final String message = (args is Map && (args['message']?.toString().isNotEmpty ?? false))
        ? args['message'].toString()
        : 'That did not go through. Please check the details and try again.';
    // Only a plan/limit failure has anything to do with upgrading.
    final bool offerUpgrade = args is Map && args['offerUpgrade'] == true;

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.5), // Dimmed background
      body: Stack(
        children: [
          // Background layout from Bill Inquiry showing through (mocked)
          Positioned(
            top: 50.h,
            left: 24.w,
            right: 24.w,
            child: Container(
              height: 400.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                   SizedBox(height: 24.h),
                   Icon(Icons.verified_user, color: const Color(0xFFFFB800), size: 40.sp),
                ],
              ),
            ),
          ),

          // The Error Bottom Sheet overlay
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -5)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64.w,
                    height: 64.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.error_outline, color: Colors.white, size: 32.sp),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Oops!',
                    style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700, color: const Color(0xFFEF4444)),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
                  ),
                  SizedBox(height: 32.h),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: offerUpgrade
                          ? () => Get.offAllNamed(MerchantRoutes.SUBSCRIPTION_PACKAGES)
                          : () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                      ),
                      child: Text(
                        offerUpgrade ? 'Upgrade Package' : 'Try Again',
                        style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextButton(
                    onPressed: () => Get.offAllNamed(MerchantRoutes.HOME),
                    child: Text('Back to Dashboard',
                        style: TextStyle(color: const Color(0xFF6B7280), fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
