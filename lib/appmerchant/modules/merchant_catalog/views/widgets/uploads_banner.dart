import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import '../../controllers/merchant_catalog_controller.dart';

/// Shows how much of the current plan's product allowance is left.
///
/// This used to render the literal string '8/2' with a "Matches mock" comment
/// — its own `remaining`/`total` parameters were never read, so every merchant
/// on every plan saw the same made-up figure. It now reads the real
/// `features.maxProducts` from GET /merchant/subscription/current against the
/// merchant's real product count.
class UploadsBanner extends StatelessWidget {
  final VoidCallback? onUpgrade;

  const UploadsBanner({super.key, this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Obx(() {
              final c = Get.find<MerchantCatalogController>();
              if (!c.hasPlanInfo.value) {
                return Text(
                  'Checking your plan…',
                  style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
                );
              }
              final unlimited = c.maxProducts.value < 0;
              return Row(
                children: [
                  Flexible(
                    child: Text(
                      unlimited ? 'Products:' : 'Remaining uploads:',
                      style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    unlimited
                        ? 'Unlimited'
                        : '${c.productsRemaining < 0 ? 0 : c.productsRemaining}/${c.maxProducts.value}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: (!unlimited && c.productsRemaining <= 0)
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF1F2937),
                    ),
                  ),
                ],
              );
            }),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onUpgrade ?? () => Get.toNamed(MerchantRoutes.SUBSCRIPTION_PACKAGES),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Text(
                    'Upgrade Package',
                    style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1F2937)),
                  ),
                  SizedBox(width: 4.w),
                  Icon(Icons.arrow_forward_ios, size: 10.sp, color: const Color(0xFF1F2937)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
