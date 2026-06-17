import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/merchant_gift_back_controller.dart';

class GiftBackPinView extends GetView<MerchantGiftBackController> {
  const GiftBackPinView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF1F2937)),
            onPressed: () => Get.back(),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          // Custom Tabs
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Obx(() => Row(
                children: [
                  _buildTabItem('PIN', Icons.grid_view_sharp, !controller.isBiometricTab.value),
                  _buildTabItem('Biometric', Icons.fingerprint, controller.isBiometricTab.value),
                ],
              )),
            ),
          ),
          SizedBox(height: 32.h),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    'Enter your PIN',
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937)),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Enter your confidential code',
                    style: TextStyle(fontSize: 14.sp, color: const Color(0xFF9CA3AF)),
                  ),
                  SizedBox(height: 40.h),

                  // PIN Dots/Boxes
                  Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      bool hasValue = controller.pinCode.value.length > index;
                      return Container(
                        width: 56.w,
                        height: 56.w,
                        margin: EdgeInsets.symmetric(horizontal: 8.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: hasValue ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: hasValue
                              ? Container(width: 12.w, height: 12.w, decoration: const BoxDecoration(color: Color(0xFF1F2937), shape: BoxShape.circle))
                              : null,
                        ),
                      );
                    }),
                  )),
                  SizedBox(height: 48.h),

                  // Numeric Keypad
                  _buildKeypad(),
                  
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(() => Checkbox(
                        value: controller.rememberMe.value,
                        onChanged: (val) => controller.rememberMe.value = val ?? false,
                        activeColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                      )),
                      Text('Remember me', style: TextStyle(fontSize: 13.sp, color: const Color(0xFF4B5563))),
                    ],
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, IconData icon, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.isBiometricTab.value = (label == 'Biometric'),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF10B981) : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16.sp, color: isActive ? Colors.white : const Color(0xFF6B7280)),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: isActive ? Colors.white : const Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildKey('1'), _buildKey('2'), _buildKey('3')],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildKey('4'), _buildKey('5'), _buildKey('6')],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildKey('7'), _buildKey('8'), _buildKey('9')],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 64, height: 64), // Empty space for layout
              _buildKey('0'),
              _buildKey('', isDelete: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String val, {bool isDelete = false}) {
    return GestureDetector(
      onTap: () => isDelete ? controller.clearPin() : controller.updatePin(val),
      child: Container(
        width: 64.w,
        height: 64.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Center(
          child: isDelete
              ? Icon(Icons.backspace_outlined, color: const Color(0xFF10B981), size: 24.sp)
              : Text(val, style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
        ),
      ),
    );
  }
}
