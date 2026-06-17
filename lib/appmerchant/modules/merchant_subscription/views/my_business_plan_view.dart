import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/merchant_subscription_controller.dart';
import '../../../routes/merchant_routes.dart';

class MyBusinessPlanView extends GetView<MerchantSubscriptionController> {
  const MyBusinessPlanView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937), size: 20),
            onPressed: () => Get.back(),
          ),
        ),
        title: Text(
          'My Business Plan',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Get.offAllNamed(MerchantRoutes.HOME),
            icon: const Icon(Icons.home_outlined, color: Color(0xFF1F2937)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                children: [
                   Text(
                    'Commission Base Plan',
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: const Color(0xFFF59E0B)),
                  ),
                  SizedBox(height: 4.h),
                  Obx(() => Text(
                    '${controller.currentCommission.value}%',
                    style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w800, color: const Color(0xFFF59E0B)),
                  )),
                  SizedBox(height: 32.h),
                  
                  Text(
                    'Partner will pay 0.3% commission to VIPsApp from each order You will get access of all the features and options in partner panel, app and interaction with user',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13.sp, color: const Color(0xFF9CA3AF), height: 1.5),
                  ),
                  SizedBox(height: 32.h),

                  // Current Plan Features card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      children: [
                        _buildFeatureRow('Inactive Gift Back', false),
                        _buildFeatureRow('Max Monthly SMS (100)', true),
                        _buildFeatureRow('Max Monthly Product (10)', true),
                        _buildFeatureRow('POS', true),
                        _buildFeatureRow('Mobile App', true),
                        _buildFeatureRow('Credit limit relative to the number of customers Max (D 50)', true),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Access',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: [
                            _quickLink('Business Registration', MerchantRoutes.BUSINESS_REGISTRATION),
                            _quickLink('Gift Back', MerchantRoutes.GIFT_BACK_FORM),
                            _quickLink('Bill Inquiry', MerchantRoutes.BILL_INQUIRY),
                            _quickLink('Catalog', MerchantRoutes.CATALOG),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.toNamed(MerchantRoutes.SUBSCRIPTION_PACKAGES),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    elevation: 0,
                  ),
                  child: Text('Change Business Plan', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String text, bool isActive) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            color: isActive ? Colors.white : const Color(0xFFEF4444),
            size: 18.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.sp,
                color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                decoration: isActive ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickLink(String label, String route) {
    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: const Color(0xFF374151),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
