import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../auth/controllers/admin_auth_controller.dart';
import '../controllers/reports_controller.dart';

/// Every report as a file, over one shared date range.
///
/// The reports screen exports whichever report is on it; this exports any of
/// them without opening it first, which is what somebody collecting a set of
/// figures for a month actually wants.
class ReportsExportView extends GetView<AdminReportsController> {
  const ReportsExportView({super.key});

  bool get _canExport {
    if (!Get.isRegistered<AdminAuthController>()) return true;
    final auth = Get.find<AdminAuthController>();
    if (!auth.isIdentityLoaded.value) return true;
    return auth.can('reports.export');
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Export reports',
      route: AdminRoutes.REPORTS_EXPORT,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 28.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildRangeCard(context),
            SizedBox(height: 12.h),
            Obx(() => _canExport
                ? const SizedBox.shrink()
                : _buildNotAllowed()),
            Obx(() => AdminCard(
                  title: 'Choose a report',
                  subtitle: 'Each downloads as CSV over the range above',
                  child: Column(
                    children: [
                      for (final type in AdminReportsController.reports)
                        _buildRow(type),
                    ],
                  ),
                )),
            SizedBox(height: 12.h),
            _buildFormatNote(),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeCard(BuildContext context) {
    return Obx(() {
      final range = controller.dateRange.value;
      return AdminCard(
        title: 'Date range',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => _pickRange(context),
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AdminColors.background,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AdminColors.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 15.sp, color: AdminColors.primary),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        range == null
                            ? 'Last 30 days'
                            : '${adminDateLabel(range.start)} – '
                                '${adminDateLabel(range.end)}',
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w600,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(Icons.edit_calendar_outlined,
                        size: 16.sp, color: AdminColors.textMuted),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              // The merchants report is lifetime, so a range on this screen
              // would otherwise look as though it applied to all seven.
              'The merchants report covers all time and ignores this range.',
              style: TextStyle(fontSize: 10.5.sp, color: AdminColors.textMuted),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNotAllowed() {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: AdminColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AdminColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline_rounded, size: 16.sp, color: AdminColors.warning),
          SizedBox(width: 9.w),
          Expanded(
            child: Text(
              'Downloading a report is its own permission (reports.export). '
              'Your role can read these reports but not take them out of the '
              'system as a file.',
              style: TextStyle(
                fontSize: 11.5.sp,
                height: 1.35,
                color: AdminColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String type) {
    final allowed = _canExport;
    final busy = controller.isExporting.value;

    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.r),
        onTap: (allowed && !busy) ? () => _export(type) : null,
        child: Opacity(
          opacity: allowed ? 1 : 0.5,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 11.h, horizontal: 4.w),
            child: Row(
              children: [
                Icon(Icons.description_outlined,
                    size: 19.sp, color: AdminColors.primary),
                SizedBox(width: 13.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        adminLabel(type),
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w600,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _describe(type),
                        style: TextStyle(
                            fontSize: 10.5.sp, color: AdminColors.textMuted),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                TextButton(
                  onPressed: (allowed && !busy) ? () => _export(type) : null,
                  child: Text('Open', style: TextStyle(fontSize: 11.5.sp)),
                ),
                Icon(Icons.download_rounded,
                    size: 17.sp,
                    color: allowed ? AdminColors.textSecondary : AdminColors.border),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// What each file actually contains — a filename alone does not say whether
  /// "products" means the ranking or the whole catalogue.
  String _describe(String type) => switch (type) {
        'sales' => 'Revenue and orders per period',
        'profit' => 'Revenue, cost and gross profit per period',
        'products' => 'Best sellers by revenue',
        'customers' => 'Top spenders with lifetime totals',
        'orders' => 'Order counts and value by status',
        'merchants' => 'Merchant performance — all time',
        'commission' => 'Platform cut per merchant',
        _ => '',
      };

  Widget _buildFormatNote() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: AdminColors.info.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AdminColors.info.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 15.sp, color: AdminColors.info),
          SizedBox(width: 9.w),
          Expanded(
            child: Text(
              // Said rather than discovered: there is no PDF, and a CSV named
              // .pdf would be worse than saying so.
              'CSV only. The file carries a byte-order mark so Excel opens '
              "Arabic names correctly. For a PDF, use the browser's print view "
              'on the report itself.',
              style: TextStyle(
                fontSize: 11.sp,
                height: 1.4,
                color: AdminColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
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

  Future<void> _export(String type) async {
    final csv = await controller.exportReportOfType(type);
    if (csv == null) return;
    // Shown for copying rather than downloaded: a browser download needs a
    // user gesture this side cannot fake, and a button that silently does
    // nothing is worse than one that hands over the text.
    adminSheet(
      title: controller.exportFilenameFor(type),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Copy this into a spreadsheet.',
            style: TextStyle(fontSize: 12.sp, color: AdminColors.textSecondary),
          ),
          SizedBox(height: 12.h),
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
