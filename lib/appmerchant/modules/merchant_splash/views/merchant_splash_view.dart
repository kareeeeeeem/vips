import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/merchant_splash_controller.dart';

class MerchantSplashView extends GetView<MerchantSplashController> {
  const MerchantSplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller explicitly if it's not bound yet
    Get.put(MerchantSplashController());
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storefront_outlined,
              size: 100.sp,
              color: const Color(0xFF10B981),
            ),
            SizedBox(height: 24.h),
            Text(
              'VIPs Merchant',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111827),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Manage your business easily',
              style: TextStyle(
                fontSize: 16.sp,
                color: const Color(0xFF6B7280),
              ),
            ),
            SizedBox(height: 48.h),
            const CircularProgressIndicator(
              color: Color(0xFF10B981),
            ),
          ],
        ),
      ),
    );
  }
}
