import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../dashboards/models/dashboard_models.dart';
import '../../dashboards/widgets/dashboard_chart.dart';
import '../../dashboards/widgets/dashboard_quick_stats.dart';
import '../../dashboards/widgets/dashboard_stats_card.dart';
import '../../dashboards/widgets/dashboard_table.dart';
import '../../dashboards/views/dashboard_shell.dart';
import '../controllers/analytics_controller.dart';

/// Who is looking, and how much of that turns into orders.
class AnalyticsView extends GetView<AnalyticsController> {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Analytics',
      route: AdminRoutes.ANALYTICS,
      onRefresh: controller.load,
      body: Column(
        children: [
          _buildWindowFilter(),
          Expanded(child: Obx(_buildBody)),
        ],
      ),
    );
  }

  Widget _buildWindowFilter() {
    return Container(
      color: AdminColors.background,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      child: Obx(() => AdminFilterChips(
            options: [
              for (final d in AnalyticsController.windows)
                AdminFilterOption('$d', 'Last $d days'),
            ],
            selected: '${controller.days.value}',
            onSelected: (value) =>
                controller.setDays(int.tryParse(value) ?? 30),
          )),
    );
  }

  Widget _buildBody() {
    if (controller.isLoading.value && !controller.hasData) {
      return const AdminLoading();
    }
    if (controller.errorMessage.isNotEmpty && !controller.hasData) {
      return AdminErrorState(
        message: controller.errorMessage.value,
        onRetry: controller.load,
      );
    }
    if (!controller.hasData) {
      return const AdminEmptyState(
        icon: Icons.query_stats_outlined,
        title: 'No analytics yet',
        message: 'Nothing has been recorded.',
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTrackingNote(),
          _buildCards(),
          SizedBox(height: 12.h),
          _buildEngagement(),
          _buildCharts(),
          _buildScreensTable(),
        ],
      ),
    );
  }

  /// What a "visitor" means here, and what is not collected — stated once at
  /// the top rather than left for somebody to assume.
  Widget _buildTrackingNote() {
    final tracking = controller.isTracking;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: (tracking ? AdminColors.info : AdminColors.warning)
            .withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: (tracking ? AdminColors.info : AdminColors.warning)
              .withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            tracking ? Icons.privacy_tip_outlined : Icons.info_outline_rounded,
            size: 16.sp,
            color: tracking ? AdminColors.info : AdminColors.warning,
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: Text(
              controller.trackingNote,
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

  Widget _buildCards() {
    return DashboardStatsGrid(
      cards: [
        DashboardStatsCard(
          title: 'Visitors',
          value: '${controller.visitorsInWindow}',
          note: '${controller.totalVisitors} since tracking began',
          icon: Icons.groups_outlined,
          color: AdminColors.primary,
        ),
        DashboardStatsCard(
          title: 'Today',
          value: '${controller.visitorsToday}',
          note: '${controller.visitorsThisWeek} in the last 7 days',
          icon: Icons.today_outlined,
          color: AdminColors.info,
        ),
        DashboardStatsCard(
          title: 'Conversion rate',
          value: controller.conversionMeasurable
              ? '${controller.conversionRate.toStringAsFixed(1)}%'
              : '—',
          // Withheld rather than shown as a number above 100%: while tracking
          // is younger than the window, orders are being counted against only
          // part of the visits they came from.
          isUnavailable: !controller.conversionMeasurable,
          note: controller.conversionMeasurable
              ? '${controller.ordersInWindow} orders from '
                  '${controller.visitorsInWindow} visitors'
              : controller.conversionReason,
          icon: Icons.percent_rounded,
          color: AdminColors.success,
        ),
        DashboardStatsCard(
          title: 'Screen views',
          value: '${controller.screenViews}',
          note: '${controller.viewsPerSession.toStringAsFixed(1)} per visitor',
          icon: Icons.visibility_outlined,
          color: AdminColors.purple,
        ),
      ],
    );
  }

  Widget _buildEngagement() {
    final started = controller.trackingStartedAt;
    return DashboardQuickStats(
      title: 'Who is on the platform',
      stats: [
        QuickStat(
          'Signed-in sessions',
          '${controller.signedInSessions}',
          note: 'Visits where somebody was already signed in',
        ),
        QuickStat(
          'Customers who bought',
          '${controller.buyersInWindow}',
          note: controller.conversionMeasurable
              ? '${controller.buyerRate.toStringAsFixed(1)}% of visitors'
              : 'Share of visitors not yet measurable',
        ),
        QuickStat(
          'New customers',
          '${controller.newCustomers}',
          note: 'of ${controller.totalCustomers} registered',
        ),
        QuickStat(
          'Tracking since',
          started == null ? 'Not started' : adminDateLabel(started),
          // Naming the start date is what makes the conversion caveat above
          // checkable rather than something to take on trust.
          note: started == null
              ? 'No session has been recorded'
              : 'Figures before this date were never counted',
        ),
      ],
    );
  }

  Widget _buildCharts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DashboardChart(
          title: 'Visitors per day',
          subtitle: 'One visitor is one app session, not one screen view',
          data: controller.visitorsByDay,
          type: DashboardChartType.line,
          color: AdminColors.primary,
          formatValue: (v) => '${v.toInt()}',
          emptyMessage: 'No session has been recorded yet.',
        ),
        DashboardChart(
          title: 'Which app',
          data: controller.byApp,
          type: DashboardChartType.pie,
          formatValue: (v) => '${v.toInt()}',
          height: 150.h,
          emptyMessage: 'No session has been recorded yet.',
        ),
        DashboardChart(
          title: 'Which platform',
          data: controller.byPlatform,
          type: DashboardChartType.bar,
          color: AdminColors.info,
          formatValue: (v) => '${v.toInt()}',
          height: 140.h,
          emptyMessage: 'No session has been recorded yet.',
        ),
      ],
    );
  }

  Widget _buildScreensTable() {
    return DashboardTable(
      title: 'Most visited screens',
      // Sessions matters more than views: one person refreshing a screen ten
      // times is one person, and ranking on views alone would say otherwise.
      subtitle: 'Views, and how many separate visitors made them',
      columns: [
        const DashboardColumn('Screen', 'screen', flex: 3),
        DashboardColumn('Views', 'views', numeric: true, format: dashboardCount),
        DashboardColumn('Visitors', 'sessions',
            numeric: true, format: dashboardCount),
      ],
      rows: controller.topScreens,
      maxRows: 15,
      emptyMessage: 'No screen has been recorded yet.',
    );
  }
}
