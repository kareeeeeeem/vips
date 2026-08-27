import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/modules/merchant_home/controllers/merchant_home_controller.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import 'package:vip/appuser/modules/QR_scanner/views/q_r_scanner_view.dart';

/// Displays the Gift Back Quick Actions overlay as a bottom sheet.
/// Usage: showGiftBackQuickActions(context);
void showGiftBackQuickActions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const GiftBackQuickActionsSheet(),
  );
}

class GiftBackQuickActionsSheet extends StatelessWidget {
  const GiftBackQuickActionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 24.h,
        bottom: 32.h + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 24.h),

          // Title
          Text(
            'Quick Actions!',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 8.h),

          // Available VIPs Points
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available VIPs Points',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.back();
                  Get.toNamed(MerchantRoutes.SETTINGS);
                },
                child: Icon(
                  Icons.settings_outlined,
                  size: 18.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Points display
          // Real spendable balance (User.walletPoints via /merchant/profile).
          // This used to read `vipsIn` (lifetime rewards issued to customers)
          // and then split the digit string two from the right to fake a
          // decimal part — so 1500 points was displayed as "15.00".
          Obx(() {
            final homeCtrl = Get.find<MerchantHomeController>();
            final pts = homeCtrl.availablePoints.value;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  pts.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8.h, left: 6.w),
                  child: Text(
                    'PTS',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: 24.h),

          // Grid of Quick Actions
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.0,
            children: [
              // 'Expense' opened Bill Inquiry — bills are money coming in,
              // not an expense. Recording an expense is the Finance
              // Add-Transaction screen, opened straight on its Expense tab.
              _buildActionItem(
                icon: Icons.swap_horiz_rounded,
                label: 'Expense',
                bgColor: const Color(0xFFE8F5E9),
                iconColor: const Color(0xFF4CAF50),
                onTap: () {
                  Get.back();
                  Get.toNamed(MerchantRoutes.ADD_TRANSACTION,
                      arguments: {'type': 'expense'});
                },
              ),
              _buildActionItem(
                icon: Icons.card_giftcard_rounded,
                label: 'Gift Back',
                bgColor: const Color(0xFFFFF3E0),
                iconColor: const Color(0xFFFF9800),
                isPrimary: true,
                onTap: () {
                  Get.back();
                  Get.toNamed(MerchantRoutes.GIFT_BACK_FORM);
                },
              ),
              // 'Reward' opened the subscription pricing screen, which has
              // nothing to do with rewarding a customer. Creating a coupon is
              // the merchant's real reward-offer action.
              _buildActionItem(
                icon: Icons.star_rounded,
                label: 'Reward',
                bgColor: const Color(0xFFFCE4EC),
                iconColor: const Color(0xFFE91E63),
                onTap: () {
                  Get.back();
                  Get.toNamed(MerchantRoutes.CREATE_COUPON);
                },
              ),
              // 'Income' opened the invoice screen with no arguments, so it
              // rendered that screen's "#INV-0000 / D 0.00" placeholders —
              // a receipt for nothing. Recording income is Add Transaction.
              _buildActionItem(
                icon: Icons.payment_rounded,
                label: 'Income',
                bgColor: const Color(0xFFE3F2FD),
                iconColor: const Color(0xFF2196F3),
                onTap: () {
                  Get.back();
                  Get.toNamed(MerchantRoutes.ADD_TRANSACTION,
                      arguments: {'type': 'income'});
                },
              ),
              _buildActionItem(
                icon: Icons.toggle_on_rounded,
                label: 'Switch',
                bgColor: const Color(0xFFF3E5F5),
                iconColor: const Color(0xFF9C27B0),
                onTap: () {
                  Get.back();
                  Get.toNamed(MerchantRoutes.SWITCH_BUSINESS);
                },
              ),
              _buildActionItem(
                icon: Icons.qr_code_scanner_rounded,
                label: 'Scan QR',
                bgColor: const Color(0xFFE0F7FA),
                iconColor: const Color(0xFF00BCD4),
                onTap: () {
                  Get.back();
                  Get.to(() => QRScannerView());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
    bool isPrimary = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFFFFF8E1) : bgColor,
          borderRadius: BorderRadius.circular(16.r),
          border:
              isPrimary
                  ? Border.all(color: const Color(0xFFFF9800), width: 2)
                  : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(child: Icon(icon, size: 24.sp, color: iconColor)),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w600,
                color:
                    isPrimary
                        ? const Color(0xFFFF9800)
                        : const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
