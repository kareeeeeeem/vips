import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../models/dashboard_models.dart';

/// The time-window control shared by all five dashboards.
///
/// Driven by the controller's state rather than holding its own: a chip that
/// tracked its own selection would keep showing "Week" after a failed reload
/// left the data on screen from the previous window.
class DashboardFilter extends StatelessWidget {
  final DashboardPeriod selected;
  final DateTimeRange? customRange;

  /// Fires with the chosen preset, and the range when that preset is
  /// [DashboardPeriod.custom].
  final void Function(DashboardPeriod period, DateTimeRange? range) onFilterChanged;

  /// The window the server actually applied, echoed back from the response.
  /// Shown so the operator reads the real window rather than the requested
  /// one — the two differ whenever a bad custom range falls back.
  final String? appliedLabel;

  final bool isLoading;

  const DashboardFilter({
    super.key,
    required this.selected,
    required this.onFilterChanged,
    this.customRange,
    this.appliedLabel,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AdminColors.background,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminFilterChips(
            options: [
              for (final period in DashboardPeriod.values)
                AdminFilterOption(period.key, period.chipLabel),
            ],
            selected: selected.key,
            onSelected: (key) {
              final period = DashboardPeriodX.fromKey(key);
              if (period == DashboardPeriod.custom) {
                _pickRange(context);
                return;
              }
              onFilterChanged(period, null);
            },
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 13.sp, color: AdminColors.textMuted),
              SizedBox(width: 7.w),
              Expanded(
                child: Text(
                  appliedLabel ?? selected.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.textSecondary,
                  ),
                ),
              ),
              if (isLoading)
                SizedBox(
                  width: 12.w,
                  height: 12.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 1.8,
                    valueColor: AlwaysStoppedAnimation<Color>(AdminColors.primary),
                  ),
                )
              else
                InkWell(
                  onTap: () => _pickRange(context),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: Text(
                      'Pick dates',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AdminColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
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
      initialDateRange: customRange,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              Theme.of(context).colorScheme.copyWith(primary: AdminColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) onFilterChanged(DashboardPeriod.custom, picked);
  }
}

/// The strip that moves between the five dashboards.
///
/// Every dashboard carries it, so an operator comparing sales against finance
/// does not have to go back out through the drawer each time.
class DashboardSwitcher extends StatelessWidget {
  final String currentRoute;
  final List<DashboardTab> tabs;
  final void Function(String route) onSelected;

  const DashboardSwitcher({
    super.key,
    required this.currentRoute,
    required this.tabs,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AdminColors.surface,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Row(
          children: [
            for (final tab in tabs) ...[
              _buildTab(tab, tab.route == currentRoute),
              SizedBox(width: 6.w),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTab(DashboardTab tab, bool active) {
    return InkWell(
      borderRadius: BorderRadius.circular(20.r),
      onTap: active ? null : () => onSelected(tab.route),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: active ? AdminColors.primary : AdminColors.background,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: active ? AdminColors.primary : AdminColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tab.icon,
                size: 14.sp, color: active ? Colors.white : AdminColors.textSecondary),
            SizedBox(width: 6.w),
            Text(
              tab.label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                color: active ? Colors.white : AdminColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardTab {
  final String route;
  final String label;
  final IconData icon;

  /// The permission the backend requires for this dashboard. Tabs the caller
  /// cannot open are left out rather than shown and then refused.
  final String permission;

  const DashboardTab(this.route, this.label, this.icon, this.permission);
}
