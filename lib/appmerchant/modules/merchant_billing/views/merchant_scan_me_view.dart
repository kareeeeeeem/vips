import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MerchantScanMeView extends StatelessWidget {
  const MerchantScanMeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String buttonText = args['buttonText'] ?? 'Close';
    final String nextRoute = args['nextRoute'] ?? '/merchant-home';
    final double amount = args['amount'] ?? 0.0;
    final String orderId = args['orderId'] ?? 'ORD-000000';
    
    // In a real app, this data would be JSON or an encrypted string
    final String qrData = 'vips_order:$orderId:$amount';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF1F2937)),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 64.w,
                    height: 64.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1B6DF9),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('V', style: TextStyle(color: Colors.white, fontSize: 32.sp, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.link, color: const Color(0xFF1B6DF9), size: 16.sp),
                            SizedBox(width: 8.w),
                            Text('Code/Share', style: TextStyle(color: const Color(0xFF1B6DF9), fontSize: 12.sp, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.qr_code, color: const Color(0xFFFFB800), size: 16.sp),
                            SizedBox(width: 8.w),
                            Text('QR code', style: TextStyle(color: const Color(0xFFFFB800), fontSize: 12.sp, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 64.h),
                  
                  Text(
                    'Total: \$${amount.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800, color: const Color(0xFF10B981)),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Order ID: $orderId',
                    style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
                  ),
                  SizedBox(height: 24.h),
                  
                  Container(
                    width: 240.w,
                    height: 240.w,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFF10B981), width: 2),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 200.w,
                        foregroundColor: const Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  
                  Text(
                    'Enjoy !',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'See you in the next visit !',
                    style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  // SIMULATION BUTTON: This mimics what happens when the User app scans the QR
                  // and the server sends a socket event to the Merchant app saying "Payment Success"
                  TextButton.icon(
                    onPressed: () {
                      Get.snackbar(
                        'Payment Received',
                        'Customer paid \$${amount.toStringAsFixed(2)}. Points awarded!',
                        backgroundColor: const Color(0xFF10B981),
                        colorText: Colors.white,
                        icon: const Icon(Icons.check_circle, color: Colors.white),
                        duration: const Duration(seconds: 3),
                      );
                      Future.delayed(const Duration(seconds: 2), () {
                        Get.offNamed(nextRoute); // Go back home
                      });
                    },
                    icon: const Icon(Icons.bug_report, color: Color(0xFF9CA3AF)),
                    label: Text('Simulate User Scan', style: TextStyle(color: const Color(0xFF9CA3AF))),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F4F6),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                      ),
                      child: Text('Cancel', style: TextStyle(color: const Color(0xFF4B5563), fontSize: 16.sp, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
