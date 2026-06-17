import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';

import '../controllers/merchant_home_controller.dart';
import 'widgets/merchant_bottom_nav_bar.dart';
import 'widgets/merchant_drawer.dart';

class MerchantHomeView extends GetView<MerchantHomeController> {
  const MerchantHomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // This allows the FAB to overlap with the body
      drawer: const MerchantDrawer(),
      bottomNavigationBar: Obx(
        () => MerchantBottomNavBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changePage,
        ),
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading:
            false, // يمنع ظهور أيقونة الدروير الافتراضية على اليسار
        title: InkWell(
          onTap: () => Get.toNamed(MerchantRoutes.SWITCH_BUSINESS),
          child: Row(
            children: [
              Image.asset(
                'assets/icons/iconmerchant.png',
                width: 32.w,
                height: 32.w,
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Merchant Dashboard',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "McDonald's", // This will eventually come from the profile controller
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 20.sp,
                        color: const Color(0xFF10B981),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          // 1. أيقونة الإشعارات تأتي أولاً الآن
          IconButton(
            icon: Stack(
              children: [
                const Icon(
                  Icons.notifications_none_outlined,
                  color: Color(0xFF111827),
                ),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () => Get.toNamed(MerchantRoutes.NOTIFICATIONS),
          ),

          // 2. زرار الدروير يأتي ثانياً (في أقصى اليمين)
          Builder(
            builder:
                (context) => IconButton(
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: Color(0xFF111827),
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
          ),
          SizedBox(width: 8.w), // مسافة من حافة الشاشة اليمين لجمالية التصميم
        ],
      ), // تم قفل الـ AppBar هنا بشكل صحيح
      body: RefreshIndicator(
        onRefresh: controller.refreshStats,
        color: const Color(0xFF10B981),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),

              _sectionTitle('Performance'),
              SizedBox(height: 12.h),

              // New Accounting Summary Card
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF10B981)),
                  );
                }
                return _buildAccountingSummaryCard();
              }),

              SizedBox(height: 12.h),

              // Operations list
              _buildOperationsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountingSummaryCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _accountingItem(
                'Sale',
                controller.totalSales.value,
                const Color(0xFF10B981),
              ),
              _accountingItem(
                'Expense',
                controller.totalExpenses.value,
                const Color(0xFFEF4444),
              ),
              _buildTimeSelector(),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _accountingItem(
                'Purchase',
                controller.totalPurchases.value,
                const Color(0xFF8B5CF6),
              ),
              _accountingItem(
                'Sale Due',
                controller.totalSaleDue.value,
                const Color(0xFFF97316),
              ),
              _accountingItem(
                'Due Collect',
                controller.totalDueCollect.value,
                const Color(0xFF3B82F6),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF3F4F6),
          ), // Dotted divider simulation
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _vipAccountingItem(
                'VIPs In',
                controller.vipsIn.value,
                const Color(0xFF10B981),
                Icons.arrow_downward_rounded,
              ),
              _vipAccountingItem(
                'VIPs Out',
                controller.vipsOut.value,
                const Color(0xFFEF4444),
                Icons.arrow_upward_rounded,
              ),
              _vipAccountingItem(
                'VIPs Recovery',
                controller.vipsRecovery.value,
                const Color(0xFF3B82F6),
                Icons.sync_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _vipAccountingItem(
    String label,
    double value,
    Color color,
    IconData icon,
  ) {
    String valueStr = value.toStringAsFixed(2);
    String mainPart = valueStr.split('.')[0];
    String decimalPart = valueStr.split('.')[1];

    return SizedBox(
      width: 100.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12.sp, color: color),
              SizedBox(width: 4.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: const Color(0xFF1F2937),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'VIP ',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF9CA3AF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: mainPart,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                TextSpan(
                  text: decimalPart,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountingItem(String label, double value, Color color) {
    return SizedBox(
      width: 100.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'D ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Today',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down,
            size: 16,
            color: const Color(0xFF6B7280),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF374151),
      ),
    );
  }

  Widget _buildOperationsList() {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Income/Expense',
        'icon': Icons.account_balance_wallet_outlined,
        'route': MerchantRoutes.FINANCE_DASHBOARD,
        'color': const Color(0xFF3B82F6),
      },
      {
        'title': 'All Party',
        'icon': Icons.people_alt_outlined,
        'route': MerchantRoutes.CUSTOMERS,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'title': 'Products',
        'icon': Icons.inventory_2_outlined,
        'route': MerchantRoutes.CATALOG,
        'color': const Color(0xFFF59E0B),
      },
      {
        'title': 'Sale',
        'icon': Icons.point_of_sale_outlined,
        'route': MerchantRoutes.CREATE_BILL,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'Sales List',
        'icon': Icons.receipt_long_outlined,
        'route': MerchantRoutes.ORDERS,
        'color': const Color(0xFF06B6D4),
      },
      {
        'title': 'Due List',
        'icon': Icons.assignment_late_outlined,
        'route': MerchantRoutes.DUE_LIST,
        'color': const Color(0xFFEF4444),
      },
      {
        'title': 'Purchase',
        'icon': Icons.shopping_cart_outlined,
        'route': MerchantRoutes.STOCK_LIST,
        'color': const Color(0xFF6366F1),
      },
      {
        'title': 'Purchase List',
        'icon': Icons.history_edu_outlined,
        'route': MerchantRoutes.STOCK_LIST,
        'color': const Color(0xFFEC4899),
      },
      {
        'title': 'Due Collection',
        'icon': Icons.payments_outlined,
        'route': MerchantRoutes.DUE_LIST,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'My Stock',
        'icon': Icons.warehouse_outlined,
        'route': MerchantRoutes.STOCK_LIST,
        'color': const Color(0xFFF97316),
      },
      {
        'title': 'Accounts',
        'icon': Icons.account_balance_outlined,
        'route': MerchantRoutes.ACCOUNTS,
        'color': const Color(0xFF1F2937),
      },
      {
        'title': 'Transactions',
        'icon': Icons.swap_horiz_outlined,
        'route': MerchantRoutes.WALLET,
        'color': const Color(0xFF3B82F6),
      },
      {
        'title': 'Tax Rates',
        'icon': Icons.receipt_outlined,
        'route': MerchantRoutes.TAX_RATES,
        'color': const Color(0xFFF59E0B),
      },
      {
        'title': 'Staff',
        'icon': Icons.badge_outlined,
        'route': MerchantRoutes.STAFF_MANAGEMENT,
        'color': const Color(0xFF3B82F6),
      },
      {
        'title': 'Staff Ledger',
        'icon': Icons.menu_book_outlined,
        'route': MerchantRoutes.STAFF_LEDGER,
        'color': const Color(0xFF6B7280),
      },
      {
        'title': 'Barcode',
        'icon': Icons.qr_code_scanner_outlined,
        'route': MerchantRoutes.BARCODE_GEN,
        'color': const Color(0xFF1F2937),
      },
      {
        'title': 'HRM',
        'icon': Icons.account_tree_outlined,
        'route': MerchantRoutes.HRM,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'title': 'Asset Management',
        'icon': Icons.home_repair_service_outlined,
        'route': MerchantRoutes.ASSET_MANAGEMENT,
        'color': const Color(0xFFF97316),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menuItems.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.90,
      ),
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return InkWell(
          onTap: () => Get.toNamed(item['route']),
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: item['color'] as Color,
                    size: 24.sp,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  item['title'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _listTile(String title, String subtitle, IconData icon, String route) {
    return ListTile(
      onTap: () => Get.toNamed(route),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: const Color(0xFF4B5563), size: 20.sp),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF111827),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6));
  }
}
