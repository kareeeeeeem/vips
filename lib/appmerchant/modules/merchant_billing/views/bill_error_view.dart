import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';

class BillErrorView extends StatelessWidget {
  const BillErrorView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5), // Dimmed background
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
                   // Just a mock background...
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
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5)),
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
                    'Sorry Insufficient Approved -814',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
                  ),
                  SizedBox(height: 32.h),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.offAllNamed(MerchantRoutes.SUBSCRIPTION_PACKAGES),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                      ),
                      child: Text('Upgrade Package', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancel', style: TextStyle(color: const Color(0xFF6B7280), fontSize: 14.sp, fontWeight: FontWeight.w600)),
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
