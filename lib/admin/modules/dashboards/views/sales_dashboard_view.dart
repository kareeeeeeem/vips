import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/admin_toast.dart';
import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../../auth/controllers/admin_auth_controller.dart';
import '../controllers/sales_dashboard_controller.dart';
import '../models/dashboard_models.dart';
import '../widgets/dashboard_chart.dart';
import '../widgets/dashboard_quick_stats.dart';
import '../widgets/dashboard_stats_card.dart';
import '../widgets/dashboard_table.dart';
import 'dashboard_shell.dart';

/// What the platform sold, and through which channel.
class SalesDashboardView extends GetView<SalesDashboardController> {
  const SalesDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'Sales',
      route: AdminRoutes.DASH_SALES,
      controller: controller,
      body: () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCards(),
          SizedBox(height: 12.h),
          _buildCharts(),
          _buildQuickStats(),
          _buildTables(),
        ],
      ),
    );
  }

  Widget _buildCards() {
    return DashboardStatsGrid(
      cards: [
        DashboardStatsCard(
          title: 'Total revenue',
          value: adminMoney(controller.totalRevenue),
          change: controller.change('totalRevenue'),
          icon: Icons.payments_outlined,
          color: AdminColors.success,
        ),
        DashboardStatsCard(
          title: 'Orders',
          value: '${controller.totalOrders}',
          change: controller.change('totalOrders'),
          icon: Icons.receipt_long_outlined,
          color: AdminColors.primary,
        ),
        DashboardStatsCard(
          title: 'Average order value',
          value: adminMoney(controller.averageOrderValue),
          change: controller.change('averageOrderValue'),
          icon: Icons.calculate_outlined,
          color: AdminColors.info,
        ),
        DashboardStatsCard(
          title: 'Conversion rate',
          value: '—',
          // Named as untracked rather than shown as a plausible number: this
          // platform stores no visitor or session data to divide orders by.
          isUnavailable: !controller.conversionIsTracked,
          note: controller.conversionNote,
          icon: Icons.percent_rounded,
          color: AdminColors.textMuted,
        ),
      ],
    );
  }

  Widget _buildCharts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardChart(
          title: 'Revenue',
          data: controller.salesChart,
          type: DashboardChartType.line,
          color: AdminColors.success,
          formatValue: adminMoney,
        ),
        DashboardChart(
          title: 'Orders per period',
          data: controller.orderVolume,
          type: DashboardChartType.bar,
          color: AdminColors.primary,
          formatValue: (v) => '${v.toInt()}',
        ),
        DashboardChart(
          title: 'Where the money came in',
          subtitle: 'Online orders against counter sales',
          data: controller.channelSplit,
          type: DashboardChartType.pie,
          formatValue: adminMoney,
          height: 160.h,
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    final unattributed = controller.unattributedRevenue;
    return DashboardQuickStats(
      title: 'Breakdown',
      stats: [
        QuickStat('Online revenue', adminMoney(controller.onlineRevenue)),
        QuickStat('Counter revenue', adminMoney(controller.posRevenue)),
        QuickStat(
          'Previous period',
          adminMoney(controller.previous('totalRevenue')),
          note: 'The same length of time immediately before this window',
        ),
        // Only shown when there is something to explain: order lines with no
        // product id and no name cannot be attributed to any product, so the
        // ranking below does not account for this money.
        if (unattributed > 0)
          QuickStat(
            'Unattributed',
            adminMoney(unattributed),
            tone: AdminColors.warning,
            note: 'Sold on lines carrying no product — not in the ranking below',
          ),
      ],
    );
  }

  /// Opens the row's own record.
  ///
  /// A counter sale is a PosInvoice, and the receipt screen renders a full
  /// invoice rather than fetching one by id — handing it this summary row
  /// would draw a receipt with no lines on it. Those go to the receipts
  /// history instead, which can find the real thing.
  void _openSaleRow(Map<String, dynamic> row) {
    final id = adminString(row['_id']);
    if (id.isEmpty) return;

    if (adminString(row['source']) == 'pos') {
      final auth = Get.isRegistered<AdminAuthController>()
          ? Get.find<AdminAuthController>()
          : null;
      if (auth != null && !auth.can('pos.read')) {
        adminToast('Not allowed',
            'Viewing receipts needs the pos.read permission.', isError: true);
        return;
      }
      Get.toNamed(AdminRoutes.POS_INVOICES);
      return;
    }
    Get.toNamed(AdminRoutes.orderDetails(id));
  }

  Widget _buildTables() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardTable(
          title: 'Top products',
          subtitle: 'By revenue in this window',
          columns: [
            const DashboardColumn('Product', 'name', flex: 3),
            DashboardColumn('Units', 'sales', numeric: true, format: dashboardCount),
            DashboardColumn('Revenue', 'revenue', numeric: true, format: dashboardMoney),
          ],
          rows: controller.topProducts,
          emptyMessage: 'Nothing sold in this window.',
        ),
        DashboardTable(
          title: 'Top merchants',
          subtitle: 'By revenue in this window',
          columns: [
            const DashboardColumn('Merchant', 'name', flex: 3),
            DashboardColumn('Orders', 'orders', numeric: true, format: dashboardCount),
            DashboardColumn('Revenue', 'revenue', numeric: true, format: dashboardMoney),
          ],
          rows: controller.topMerchants,
          onRowTap: (row) {
            final id = adminString(row['merchantId']);
            if (id.isNotEmpty) Get.toNamed(AdminRoutes.merchantDetails(id));
          },
        ),
        DashboardTable(
          title: 'Recent orders',
          subtitle: 'Online orders and counter sales together',
          columns: [
            const DashboardColumn('Reference', 'reference', flex: 2),
            const DashboardColumn('Customer', 'customerName', flex: 2),
            const DashboardColumn('Status', 'status'),
            DashboardColumn('Amount', 'amount', numeric: true, format: dashboardMoney),
          ],
          rows: controller.recentOrders,
          onRowTap: _openSaleRow,
        ),
      ],
    );
  }
}
