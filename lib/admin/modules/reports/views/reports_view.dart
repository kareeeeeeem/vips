import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/reports_controller.dart';

/// Sales, users, merchants and orders reports over a selectable date range.
class ReportsView extends GetView<AdminReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Reports',
      route: AdminRoutes.REPORTS,
      onRefresh: controller.load,
      actions: [
        IconButton(
          tooltip: 'Change date range',
          onPressed: () => _pickRange(context),
          icon: Icon(Icons.date_range_rounded, size: 20.sp, color: AdminColors.primary),
        ),
      ],
      body: Obx(() {
        if (controller.isLoading.value && controller.sales.value == null) {
          return const AdminLoading();
        }
        if (controller.errorMessage.isNotEmpty) {
          return AdminErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.load,
          );
        }

        return Column(
          children: [
            _buildRangeBar(context),
            _buildTabs(),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                child: switch (controller.activeTab.value) {
                  'users' => _buildUsersReport(),
                  'merchants' => _buildMerchantsReport(),
                  'orders' => _buildOrdersReport(),
                  _ => _buildSalesReport(),
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildRangeBar(BuildContext context) {
    return Obx(() {
      final range = controller.dateRange.value;
      // The merchants report is lifetime data — saying so beats letting the
      // operator assume the date range applies to it.
      final scoped = controller.activeTab.value != 'merchants';
      return GestureDetector(
        onTap: () => _pickRange(context),
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
          decoration: BoxDecoration(
            color: AdminColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AdminColors.border),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 15.sp, color: AdminColors.primary),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  scoped
                      ? (range == null
                          ? 'Last 30 days'
                          : '${adminDateLabel(range.start)} – ${adminDateLabel(range.end)}')
                      : 'Lifetime — this report ignores the date range',
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    color: scoped ? AdminColors.textPrimary : AdminColors.textMuted,
                  ),
                ),
              ),
              if (scoped)
                Icon(Icons.edit_calendar_outlined, size: 16.sp, color: AdminColors.textMuted),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _pickRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1),
      initialDateRange: controller.dateRange.value,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              Theme.of(context).colorScheme.copyWith(primary: AdminColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) controller.setDateRange(picked);
  }

  Widget _buildTabs() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 6.h),
      child: Obx(() => AdminFilterChips(
            options: const [
              AdminFilterOption('sales', 'Sales'),
              AdminFilterOption('orders', 'Orders'),
              AdminFilterOption('users', 'Users'),
              AdminFilterOption('merchants', 'Merchants'),
            ],
            selected: controller.activeTab.value,
            onSelected: controller.setTab,
          )),
    );
  }

  // ── Sales ─────────────────────────────────────────────────

  Widget _buildSalesReport() {
    final byDay = controller.section(controller.sales, 'byDay');
    final byMethod = controller.section(controller.sales, 'byPaymentMethod');
    final topMerchants = controller.section(controller.sales, 'topMerchants');

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                label: 'Revenue',
                value: adminMoney(controller.summary(controller.sales, 'revenue')),
                icon: Icons.payments_rounded,
                color: AdminColors.success,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: AdminStatCard(
                label: 'Completed orders',
                value: adminCount(controller.summary(controller.sales, 'orders')),
                icon: Icons.check_circle_outline_rounded,
                color: AdminColors.info,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                label: 'Avg order value',
                value: adminMoney(controller.summary(controller.sales, 'averageOrderValue')),
                icon: Icons.trending_up_rounded,
                color: AdminColors.accent,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: AdminStatCard(
                label: 'Discounts given',
                value: adminMoney(controller.summary(controller.sales, 'discounts')),
                icon: Icons.local_offer_outlined,
                color: AdminColors.purple,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        AdminCard(
          title: 'Revenue per day',
          child: AdminMiniBarChart(
            values: [for (final day in byDay) adminDouble(day['revenue'])],
            labels: [for (final day in byDay) adminString(day['date'])],
            color: AdminColors.success,
            formatValue: adminMoney,
          ),
        ),
        SizedBox(height: 16.h),
        _buildBreakdownCard(
          'By payment method',
          [
            for (final method in byMethod)
              (
                adminLabel(adminString(method['method'])),
                adminMoney(adminDouble(method['revenue'])),
                adminDouble(method['revenue']),
              ),
          ],
          AdminColors.info,
          'No completed sales in this period.',
        ),
        SizedBox(height: 16.h),
        AdminCard(
          title: 'Top merchants by revenue',
          child: topMerchants.isEmpty
              ? _mutedText('No merchant made a completed sale in this period.')
              : Column(
                  children: [
                    for (var i = 0; i < topMerchants.length; i++)
                      _rankRow(
                        rank: i + 1,
                        name: adminString(topMerchants[i]['name'], 'Unknown'),
                        detail: '${adminCount(adminInt(topMerchants[i]['orders']))} orders',
                        value: adminMoney(adminDouble(topMerchants[i]['revenue'])),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  // ── Orders ────────────────────────────────────────────────

  Widget _buildOrdersReport() {
    final byStatus = controller.section(controller.orders, 'byStatus');
    final byType = controller.section(controller.orders, 'byType');
    final byPayment = controller.section(controller.orders, 'byPaymentStatus');
    final avgMinutes = controller.orders.value?['summary'] is Map
        ? (controller.orders.value!['summary'] as Map)['averageFulfilmentMinutes']
        : null;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                label: 'Orders',
                value: adminCount(controller.summary(controller.orders, 'total')),
                icon: Icons.receipt_long_rounded,
                color: AdminColors.info,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: AdminStatCard(
                label: 'Cancellation rate',
                value: '${controller.summary(controller.orders, 'cancellationRate')}%',
                icon: Icons.cancel_outlined,
                color: AdminColors.danger,
                sublabel:
                    '${adminCount(controller.summary(controller.orders, 'cancelled'))} cancelled',
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        AdminStatCard(
          label: 'Average time to delivery',
          // null means no order in this window reached 'delivered' — saying
          // that beats printing a fabricated "0 min".
          value: avgMinutes == null
              ? 'No data'
              : '${adminDouble(avgMinutes).toStringAsFixed(0)} min',
          icon: Icons.timer_outlined,
          color: AdminColors.purple,
          sublabel: avgMinutes == null
              ? 'No order in this period reached "delivered"'
              : 'Across ${adminCount(controller.summary(controller.orders, 'deliveredSampleSize'))} delivered orders',
        ),
        SizedBox(height: 16.h),
        _buildBreakdownCard(
          'By status',
          [
            for (final status in byStatus)
              (
                adminLabel(adminString(status['status'])),
                adminCount(adminInt(status['count'])),
                adminDouble(status['count']),
              ),
          ],
          AdminColors.accent,
          'No orders in this period.',
        ),
        SizedBox(height: 16.h),
        _buildBreakdownCard(
          'By order type',
          [
            for (final type in byType)
              (
                adminLabel(adminString(type['type'])),
                adminCount(adminInt(type['count'])),
                adminDouble(type['count']),
              ),
          ],
          AdminColors.purple,
          'No orders in this period.',
        ),
        SizedBox(height: 16.h),
        _buildBreakdownCard(
          'By payment status',
          [
            for (final payment in byPayment)
              (
                adminLabel(adminString(payment['status'])),
                '${adminCount(adminInt(payment['count']))} · '
                    '${adminMoney(adminDouble(payment['value']))}',
                adminDouble(payment['count']),
              ),
          ],
          AdminColors.success,
          'No orders in this period.',
        ),
      ],
    );
  }

  // ── Users ─────────────────────────────────────────────────

  Widget _buildUsersReport() {
    final byDay = controller.section(controller.users, 'signupsByDay');
    final byRole = controller.section(controller.users, 'byRole');
    final topSpenders = controller.section(controller.users, 'topSpenders');

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                label: 'Customers',
                value: adminCount(controller.summary(controller.users, 'customers')),
                icon: Icons.people_alt_rounded,
                color: AdminColors.info,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: AdminStatCard(
                label: 'Signups in range',
                value: adminCount(controller.summary(controller.users, 'signupsInRange')),
                icon: Icons.person_add_alt_rounded,
                color: AdminColors.success,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                label: 'Email verified',
                value: adminCount(controller.summary(controller.users, 'verified')),
                icon: Icons.verified_outlined,
                color: AdminColors.purple,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: AdminStatCard(
                label: 'Security PIN set',
                value: adminCount(controller.summary(controller.users, 'withPin')),
                icon: Icons.lock_outline_rounded,
                color: AdminColors.accent,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        AdminCard(
          title: 'Signups per day',
          child: AdminMiniBarChart(
            values: [for (final day in byDay) adminDouble(day['signups'])],
            labels: [for (final day in byDay) adminString(day['date'])],
            color: AdminColors.info,
            formatValue: adminCount,
          ),
        ),
        SizedBox(height: 16.h),
        _buildBreakdownCard(
          'Accounts by role',
          [
            for (final role in byRole)
              (
                adminLabel(adminString(role['role'])),
                '${adminCount(adminInt(role['count']))} '
                    '(${adminCount(adminInt(role['active']))} active)',
                adminDouble(role['count']),
              ),
          ],
          AdminColors.purple,
          'No accounts yet.',
        ),
        SizedBox(height: 16.h),
        AdminCard(
          title: 'Top spenders (lifetime)',
          child: topSpenders.isEmpty
              ? _mutedText('No customer has completed an order yet.')
              : Column(
                  children: [
                    for (var i = 0; i < topSpenders.length; i++)
                      _rankRow(
                        rank: i + 1,
                        name: adminString(topSpenders[i]['name'], 'Unknown'),
                        detail: adminString(topSpenders[i]['email']),
                        value: adminMoney(adminDouble(topSpenders[i]['spent'])),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  // ── Merchants ─────────────────────────────────────────────

  Widget _buildMerchantsReport() {
    final byCategory = controller.section(controller.merchants, 'byCategory');
    final performance = controller.section(controller.merchants, 'performance');

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                label: 'Merchants',
                value: adminCount(controller.summary(controller.merchants, 'total')),
                icon: Icons.storefront_rounded,
                color: AdminColors.purple,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: AdminStatCard(
                label: 'Approved',
                value: adminCount(controller.summary(controller.merchants, 'approved')),
                icon: Icons.verified_outlined,
                color: AdminColors.success,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                label: 'Awaiting review',
                value: adminCount(controller.summary(controller.merchants, 'pending')),
                icon: Icons.pending_outlined,
                color: AdminColors.warning,
                onTap: () => Get.toNamed(
                  AdminRoutes.MERCHANTS,
                  arguments: {'approval': 'pending'},
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: AdminStatCard(
                label: 'Never registered',
                value: adminCount(controller.summary(controller.merchants, 'unregistered')),
                icon: Icons.assignment_late_outlined,
                color: AdminColors.textSecondary,
                onTap: () => Get.toNamed(
                  AdminRoutes.MERCHANTS,
                  arguments: {'approval': 'none'},
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _buildBreakdownCard(
          'By store category',
          [
            for (final category in byCategory)
              (
                adminString(category['category'], 'Uncategorised'),
                adminCount(adminInt(category['count'])),
                adminDouble(category['count']),
              ),
          ],
          AdminColors.info,
          'No merchants yet.',
        ),
        SizedBox(height: 16.h),
        AdminCard(
          title: 'Merchant performance',
          child: performance.isEmpty
              ? _mutedText('No merchant has taken an order yet.')
              : Column(
                  children: [
                    for (final merchant in performance)
                      InkWell(
                        onTap: () => Get.toNamed(
                          AdminRoutes.merchantDetails(
                              adminString(merchant['merchantId'])),
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      adminString(merchant['name'], 'Unknown'),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AdminColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${adminCount(adminInt(merchant['orders']))} orders · '
                                      '${merchant['cancellationRate']}% cancelled',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: adminDouble(merchant['cancellationRate']) > 20
                                            ? AdminColors.danger
                                            : AdminColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                adminMoney(adminDouble(merchant['revenue'])),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AdminColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  // ── Shared pieces ─────────────────────────────────────────

  /// Rows of (label, formatted value, raw magnitude) drawn as proportional
  /// bars against the largest value in the set.
  Widget _buildBreakdownCard(
    String title,
    List<(String, String, double)> rows,
    Color color,
    String emptyMessage,
  ) {
    if (rows.isEmpty) {
      return AdminCard(title: title, child: _mutedText(emptyMessage));
    }

    final max = rows.map((r) => r.$3).reduce((a, b) => a > b ? a : b);
    return AdminCard(
      title: title,
      child: Column(
        children: [
          for (final row in rows)
            AdminBarRow(
              label: row.$1,
              value: row.$2,
              // A set of all-zero values would divide by zero; fall back to
              // an empty bar rather than a NaN width.
              fraction: max > 0 ? row.$3 / max : 0,
              color: color,
            ),
        ],
      ),
    );
  }

  Widget _rankRow({
    required int rank,
    required String name,
    required String detail,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h),
      child: Row(
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: rank <= 3
                  ? AdminColors.accent.withValues(alpha: 0.15)
                  : AdminColors.divider,
              borderRadius: BorderRadius.circular(7.r),
            ),
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
                color: rank <= 3 ? AdminColors.accent : AdminColors.textSecondary,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AdminColors.textPrimary,
                  ),
                ),
                if (detail.isNotEmpty)
                  Text(
                    detail,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11.sp, color: AdminColors.textMuted),
                  ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: AdminColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mutedText(String text) => Text(
        text,
        style: TextStyle(fontSize: 12.sp, color: AdminColors.textMuted),
      );
}
