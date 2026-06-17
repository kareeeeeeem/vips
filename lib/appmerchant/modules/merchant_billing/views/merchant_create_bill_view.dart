import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/merchant_create_bill_controller.dart';

class MerchantCreateBillView extends GetView<MerchantCreateBillController> {
  const MerchantCreateBillView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MerchantCreateBillController());

    return Scaffold(
      backgroundColor: const Color(0xFF111827), // Dark theme for POS feel
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'New Order Bill',
          style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Enter Amount',
                    style: TextStyle(color: const Color(0xFF9CA3AF), fontSize: 16.sp),
                  ),
                  SizedBox(height: 8.h),
                  Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$',
                        style: TextStyle(color: const Color(0xFF10B981), fontSize: 32.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8.w),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          controller.amount.value,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 56.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )),
                ],
              ),
            ),
          ),
          
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.only(top: 24.h, left: 16.w, right: 16.w, bottom: 32.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildKeypadRow(['1', '2', '3']),
                        _buildKeypadRow(['4', '5', '6']),
                        _buildKeypadRow(['7', '8', '9']),
                        _buildKeypadRow(['.', '0', 'DEL']),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.generateOrderQr,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                        elevation: 4,
                        shadowColor: const Color(0xFF10B981).withValues(alpha: 0.4),
                      ),
                      child: Text(
                        'Generate QR Code',
                        style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
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

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        return _buildKeypadButton(key);
      }).toList(),
    );
  }

  Widget _buildKeypadButton(String key) {
    return InkWell(
      onTap: () {
        if (key == 'DEL') {
          controller.backspace();
        } else if (key == '.') {
          controller.appendDecimal();
        } else {
          controller.appendNumber(key);
        }
      },
      borderRadius: BorderRadius.circular(40.r),
      child: Container(
        width: 75.w,
        height: 60.h,
        alignment: Alignment.center,
        child: key == 'DEL'
            ? const Icon(Icons.backspace_outlined, color: Color(0xFF4B5563))
            : Text(
                key,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
      ),
    );
  }
}
