import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/merchant_subscription_controller.dart';
import '../../../routes/merchant_routes.dart';

class PlanMigrationView extends GetView<MerchantSubscriptionController> {
  const PlanMigrationView({super.key});

  @override
  Widget build(BuildContext context) {
    final plan = (Get.arguments as Map<dynamic, dynamic>?) ?? {};
    final planName = (plan['name'] ?? plan['planName'] ?? plan['code'] ?? plan['id'] ?? 'Plan').toString();
    final price = (((plan['price'] ?? plan['monthlyPrice'] ?? 0) as num?) ?? 0).toDouble();
    final currency = (plan['currency'] ?? 'D').toString();
    // Backend plan objects key the subscribe code as `code`, not `id`/`planCode`.
    final planId = (plan['code'] ?? plan['id'] ?? plan['planCode'] ?? planName).toString();

    // Sync controller with selected plan from arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.selectPackage(planId, price);
    });

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
          'My Business Plan',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                children: [
                   Text(
                    'Shift to New Business Plan',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
                  ),
                  SizedBox(height: 24.h),

                  // What used to sit here: a "Commission Base Plan / 2.5%"
                  // comparison card (no commission concept exists), a fixed
                  // "30 days" validity and a "Bill Status: Migrate" meta row,
                  // a "Wallet Points / VP 0" box whose Apply button actually
                  // subscribed, and two payment tiles (Cash on Delivery, and
                  // "Pay Via Online — PayPal, Bkash"). The subscribe endpoint
                  // takes no gateway at all: it debits User.walletBalance.
                  Obx(() {
                    final effective = controller.priceFor(price);
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildComparisonCard(
                                'Current: ${controller.currentPlan['planName'] ?? '—'}',
                                controller.currentPlan['price'] is num &&
                                        (controller.currentPlan['price'] as num) > 0
                                    ? '$currency ${(controller.currentPlan['price'] as num).toStringAsFixed(2)}'
                                    : 'Free',
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Icon(Icons.swap_horiz,
                                  color: const Color(0xFFEF4444), size: 32.sp),
                            ),
                            Expanded(
                              child: _buildComparisonCard(
                                planName,
                                effective > 0
                                    ? '$currency ${effective.toStringAsFixed(2)}'
                                    : 'Free',
                                subtitle: '${controller.monthsForCycle} month'
                                    '${controller.monthsForCycle == 1 ? '' : 's'}',
                                isGreen: true,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        // Billing cycle — the backend supports monthly and
                        // yearly (10x monthly, i.e. two months free) but the
                        // app never sent `billingCycle`, so every subscribe
                        // silently defaulted to monthly.
                        Row(
                          children: [
                            Expanded(
                              child: _buildCycleTile('Monthly', 'monthly',
                                  '$currency ${price.toStringAsFixed(2)} / month'),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: _buildCycleTile('Yearly', 'yearly',
                                  '$currency ${(price * 10).toStringAsFixed(2)} / year'
                                  '${price > 0 ? '  •  2 months free' : ''}'),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Column(
                            children: [
                              _buildSummaryRow('Amount due',
                                  effective > 0 ? '$currency ${effective.toStringAsFixed(2)}' : 'Free'),
                              SizedBox(height: 8.h),
                              _buildSummaryRow('Paid from wallet',
                                  '$currency ${controller.walletBalance.value.toStringAsFixed(2)}'),
                              if (effective > controller.walletBalance.value) ...[
                                SizedBox(height: 10.h),
                                Row(
                                  children: [
                                    Icon(Icons.error_outline,
                                        size: 16.sp, color: const Color(0xFFDC2626)),
                                    SizedBox(width: 6.w),
                                    Expanded(
                                      child: Text(
                                        'Not enough wallet balance for this plan.',
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            color: const Color(0xFFDC2626),
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    );
                  }),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
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
                    // This button used to push the billing PIN → scan-me →
                    // invoice-receipt chain, rendering a receipt for a plan
                    // change that never happened — POST /subscribe was never
                    // called from here at all.
                    child: Obx(() {
                      final effective = controller.priceFor(price);
                      final affordable =
                          effective <= controller.walletBalance.value;
                      return ElevatedButton(
                        onPressed:
                            (controller.isSubscribing.value || !affordable)
                                ? null
                                : () async {
                                    final ok =
                                        await controller.subscribe(planId);
                                    if (ok) {
                                      Get.until((route) =>
                                          Get.currentRoute ==
                                          MerchantRoutes.BUSINESS_PLAN);
                                    }
                                  },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          disabledBackgroundColor: const Color(0xFFE5E7EB),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r)),
                          elevation: 0,
                        ),
                        child: controller.isSubscribing.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : Text('Shift Subscription Plan',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700)),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(String title, String price, {String? subtitle, bool isGreen = false}) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isGreen ? const Color(0xFF10B981) : Colors.white,
        border: Border.all(color: isGreen ? const Color(0xFF10B981) : const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: isGreen ? Colors.white : const Color(0xFF1F2937)),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isGreen ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              price,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: isGreen ? Colors.white : const Color(0xFF1B6DF9)),
            ),
          ),
          if (subtitle != null) ...[
             SizedBox(height: 8.h),
             Text(subtitle, style: TextStyle(fontSize: 10.sp, color: Colors.white.withValues(alpha: 0.8))),
          ],
        ],
      ),
    );
  }

  Widget _buildCycleTile(String label, String value, String detail) {
    return Obx(() {
      final selected = controller.billingCycle.value == value;
      return GestureDetector(
        onTap: () => controller.billingCycle.value = value,
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFECFDF5) : Colors.white,
            border: Border.all(
                color: selected
                    ? const Color(0xFF10B981)
                    : const Color(0xFFE5E7EB),
                width: selected ? 2 : 1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 16.sp,
                    color: selected
                        ? const Color(0xFF10B981)
                        : const Color(0xFF9CA3AF),
                  ),
                  SizedBox(width: 6.w),
                  Text(label,
                      style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937))),
                ],
              ),
              SizedBox(height: 6.h),
              Text(detail,
                  style: TextStyle(
                      fontSize: 10.sp, color: const Color(0xFF6B7280))),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
        Text(value,
            style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937))),
      ],
    );
  }
}
