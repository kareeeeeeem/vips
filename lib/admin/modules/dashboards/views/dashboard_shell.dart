import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../../auth/controllers/admin_auth_controller.dart';
import '../controllers/dashboard_base_controller.dart';
import '../widgets/dashboard_filter.dart';

/// The chrome every analytical dashboard wears.
///
/// Title bar, the switcher between the five boards, the window filter, the
/// export action and the loading / error / not-permitted states are identical
/// across all of them; only the body differs. Keeping this in one place is
/// what stops board four from being the one that forgets to show its error.
class DashboardShell extends StatelessWidget {
  final String title;
  final String route;
  final DashboardBaseController controller;

  /// Built only once there is data to build it from.
  final Widget Function() body;

  const DashboardShell({
    super.key,
    required this.title,
    required this.route,
    required this.controller,
    required this.body,
  });

  /// The five boards, in the order they appear everywhere in the console.
  static const List<DashboardTab> tabs = [
    DashboardTab(AdminRoutes.DASH_SALES, 'Sales', Icons.trending_up_rounded,
        'reports.read'),
    DashboardTab(AdminRoutes.DASH_OPERATIONS, 'Operations',
        Icons.local_shipping_outlined, 'dashboard.read'),
    DashboardTab(AdminRoutes.DASH_FINANCE, 'Finance',
        Icons.account_balance_wallet_outlined, 'reports.read'),
    DashboardTab(AdminRoutes.DASH_MARKETING, 'Marketing',
        Icons.campaign_outlined, 'reports.read'),
    DashboardTab(AdminRoutes.DASH_MERCHANTS, 'Merchants',
        Icons.storefront_outlined, 'reports.read'),
  ];

  /// Tabs the signed-in operator can actually open. Presentation only — the
  /// server refuses the rest regardless — but offering a tab that answers 403
  /// is worse than not offering it.
  static List<DashboardTab> visibleTabs() {
    if (!Get.isRegistered<AdminAuthController>()) return tabs;
    final auth = Get.find<AdminAuthController>();
    // Until /admin/me has answered, nothing is known about this caller — and
    // "unknown" must not be read as "denied", or a browser refresh on a board
    // would strip the switcher down to nothing until the profile arrived.
    if (!auth.isIdentityLoaded.value) return tabs;
    return tabs.where((t) => auth.can(t.permission)).toList();
  }

  /// Whether this operator may download a dashboard.
  ///
  /// Unknown counts as allowed: the server refuses it either way, and hiding
  /// the control before /admin/me has answered would look like a missing
  /// feature rather than a permission.
  bool get _canExport {
    if (!Get.isRegistered<AdminAuthController>()) return true;
    final auth = Get.find<AdminAuthController>();
    if (!auth.isIdentityLoaded.value) return true;
    return auth.can('reports.export');
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: title,
      route: route,
      onRefresh: controller.refreshData,
      actions: [
        Obx(() {
          // Taking the data out of the system is its own grant, so an operator
          // without it gets a disabled control that says why — not a live
          // button that answers 403 after the tap.
          final allowed = _canExport;
          final enabled =
              allowed && controller.hasData && !controller.isExporting.value;
          return IconButton(
            tooltip: !allowed
                ? 'Exporting needs the reports.export permission'
                : controller.isExporting.value
                    ? 'Building the file…'
                    : 'Export CSV',
            onPressed: enabled ? () => _export(context) : null,
            icon: Icon(Icons.download_rounded,
                size: 20.sp,
                color: enabled ? AdminColors.textSecondary : AdminColors.border),
          );
        }),
      ],
      body: Column(
        children: [
          Obx(() {
            final visible = visibleTabs();
            // With one board available the strip is just a label for the page
            // you are already on.
            if (visible.length < 2) return const SizedBox.shrink();
            return DashboardSwitcher(
              currentRoute: route,
              tabs: visible,
              onSelected: Get.offNamed,
            );
          }),
          Obx(() => DashboardFilter(
                selected: controller.period.value,
                customRange: controller.customRange.value,
                isLoading: controller.isLoading.value,
                appliedLabel:
                    controller.hasData ? controller.appliedWindowLabel : null,
                onFilterChanged: controller.setFilter,
              )),
          Expanded(child: Obx(_buildBody)),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (controller.isForbidden.value) {
      return AdminEmptyState(
        icon: Icons.lock_outline_rounded,
        title: 'Not available to your role',
        message: controller.errorMessage.value.isNotEmpty
            ? controller.errorMessage.value
            : 'This dashboard needs the ${controller.permission} permission.',
      );
    }

    if (controller.isLoading.value && !controller.hasData) {
      return const AdminLoading();
    }

    if (controller.errorMessage.isNotEmpty && !controller.hasData) {
      return AdminErrorState(
        message: controller.errorMessage.value,
        onRetry: controller.refreshData,
      );
    }

    if (!controller.hasData) {
      return const AdminEmptyState(
        icon: Icons.insights_outlined,
        title: 'No data yet',
        message: 'Nothing has been recorded for this window.',
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // A refresh that failed leaves the previous figures up, so it has to
          // say so — silently stale numbers are the worse failure.
          if (controller.errorMessage.isNotEmpty) _buildStaleBanner(),
          body(),
          SizedBox(height: 10.h),
          Center(
            child: Text(
              controller.lastUpdatedLabel,
              style: TextStyle(fontSize: 10.5.sp, color: AdminColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaleBanner() {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AdminColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AdminColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 16.sp, color: AdminColors.warning),
          SizedBox(width: 9.w),
          Expanded(
            child: Text(
              'Showing the last figures that loaded. ${controller.errorMessage.value}',
              style: TextStyle(
                fontSize: 11.5.sp,
                height: 1.35,
                color: AdminColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: controller.refreshData,
            child: Text('Retry',
                style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context) async {
    final csv = await controller.exportCsv();
    if (csv == null) return;
    // A browser download needs a user gesture this side cannot fake, so the
    // file is shown for copying rather than behind a button that silently
    // does nothing — the same choice the reports screen makes.
    adminSheet(
      title: controller.exportFilename,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'The table from this dashboard as CSV, over the window shown on '
            "screen. Copy it into a spreadsheet, or use the browser's print "
            'view for a PDF.',
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
}

// ── Formatting shared by the five boards ────────────────────

String dashboardPercent(dynamic value) =>
    value is num ? '${value.toStringAsFixed(1)}%' : '—';

String dashboardMoney(dynamic value) =>
    value is num ? adminMoney(value) : '—';

String dashboardCount(dynamic value) =>
    value is num ? adminInt(value).toString() : '—';

/// A rating, or an explicit dash. A merchant nobody has rated is not a
/// merchant rated zero, so the two must not print the same character.
String dashboardRating(dynamic value) =>
    value is num && value > 0 ? '${value.toStringAsFixed(1)} ★' : 'Unrated';
