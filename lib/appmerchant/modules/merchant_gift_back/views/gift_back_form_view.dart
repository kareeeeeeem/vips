import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import '../controllers/merchant_gift_back_controller.dart';

class GiftBackFormView extends GetView<MerchantGiftBackController> {
  const GiftBackFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Gift Back',
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
            onPressed: () => Get.toNamed(MerchantRoutes.SETTINGS),
            child: Text('Help !', style: TextStyle(color: const Color(0xFF1F2937), fontSize: 13.sp)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phone / ID input
                    _buildFieldLabel('Phone / ID'),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: controller.phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: '#12345678',
                        hintStyle: TextStyle(color: const Color(0xFFD1D5DB), fontSize: 24.sp),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        suffixIcon: IconButton(
                          onPressed: controller.onScanQR,
                          icon: Icon(Icons.qr_code_scanner, color: const Color(0xFF10B981), size: 32.sp),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: const Color(0xFFE5E7EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: const Color(0xFFE5E7EB)),
                        ),
                      ),
                      style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 24.h),

                    // Amount input
                    _buildFieldLabel('Enter Back Amount'),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: '0.000',
                              hintStyle: TextStyle(color: const Color(0xFFD1D5DB), fontSize: 48.sp),
                              filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12.r),
                                  bottomLeft: Radius.circular(12.r),
                                ),
                                borderSide: BorderSide(color: const Color(0xFFE5E7EB)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12.r),
                                  bottomLeft: Radius.circular(12.r),
                                ),
                                borderSide: BorderSide(color: const Color(0xFFE5E7EB)),
                              ),
                            ),
                            style: TextStyle(fontSize: 48.sp, fontWeight: FontWeight.w500, color: const Color(0xFFD1D5DB)),
                          ),
                        ),
                        Container(
                          height: 72.h,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF065F46),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(12.r),
                              bottomRight: Radius.circular(12.r),
                            ),
                          ),
                          child: Center(
                            child: Obx(() => Text(
                                  controller.currency.value,
                                  style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                                )),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    // Why Proceed is disabled. The button used to enable on
                    // "both fields non-empty", so an over-limit amount was only
                    // rejected by the server after the inquiry and PIN steps.
                    Obx(() => controller.formError.value.isEmpty
                        ? SizedBox(height: 16.h)
                        : Text(
                            controller.formError.value,
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFFDC2626),
                                fontWeight: FontWeight.w600),
                          )),
                    SizedBox(height: 24.h),

                    // Info items. The 'Limit Time: 03"00' row that used to sit
                    // here counted down nothing — there is no gift-back
                    // expiry/timer concept in the backend or this flow.
                    _buildInfoItem(Icons.info_outline, 'Service Charge & Vat/Tax: 000 D'),
                    SizedBox(height: 32.h),

                    // Limit Information Grid
                    Obx(() {
                      final c = controller.currency.value;
                      return Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Limit Information',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            _buildLimitRow(
                              'Daily Limit', 'Remaining Daily Limit',
                              '${controller.dailyLimit.value.toStringAsFixed(4)} $c',
                              '${controller.remainingDailyLimit.value.toStringAsFixed(4)} $c',
                            ),
                            SizedBox(height: 12.h),
                            _buildLimitRow(
                              'Monthly Limit', 'Remaining Monthly Limit',
                              '${controller.monthlyLimit.value.toStringAsFixed(4)} $c',
                              '${controller.remainingMonthlyLimit.value.toStringAsFixed(4)} $c',
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'Transaction Limit',
                              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF10B981), fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${controller.txMin.value.toStringAsFixed(4)} - ${controller.txMax.value.toStringAsFixed(4)} $c',
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF10B981)),
                            ),
                          ],
                        ),
                      );
                    }),
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
                        side: const BorderSide(color: Color(0xFF10B981)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text('Cancel', style: TextStyle(color: const Color(0xFF10B981), fontSize: 16.sp, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    flex: 2,
                    child: Obx(() => ElevatedButton(
                      onPressed: (controller.isFormValid.value && !controller.isLookingUp.value)
                          ? () => controller.onProceedToInquiry()
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        disabledBackgroundColor: const Color(0xFFE5E7EB),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                      ),
                      child: controller.isLookingUp.value
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text('Proceed', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700)),
                    )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: const Color(0xFF10B981)),
          SizedBox(width: 12.w),
          Text(label, style: TextStyle(fontSize: 14.sp, color: const Color(0xFF10B981), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildLimitRow(String title1, String title2, String val1, String val2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title1, style: TextStyle(fontSize: 13.sp, color: const Color(0xFF10B981), fontWeight: FontWeight.w600)),
            Text(val1, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF10B981))),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(title2, style: TextStyle(fontSize: 13.sp, color: const Color(0xFF10B981), fontWeight: FontWeight.w600)),
            Text(val2, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF10B981))),
          ],
        ),
      ],
    );
  }
}
