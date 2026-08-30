import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Dashboard',
      route: AdminRoutes.DASHBOARD,
      onRefresh: controller.load,
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: controller.load,
          icon: Icon(Icons.refresh_rounded, size: 20.sp, color: AdminColors.textSecondary),
        ),
      ],
      body: Obx(() {
        if (controller.isLoading.value && controller.stats.isEmpty) {
          return const AdminLoading();
        }
        if (controller.errorMessage.isNotEmpty && controller.stats.isEmpty) {
          return AdminErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.load,
          );
        }

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          children: [
            _buildStatGrid(),
            SizedBox(height: 16.h),
            _buildQuickActions(),
            SizedBox(height: 16.h),
            _buildChartCard(),
            SizedBox(height: 16.h),
            _buildAlertsCard(),
            SizedBox(height: 16.h),
            _buildPendingApprovals(),
            SizedBox(height: 16.h),
            _buildRecentOrders(),
            SizedBox(height: 16.h),
            _buildRecentUsers(),
          ],
        );
      }),
    );
  }

  // ── Stat cards ────────────────────────────────────────────

  Widget _buildStatGrid() {
    final cards = <Widget>[
      AdminStatCard(
        label: 'Customers',
        value: adminCount(controller.stat('users', 'total')),
        icon: Icons.people_alt_rounded,
        color: AdminColors.info,
        sublabel: '${adminCount(controller.stat('users', 'newLast30Days'))} new in 30 days',
        onTap: () => Get.toNamed(AdminRoutes.USERS),
      ),
      AdminStatCard(
        label: 'Merchants',
        value: adminCount(controller.stat('merchants', 'total')),
        icon: Icons.storefront_rounded,
        color: AdminColors.purple,
        sublabel: '${adminCount(controller.stat('merchants', 'pendingApproval'))} awaiting approval',
        onTap: () => Get.toNamed(AdminRoutes.MERCHANTS),
      ),
      AdminStatCard(
        label: 'Orders',
        value: adminCount(controller.stat('orders', 'total')),
        icon: Icons.receipt_long_rounded,
        color: AdminColors.accent,
        sublabel: '${adminCount(controller.stat('orders', 'pending'))} pending',
        onTap: () => Get.toNamed(AdminRoutes.ORDERS),
      ),
      AdminStatCard(
        label: 'Revenue',
        value: adminMoney(controller.stat('revenue', 'total')),
        icon: Icons.payments_rounded,
        color: AdminColors.success,
        sublabel: '${adminMoney(controller.stat('revenue', 'last30Days'))} in 30 days',
        onTap: () => Get.toNamed(AdminRoutes.REPORTS),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Two columns on a phone, four on anything tablet-width and up.
        final columns = constraints.maxWidth > 700 ? 4 : 2;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: columns == 4 ? 1.5 : 1.25,
          children: cards,
        );
      },
    );
  }

  // ── Quick actions ─────────────────────────────────────────

  /// Jump straight to the screens an operator opens most, each pre-filtered
  /// to the subset they actually came to deal with.
  Widget _buildQuickActions() {
    return AdminCard(
      title: 'Quick actions',
      child: Wrap(
        spacing: 10.w,
        runSpacing: 10.h,
        children: [
          _quickAction(
            'Approve merchants',
            Icons.verified_outlined,
            AdminColors.warning,
            () => Get.toNamed(AdminRoutes.MERCHANTS, arguments: {'approval': 'pending'}),
          ),
          _quickAction(
            'Pending orders',
            Icons.pending_actions_outlined,
            AdminColors.info,
            () => Get.toNamed(AdminRoutes.ORDERS, arguments: {'status': 'pending'}),
          ),
          _quickAction(
            'Refund requests',
            Icons.assignment_return_outlined,
            AdminColors.danger,
            () => Get.toNamed(AdminRoutes.ORDERS,
                arguments: {'status': 'refund_requested'}),
          ),
          _quickAction(
            'Low stock',
            Icons.inventory_2_outlined,
            AdminColors.accent,
            () => Get.toNamed(AdminRoutes.INVENTORY, arguments: {'lowStock': true}),
          ),
          _quickAction(
            'Banned accounts',
            Icons.block_rounded,
            AdminColors.textSecondary,
            () => Get.toNamed(AdminRoutes.USERS, arguments: {'status': 'banned'}),
          ),
          _quickAction(
            'Sales report',
            Icons.insert_chart_outlined,
            AdminColors.success,
            () => Get.toNamed(AdminRoutes.REPORTS),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17.sp, color: color),
            SizedBox(width: 9.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Chart ─────────────────────────────────────────────────

  Widget _buildChartCard() {
    return AdminCard(
      title: 'Activity',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final days in [7, 14, 30])
            Padding(
              padding: EdgeInsets.only(left: 6.w),
              child: GestureDetector(
                onTap: () => controller.setChartDays(days),
                child: Obx(() {
                  final active = controller.chartDays.value == days;
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: active ? AdminColors.primary : AdminColors.divider,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      '${days}d',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: active ? Colors.white : AdminColors.textSecondary,
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => AdminFilterChips(
                options: const [
                  AdminFilterOption('revenue', 'Revenue'),
                  AdminFilterOption('orders', 'Orders'),
                  AdminFilterOption('users', 'Signups'),
                ],
                selected: controller.chartMetric.value,
                onSelected: controller.setChartMetric,
              )),
          SizedBox(height: 16.h),
          Obx(() {
            final metric = controller.chartMetric.value;
            return AdminMiniBarChart(
              values: controller.chartValues,
              labels: controller.chartLabels,
              color: metric == 'revenue'
                  ? AdminColors.success
                  : metric == 'orders'
                      ? AdminColors.accent
                      : AdminColors.info,
              formatValue: (v) =>
                  metric == 'revenue' ? adminMoney(v) : adminCount(v),
            );
          }),
        ],
      ),
    );
  }

  // ── Operational alerts ────────────────────────────────────

  Widget _buildAlertsCard() {
    return Obx(() {
      final lowStock = controller.stat('catalog', 'lowStockItems');
      final payouts = controller.stat('payouts', 'pending');
      final pendingMerchants = controller.stat('merchants', 'pendingApproval');
      final banned = controller.stat('users', 'banned');

      final alerts = <Widget>[
        if (pendingMerchants > 0)
          _alertRow(
            Icons.storefront_outlined,
            AdminColors.warning,
            '${adminCount(pendingMerchants)} merchant${pendingMerchants == 1 ? '' : 's'} awaiting approval',
            () => Get.toNamed(AdminRoutes.MERCHANTS, arguments: {'approval': 'pending'}),
          ),
        if (lowStock > 0)
          _alertRow(
            Icons.inventory_2_outlined,
            AdminColors.danger,
            '${adminCount(lowStock)} stock item${lowStock == 1 ? '' : 's'} at or below threshold',
            () => Get.toNamed(AdminRoutes.INVENTORY, arguments: {'lowStock': true}),
          ),
        if (payouts > 0)
          _alertRow(
            Icons.account_balance_outlined,
            AdminColors.info,
            '${adminCount(payouts)} payout request${payouts == 1 ? '' : 's'} pending',
            null,
          ),
        if (banned > 0)
          _alertRow(
            Icons.block_rounded,
            AdminColors.textSecondary,
            '${adminCount(banned)} banned account${banned == 1 ? '' : 's'}',
            () => Get.toNamed(AdminRoutes.USERS, arguments: {'status': 'banned'}),
          ),
      ];

      return AdminCard(
        title: 'Needs attention',
        child: alerts.isEmpty
            ? Row(
                children: [
                  Icon(Icons.check_circle_rounded, size: 18.sp, color: AdminColors.success),
                  SizedBox(width: 10.w),
                  Text(
                    'Nothing needs attention right now.',
                    style: TextStyle(fontSize: 13.sp, color: AdminColors.textSecondary),
                  ),
                ],
              )
            : Column(children: alerts),
      );
    });
  }

  Widget _alertRow(IconData icon, Color color, String text, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 4.w),
        child: Row(
          children: [
            Icon(icon, size: 18.sp, color: color),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AdminColors.textPrimary,
                ),
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, size: 18.sp, color: AdminColors.textMuted),
          ],
        ),
      ),
    );
  }

  // ── Pending approvals ─────────────────────────────────────

  Widget _buildPendingApprovals() {
    return Obx(() {
      final items = controller.pendingRegistrations;
      if (items.isEmpty) return const SizedBox.shrink();

      return AdminCard(
        title: 'Pending merchant approvals',
        trailing: TextButton(
          onPressed: () =>
              Get.toNamed(AdminRoutes.MERCHANTS, arguments: {'approval': 'pending'}),
          child: Text('View all', style: TextStyle(fontSize: 12.sp)),
        ),
        child: Column(
          children: [
            for (final reg in items.take(4))
              Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: AdminColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(Icons.store_mall_directory_outlined,
                          size: 18.sp, color: AdminColors.warning),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            adminString(reg['businessName'], 'Unnamed business'),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AdminColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${adminString(reg['ownerName'], 'Unknown owner')} · '
                            '${adminRelative(adminDate(reg['createdAt']))}',
                            style: TextStyle(fontSize: 11.sp, color: AdminColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    AdminStatusPill(
                      label: adminLabel(adminString(reg['status'])),
                      color: AdminColors.approvalStatus(adminString(reg['status'])),
                      compact: true,
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  // ── Recent activity ───────────────────────────────────────

  Widget _buildRecentOrders() {
    return Obx(() {
      final orders = controller.recentOrders;
      return AdminCard(
        title: 'Recent orders',
        trailing: TextButton(
          onPressed: () => Get.toNamed(AdminRoutes.ORDERS),
          child: Text('View all', style: TextStyle(fontSize: 12.sp)),
        ),
        child: orders.isEmpty
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text(
                  'No orders yet.',
                  style: TextStyle(fontSize: 13.sp, color: AdminColors.textMuted),
                ),
              )
            : Column(
                children: [
                  for (final order in orders)
                    InkWell(
                      onTap: () => Get.toNamed(
                        AdminRoutes.orderDetails(adminString(order['_id'])),
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
                                    '#${adminString(order['orderNumber'], '—')} · '
                                    '${adminString(order['customerName'], 'Unknown customer')}',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AdminColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    '${adminString(order['merchantName'], 'No merchant')} · '
                                    '${adminRelative(adminDate(order['createdAt']))}',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 11.sp, color: AdminColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  adminMoney(adminDouble(order['totalAmount'])),
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AdminColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                AdminStatusPill(
                                  label: adminLabel(adminString(order['status'])),
                                  color: AdminColors.orderStatus(adminString(order['status'])),
                                  compact: true,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      );
    });
  }

  Widget _buildRecentUsers() {
    return Obx(() {
      final users = controller.recentUsers;
      return AdminCard(
        title: 'New customers',
        trailing: TextButton(
          onPressed: () => Get.toNamed(AdminRoutes.USERS),
          child: Text('View all', style: TextStyle(fontSize: 12.sp)),
        ),
        child: users.isEmpty
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text(
                  'No customers yet.',
                  style: TextStyle(fontSize: 13.sp, color: AdminColors.textMuted),
                ),
              )
            : Column(
                children: [
                  for (final user in users)
                    InkWell(
                      onTap: () => Get.toNamed(
                        AdminRoutes.userDetails(adminString(user['_id'])),
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16.r,
                              backgroundColor: AdminColors.info.withValues(alpha: 0.12),
                              child: Text(
                                _initial(adminString(user['fullName'])),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AdminColors.info,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    adminString(user['fullName'], 'Unnamed'),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AdminColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    adminString(user['email']),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 11.sp, color: AdminColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              adminRelative(adminDate(user['createdAt'])),
                              style: TextStyle(fontSize: 11.sp, color: AdminColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      );
    });
  }

  String _initial(String name) => name.isEmpty ? '?' : name[0].toUpperCase();
}
