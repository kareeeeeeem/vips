import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/operations_dashboard_controller.dart';
import '../models/dashboard_models.dart';
import '../widgets/dashboard_chart.dart';
import '../widgets/dashboard_quick_stats.dart';
import '../widgets/dashboard_stats_card.dart';
import '../widgets/dashboard_table.dart';
import 'dashboard_shell.dart';

/// The order queue, the fulfilment clock and the stock backlog.
class OperationsDashboardView extends GetView<OperationsDashboardController> {
  const OperationsDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'Operations',
      route: AdminRoutes.DASH_OPERATIONS,
      controller: controller,
      body: () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCards(),
          SizedBox(height: 12.h),
          _buildFulfilment(),
          _buildCharts(),
          _buildTables(),
        ],
      ),
    );
  }

  Widget _buildCards() {
    return DashboardStatsGrid(
      cards: [
        DashboardStatsCard(
          title: 'Pending',
          value: '${controller.pendingOrders}',
          note: 'Waiting to be accepted',
          icon: Icons.hourglass_empty_rounded,
          color: AdminColors.warning,
          onTap: () => Get.toNamed(AdminRoutes.ORDERS),
        ),
        DashboardStatsCard(
          title: 'In progress',
          value: '${controller.inProgressOrders}',
          note: 'Confirmed through to handover',
          icon: Icons.sync_rounded,
          color: AdminColors.info,
          onTap: () => Get.toNamed(AdminRoutes.ORDERS),
        ),
        DashboardStatsCard(
          title: 'Completed',
          value: '${controller.completedOrders}',
          note: 'Delivered or picked up',
          icon: Icons.check_circle_outline_rounded,
          color: AdminColors.success,
        ),
        DashboardStatsCard(
          title: 'Cancelled',
          value: '${controller.cancelledOrders}',
          // A rise in cancellations is bad news, so it must not paint green.
          change: controller.change('cancelledOrders'),
          higherIsBetter: false,
          note: '${controller.cancellationRate.toStringAsFixed(1)}% of orders',
          icon: Icons.cancel_outlined,
          color: AdminColors.danger,
        ),
      ],
    );
  }

  Widget _buildFulfilment() {
    final sample = controller.fulfilmentSampleSize;

    return DashboardQuickStats(
      title: 'Fulfilment and stock',
      stats: [
        QuickStat(
          'Average fulfilment',
          // Null, not zero, when nothing was delivered: an empty sample and an
          // instant delivery are different answers and must read differently.
          controller.hasFulfilmentSample
              ? '${controller.averageFulfilmentHours.toStringAsFixed(2)} h'
              : 'No data',
          note: controller.hasFulfilmentSample
              ? 'Averaged over $sample delivered order${sample == 1 ? '' : 's'}'
              : 'No order in this window carries a delivery time',
        ),
        QuickStat(
          'Unpaid orders',
          '${controller.unpaidOrders}',
          tone: controller.unpaidOrders > 0 ? AdminColors.warning : null,
          note: 'Payment not yet settled',
        ),
        QuickStat(
          'Low stock lines',
          '${controller.lowStockItems}',
          tone: controller.lowStockItems > 0 ? AdminColors.warning : null,
          note: 'At or under their own threshold',
        ),
        QuickStat(
          'Out of stock',
          '${controller.outOfStockItems}',
          tone: controller.outOfStockItems > 0 ? AdminColors.danger : null,
          note: 'Nothing left to sell',
        ),
      ],
    );
  }

  Widget _buildCharts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardChart(
          title: 'Order status',
          subtitle: 'Every order in this window, by where it stands',
          data: controller.statusDistribution,
          type: DashboardChartType.pie,
          formatValue: (v) => '${v.toInt()}',
          height: 160.h,
        ),
        DashboardChart(
          title: 'The queue',
          subtitle: 'How far along the orders in this window are',
          data: controller.queueStages,
          type: DashboardChartType.bar,
          color: AdminColors.info,
          formatValue: (v) => '${v.toInt()}',
          height: 150.h,
        ),
      ],
    );
  }

  Widget _buildTables() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardTable(
          title: 'Needs restocking',
          subtitle: 'Lowest first',
          columns: [
            const DashboardColumn('Item', 'name', flex: 3),
            const DashboardColumn('Location', 'location', flex: 2),
            DashboardColumn('In stock', 'currentStock',
                numeric: true, format: dashboardCount),
            DashboardColumn('Threshold', 'lowStockThreshold',
                numeric: true, format: dashboardCount),
          ],
          rows: controller.lowStockList,
          emptyMessage: 'Every stock line is above its threshold.',
          trailing: TextButton(
            onPressed: () => Get.toNamed(AdminRoutes.INVENTORY_ALERTS),
            child: Text('All alerts', style: TextStyle(fontSize: 11.5.sp)),
          ),
        ),
        DashboardTable(
          title: 'Recently touched orders',
          // Said plainly: there is no per-change audit trail behind this, so
          // it shows where each order landed, not how it got there.
          subtitle: 'Where each order stands, most recently updated first',
          columns: [
            const DashboardColumn('Reference', 'reference', flex: 2),
            const DashboardColumn('Merchant', 'merchantName', flex: 2),
            const DashboardColumn('Status', 'status'),
            DashboardColumn('Amount', 'amount', numeric: true, format: dashboardMoney),
          ],
          rows: controller.recentActivity,
          onRowTap: (row) {
            final id = adminString(row['_id']);
            if (id.isNotEmpty) Get.toNamed(AdminRoutes.orderDetails(id));
          },
        ),
      ],
    );
  }
}
