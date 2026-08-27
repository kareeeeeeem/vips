import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import '../controllers/merchant_partnership_controller.dart';

class MerchantRewardSetupView extends GetView<MerchantPartnershipController> {
  const MerchantRewardSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reward',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF10B981),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'VIPs App Convention',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: 16.h),

              // Reward Convention Row
              Row(
                children: [
                   _buildInputBox('Minimum', controller.minRewardPercentController, '%'),
                   SizedBox(width: 12.w),
                   Text('FOR', style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6B7280))),
                   SizedBox(width: 12.w),
                   _buildInputBox('Purchase More than', controller.minPurchaseAmountController, 'D'),
                ],
              ),
              SizedBox(height: 16.h),
              Obx(() => Text(
                '${_fmt(controller.minRewardPercent.value)}% discount will be applicable when '
                'order amount exceeds D ${_fmt(controller.minPurchaseAmount.value)}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                  height: 1.4,
                ),
              )),

              SizedBox(height: 40.h),
              Text(
                'Redeem',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF10B981),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Redeem VIPs point Value',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: 24.h),

              // Redeem Convention Row
              Row(
                children: [
                  _buildUnitInputBox(controller.redeemPointsController, 'VIPs Points', 3),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text('=', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
                  ),
                  _buildUnitInputBox(controller.redeemDinarController, 'Dinar', 2),
                ],
              ),
              SizedBox(height: 20.h),
              Obx(() => Text(
                'Each ${controller.redeemPointsValue.value} VIPs points will give the user a '
                'discount of D ${controller.redeemDinarValue.value}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                  height: 1.4,
                ),
              )),

              SizedBox(height: 40.h),
              Text(
                'Business Address',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: controller.storeAddressController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Enter your store address',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
              ),

              SizedBox(height: 48.h),

              // Terms checkbox
              Obx(() => Row(
                children: [
                  Checkbox(
                    value: controller.isAgreed.value,
                    onChanged: controller.toggleAgreement,
                    activeColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: 'Agree with ',
                        style: TextStyle(color: const Color(0xFF6B7280), fontSize: 13.sp),
                        children: [
                          TextSpan(
                            text: 'Terms & Condition',
                            style: TextStyle(
                              color: const Color(0xFF10B981),
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Get.toNamed(MerchantRoutes.TERMS),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),

              SizedBox(height: 32.h),

              // Confirm Button
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.confirmSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
                      ? SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Confirm',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              )),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  /// 0.5 -> "0.5", 1.0 -> "1"
  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  /// These three used to be read-only Containers with the default values
  /// painted on as literal text — the merchant could not change the deal they
  /// were agreeing to, and the RxDouble/RxInt passed in was never read.
  Widget _buildInputBox(String label, TextEditingController target, String unit) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF9CA3AF))),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFFFFB800), width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: target,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitInputBox(TextEditingController target, String unit, int flex) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFFFB800), width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: target,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              unit,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
