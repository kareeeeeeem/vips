import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../controllers/finance_dashboard_controller.dart';
import '../models/dashboard_models.dart';
import '../widgets/dashboard_chart.dart';
import '../widgets/dashboard_quick_stats.dart';
import '../widgets/dashboard_stats_card.dart';
import '../widgets/dashboard_table.dart';
import 'dashboard_shell.dart';

/// Revenue against cost, the platform's cut, and money owed out.
class FinanceDashboardView extends GetView<FinanceDashboardController> {
  const FinanceDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'Finance',
      route: AdminRoutes.DASH_FINANCE,
      controller: controller,
      body: () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCards(),
          SizedBox(height: 12.h),
          _buildCaveats(),
          _buildCharts(),
          _buildTables(),
        ],
      ),
    );
  }

  Widget _buildCards() {
    final coverage = controller.costCoverage;

    return DashboardStatsGrid(
      cards: [
        DashboardStatsCard(
          title: 'Revenue',
          value: adminMoney(controller.totalRevenue),
          change: controller.change('totalRevenue'),
          icon: Icons.payments_outlined,
          color: AdminColors.success,
        ),
        DashboardStatsCard(
          title: 'Gross profit',
          value: adminMoney(controller.totalProfit),
          change: controller.change('totalProfit'),
          // The caveat travels with the figure rather than sitting further
          // down the page, because this is the number that gets screenshotted.
          note: 'Over ${coverage.toStringAsFixed(1)}% of revenue with a known cost',
          icon: Icons.trending_up_rounded,
          color: AdminColors.primary,
        ),
        DashboardStatsCard(
          title: 'Commission earned',
          value: adminMoney(controller.totalCommissions),
          note: controller.merchantsOnZeroRate > 0
              ? '${controller.merchantsOnZeroRate} selling merchant(s) still on 0%'
              : 'From each merchant\'s own rate',
          icon: Icons.percent_rounded,
          color: AdminColors.accent,
        ),
        DashboardStatsCard(
          title: 'Pending payouts',
          value: adminMoney(controller.pendingPayouts),
          note: '${controller.pendingPayoutCount} request(s) awaiting a decision',
          icon: Icons.account_balance_wallet_outlined,
          color: AdminColors.warning,
        ),
      ],
    );
  }

  /// What the figures above can and cannot be read to mean.
  ///
  /// `Product.costPrice` defaults to 0 meaning "not recorded", so a margin
  /// taken over all revenue would show 100% on every legacy sale. The margin
  /// is computed only over the revenue with a real cost behind it, and the
  /// share that covers is stated next to it.
  Widget _buildCaveats() {
    final coverage = controller.costCoverage;
    final thin = coverage < 50;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardQuickStats(
          title: 'How to read the margin',
          stats: [
            QuickStat(
              'Margin',
              '${controller.margin.toStringAsFixed(1)}%',
              tone: thin ? AdminColors.warning : null,
              note: 'Taken over costed revenue only',
            ),
            QuickStat(
              'Cost coverage',
              '${coverage.toStringAsFixed(1)}%',
              tone: thin ? AdminColors.warning : AdminColors.success,
              note: 'Share of revenue whose product has a cost recorded',
            ),
            QuickStat(
              'Costed revenue',
              adminMoney(controller.costedRevenue),
              note: 'The slice the margin above describes',
            ),
            QuickStat(
              'Paid out this period',
              adminMoney(controller.paidPayouts),
              note: 'Payout requests marked paid',
            ),
          ],
        ),
        if (thin) _buildCoverageWarning(coverage),
      ],
    );
  }

  Widget _buildCoverageWarning(double coverage) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: AdminColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AdminColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 16.sp, color: AdminColors.warning),
          SizedBox(width: 9.w),
          Expanded(
            child: Text(
              'Only ${coverage.toStringAsFixed(1)}% of revenue comes from products '
              'with a cost price recorded, so the profit and margin above '
              'describe that slice, not the whole business. Set cost prices on '
              'the remaining products to make these figures complete.',
              style: TextStyle(
                fontSize: 11.5.sp,
                height: 1.4,
                color: AdminColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardChart(
          title: 'Revenue',
          data: controller.revenueChart,
          type: DashboardChartType.line,
          color: AdminColors.success,
          formatValue: adminMoney,
        ),
        DashboardChart(
          title: 'Gross profit',
          subtitle: 'Costed revenue less cost of goods',
          data: controller.profitChart,
          type: DashboardChartType.bar,
          color: AdminColors.primary,
          formatValue: adminMoney,
        ),
        DashboardChart(
          title: 'Commission by category',
          data: controller.commissionByCategory,
          type: DashboardChartType.pie,
          formatValue: adminMoney,
          height: 160.h,
          emptyMessage: 'No commission earned in this window.',
        ),
      ],
    );
  }

  Widget _buildTables() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardTable(
          title: 'Commission breakdown',
          subtitle: 'By merchant category',
          columns: [
            const DashboardColumn('Category', 'category', flex: 2),
            DashboardColumn('Merchants', 'merchants',
                numeric: true, format: dashboardCount),
            DashboardColumn('Revenue', 'revenue', numeric: true, format: dashboardMoney),
            DashboardColumn('Commission', 'amount',
                numeric: true, format: dashboardMoney),
          ],
          rows: controller.commissionBreakdown,
          emptyMessage: 'No merchant sold anything in this window.',
        ),
        DashboardTable(
          title: 'Recent payout requests',
          // Lifetime, not windowed: an operator opening this board wants the
          // requests still waiting on them, whenever they were made.
          subtitle: 'Latest first, regardless of the window above',
          columns: [
            const DashboardColumn('Merchant', 'merchantName', flex: 3),
            const DashboardColumn('Status', 'status'),
            DashboardColumn('Amount', 'amount', numeric: true, format: dashboardMoney),
          ],
          rows: controller.recentPayouts,
          emptyMessage: 'No merchant has requested a payout.',
        ),
      ],
    );
  }
}
