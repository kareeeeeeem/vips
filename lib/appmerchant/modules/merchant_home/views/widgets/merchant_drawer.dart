import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vip/appmerchant/modules/merchant_auth/controllers/merchant_auth_controller.dart';
import 'package:vip/appmerchant/modules/merchant_home/controllers/merchant_home_controller.dart';
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
                    icon: Icons.campaign_outlined,
                    label: 'Advertisements',
                    onTap: () => Get.toNamed(MerchantRoutes.ADVERTISEMENTS),
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
                    onTap: () => _showHelp(),
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
    final homeCtrl = Get.find<MerchantHomeController>();
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 24.h),
      decoration: const BoxDecoration(
        color: Color(0xFF10B981),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
        ),
      ),
      child: Obx(() => Row(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: homeCtrl.storeImageUrl.value.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.network(homeCtrl.storeImageUrl.value, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset('assets/icons/iconmerchant.png', width: 40.w, height: 40.w)),
                  )
                : Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Image.asset('assets/icons/iconmerchant.png', width: 40.w, height: 40.w),
                  ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  homeCtrl.storeName.value.isNotEmpty ? homeCtrl.storeName.value : 'My Store',
                  style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  homeCtrl.storePhone.value.isNotEmpty ? homeCtrl.storePhone.value : 'Merchant',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      )),
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
              color: isActive ? const Color(0xFF10B981).withValues(alpha: 0.1) : Colors.transparent,
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

  void _showHelp() {
    Get.back();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.support_agent_rounded, size: 48, color: Color(0xFF10B981)),
            const SizedBox(height: 12),
            const Text('Help & Support', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Contact our merchant support team.',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.email_outlined, color: Color(0xFF10B981)),
              ),
              title: const Text('Email Support', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('support@vipsapp.com'),
              onTap: () => _launchMailto('support@vipsapp.com', 'VIPs Merchant Help'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  static Future<void> _launchMailto(String email, String subject) async {
    final uri = Uri.parse('mailto:$email?subject=$subject');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
