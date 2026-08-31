import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../modules/auth/controllers/admin_auth_controller.dart';
import '../routes/admin_routes.dart';
import '../theme/admin_theme.dart';
import 'admin_nav_entry.dart';

/// Full navigation for the console. Every entry points at a registered route.
class AdminDrawer extends StatelessWidget {
  final String currentRoute;

  const AdminDrawer({super.key, required this.currentRoute});

  static const List<AdminNavEntry> entries = [
    AdminNavEntry(AdminRoutes.DASHBOARD, 'Dashboard', Icons.dashboard_outlined),
    AdminNavEntry(AdminRoutes.USERS, 'Users', Icons.people_alt_outlined),
    AdminNavEntry(AdminRoutes.MERCHANTS, 'Merchants', Icons.storefront_outlined),
    AdminNavEntry(AdminRoutes.ORDERS, 'Orders', Icons.receipt_long_outlined),
    AdminNavEntry(AdminRoutes.INVENTORY, 'Inventory', Icons.inventory_2_outlined),
    AdminNavEntry(AdminRoutes.POS, 'Point of Sale', Icons.point_of_sale_outlined),
    AdminNavEntry(AdminRoutes.REPORTS, 'Reports', Icons.insert_chart_outlined),
    AdminNavEntry(AdminRoutes.STAFF, 'Staff', Icons.badge_outlined),
    AdminNavEntry(AdminRoutes.SETTINGS, 'Settings', Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280.w,
      backgroundColor: AdminColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              children: [
                for (final entry in entries)
                  _drawerItem(
                    entry,
                    isActive: entry.route == currentRoute,
                  ),
              ],
            ),
          ),
          const Divider(indent: 20, endIndent: 20, color: AdminColors.divider),
          _buildLogoutButton(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 56.h, 20.w, 24.h),
      decoration: const BoxDecoration(
        color: AdminColors.primary,
        borderRadius: BorderRadius.only(topRight: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.admin_panel_settings_rounded,
                  color: AdminColors.primary,
                  size: 28.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'VIPs Admin',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                if (Get.isRegistered<AdminAuthController>())
                  Obx(() {
                    final email = Get.find<AdminAuthController>().adminEmail.value;
                    return Text(
                      email.isEmpty ? 'Platform console' : email,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(AdminNavEntry entry, {required bool isActive}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
      child: Material(
        color: isActive ? AdminColors.primary.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () {
            Get.back(); // close the drawer first
            if (isActive) return;
            // offNamed, not toNamed: the drawer is lateral navigation, so
            // hopping between sections must not build an unbounded back stack.
            Get.offNamed(entry.route);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            child: Row(
              children: [
                Icon(
                  entry.icon,
                  size: 20.sp,
                  color: isActive ? AdminColors.primary : AdminColors.textSecondary,
                ),
                SizedBox(width: 14.w),
                Text(
                  entry.label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? AdminColors.primary : AdminColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            Get.back();
            if (Get.isRegistered<AdminAuthController>()) {
              Get.find<AdminAuthController>().confirmLogout();
            }
          },
          icon: Icon(Icons.logout_rounded, size: 18.sp, color: AdminColors.danger),
          label: Text(
            'Sign out',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AdminColors.danger,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            side: BorderSide(color: AdminColors.danger.withValues(alpha: 0.4)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
        ),
      ),
    );
  }
}

/// Bottom bar for the five sections an operator moves between constantly.
/// Reports and Settings live in the drawer only.
