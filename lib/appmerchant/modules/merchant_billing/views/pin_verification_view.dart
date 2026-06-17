import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import '../controllers/merchant_billing_controller.dart';

class PinVerificationView extends StatelessWidget {
  const PinVerificationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Attempt to find either billing or subscription controller
    dynamic controller;
    try {
      controller = Get.find<MerchantBillingController>();
    } catch (e) {
      // Fallback or handle subscription controller if needed
      // For now, let's assume we can use a generic approach or just find what's available
    }

    final String nextRoute = Get.arguments?['nextSelection'] ?? MerchantRoutes.INVOICE_RECEIPT;
    final String errorRoute = Get.arguments?['errorSelection'] ?? MerchantRoutes.BILL_ERROR;

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
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 16.h),
            // Toggle Switch
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24.w),
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(32.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B6DF9), // Blue from design
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.more_horiz, color: Colors.white, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text('PIN', style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fingerprint, color: const Color(0xFF6B7280), size: 20.sp),
                        SizedBox(width: 8.w),
                        Text('Biometric', style: TextStyle(color: const Color(0xFF6B7280), fontSize: 14.sp, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 48.h),
            Text(
              'Enter your PIN',
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
            ),
            SizedBox(height: 8.h),
            Text(
              'Enter your confidential code',
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
            ),
            SizedBox(height: 48.h),

            // PIN Dots
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4, // Fixed length or from controller
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.w),
                  width: 50.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: (controller?.currentPin.value.length ?? 0) > index
                          ? const Color(0xFF1B6DF9)
                          : const Color(0xFFE5E7EB),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: (controller?.currentPin.value.length ?? 0) > index
                        ? Container(
                            width: 16.w,
                            height: 16.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1F2937),
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            )),
            
            Spacer(),

            // Numpad
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                children: [
                  _buildNumpadRow(['1', '2', '3'], controller),
                  SizedBox(height: 16.h),
                  _buildNumpadRow(['4', '5', '6'], controller),
                  SizedBox(height: 16.h),
                  _buildNumpadRow(['7', '8', '9'], controller),
                  SizedBox(height: 16.h),
                  _buildNumpadRow(['fingerprint', '0', 'delete'], controller, nextRoute: nextRoute, errorRoute: errorRoute),
                ],
              ),
            ),

            // Remember me
            Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: Checkbox(
                      value: false,
                      onChanged: (val) {},
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text('Remember me', style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumpadRow(List<String> items, dynamic controller, {String? nextRoute, String? errorRoute}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items.map((item) {
        if (item == 'fingerprint') {
          return IconButton(
            icon: Icon(Icons.fingerprint, color: const Color(0xFF1B6DF9), size: 32.sp),
            onPressed: () => Get.snackbar('Biometric', 'Biometric flow not configured yet', snackPosition: SnackPosition.BOTTOM),
          );
        } else if (item == 'delete') {
          return IconButton(
            icon: Icon(Icons.backspace_outlined, color: const Color(0xFF6B7280), size: 28.sp),
            onPressed: () => controller?.removePinDigit(),
          );
        } else {
          return GestureDetector(
            onTap: () {
              controller?.addPinDigit(item);
              if (controller?.currentPin.value.length == 4) {
                if (controller?.currentPin.value == '0000') {
                  Get.offNamed(nextRoute ?? MerchantRoutes.INVOICE_RECEIPT);
                } else {
                  Get.offNamed(errorRoute ?? MerchantRoutes.BILL_ERROR);
                }
                controller?.currentPin.value = ''; // Reset
              }
            },
            child: Container(
              width: 80.w,
              height: 60.h,
              color: Colors.transparent,
              child: Center(
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B6DF9),
                  ),
                ),
              ),
            ),
          );
        }
      }).toList(),
    );
  }
}
