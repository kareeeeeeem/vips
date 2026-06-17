import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/merchant_subscription_controller.dart';
import '../../../routes/merchant_routes.dart';

class SubscriptionPackagesView extends GetView<MerchantSubscriptionController> {
  const SubscriptionPackagesView({Key? key}) : super(key: key);

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
        title: Text(
          'My Business Plan', // Title from image
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 24.h),
          Text(
            'Commission Base Plan',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: const Color(0xFFF59E0B)),
          ),
          SizedBox(height: 4.h),
          Text(
            '0.3%',
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800, color: const Color(0xFFF59E0B)),
          ),
          SizedBox(height: 24.h),
          
          Expanded(
            child: Stack(
              children: [
                // Bottom Sheet background style
                Positioned.fill(
                  top: 50.h,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5)),
                      ],
                    ),
                  ),
                ),
                
                Column(
                  children: [
                    SizedBox(height: 16.h),
                    Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2.r)),
                    ),
                    SizedBox(height: 32.h),
                    Text(
                      'Change Subscription Plan',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Renew or shift your plan to get better experience!',
                      style: TextStyle(fontSize: 13.sp, color: const Color(0xFF9CA3AF)),
                    ),
                    SizedBox(height: 32.h),
                    
                    // Package Cards Carousel
                    Expanded(
                      child: PageView(
                        controller: PageController(viewportFraction: 0.8),
                        children: [
                          _buildPlanCard(
                            title: 'Commission Base',
                            price: '0.3%',
                            duration: 'Forever',
                            color: const Color(0xFF10B981),
                            isCurrent: true,
                          ),
                          _buildPlanCard(
                            title: 'Basic',
                            price: 'D 99.00',
                            duration: '120 Days',
                            color: const Color(0xFF10B981),
                            isCurrent: false,
                          ),
                          _buildPlanCard(
                            title: 'Commission Base 2.5%',
                            price: '2.5%',
                            duration: 'Forever',
                            color: const Color(0xFF10B981),
                            isCurrent: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String duration,
    required Color color,
    bool isCurrent = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          // Header Part
          Container(
            padding: EdgeInsets.all(24.w),
            width: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              children: [
                Text(title, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600)),
                SizedBox(height: 8.h),
                Text(price, style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.w800)),
                SizedBox(height: 4.h),
                Text(duration, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12.sp)),
              ],
            ),
          ),
          
          // Features List
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                   _buildFeatureRow('Inactive Gift Back', false),
                   _buildFeatureRow('Max SMS (500)', true),
                   _buildFeatureRow('Max Product (50)', true),
                   _buildFeatureRow('POS', true),
                   _buildFeatureRow('Mobile App', true),
                   _buildFeatureRow('Review', true),
                   if (isCurrent) _buildFeatureRow('Current Plan', true),
                ],
              ),
            ),
          ),
          
          // Button
          Padding(
            padding: EdgeInsets.all(24.w),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (!isCurrent) {
                    Get.toNamed(MerchantRoutes.PLAN_MIGRATION);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCurrent ? const Color(0xFF9CA3AF) : const Color(0xFFF97316), // Orange for "Shift in this plan"
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  elevation: 0,
                ),
                child: Text(
                  isCurrent ? 'Current plan' : 'Shift in this plan',
                  style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w700),
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
            color: isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            size: 16.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.sp,
                color: isActive ? const Color(0xFF4B5563) : const Color(0xFFEF4444), // Red for commission text cross
                fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                decoration: isActive ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
