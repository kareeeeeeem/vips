import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';

import '../controllers/merchant_ads_controller.dart';

/// Ad campaigns list. The merchant app could create an ad (through a screen
/// nothing linked to) and the controller could pause, resume, boost and
/// delete campaigns — but there was no screen anywhere that listed them, so
/// none of those actions was reachable and no merchant could see a campaign
/// they had created.
class MerchantAdsView extends GetView<MerchantAdsController> {
  const MerchantAdsView({super.key});

  static const _green = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Advertisements',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6B7280)),
            onPressed: () {
              controller.loadAds();
              controller.loadStats();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _green,
        onPressed: () async {
          await Get.toNamed(MerchantRoutes.ADD_ADVERTISEMENT);
          await controller.loadAds();
          await controller.loadStats();
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Campaign', style: TextStyle(color: Colors.white)),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.ads.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: _green));
        }
        return RefreshIndicator(
          onRefresh: () async {
            await controller.loadAds();
            await controller.loadStats();
          },
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 96.h),
            children: [
              _summary(),
              SizedBox(height: 16.h),
              if (controller.ads.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 80.h),
                  child: Column(
                    children: [
                      Icon(Icons.campaign_outlined,
                          size: 64.sp, color: const Color(0xFFD1D5DB)),
                      SizedBox(height: 16.h),
                      Text('No campaigns yet',
                          style: TextStyle(
                              fontSize: 16.sp, color: const Color(0xFF6B7280))),
                      SizedBox(height: 6.h),
                      Text('Create one to promote your store',
                          style: TextStyle(
                              fontSize: 13.sp, color: const Color(0xFF9CA3AF))),
                    ],
                  ),
                )
              else
                ...controller.ads.map(_adCard),
            ],
          ),
        );
      }),
    );
  }

  /// Totals across every campaign, straight from GET /merchant/ads/stats.
  Widget _summary() {
    final stats = (controller.stats['stats'] as List?) ?? const [];
    num budget = 0, spent = 0, impressions = 0, clicks = 0;
    for (final row in stats) {
      if (row is! Map) continue;
      budget += (row['totalBudget'] as num?) ?? 0;
      spent += (row['totalSpent'] as num?) ?? 0;
      impressions += (row['totalImpressions'] as num?) ?? 0;
      clicks += (row['totalClicks'] as num?) ?? 0;
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          _stat('Budget', 'D ${budget.toStringAsFixed(2)}'),
          _stat('Spent', 'D ${spent.toStringAsFixed(2)}'),
          _stat('Views', impressions.toString()),
          _stat('Clicks', clicks.toString()),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) => Expanded(
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1F2937))),
            SizedBox(height: 2.h),
            Text(label,
                style: TextStyle(fontSize: 11.sp, color: const Color(0xFF9CA3AF))),
          ],
        ),
      );

  Widget _adCard(Map<String, dynamic> ad) {
    final id = (ad['_id'] ?? '').toString();
    final status = (ad['status'] ?? 'draft').toString();
    final impressions = (ad['impressions'] as num?) ?? 0;
    final clicks = (ad['clicks'] as num?) ?? 0;
    final budget = (ad['budget'] as num?) ?? 0;
    final spent = (ad['spentAmount'] as num?) ?? 0;
    final image = (ad['imageUrl'] ?? '').toString();

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (image.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.network(
                    image,
                    width: 56.w,
                    height: 56.w,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imageFallback(),
                  ),
                )
              else
                _imageFallback(),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (ad['title'] ?? '').toString(),
                      style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${(ad['adType'] ?? 'banner').toString()} · $impressions views · $clicks clicks',
                      style: TextStyle(
                          fontSize: 11.sp, color: const Color(0xFF6B7280)),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'D ${spent.toStringAsFixed(2)} of D ${budget.toStringAsFixed(2)} spent',
                      style: TextStyle(
                          fontSize: 11.sp, color: const Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
              _statusChip(status),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              if (status == 'active')
                _action(Icons.pause_rounded, 'Pause',
                    () => controller.pauseAd(id))
              else if (status == 'paused')
                _action(Icons.play_arrow_rounded, 'Resume',
                    () => controller.resumeAd(id)),
              _action(Icons.rocket_launch_outlined, 'Boost',
                  () => _showBoostDialog(id)),
              _action(Icons.delete_outline_rounded, 'Delete',
                  () => _confirmDelete(id),
                  color: const Color(0xFFEF4444)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imageFallback() => Container(
        width: 56.w,
        height: 56.w,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: const Icon(Icons.campaign_outlined, color: Color(0xFF9CA3AF)),
      );

  Widget _statusChip(String status) {
    final color = switch (status) {
      'active' => _green,
      'paused' => const Color(0xFFF59E0B),
      'scheduled' => const Color(0xFF3B82F6),
      'ended' => const Color(0xFF6B7280),
      _ => const Color(0xFF9CA3AF),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        status,
        style: TextStyle(
            fontSize: 10.sp, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  Widget _action(IconData icon, String label, VoidCallback onTap,
      {Color color = const Color(0xFF10B981)}) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16.sp, color: color),
        label: Text(label, style: TextStyle(fontSize: 12.sp, color: color)),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  void _showBoostDialog(String id) {
    final amountCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Boost campaign'),
        content: TextField(
          controller: amountCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Extra budget (D)',
            hintText: 'e.g. 25',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
              if (amount <= 0) return;
              Get.back();
              controller.boostAd(id, amount);
            },
            style: ElevatedButton.styleFrom(backgroundColor: _green),
            child: const Text('Boost', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Delete campaign'),
        content: const Text('This removes the campaign permanently.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteAd(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
