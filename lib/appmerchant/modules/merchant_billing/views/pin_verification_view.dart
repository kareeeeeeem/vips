import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import '../controllers/merchant_billing_controller.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class PinVerificationView extends StatelessWidget {
  const PinVerificationView({super.key});

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
    // Whatever the caller wants the next screen to render. Without this the
    // PIN screen dropped the payload and the invoice screen fell back to its
    // "#INV-0000 / D 0.00" placeholders — an approved bill showed an empty
    // receipt.
    final Map<String, dynamic>? nextArguments =
        Get.arguments?['nextArguments'] is Map
            ? Map<String, dynamic>.from(Get.arguments['nextArguments'] as Map)
            : null;

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
                    child: GestureDetector(
                      onTap: () => _authenticateBiometric(nextRoute),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.fingerprint, color: const Color(0xFF6B7280), size: 20.sp),
                            SizedBox(width: 8.w),
                            Text('Biometric', style: TextStyle(color: const Color(0xFF6B7280), fontSize: 14.sp, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
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
                  _buildNumpadRow(['1', '2', '3'], controller, nextRoute: nextRoute, errorRoute: errorRoute, nextArguments: nextArguments),
                  SizedBox(height: 16.h),
                  _buildNumpadRow(['4', '5', '6'], controller, nextRoute: nextRoute, errorRoute: errorRoute, nextArguments: nextArguments),
                  SizedBox(height: 16.h),
                  _buildNumpadRow(['7', '8', '9'], controller, nextRoute: nextRoute, errorRoute: errorRoute, nextArguments: nextArguments),
                  SizedBox(height: 16.h),
                  _buildNumpadRow(['fingerprint', '0', 'delete'], controller, nextRoute: nextRoute, errorRoute: errorRoute, nextArguments: nextArguments),
                ],
              ),
            ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  /// Device biometrics as an alternative to typing the PIN. Used by both the
  /// fingerprint key on the numpad and the "Biometric" half of the toggle at
  /// the top — that half looked like a tab but had no handler at all.
  static Future<void> _authenticateBiometric(String? nextRoute,
      [Map<String, dynamic>? nextArguments]) async {
    final auth = LocalAuthentication();
    final canCheck = await auth.canCheckBiometrics;
    if (!canCheck) {
      safeSnackbar('Unavailable',
          'Biometric authentication not available on this device',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final authenticated = await auth.authenticate(
      localizedReason: 'Authenticate to access billing',
      options: const AuthenticationOptions(biometricOnly: true),
    );
    if (authenticated && nextRoute != null) {
      Get.offAllNamed(nextRoute, arguments: nextArguments);
    }
  }

  Widget _buildNumpadRow(List<String> items, dynamic controller,
      {String? nextRoute, String? errorRoute, Map<String, dynamic>? nextArguments}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items.map((item) {
        if (item == 'fingerprint') {
          return IconButton(
            icon: Icon(Icons.fingerprint, color: const Color(0xFF1B6DF9), size: 32.sp),
            onPressed: () => _authenticateBiometric(nextRoute, nextArguments),
          );
        } else if (item == 'delete') {
          return IconButton(
            icon: Icon(Icons.backspace_outlined, color: const Color(0xFF6B7280), size: 28.sp),
            onPressed: () => controller?.removePinDigit(),
          );
        } else {
          return GestureDetector(
            onTap: () async {
              if (controller == null) return;
              controller.addPinDigit(item);
              if (controller.currentPin.value.length != 4) return;

              final entered = controller.currentPin.value;
              controller.currentPin.value = ''; // Reset the dots immediately
              // Server-side verification. The previous check compared the
              // digits against a local SharedPreferences value that was never
              // written, so '0000' always passed.
              final ok = await controller.verifyPin(entered);
              if (ok) {
                Get.offNamed(nextRoute ?? MerchantRoutes.INVOICE_RECEIPT,
                    arguments: nextArguments);
              } else {
                if (controller.hasPin.value == false) {
                  safeSnackbar(
                    'No PIN set',
                    'Set a security PIN in Settings before approving bills.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  Get.toNamed(MerchantRoutes.SETTINGS);
                  return;
                }
                // Tell the error screen what actually failed — it used to be
                // handed nothing and fell back to a fixed "insufficient
                // plan" message for a simple wrong PIN.
                Get.offNamed(errorRoute ?? MerchantRoutes.BILL_ERROR,
                    arguments: {
                      'message': 'That PIN is not correct. Please try again.',
                    });
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
