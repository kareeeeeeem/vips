import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/marketing_dashboard_controller.dart';
import '../models/dashboard_models.dart';
import '../widgets/dashboard_chart.dart';
import '../widgets/dashboard_quick_stats.dart';
import '../widgets/dashboard_stats_card.dart';
import '../widgets/dashboard_table.dart';
import 'dashboard_shell.dart';

/// Who signed up, who bought, and who stopped.
class MarketingDashboardView extends GetView<MarketingDashboardController> {
  const MarketingDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'Marketing',
      route: AdminRoutes.DASH_MARKETING,
      controller: controller,
      body: () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCards(),
          SizedBox(height: 12.h),
          _buildEngagement(),
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
          title: 'Total customers',
          value: '${controller.totalCustomers}',
          note: '${controller.verifiedCustomers} verified',
          icon: Icons.people_alt_outlined,
          color: AdminColors.primary,
          onTap: () => Get.toNamed(AdminRoutes.USERS),
        ),
        DashboardStatsCard(
          title: 'New customers',
          value: '${controller.newCustomers}',
          change: controller.change('newCustomers'),
          icon: Icons.person_add_alt_1_outlined,
          color: AdminColors.success,
        ),
        DashboardStatsCard(
          title: 'Active customers',
          value: '${controller.activeCustomers}',
          change: controller.change('activeCustomers'),
          note: 'Bought in this window',
          icon: Icons.shopping_bag_outlined,
          color: AdminColors.info,
        ),
        DashboardStatsCard(
          title: 'Churn rate',
          // Null when nobody bought in the baseline window: there is no churn
          // out of an empty cohort, and 0% would read as perfect retention.
          value: controller.hasChurnBaseline
              ? '${controller.churnRate.toStringAsFixed(1)}%'
              : '—',
          isUnavailable: !controller.hasChurnBaseline,
          higherIsBetter: false,
          note: controller.hasChurnBaseline
              ? '${controller.churnedCustomers} of ${controller.churnBaseline} '
                  'previous buyers did not return'
              : 'Nobody bought in the previous period, so there is no cohort '
                  'to measure against',
          icon: Icons.person_off_outlined,
          color: AdminColors.danger,
        ),
      ],
    );
  }

  Widget _buildEngagement() {
    return DashboardQuickStats(
      title: 'Engagement',
      stats: [
        QuickStat(
          'Orders per buyer',
          controller.ordersPerCustomer.toStringAsFixed(2),
          note: 'Across their whole history, not just this window',
        ),
        QuickStat(
          'Repeat rate',
          '${controller.repeatRate.toStringAsFixed(1)}%',
          note: '${controller.repeatBuyers} of ${controller.buyers} buyers '
              'ordered more than once',
        ),
        QuickStat(
          'Lifetime value',
          adminMoney(controller.lifetimeValue),
          note: 'Average spend per customer who has ever bought',
        ),
        QuickStat(
          'Buyer rate',
          '${controller.buyerRate.toStringAsFixed(1)}%',
          // The platform tracks no visits, so this is the only conversion
          // figure it can honestly compute.
          note: 'Registered customers who have ever bought — the platform '
              'records no visits to convert from',
        ),
      ],
    );
  }

  Widget _buildCharts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardChart(
          title: 'New customers',
          data: controller.growthChart,
          type: DashboardChartType.bar,
          color: AdminColors.success,
          formatValue: (v) => '${v.toInt()}',
        ),
        DashboardChart(
          title: 'Customer segments',
          subtitle: controller.churnDefinition.isNotEmpty
              ? 'Every customer sits in exactly one segment'
              : null,
          data: controller.segments,
          type: DashboardChartType.pie,
          formatValue: (v) => '${v.toInt()}',
          height: 160.h,
        ),
      ],
    );
  }

  Widget _buildTable() {
    return DashboardTable(
      title: 'Top customers',
      subtitle: 'By spend in this window',
      columns: [
        const DashboardColumn('Customer', 'name', flex: 2),
        const DashboardColumn('Email', 'email', flex: 3),
        DashboardColumn('Orders', 'orders', numeric: true, format: dashboardCount),
        DashboardColumn('Spend', 'spent', numeric: true, format: dashboardMoney),
      ],
      rows: controller.topCustomers,
      emptyMessage: 'No customer bought anything in this window.',
      onRowTap: (row) {
        final id = adminString(row['userId']);
        if (id.isNotEmpty) Get.toNamed(AdminRoutes.userDetails(id));
      },
    );
  }
}
