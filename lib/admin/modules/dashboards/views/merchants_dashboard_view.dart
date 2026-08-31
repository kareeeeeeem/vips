import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/merchants_dashboard_controller.dart';
import '../models/dashboard_models.dart';
import '../widgets/dashboard_chart.dart';
import '../widgets/dashboard_quick_stats.dart';
import '../widgets/dashboard_stats_card.dart';
import '../widgets/dashboard_table.dart';
import 'dashboard_shell.dart';

/// The merchant roster, who is selling, and who is not.
class MerchantsDashboardView extends GetView<MerchantsDashboardController> {
  const MerchantsDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'Merchants',
      route: AdminRoutes.DASH_MERCHANTS,
      controller: controller,
      body: () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCards(),
          SizedBox(height: 12.h),
          _buildActivity(),
          _buildCharts(),
          _buildTable(),
        ],
      ),
    );
  }

  Widget _buildCards() {
    return DashboardStatsGrid(
      cards: [
        DashboardStatsCard(
          title: 'Total merchants',
          value: '${controller.totalMerchants}',
          note: '${controller.activeMerchants} visible to customers',
          icon: Icons.storefront_outlined,
          color: AdminColors.primary,
          onTap: () => Get.toNamed(AdminRoutes.MERCHANTS),
        ),
        DashboardStatsCard(
          title: 'Selling this period',
          value: '${controller.sellingMerchants}',
          note: '${controller.idleMerchants} sold nothing',
          icon: Icons.point_of_sale_outlined,
          color: AdminColors.success,
        ),
        DashboardStatsCard(
          title: 'Pending approvals',
          value: '${controller.pendingApprovals}',
          note: 'Business registrations awaiting a decision',
          icon: Icons.pending_actions_outlined,
          color: AdminColors.warning,
          onTap: () => Get.toNamed(AdminRoutes.MERCHANTS),
        ),
        DashboardStatsCard(
          title: 'New merchants',
          value: '${controller.newMerchants}',
          change: controller.change('newMerchants'),
          icon: Icons.add_business_outlined,
          color: AdminColors.info,
        ),
      ],
    );
  }

  Widget _buildActivity() {
    final total = controller.totalMerchants;
    final selling = controller.sellingMerchants;

    return DashboardQuickStats(
      title: 'Roster',
      stats: [
        QuickStat(
          'Revenue through merchants',
          adminMoney(controller.totalRevenue),
          note: 'Across every merchant in this window',
        ),
        QuickStat(
          'Sold nothing',
          '${controller.idleMerchants}',
          tone: controller.idleMerchants > 0 ? AdminColors.warning : null,
          // The half of the roster no top-N ranking can show, and usually the
          // more actionable one.
          note: 'On the books but with no sale in this window',
        ),
        QuickStat(
          'Hidden from customers',
          '${controller.inactiveMerchants}',
          tone: controller.inactiveMerchants > 0 ? AdminColors.danger : null,
          note: 'Deactivated accounts',
        ),
        QuickStat(
          'Activation',
          total > 0 ? '${(selling / total * 100).toStringAsFixed(1)}%' : '—',
          note: 'Share of the roster that sold in this window',
        ),
        // Only shown when there is something to explain. Without it this
        // board's revenue is quietly smaller than the sales board's for the
        // same window, which reads as a bug in one of the two.
        if (controller.unattributedRevenue > 0)
          QuickStat(
            'Not through any merchant',
            adminMoney(controller.unattributedRevenue),
            tone: AdminColors.warning,
            note: '${controller.unattributedOrders} fulfilled order(s) carrying '
                'no merchant — the gap against the sales dashboard',
          ),
      ],
    );
  }

  Widget _buildCharts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardChart(
          title: 'Revenue by merchant',
          subtitle: 'The ten highest earners in this window',
          data: controller.revenueRanking,
          type: DashboardChartType.bar,
          color: AdminColors.primary,
          formatValue: adminMoney,
          emptyMessage: 'No merchant sold anything in this window.',
        ),
        DashboardChart(
          title: 'Merchants by category',
          subtitle: 'The whole roster, not just this window',
          data: controller.categories,
          type: DashboardChartType.pie,
          formatValue: (v) => '${v.toInt()}',
          height: 160.h,
        ),
        DashboardChart(
          title: 'New merchants',
          data: controller.growthChart,
          type: DashboardChartType.bar,
          color: AdminColors.success,
          formatValue: (v) => '${v.toInt()}',
        ),
      ],
    );
  }

  Widget _buildTable() {
    return DashboardTable(
      title: 'Merchant performance',
      subtitle: 'By revenue in this window',
      maxRows: 15,
      columns: [
        const DashboardColumn('Merchant', 'name', flex: 3),
        const DashboardColumn('Category', 'category', flex: 2),
        DashboardColumn('Orders', 'orders', numeric: true, format: dashboardCount),
        DashboardColumn('Revenue', 'revenue', numeric: true, format: dashboardMoney),
        // Unrated is printed as such: a merchant nobody has rated is not one
        // rated zero, and a 0.0 in this column would libel them.
        DashboardColumn('Rating', 'rating', numeric: true, format: dashboardRating),
      ],
      rows: controller.merchantPerformance,
      emptyMessage: 'No merchant took an order in this window.',
      onRowTap: (row) {
        final id = adminString(row['merchantId']);
        if (id.isNotEmpty) Get.toNamed(AdminRoutes.merchantDetails(id));
      },
    );
  }
}
