import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/merchant_credit_controller.dart';

class MerchantCreditFormView extends GetView<MerchantCreditController> {
  const MerchantCreditFormView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Credit',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF1F2937)),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('Help !', style: TextStyle(color: const Color(0xFF1F2937), fontSize: 13.sp)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 16.h),
                    // Top Balance Cards
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Row(
                        children: [
                          _buildBalanceCard('Dormant', '81.50'),
                          SizedBox(width: 12.w),
                          _buildBalanceCard('Approved', '600'),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Amount Display
                    Obx(() => Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              controller.amount.value,
                              style: TextStyle(fontSize: 56.sp, fontWeight: FontWeight.w500, color: const Color(0xFFD1D5DB)),
                            ),
                            SizedBox(width: 12.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF065F46),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                children: [
                                  Text('D', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                                  Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16.sp),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              controller.points.value,
                              style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
                            ),
                            SizedBox(width: 8.w),
                            Text('VIP', style: TextStyle(fontSize: 18.sp, color: const Color(0xFF10B981), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    )),
                    SizedBox(height: 24.h),

                    // Info Section
                    Column(
                      children: [
                        _buildSmallInfo('Exchange Rate: D 1.000 = VIP 100'),
                        _buildSmallInfo('Service Charge & Vat/Tax: 10 %'),
                        _buildSmallInfo('Limit: D 25 - D 1000'),
                      ],
                    ),
                    SizedBox(height: 32.h),

                    // Payment Selector
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Payment', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937))),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF065F46),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              children: [
                                Text('Bank', style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                                SizedBox(width: 8.w),
                                Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16.sp),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Keypad
                    _buildKeypad(),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        side: const BorderSide(color: Color(0xFFF97316)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text('Cancel', style: TextStyle(color: const Color(0xFFF97316), fontSize: 16.sp, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => controller.onProceedToInquiry(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF97316),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                      ),
                      child: Text('Proceed', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(String title, String val) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 10.sp, color: const Color(0xFF9CA3AF), fontWeight: FontWeight.w600)),
            SizedBox(height: 4.h),
            Text(val, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937))),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallInfo(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Text(
        text,
        style: TextStyle(fontSize: 12.sp, color: const Color(0xFF10B981).withOpacity(0.7), fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        _buildKeyRow(['1', '2', '3']),
        _buildKeyRow(['4', '5', '6']),
        _buildKeyRow(['7', '8', '9']),
        _buildKeyRow(['.', '0', '<']),
      ],
    );
  }

  Widget _buildKeyRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) => _buildKey(key)).toList(),
    );
  }

  Widget _buildKey(String label) {
    return InkWell(
      onTap: () {
        if (label == '<') {
          controller.onDeletePressed();
        } else if (label == '.') {
          controller.onDecimalPressed();
        } else {
          controller.onNumberPressed(label);
        }
      },
      child: Container(
        width: 100.w,
        height: 70.h,
        alignment: Alignment.center,
        child: label == '<' 
          ? Icon(Icons.backspace_outlined, size: 24.sp, color: const Color(0xFF10B981))
          : Text(
              label,
              style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w700, color: const Color(0xFF065F46)),
            ),
      ),
    );
  }
}
