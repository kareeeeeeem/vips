import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/merchant_subscription_controller.dart';
import '../../../routes/merchant_routes.dart';

class MyBusinessPlanView extends GetView<MerchantSubscriptionController> {
  const MyBusinessPlanView({super.key});

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
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
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
                  // The header used to read "Commission Base Plan / 0.3%"
                  // from a hardcoded `currentCommission`, with a paragraph
                  // asserting the partner pays 0.3% per order. There is no
                  // commission concept anywhere in the subscription API.
                  Obx(() {
                    final plan = controller.currentPlan;
                    final name = (plan['planName'] ?? '—').toString();
                    final price = plan['price'] is num
                        ? (plan['price'] as num).toDouble()
                        : 0.0;
                    final cycle = (plan['billingCycle'] ?? 'monthly').toString();
                    return Column(
                      children: [
                        Text(
                          'Current Plan',
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF9CA3AF)),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          name,
                          style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFF59E0B)),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          price > 0
                              ? 'D ${price.toStringAsFixed(2)} / $cycle'
                              : 'Free',
                          style: TextStyle(
                              fontSize: 14.sp, color: const Color(0xFF6B7280)),
                        ),
                      ],
                    );
                  }),
                  SizedBox(height: 20.h),

                  // Real renewal state, straight off
                  // GET /merchant/subscription/current.
                  Obx(() {
                    final plan = controller.currentPlan;
                    if (plan.isEmpty) return const SizedBox.shrink();
                    final endRaw = plan['endDate']?.toString();
                    final end = endRaw == null ? null : DateTime.tryParse(endRaw);
                    final autoRenew = plan['autoRenew'] == true;
                    return Container(
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
                          Row(
                            children: [
                              Icon(
                                autoRenew ? Icons.autorenew : Icons.event_busy_outlined,
                                size: 18.sp,
                                color: autoRenew
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  end == null
                                      ? (autoRenew ? 'Renews automatically' : 'No renewal date')
                                      : autoRenew
                                          ? 'Renews on ${end.day}/${end.month}/${end.year}'
                                          : 'Ends on ${end.day}/${end.month}/${end.year}',
                                  style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1F2937)),
                                ),
                              ),
                            ],
                          ),
                          // POST /merchant/subscription/cancel existed on the
                          // backend with nothing in the app calling it, so
                          // auto-renewal could never be turned off.
                          if (autoRenew) ...[
                            SizedBox(height: 8.h),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: controller.isCancelling.value
                                    ? null
                                    : () => Get.dialog(AlertDialog(
                                          title: const Text('Turn off auto-renewal?'),
                                          content: const Text(
                                              'Your plan stays active until the end of the current period.'),
                                          actions: [
                                            TextButton(
                                                onPressed: () => Get.back(),
                                                child: const Text('Keep it')),
                                            TextButton(
                                                onPressed: () {
                                                  Get.back();
                                                  controller.cancelAutoRenew();
                                                },
                                                child: const Text('Turn off')),
                                          ],
                                        )),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFEF4444)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.r)),
                                ),
                                child: controller.isCancelling.value
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2))
                                    : Text('Cancel auto-renewal',
                                        style: TextStyle(
                                            fontSize: 13.sp,
                                            color: const Color(0xFFEF4444),
                                            fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                  SizedBox(height: 24.h),

                  // Current Plan Features card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Obx(() {
                      // These six rows were hardcoded ("Max Monthly SMS
                      // (100)", "POS", "Credit limit ... Max (D 50)", ...)
                      // and matched no field the subscription API returns.
                      // The real set is the plan's own `features` map.
                      final labels = MerchantSubscriptionController
                          .featureLabels(controller.currentPlan['features']);
                      if (labels.isEmpty) {
                        return Text(
                          'No plan features to show yet.',
                          style: TextStyle(fontSize: 13.sp, color: Colors.white),
                        );
                      }
                      return Column(
                        children:
                            labels.map((f) => _buildFeatureRow(f, true)).toList(),
                      );
                    }),
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
                color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.7),
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
