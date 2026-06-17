import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
                   _buildInputBox('Minimum', '0.5', '%', controller.minRewardPercent),
                   SizedBox(width: 12.w),
                   Text('FOR', style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6B7280))),
                   SizedBox(width: 12.w),
                   _buildInputBox('Purchase More than', '1', 'D', controller.minPurchaseAmount),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                '0.5% discount will be applicable when order amount exceeds is more than D 1',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),

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
                  _buildLargeInputBox('100 VIPs Points', controller.redeemPointsValue),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text('=', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
                  ),
                  _buildDinarInputBox('1 Dinar', controller.redeemDinarValue),
                ],
              ),
              SizedBox(height: 20.h),
              Text(
                'You are about to start permanently Each 100 VIPs points will give the user discount of D 1',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                  height: 1.4,
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),

              SizedBox(height: 32.h),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.confirmSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBox(String label, String value, String unit, RxDouble target) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF9CA3AF))),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFFFFB800), width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
                ),
                Text(
                  unit,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeInputBox(String value, RxInt target) {
    return Expanded(
      flex: 3,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFFFB800), width: 1.5),
        ),
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
        ),
      ),
    );
  }
  
  Widget _buildDinarInputBox(String value, RxInt target) {
    return Expanded(
      flex: 2,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFFFB800), width: 1.5),
        ),
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
        ),
      ),
    );
  }
}
