import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

import '../views/widgets/coupon_details_sheet.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class CouponController extends GetxController {
  final RxList<Coupon> coupons = <Coupon>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final response = await ApiService().get('/rewards/coupons');
      if (response.success && response.data != null) {
        final List<dynamic> data = response.data;
        coupons.value =
            data.map((c) {
              final expiryRaw = c['expiryDate'] ?? c['expiresAt'];
              final expiry =
                  expiryRaw != null
                      ? (DateTime.tryParse(expiryRaw.toString()) ??
                          DateTime.now().add(const Duration(days: 365)))
                      : DateTime.now().add(const Duration(days: 365));
              final isExpired = expiry.isBefore(DateTime.now());
              final discount =
                  ((c['discountPercentage'] ?? c['discount'] ?? 0) as num)
                      .toDouble();
              return Coupon(
                id: (c['_id'] ?? c['id'] ?? '').toString(),
                code: (c['code'] ?? '').toString(),
                discount: discount,
                // Real backend enum (models/Coupon.js) also has 'voucher',
                // which is defined but never actually assigned by any route
                // (seeded voucher tiers only ever use percentage/fixed/
                // shipping) — percentage remains the correct fallback for it.
                type:
                    c['type'] == 'fixed'
                        ? CouponType.fixed
                        : c['type'] == 'shipping'
                            ? CouponType.shipping
                            : CouponType.percentage,
                status:
                    isExpired
                        ? CouponStatus.expired
                        : ((c['isActive'] == true)
                            ? CouponStatus.active
                            : CouponStatus.inactive),
                expiryDate: expiry,
                usageCount:
                    ((c['usageCount'] ?? c['usedCount'] ?? 0) as num).toInt(),
                // Live API always returns maxUsage: null and puts the real
                // cap in maxUses instead — falling back to a fabricated 100
                // showed a wrong "Max Usage"/"Remaining"/progress-bar value
                // for every coupon (e.g. VIPS10's real cap is 500, not 100).
                maxUsage:
                    ((c['maxUsage'] ?? c['maxUses'] ?? c['limit'] ?? 100) as num)
                        .toInt(),
                minOrderAmount:
                    ((c['minOrderAmount'] ?? 0) as num).toDouble(),
              );
            }).where((c) => c.status != CouponStatus.expired).toList();
      }
    } catch (e) {
      debugPrint('Error fetching coupons: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Voir les détails d'un coupon
  void viewCouponDetails(Coupon coupon) {
    Get.bottomSheet(
      CouponDetailsSheet(coupon: coupon),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void copyCouponCode(Coupon coupon) {
    Clipboard.setData(ClipboardData(text: coupon.code));
    safeSnackbar(
      'Copied',
      '${coupon.code} copied — paste it at checkout to apply the discount',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}

// Modèles
class Coupon {
  final String id;
  final String code;
  final double discount;
  final CouponType type;
  final CouponStatus status;
  final DateTime expiryDate;
  final int usageCount;
  final int maxUsage;
  final double minOrderAmount;

  Coupon({
    required this.id,
    required this.code,
    required this.discount,
    required this.type,
    required this.status,
    required this.expiryDate,
    required this.usageCount,
    required this.maxUsage,
    this.minOrderAmount = 0,
  });

  double get usagePercentage =>
      maxUsage == 0 ? 0 : (usageCount / maxUsage) * 100;
  bool get isExpired => DateTime.now().isAfter(expiryDate);
  int get daysLeft => expiryDate.difference(DateTime.now()).inDays;
}

enum CouponType { percentage, fixed, shipping }

enum CouponStatus { active, inactive, expired }
