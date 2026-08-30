import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';

/// The four inventory screens share one tab strip, so every one of them is
/// reachable from every other. Without it Movements and Transfers would be
/// registered routes that nothing navigates to.
class InventoryTabs extends StatelessWidget {
  final String current;

  const InventoryTabs({super.key, required this.current});

  static const List<(String, String, IconData)> tabs = [
    (AdminRoutes.INVENTORY, 'Overview', Icons.inventory_2_outlined),
    (AdminRoutes.INVENTORY_MOVEMENTS, 'Movements', Icons.swap_vert_rounded),
    (AdminRoutes.INVENTORY_TRANSFERS, 'Transfers', Icons.compare_arrows_rounded),
    (AdminRoutes.INVENTORY_ALERTS, 'Alerts', Icons.warning_amber_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AdminColors.surface,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final tab in tabs) _buildTab(tab.$1, tab.$2, tab.$3),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String route, String label, IconData icon) {
    final active = route == current;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: InkWell(
        // offNamed, not toNamed: these four are siblings, so hopping between
        // them must not stack an unbounded back history.
        onTap: active ? null : () => Get.offNamed(route),
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: active ? AdminColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15.sp,
                color: active ? Colors.white : AdminColors.textSecondary,
              ),
              SizedBox(width: 7.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                  color: active ? Colors.white : AdminColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
