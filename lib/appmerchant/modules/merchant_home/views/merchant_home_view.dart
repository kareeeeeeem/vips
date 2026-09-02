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
              // The shop's own logo, not the app's icon. Falls back to the
              // bundled mark only while the profile is still loading or when
              // the merchant has not uploaded one.
              Obx(() {
                final logo = controller.storeImageUrl.value;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: logo.isNotEmpty
                      ? Image.network(
                          logo,
                          width: 34.w,
                          height: 34.w,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/icons/iconmerchant.png',
                            width: 34.w,
                            height: 34.w,
                          ),
                        )
                      : Image.asset(
                          'assets/icons/iconmerchant.png',
                          width: 34.w,
                          height: 34.w,
                        ),
                );
              }),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Row(
                    children: [
                      Text(
                        controller.storeName.value.isNotEmpty ? controller.storeName.value : 'My Store',
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
                  )),
                  // The category sits where "Merchant Dashboard" used to.
                  Obx(() => Text(
                        controller.storeCategory.value.isNotEmpty
                            ? controller.storeCategory.value
                            : 'Set your category',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
        actions: [
          // 1. أيقونة الإشعارات تأتي أولاً الآن
          IconButton(
            // Badge reflects the real unread count from
            // GET /merchant/notifications — it used to be a red dot that was
            // always painted, so the merchant saw "you have notifications"
            // even with an empty inbox.
            icon: Obx(() {
              final unread = controller.unreadNotifications.value;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.notifications_none_outlined,
                    color: Color(0xFF111827),
                  ),
                  if (unread > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        constraints: const BoxConstraints(minWidth: 16),
                        child: Text(
                          unread > 99 ? '99+' : '$unread',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }),
            onPressed: () async {
              await Get.toNamed(MerchantRoutes.NOTIFICATIONS);
              // Reading the inbox changes the unread count.
              await controller.refreshUnreadNotifications();
            },
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
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 120.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Performance'),
              SizedBox(height: 12.h),

              // Accounting Summary Card
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF10B981)),
                  );
                }
                return _buildAccountingSummaryCard();
              }),

              SizedBox(height: 14.h),

              // Campaigns the merchant has running. Given real width here
              // because it is the one thing on this screen that earns them
              // customers, rather than reporting on ones they already have.
              _buildAdsStrip(),

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
            color: Colors.black.withValues(alpha: 0.02),
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
              // Backend has no supplier purchase-order log; this figure is
              // stock-on-hand x unit price, so it is labelled for what it
              // actually is. It is also the one card the period filter does
              // not apply to — a stock level is a balance, not a flow.
              _accountingItem(
                'Stock Value',
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

  /// Period filter for the Performance card. This used to be a static
  /// "Today" chip with a chevron and no tap handler at all — it looked like a
  /// filter but the figures were always all-time.
  /// The merchant's live campaigns, and a way in when there are none.
  Widget _buildAdsStrip() {
    return Obx(() {
      final ads = controller.activeAds;

      if (ads.isEmpty) {
        return Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: InkWell(
            onTap: () => Get.toNamed(MerchantRoutes.ADVERTISEMENTS),
            borderRadius: BorderRadius.circular(14.r),
            child: Container(
              height: 96.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign_rounded, color: Colors.white, size: 26.sp),
                  SizedBox(height: 6.h),
                  Text(
                    'Run an ad',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Put your shop in front of VIPs customers nearby',
                    style: TextStyle(fontSize: 11.sp, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return Padding(
        padding: EdgeInsets.only(bottom: 14.h),
        child: SizedBox(
          height: 96.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: ads.length,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              final ad = ads[index];
              return InkWell(
                onTap: () => Get.toNamed(MerchantRoutes.ADVERTISEMENTS),
                borderRadius: BorderRadius.circular(14.r),
                child: Container(
                  width: 280.w,
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${ad['title'] ?? 'Campaign'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${ad['adType'] ?? 'Banner'} · running',
                        style: TextStyle(fontSize: 11.sp, color: Colors.white70),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(Icons.visibility_outlined,
                              size: 13.sp, color: Colors.white70),
                          SizedBox(width: 4.w),
                          Text(
                            '${ad['impressions'] ?? 0} seen',
                            style: TextStyle(fontSize: 11.sp, color: Colors.white),
                          ),
                          SizedBox(width: 12.w),
                          Icon(Icons.touch_app_outlined,
                              size: 13.sp, color: Colors.white70),
                          SizedBox(width: 4.w),
                          Text(
                            '${ad['clicks'] ?? 0} taps',
                            style: TextStyle(fontSize: 11.sp, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  /// Income and expense are two different records, so the tile that covers
  /// both asks which before opening the form on the right one.
  void _openIncomeOrExpense() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 28.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What are you recording?',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            SizedBox(height: 16.h),
            _financeChoice(
              label: 'Money in',
              blurb: 'A sale, a payment received, anything that adds to the till',
              icon: Icons.south_west_rounded,
              color: const Color(0xFF059669),
              type: 'income',
            ),
            SizedBox(height: 10.h),
            _financeChoice(
              label: 'Money out',
              blurb: 'Rent, stock, wages, anything you paid for',
              icon: Icons.north_east_rounded,
              color: const Color(0xFFDC2626),
              type: 'expense',
            ),
            SizedBox(height: 14.h),
            Center(
              child: TextButton(
                onPressed: () {
                  Get.back<void>();
                  Get.toNamed(MerchantRoutes.FINANCE_DASHBOARD);
                },
                child: Text(
                  'See everything recorded',
                  style: TextStyle(fontSize: 13.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _financeChoice({
    required String label,
    required String blurb,
    required IconData icon,
    required Color color,
    required String type,
  }) {
    return InkWell(
      onTap: () {
        Get.back<void>();
        Get.toNamed(MerchantRoutes.ADD_TRANSACTION, arguments: {'type': type});
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(9.w),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 17.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    blurb,
                    style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18.sp, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return PopupMenuButton<String>(
      tooltip: 'Change period',
      padding: EdgeInsets.zero,
      onSelected: controller.changePeriod,
      itemBuilder: (context) => MerchantHomeController.periods
          .map(
            (p) => PopupMenuItem<String>(
              value: p,
              child: Row(
                children: [
                  if (controller.selectedPeriod.value == p)
                    Icon(Icons.check, size: 16.sp, color: const Color(0xFF10B981))
                  else
                    SizedBox(width: 16.sp),
                  SizedBox(width: 8.w),
                  Text(MerchantHomeController.periodLabels[p]!),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
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
            Flexible(
              child: Text(
                controller.selectedPeriodLabel,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: const Color(0xFF6B7280),
            ),
          ],
        ),
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
      // The two the whole loyalty model runs on, so they lead: recording a
      // sale is how a customer earns anything, and the guarantee is what
      // pays for it.
      {
        'title': 'Add Points',
        'icon': Icons.qr_code_scanner_rounded,
        'route': MerchantRoutes.EARN,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'My Guarantee',
        'icon': Icons.account_balance_outlined,
        'route': MerchantRoutes.GUARANTEE,
        'color': const Color(0xFF00205C),
      },
      {
        'title': 'Reward Action',
        'icon': Icons.campaign_outlined,
        'route': MerchantRoutes.REWARD_ACTION,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'title': 'Income/Expense',
        'icon': Icons.account_balance_wallet_outlined,
        // Two entries behind one label, so the tile asks which. It used to
        // land on the finance dashboard, from which recording either one
        // took two more taps and a tab.
        'route': MerchantRoutes.FINANCE_DASHBOARD,
        'onTap': _openIncomeOrExpense,
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
      // 'Purchase', 'Purchase List' and 'My Stock' all opened the very same
      // Stock screen, and 'Due Collection' opened the very same Due List as
      // 'Due List' — five tiles, two destinations. The backend has no
      // supplier purchase-order ledger and no separate due-collection
      // history (collecting happens inside the Due List itself), so the
      // extra labels promised screens that do not exist. Kept one tile per
      // real destination.
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
      // 'Staff Ledger' and 'HRM' both opened the very same Staff Management
      // screen as 'Staff' — three tiles, one destination. Staff has no ledger
      // or payroll data behind it (models/Staff.js is name/role/status/salary
      // only), so those two labels promised screens that do not exist.
      // The whole Advertisements feature (create / pause / resume / boost /
      // delete, all real endpoints) had no entry point anywhere in the app.
      {
        'title': 'Advertisements',
        'icon': Icons.campaign_outlined,
        'route': MerchantRoutes.ADVERTISEMENTS,
        'color': const Color(0xFFEC4899),
      },
      {
        'title': 'Barcode',
        'icon': Icons.qr_code_scanner_outlined,
        'route': MerchantRoutes.BARCODE_GEN,
        'color': const Color(0xFF1F2937),
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
      // Wide, short rows rather than tall squares: the icon is a marker for
      // the label beside it, not the subject of the tile. Fitting twice as
      // many on a screen is the point — this list is thirteen entries long.
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 2.55,
      ),
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return InkWell(
          onTap: item['onTap'] as VoidCallback? ??
              () => Get.toNamed(item['route'] as String),
          borderRadius: BorderRadius.circular(14.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: item['color'] as Color,
                    size: 17.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    item['title'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF374151),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}
