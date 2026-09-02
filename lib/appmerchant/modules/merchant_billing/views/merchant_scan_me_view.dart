import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../controllers/merchant_create_bill_controller.dart';

class MerchantScanMeView extends StatelessWidget {
  const MerchantScanMeView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final double amount = args['amount'] ?? 0.0;
    final String orderId = args['orderId'] ?? 'ORD-000000';
    // Present when this QR came from a bill the server actually created.
    final String billId = (args['billId'] ?? '').toString();
    final String payCode = (args['payCode'] ?? '').toString();

    // The code the customer's app resolves to this exact bill. This used to
    // be 'vips_order:<number>:<amount>' — a description of the bill rather
    // than a reference to it, which nothing could look up and therefore
    // nothing could pay.
    final String qrData =
        payCode.isNotEmpty ? 'vips_bill:$payCode' : 'vips_order:$orderId:$amount';

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
                    'Total: D ${amount.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800, color: const Color(0xFF10B981)),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Order ID: $orderId',
                    style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
                  ),
                  if (payCode.isNotEmpty) ...[
                    SizedBox(height: 10.h),
                    // The same code in readable form. Cameras fail — bad
                    // light, a cracked screen, a phone with no autofocus —
                    // and the customer can type this instead of the payment
                    // simply not happening.
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            payCode,
                            style: TextStyle(
                              fontSize: 19.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                              color: const Color(0xFF065F46),
                              fontFamily: 'monospace',
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Scan, tap phones, or type this code',
                            style: TextStyle(
                                fontSize: 11.sp, color: const Color(0xFF047857)),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xFF1F2937),
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Color(0xFF1F2937),
                        ),
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
                  // Bills raised for this QR are created 'pending' so their
                  // total is not booked as revenue before the customer pays.
                  // This is how the merchant closes that loop once they have.
                  if (billId.isNotEmpty) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final controller =
                              Get.find<MerchantCreateBillController>();
                          final ok = await controller.markBillPaid(billId);
                          if (ok) Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          elevation: 0,
                        ),
                        child: Text('Mark as Paid',
                            style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    SizedBox(height: 12.h),
                  ],
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
