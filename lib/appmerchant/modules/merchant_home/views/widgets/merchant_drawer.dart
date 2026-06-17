import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/modules/merchant_auth/controllers/merchant_auth_controller.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';

class MerchantDrawer extends StatelessWidget {
  const MerchantDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<MerchantAuthController>();
    return Drawer(
      width: 280.w,
      backgroundColor: Colors.white,
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
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Column(
                children: [
                  _drawerItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    onTap: () => Get.back(),
                    isActive: true,
                  ),
                  _drawerItem(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Orders',
                    onTap: () => Get.toNamed(MerchantRoutes.ORDERS),
                  ),
                  _drawerItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Wallet & Finance',
                    onTap: () => Get.toNamed(MerchantRoutes.FINANCE_DASHBOARD),
                  ),
                  _drawerItem(
                    icon: Icons.inventory_2_outlined,
                    label: 'Inventory',
                    onTap: () => Get.toNamed(MerchantRoutes.CATALOG),
                  ),
                  _drawerItem(
                    icon: Icons.people_alt_outlined,
                    label: 'Customers',
                    onTap: () => Get.toNamed(MerchantRoutes.CUSTOMERS),
                  ),
                  _drawerItem(
                    icon: Icons.badge_outlined,
                    label: 'Staff Management',
                    onTap: () => Get.toNamed(MerchantRoutes.STAFF_MANAGEMENT),
                  ),
                  _drawerItem(
                    icon: Icons.notifications_none_rounded,
                    label: 'Notifications',
                    onTap: () => Get.toNamed(MerchantRoutes.NOTIFICATIONS),
                  ),
                  const Divider(indent: 20, endIndent: 20, color: Color(0xFFF3F4F6)),
                  _drawerItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () => Get.toNamed(MerchantRoutes.SETTINGS),
                  ),
                  _drawerItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Help & Support',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          _buildLogoutButton(authController),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 24.h),
      decoration: const BoxDecoration(
        color: Color(0xFF10B981),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Image.asset(
              'assets/icons/iconmerchant.png',
              width: 40.w,
              height: 40.w,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "McDonald's",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "merchant@mcdonalds.com",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF10B981).withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22.sp,
                  color: isActive ? const Color(0xFF10B981) : const Color(0xFF6B7280),
                ),
                SizedBox(width: 16.w),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive ? const Color(0xFF10B981) : const Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(MerchantAuthController authController) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.back(); // Close drawer
            authController.logout();
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFFEE2E2)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.logout_rounded,
                  size: 22,
                  color: Color(0xFFEF4444),
                ),
                SizedBox(width: 16.w),
                Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
