import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/admin_toast.dart';
import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/reports_controller.dart';

/// Seven reports behind one date range and granularity.
class ReportsView extends GetView<AdminReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Reports',
      route: AdminRoutes.REPORTS,
      onRefresh: controller.refreshCurrent,
      actions: [
        Obx(() => IconButton(
              tooltip: 'Export CSV',
              onPressed: controller.isExporting.value ? null : _export,
              icon: Icon(Icons.download_rounded,
                  size: 20.sp, color: AdminColors.textSecondary),
            )),
        IconButton(
          tooltip: 'Change date range',
          onPressed: () => _pickRange(context),
          icon: Icon(Icons.date_range_rounded, size: 20.sp, color: AdminColors.primary),
        ),
      ],
      body: Column(
        children: [
          _buildTabs(),
          _buildRangeBar(context),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.current == null) {
                return const AdminLoading();
              }
              if (controller.errorMessage.isNotEmpty && controller.current == null) {
                return AdminErrorState(
                  message: controller.errorMessage.value,
                  onRetry: controller.refreshCurrent,
                );
              }
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
                child: switch (controller.activeTab.value) {
                  'profit' => _buildProfit(),
                  'products' => _buildProducts(),
                  'customers' => _buildCustomers(),
                  'orders' => _buildOrders(),
                  'merchants' => _buildMerchants(),
                  'commission' => _buildCommission(),
                  _ => _buildSales(),
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Chrome ────────────────────────────────────────────────

  Widget _buildTabs() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 6.h),
      child: Obx(() => AdminFilterChips(
            options: [
              for (final type in AdminReportsController.reports)
                AdminFilterOption(type, adminLabel(type)),
            ],
            selected: controller.activeTab.value,
            onSelected: controller.setTab,
          )),
    );
  }

  Widget _buildRangeBar(BuildContext context) {
    return Obx(() {
      final range = controller.dateRange.value;
      final lifetime = controller.isLifetime;

      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
        child: Column(
          children: [
            GestureDetector(
              onTap: lifetime ? null : () => _pickRange(context),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
                decoration: BoxDecoration(
                  color: AdminColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AdminColors.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 15.sp,
                        color: lifetime ? AdminColors.textMuted : AdminColors.primary),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        // Said explicitly rather than showing a range this
                        // report does not use.
                        lifetime
                            ? 'Lifetime — this report ignores the date range'
                            : range == null
                                ? 'Last 30 days'
                                : '${adminDateLabel(range.start)} – ${adminDateLabel(range.end)}',
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w600,
                          color:
                              lifetime ? AdminColors.textMuted : AdminColors.textPrimary,
                        ),
                      ),
                    ),
                    if (!lifetime)
                      Icon(Icons.edit_calendar_outlined,
                          size: 16.sp, color: AdminColors.textMuted),
                  ],
                ),
              ),
            ),
            if (controller.isGroupable) ...[
              SizedBox(height: 8.h),
              AdminFilterChips(
                options: [
                  for (final g in AdminReportsController.granularities)
                    AdminFilterOption(g, adminLabel(g)),
                ],
                selected: controller.groupBy.value,
                onSelected: controller.setGroupBy,
              ),
            ],
          ],
        ),
      );
    });
  }

  Future<void> _pickRange(BuildContext context) async {
    if (controller.isLifetime) {
      return adminToast('Lifetime report',
          'This report covers all time and ignores the date range.',
          isError: false);
    }
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

  Future<void> _export() async {
    final csv = await controller.exportCsv();
    if (csv == null) return;
    // A browser download needs a user gesture this side cannot fake, so the
    // file is shown for copying rather than a button that silently does
    // nothing.
    adminSheet(
      title: controller.exportFilename,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'The report as CSV. Copy it into a spreadsheet, or use the '
            "browser's print view for a PDF.",
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.45,
              color: AdminColors.textSecondary,
            ),
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AdminColors.background,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AdminColors.border),
            ),
            child: SelectableText(
              csv,
              style: TextStyle(
                fontSize: 11.sp,
                height: 1.5,
                fontFamily: 'monospace',
                color: AdminColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared pieces ─────────────────────────────────────────

  Widget _statRow(List<Widget> cards) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) SizedBox(width: 10.w),
            Expanded(child: cards[i]),
          ],
        ],
      ),
    );
  }

  Widget _seriesChart(String valueKey, String label, Color color,
      {bool money = true}) {
    final series = controller.section('series');
    return AdminCard(
      title: label,
      child: AdminMiniBarChart(
        values: [for (final s in series) adminDouble(s[valueKey])],
        labels: [for (final s in series) adminString(s['period'])],
        color: color,
        formatValue: money ? adminMoney : adminCount,
      ),
    );
  }

  Widget _barBreakdown(
    String title,
    List<(String, String, double)> rows,
    Color color,
    String emptyMessage,
  ) {
    if (rows.isEmpty) {
      return AdminCard(title: title, child: _muted(emptyMessage));
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
              // An all-zero set would divide by zero; fall back to an empty bar.
              fraction: max > 0 ? row.$3 / max : 0,
              color: color,
            ),
        ],
      ),
    );
  }

  Widget _rankTable(
    String title,
    List<Map<String, dynamic>> rows,
    String emptyMessage, {
    required String Function(Map<String, dynamic>) name,
    required String Function(Map<String, dynamic>) detail,
    required String Function(Map<String, dynamic>) value,
    void Function(Map<String, dynamic>)? onTap,
  }) {
    return AdminCard(
      title: title,
      child: rows.isEmpty
          ? _muted(emptyMessage)
          : Column(
              children: [
                for (var i = 0; i < rows.length; i++)
                  InkWell(
                    onTap: onTap == null ? null : () => onTap(rows[i]),
                    borderRadius: BorderRadius.circular(10.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                      child: Row(
                        children: [
                          Container(
                            width: 24.w,
                            height: 24.w,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: i < 3
                                  ? AdminColors.accent.withValues(alpha: 0.15)
                                  : AdminColors.divider,
                              borderRadius: BorderRadius.circular(7.r),
                            ),
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w800,
                                color:
                                    i < 3 ? AdminColors.accent : AdminColors.textSecondary,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name(rows[i]),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AdminColors.textPrimary,
                                  ),
                                ),
                                if (detail(rows[i]).isNotEmpty)
                                  Text(
                                    detail(rows[i]),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 11.sp, color: AdminColors.textMuted),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            value(rows[i]),
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
    );
  }

  Widget _muted(String text) => Text(
        text,
        style: TextStyle(fontSize: 12.sp, color: AdminColors.textMuted),
      );

  /// A banner for a number the operator should not read at face value.
  Widget _caveat(String text, {Color color = AdminColors.warning}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 17.sp, color: color),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11.5.sp,
                height: 1.45,
                color: AdminColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sales ─────────────────────────────────────────────────

  Widget _buildSales() {
    return Column(
      children: [
        _statRow([
          AdminStatCard(
            label: 'Revenue',
            value: adminMoney(controller.summary('revenue')),
            icon: Icons.payments_rounded,
            color: AdminColors.success,
            sublabel: 'Online + till',
          ),
          AdminStatCard(
            label: 'Orders',
            value: adminCount(controller.summary('orders')),
            icon: Icons.receipt_long_rounded,
            color: AdminColors.info,
          ),
        ]),
        _statRow([
          AdminStatCard(
            label: 'Avg order',
            value: adminMoney(controller.summary('averageOrderValue')),
            icon: Icons.trending_up_rounded,
            color: AdminColors.accent,
          ),
          AdminStatCard(
            label: 'Discounts',
            value: adminMoney(controller.summary('discounts')),
            icon: Icons.local_offer_outlined,
            color: AdminColors.purple,
          ),
        ]),
        _statRow([
          AdminStatCard(
            label: 'Online',
            value: adminMoney(controller.summary('onlineRevenue')),
            icon: Icons.shopping_bag_outlined,
            color: AdminColors.info,
          ),
          AdminStatCard(
            label: 'Point of sale',
            value: adminMoney(controller.summary('posRevenue')),
            icon: Icons.point_of_sale_outlined,
            color: AdminColors.primary,
          ),
        ]),
        SizedBox(height: 4.h),
        _seriesChart(
            'revenue', 'Revenue per ${controller.groupBy.value}', AdminColors.success),
        SizedBox(height: 14.h),
        _barBreakdown(
          'By payment method',
          [
            for (final m in controller.section('byPaymentMethod'))
              (
                adminLabel(adminString(m['method'])),
                adminMoney(adminDouble(m['revenue'])),
                adminDouble(m['revenue']),
              ),
          ],
          AdminColors.info,
          'No completed sales in this period.',
        ),
        SizedBox(height: 14.h),
        _rankTable(
          'Top merchants',
          controller.section('topMerchants'),
          'No merchant made a completed sale in this period.',
          name: (m) => adminString(m['name'], 'Unknown'),
          detail: (m) => '${adminCount(adminInt(m['orders']))} orders',
          value: (m) => adminMoney(adminDouble(m['revenue'])),
          onTap: (m) =>
              Get.toNamed(AdminRoutes.merchantDetails(adminString(m['merchantId']))),
        ),
      ],
    );
  }

  // ── Profit ────────────────────────────────────────────────

  Widget _buildProfit() {
    final coverage = controller.summary('costCoverage');
    final withCost = controller.summary('productsWithCost');
    final totalProducts = controller.summary('productsTotal');

    return Column(
      children: [
        // The most important thing on this screen: a margin computed over 5%
        // of revenue is not the business's margin, and saying so is the
        // difference between a report and a misleading number.
        if (coverage < 100)
          _caveat(
            coverage == 0
                ? 'No cost prices are recorded, so no margin can be calculated. '
                    '${adminCount(withCost)} of ${adminCount(totalProducts)} products have a cost — '
                    'set one and this report fills in.'
                : 'Margin covers ${coverage.toStringAsFixed(1)}% of revenue — the sales whose '
                    'product has a cost recorded (${adminCount(withCost)} of '
                    '${adminCount(totalProducts)} products). Treat it as indicative '
                    'until every product has a cost.',
            color: coverage == 0 ? AdminColors.danger : AdminColors.warning,
          ),
        _statRow([
          AdminStatCard(
            label: 'Revenue',
            value: adminMoney(controller.summary('revenue')),
            icon: Icons.payments_rounded,
            color: AdminColors.success,
          ),
          AdminStatCard(
            label: 'Cost of goods',
            value: adminMoney(controller.summary('cost')),
            icon: Icons.inventory_2_outlined,
            color: AdminColors.danger,
          ),
        ]),
        _statRow([
          AdminStatCard(
            label: 'Gross profit',
            value: adminMoney(controller.summary('grossProfit')),
            icon: Icons.savings_outlined,
            color: AdminColors.primary,
            sublabel: 'On costed sales only',
          ),
          AdminStatCard(
            label: 'Margin',
            value: coverage == 0
                ? 'No data'
                : '${controller.summary('margin').toStringAsFixed(1)}%',
            icon: Icons.percent_rounded,
            color: AdminColors.accent,
            sublabel: '${coverage.toStringAsFixed(1)}% cost coverage',
          ),
        ]),
        SizedBox(height: 4.h),
        _seriesChart('grossProfit', 'Gross profit per ${controller.groupBy.value}',
            AdminColors.primary),
        SizedBox(height: 14.h),
        AdminCard(
          title: 'Per ${controller.groupBy.value}',
          child: controller.section('series').isEmpty
              ? _muted('No sales in this period.')
              : Column(
                  children: [
                    for (final row in controller.section('series'))
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.h),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                adminString(row['period']),
                                style: TextStyle(
                                    fontSize: 12.sp, color: AdminColors.textSecondary),
                              ),
                            ),
                            Text(
                              adminMoney(adminDouble(row['revenue'])),
                              style: TextStyle(
                                  fontSize: 12.sp, color: AdminColors.textPrimary),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              adminMoney(adminDouble(row['grossProfit'])),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: AdminColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  // ── Products ──────────────────────────────────────────────

  Widget _buildProducts() {
    final notSold = controller.section('notSold');
    return Column(
      children: [
        _statRow([
          AdminStatCard(
            label: 'Products sold',
            value: adminCount(controller.summary('productsSold')),
            icon: Icons.local_mall_outlined,
            color: AdminColors.info,
          ),
          AdminStatCard(
            label: 'Units',
            value: adminCount(controller.summary('unitsSold')),
            icon: Icons.numbers_rounded,
            color: AdminColors.accent,
          ),
        ]),
        _statRow([
          AdminStatCard(
            label: 'Revenue',
            value: adminMoney(controller.summary('revenue')),
            icon: Icons.payments_rounded,
            color: AdminColors.success,
          ),
          AdminStatCard(
            label: 'Sold nothing',
            value: adminCount(controller.summary('notSold')),
            icon: Icons.remove_shopping_cart_outlined,
            color: AdminColors.textSecondary,
            sublabel: 'Active but no sales',
          ),
        ]),
        SizedBox(height: 4.h),
        _rankTable(
          'Top by revenue',
          controller.section('topByRevenue'),
          'Nothing sold in this period.',
          name: (p) => adminString(p['name'], 'Unnamed'),
          detail: (p) => '${adminCount(adminInt(p['units']))} units',
          value: (p) => adminMoney(adminDouble(p['revenue'])),
        ),
        SizedBox(height: 14.h),
        _rankTable(
          'Top by units',
          controller.section('topByUnits'),
          'Nothing sold in this period.',
          name: (p) => adminString(p['name'], 'Unnamed'),
          detail: (p) => adminMoney(adminDouble(p['revenue'])),
          value: (p) => adminCount(adminInt(p['units'])),
        ),
        SizedBox(height: 14.h),
        AdminCard(
          // Just as actionable as the best sellers, and invisible in a top-N
          // list — this is shelf space earning nothing.
          title: 'Active but not selling',
          child: notSold.isEmpty
              ? _muted('Every active product sold at least once in this period.')
              : Column(
                  children: [
                    for (final p in notSold.take(15))
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.h),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                adminString(p['name'], 'Unnamed'),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 12.5.sp, color: AdminColors.textPrimary),
                              ),
                            ),
                            Text(
                              '${adminCount(adminInt(p['stock']))} in stock',
                              style: TextStyle(
                                  fontSize: 11.sp, color: AdminColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  // ── Customers ─────────────────────────────────────────────

  Widget _buildCustomers() {
    return Column(
      children: [
        _statRow([
          AdminStatCard(
            label: 'Customers',
            value: adminCount(controller.summary('customers')),
            icon: Icons.people_alt_rounded,
            color: AdminColors.info,
            sublabel: '${adminCount(controller.summary('active'))} active',
          ),
          AdminStatCard(
            label: 'New in range',
            value: adminCount(controller.summary('signupsInRange')),
            icon: Icons.person_add_alt_rounded,
            color: AdminColors.success,
          ),
        ]),
        _statRow([
          AdminStatCard(
            label: 'Ever bought',
            value: adminCount(controller.summary('buyers')),
            icon: Icons.shopping_bag_outlined,
            color: AdminColors.accent,
            sublabel:
                '${controller.summary('conversionRate').toStringAsFixed(1)}% of customers',
          ),
          AdminStatCard(
            label: 'Repeat rate',
            value: '${controller.summary('repeatRate').toStringAsFixed(1)}%',
            icon: Icons.repeat_rounded,
            color: AdminColors.purple,
            sublabel:
                '${adminCount(controller.summary('repeatBuyers'))} bought more than once',
          ),
        ]),
        _statRow([
          AdminStatCard(
            label: 'Lifetime value',
            value: adminMoney(controller.summary('lifetimeValue')),
            icon: Icons.diamond_outlined,
            color: AdminColors.primary,
            sublabel: 'Average per buyer',
          ),
          AdminStatCard(
            label: 'Bought in range',
            value: adminCount(controller.summary('activeInRange')),
            icon: Icons.event_available_outlined,
            color: AdminColors.info,
          ),
        ]),
        SizedBox(height: 4.h),
        AdminCard(
          title: 'Signups per ${controller.groupBy.value}',
          child: AdminMiniBarChart(
            values: [
              for (final s in controller.section('signupsByPeriod'))
                adminDouble(s['signups'])
            ],
            labels: [
              for (final s in controller.section('signupsByPeriod'))
                adminString(s['period'])
            ],
            color: AdminColors.info,
            formatValue: adminCount,
          ),
        ),
        SizedBox(height: 14.h),
        _rankTable(
          'Top spenders (lifetime)',
          controller.section('topSpenders'),
          'No customer has completed an order yet.',
          name: (c) => adminString(c['name'], 'Unknown'),
          detail: (c) =>
              '${adminCount(adminInt(c['orders']))} orders · avg ${adminMoney(adminDouble(c['averageOrder']))}',
          value: (c) => adminMoney(adminDouble(c['spent'])),
          onTap: (c) => Get.toNamed(AdminRoutes.userDetails(adminString(c['userId']))),
        ),
      ],
    );
  }

  // ── Orders ────────────────────────────────────────────────

  Widget _buildOrders() {
    final noFulfilment = controller.summaryIsNull('averageFulfilmentMinutes');
    return Column(
      children: [
        _statRow([
          AdminStatCard(
            label: 'Orders',
            value: adminCount(controller.summary('total')),
            icon: Icons.receipt_long_rounded,
            color: AdminColors.info,
          ),
          AdminStatCard(
            label: 'Cancellation rate',
            value: '${controller.summary('cancellationRate').toStringAsFixed(1)}%',
            icon: Icons.cancel_outlined,
            color: AdminColors.danger,
            sublabel: '${adminCount(controller.summary('cancelled'))} cancelled',
          ),
        ]),
        AdminStatCard(
          label: 'Average time to delivery',
          // null means nothing reached 'delivered' in the window; printing a
          // fabricated 0 would read as instant fulfilment.
          value: noFulfilment
              ? 'No data'
              : '${controller.summary('averageFulfilmentMinutes').toStringAsFixed(0)} min',
          icon: Icons.timer_outlined,
          color: AdminColors.purple,
          sublabel: noFulfilment
              ? 'No order reached "delivered" in this period'
              : 'Across ${adminCount(controller.summary('deliveredSampleSize'))} delivered orders',
        ),
        SizedBox(height: 14.h),
        _barBreakdown(
          'By status',
          [
            for (final s in controller.section('byStatus'))
              (
                adminLabel(adminString(s['status'])),
                adminCount(adminInt(s['count'])),
                adminDouble(s['count']),
              ),
          ],
          AdminColors.accent,
          'No orders in this period.',
        ),
        SizedBox(height: 14.h),
        _barBreakdown(
          'By order type',
          [
            for (final t in controller.section('byType'))
              (
                adminLabel(adminString(t['type'])),
                adminCount(adminInt(t['count'])),
                adminDouble(t['count']),
              ),
          ],
          AdminColors.purple,
          'No orders in this period.',
        ),
        SizedBox(height: 14.h),
        _barBreakdown(
          'By payment status',
          [
            for (final p in controller.section('byPaymentStatus'))
              (
                adminLabel(adminString(p['status'])),
                '${adminCount(adminInt(p['count']))} · ${adminMoney(adminDouble(p['value']))}',
                adminDouble(p['count']),
              ),
          ],
          AdminColors.success,
          'No orders in this period.',
        ),
      ],
    );
  }

  // ── Merchants ─────────────────────────────────────────────

  Widget _buildMerchants() {
    return Column(
      children: [
        _statRow([
          AdminStatCard(
            label: 'Merchants',
            value: adminCount(controller.summary('total')),
            icon: Icons.storefront_rounded,
            color: AdminColors.purple,
          ),
          AdminStatCard(
            label: 'Approved',
            value: adminCount(controller.summary('approved')),
            icon: Icons.verified_outlined,
            color: AdminColors.success,
          ),
        ]),
        _statRow([
          AdminStatCard(
            label: 'Awaiting review',
            value: adminCount(controller.summary('pending')),
            icon: Icons.pending_outlined,
            color: AdminColors.warning,
            onTap: () =>
                Get.toNamed(AdminRoutes.MERCHANTS, arguments: {'approval': 'pending'}),
          ),
          AdminStatCard(
            label: 'Never registered',
            value: adminCount(controller.summary('unregistered')),
            icon: Icons.assignment_late_outlined,
            color: AdminColors.textSecondary,
            onTap: () =>
                Get.toNamed(AdminRoutes.MERCHANTS, arguments: {'approval': 'none'}),
          ),
        ]),
        SizedBox(height: 4.h),
        _barBreakdown(
          'By store category',
          [
            for (final c in controller.section('byCategory'))
              (
                adminString(c['category'], 'Uncategorised'),
                adminCount(adminInt(c['count'])),
                adminDouble(c['count']),
              ),
          ],
          AdminColors.info,
          'No merchants yet.',
        ),
        SizedBox(height: 14.h),
        _rankTable(
          'Performance',
          controller.section('performance'),
          'No merchant has taken an order yet.',
          name: (m) => adminString(m['name'], 'Unknown'),
          detail: (m) =>
              '${adminCount(adminInt(m['orders']))} orders · ${m['cancellationRate']}% cancelled',
          value: (m) => adminMoney(adminDouble(m['revenue'])),
          onTap: (m) =>
              Get.toNamed(AdminRoutes.merchantDetails(adminString(m['merchantId']))),
        ),
      ],
    );
  }

  // ── Commission ────────────────────────────────────────────

  Widget _buildCommission() {
    final zeroRate = controller.summary('merchantsOnZeroRate');
    final withRate = controller.summary('merchantsWithRateSet');

    return Column(
      children: [
        // Without this, a near-zero commission total reads as weak sales
        // rather than as rates never having been set.
        if (zeroRate > 0)
          _caveat(
            '${adminCount(zeroRate)} of the merchants that sold in this period are on a '
            '0% rate, so they contribute nothing to the total. '
            '${adminCount(withRate)} merchant(s) have a rate set — set one on a '
            "merchant's record to include them.",
          ),
        _statRow([
          AdminStatCard(
            label: 'Platform commission',
            value: adminMoney(controller.summary('commission')),
            icon: Icons.account_balance_rounded,
            color: AdminColors.primary,
          ),
          AdminStatCard(
            label: 'Effective rate',
            value: '${controller.summary('effectiveRate').toStringAsFixed(2)}%',
            icon: Icons.percent_rounded,
            color: AdminColors.accent,
            sublabel: 'Across all sales',
          ),
        ]),
        _statRow([
          AdminStatCard(
            label: 'Revenue',
            value: adminMoney(controller.summary('revenue')),
            icon: Icons.payments_rounded,
            color: AdminColors.success,
          ),
          AdminStatCard(
            label: 'Merchants keep',
            value: adminMoney(controller.summary('merchantEarnings')),
            icon: Icons.storefront_outlined,
            color: AdminColors.purple,
          ),
        ]),
        SizedBox(height: 4.h),
        _rankTable(
          'By merchant',
          controller.section('byMerchant'),
          'No merchant made a completed sale in this period.',
          name: (m) => adminString(m['name'], 'Unknown'),
          detail: (m) =>
              '${m['commissionRate']}% of ${adminMoney(adminDouble(m['revenue']))} · '
              '${adminCount(adminInt(m['orders']))} orders',
          value: (m) => adminMoney(adminDouble(m['commission'])),
          onTap: (m) =>
              Get.toNamed(AdminRoutes.merchantDetails(adminString(m['merchantId']))),
        ),
      ],
    );
  }
}
