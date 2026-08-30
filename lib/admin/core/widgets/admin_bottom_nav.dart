import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../routes/admin_routes.dart';
import '../theme/admin_theme.dart';
import 'admin_nav_entry.dart';

/// Reports and Settings live in the drawer only.
class AdminBottomNav extends StatelessWidget {
  final String currentRoute;

  const AdminBottomNav({super.key, required this.currentRoute});

  static const List<AdminNavEntry> entries = [
    AdminNavEntry(AdminRoutes.DASHBOARD, 'Home', Icons.dashboard_rounded),
    AdminNavEntry(AdminRoutes.USERS, 'Users', Icons.people_alt_rounded),
    AdminNavEntry(AdminRoutes.ORDERS, 'Orders', Icons.receipt_long_rounded),
    AdminNavEntry(AdminRoutes.MERCHANTS, 'Stores', Icons.storefront_rounded),
    AdminNavEntry(AdminRoutes.INVENTORY, 'Stock', Icons.inventory_2_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final index = entries.indexWhere((e) => e.route == currentRoute);

    return Container(
      decoration: const BoxDecoration(
        color: AdminColors.surface,
        border: Border(top: BorderSide(color: AdminColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62.h,
          child: Row(
            children: List.generate(entries.length, (i) {
              final entry = entries[i];
              final isActive = i == index;
              return Expanded(
                child: InkWell(
                  onTap: isActive ? null : () => Get.offNamed(entry.route),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        entry.icon,
                        size: 21.sp,
                        color: isActive ? AdminColors.primary : AdminColors.textMuted,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        entry.label,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive ? AdminColors.primary : AdminColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// One navigation destination. Public because [AdminDrawer.entries] and
/// [AdminBottomNav.entries] expose the lists themselves.
