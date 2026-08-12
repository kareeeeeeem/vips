import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/merchant_subscription_controller.dart';
import '../../../routes/merchant_routes.dart';

class SubscriptionPackagesView extends GetView<MerchantSubscriptionController> {
  const SubscriptionPackagesView({super.key});

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
          'Business Plans',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
        }

        final current = controller.currentPlan;
        final currentPlanCode = (current['planCode'] ?? current['plan'] ?? 'free').toString().toLowerCase();

        return Column(
          children: [
            SizedBox(height: 16.h),

            // ── Current plan badge ──────────────────────────
            if (current.isNotEmpty) ...[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24.w),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_outlined, color: Color(0xFF10B981), size: 20),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current Plan: ${current['planName'] ?? currentPlanCode.toUpperCase()}',
                              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF065F46))),
                          if (current['endDate'] != null)
                            Text(
                              'Renews: ${(current['endDate'] as String).split('T').first}',
                              style: TextStyle(fontSize: 11.sp, color: const Color(0xFF6B7280)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ],

            Text('Choose a Plan', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937))),
            SizedBox(height: 4.h),
            Text('Upgrade for more features & better experience',
                style: TextStyle(fontSize: 12.sp, color: const Color(0xFF9CA3AF))),
            SizedBox(height: 20.h),

            // ── Plans from API ──────────────────────────────
            Expanded(
              child: controller.availablePlans.isEmpty
                  ? _buildFallbackPlans(currentPlanCode)
                  : PageView.builder(
                      controller: PageController(viewportFraction: 0.82),
                      itemCount: controller.availablePlans.length,
                      itemBuilder: (_, i) {
                        final plan = controller.availablePlans[i];
                        final planCode = (plan['id'] ?? plan['planCode'] ?? '').toString().toLowerCase();
                        final isCurrent = planCode == currentPlanCode;
                        return _buildPlanCard(plan: plan, isCurrent: isCurrent);
                      },
                    ),
            ),
            SizedBox(height: 16.h),
          ],
        );
      }),
    );
  }

  // Shown while API returns empty or on error
  Widget _buildFallbackPlans(String currentPlanCode) {
    final plans = [
      {'id': 'free', 'name': 'Free', 'price': 0.0, 'currency': 'D', 'features': ['10 Products', '1 Cashier', 'Basic POS']},
      {'id': 'basic', 'name': 'Basic', 'price': 9.99, 'currency': 'D', 'features': ['50 Products', '3 Cashiers', 'Analytics', 'POS']},
      {'id': 'pro', 'name': 'Pro', 'price': 29.99, 'currency': 'D', 'features': ['500 Products', '10 Cashiers', 'Ads', 'Priority Support']},
      {'id': 'enterprise', 'name': 'Enterprise', 'price': 99.99, 'currency': 'D', 'features': ['Unlimited', 'All Features', 'API Access']},
    ];
    return PageView.builder(
      controller: PageController(viewportFraction: 0.82),
      itemCount: plans.length,
      itemBuilder: (_, i) {
        final plan = plans[i];
        final planCode = (plan['id'] as String).toLowerCase();
        final isCurrent = planCode == currentPlanCode;
        return _buildPlanCard(plan: plan, isCurrent: isCurrent, isFallback: true);
      },
    );
  }

  Widget _buildPlanCard({required Map<dynamic, dynamic> plan, required bool isCurrent, bool isFallback = false}) {
    final planName = (plan['name'] ?? plan['planName'] ?? plan['id'] ?? 'Plan').toString();
    final price = ((plan['price'] ?? plan['monthlyPrice'] ?? 0) as num?) ?? 0;
    final currency = (plan['currency'] ?? 'D').toString();
    final features = plan['features'] as List? ?? _extractFeatures(plan);
    final planCode = (plan['id'] ?? plan['planCode'] ?? '').toString().toLowerCase();

    final Color planColor = _planColor(planCode);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 12, offset: const Offset(0, 4)),
        ],
        border: isCurrent ? Border.all(color: const Color(0xFF10B981), width: 2) : null,
      ),
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────
          Container(
            padding: EdgeInsets.all(24.w),
            width: double.infinity,
            decoration: BoxDecoration(
              color: planColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              children: [
                if (isCurrent)
                  Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text('CURRENT', style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1)),
                  ),
                Text(planName, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600)),
                SizedBox(height: 8.h),
                price == 0
                    ? Text('Free', style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.w800))
                    : RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.w800),
                          children: [
                            TextSpan(text: '$currency '),
                            TextSpan(text: price.toStringAsFixed(2)),
                            TextSpan(text: '/mo', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400)),
                          ],
                        ),
                      ),
              ],
            ),
          ),

          // ── Features ──────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: features
                    .map((f) => _buildFeatureRow(f.toString()))
                    .toList(),
              ),
            ),
          ),

          // ── Button ────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCurrent
                    ? null
                    : () => Get.toNamed(MerchantRoutes.PLAN_MIGRATION, arguments: plan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCurrent ? const Color(0xFF9CA3AF) : const Color(0xFFF97316),
                  disabledBackgroundColor: const Color(0xFF9CA3AF),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  elevation: 0,
                ),
                child: Text(
                  isCurrent ? 'Current Plan' : 'Select Plan',
                  style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _extractFeatures(Map plan) {
    final features = plan['features'];
    if (features is Map) {
      return [
        if ((features['maxProducts'] as int?) != null)
          '${features['maxProducts']} Products',
        if ((features['maxCashiers'] as int?) != null)
          '${features['maxCashiers']} Cashiers',
        if (features['analytics'] == true) 'Analytics',
        if (features['adsEnabled'] == true) 'Advertisements',
        if (features['prioritySupport'] == true) 'Priority Support',
        if (features['apiAccess'] == true) 'API Access',
      ];
    }
    return [];
  }

  Widget _buildFeatureRow(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: const Color(0xFF10B981), size: 16.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF4B5563), fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Color _planColor(String code) {
    switch (code) {
      case 'pro': return const Color(0xFF7C3AED);
      case 'enterprise': return const Color(0xFF1F2937);
      case 'basic': return const Color(0xFF1B6DF9);
      default: return const Color(0xFF10B981);
    }
  }
}
