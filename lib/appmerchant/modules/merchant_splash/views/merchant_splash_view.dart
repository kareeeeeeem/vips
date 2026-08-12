import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/merchant_splash_controller.dart';

class MerchantSplashView extends StatefulWidget {
  const MerchantSplashView({super.key});

  @override
  State<MerchantSplashView> createState() => _MerchantSplashViewState();
}

class _MerchantSplashViewState extends State<MerchantSplashView> {
  @override
  void initState() {
    super.initState();
    Get.put(MerchantSplashController());
  }

  @override
  Widget build(BuildContext context) {
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
