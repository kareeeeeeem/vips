import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../theme/admin_theme.dart';

// ── Formatting ──────────────────────────────────────────────

final NumberFormat _moneyFormat = NumberFormat('#,##0.000', 'en_US');
final NumberFormat _countFormat = NumberFormat('#,##0', 'en_US');

/// Tunisian dinar, 3 decimals — the currency the whole platform prices in.
/// (An earlier merchant-side audit found six screens printing "$" in a
/// dinar app; the console formats money in exactly one place instead.)
String adminMoney(num value) => 'D ${_moneyFormat.format(value)}';

String adminCount(num value) => _countFormat.format(value);

String adminDateLabel(DateTime? date) {
  if (date == null) return '—';
  return DateFormat('d MMM yyyy').format(date.toLocal());
}

String adminDateTimeLabel(DateTime? date) {
  if (date == null) return '—';
  return DateFormat('d MMM yyyy, HH:mm').format(date.toLocal());
}

/// "3 days ago" for the activity feed.
String adminRelative(DateTime? date) {
  if (date == null) return '—';
  final diff = DateTime.now().difference(date.toLocal());
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 30) return '${diff.inDays}d ago';
  return adminDateLabel(date);
}

// ── Building blocks ─────────────────────────────────────────

/// A metric tile for the dashboard grid.
class AdminStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? sublabel;
  final VoidCallback? onTap;

  const AdminStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.sublabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AdminColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AdminColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, size: 18.sp, color: color),
                ),
                const Spacer(),
                if (onTap != null)
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 12.sp, color: AdminColors.textMuted),
              ],
            ),
            SizedBox(height: 12.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: AdminColors.textPrimary,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: AdminColors.textSecondary),
            ),
            if (sublabel != null) ...[
              SizedBox(height: 6.h),
              Text(
                sublabel!,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AdminColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A coloured status pill (order status, approval status, active/banned).
class AdminStatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final bool compact;

  const AdminStatusPill({
    super.key,
    required this.label,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6.w : 10.w,
        vertical: compact ? 2.h : 4.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: compact ? 10.sp : 11.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// The white rounded panel every list and report section sits in.
class AdminCard extends StatelessWidget {
  final String? title;

  /// A qualifier under the title — what the card is counted over, or what it
  /// is not showing. Where a caveat goes so it cannot be missed.
  final String? subtitle;

  final Widget child;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const AdminCard({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    title!,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            if (subtitle != null) ...[
              SizedBox(height: 3.h),
              Text(
                subtitle!,
                style: TextStyle(fontSize: 11.5.sp, color: AdminColors.textMuted),
              ),
            ],
            SizedBox(height: 14.h),
          ],
          child,
        ],
      ),
    );
  }
}

/// Debounced search field used by every list screen.
class AdminSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const AdminSearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(fontSize: 14.sp, color: AdminColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14.sp, color: AdminColors.textMuted),
        prefixIcon: Icon(Icons.search, size: 20.sp, color: AdminColors.textMuted),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: Icon(Icons.close, size: 18.sp, color: AdminColors.textMuted),
                onPressed: onClear,
              ),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        filled: true,
        fillColor: AdminColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AdminColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AdminColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AdminColors.primary),
        ),
      ),
    );
  }
}

/// A horizontally scrolling row of filter chips.
class AdminFilterChips extends StatelessWidget {
  final List<AdminFilterOption> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const AdminFilterChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final option = options[index];
          final isActive = option.value == selected;
          return GestureDetector(
            onTap: () => onSelected(option.value),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? AdminColors.primary : AdminColors.surface,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isActive ? AdminColors.primary : AdminColors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    option.label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : AdminColors.textSecondary,
                    ),
                  ),
                  if (option.count != null) ...[
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.white.withValues(alpha: 0.25)
                            : AdminColors.divider,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        '${option.count}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: isActive ? Colors.white : AdminColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AdminFilterOption {
  final String value;
  final String label;
  final int? count;

  const AdminFilterOption(this.value, this.label, {this.count});
}

/// Prev/next pager shown under every paginated list.
class AdminPaginator extends StatelessWidget {
  final int page;
  final int pages;
  final int total;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const AdminPaginator({
    super.key,
    required this.page,
    required this.pages,
    required this.total,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    if (pages <= 1) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Center(
          child: Text(
            '${adminCount(total)} result${total == 1 ? '' : 's'}',
            style: TextStyle(fontSize: 12.sp, color: AdminColors.textMuted),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: page > 1 ? onPrevious : null,
            icon: const Icon(Icons.chevron_left),
            color: AdminColors.primary,
            disabledColor: AdminColors.textMuted.withValues(alpha: 0.4),
          ),
          Text(
            'Page $page of $pages  ·  ${adminCount(total)} total',
            style: TextStyle(fontSize: 12.sp, color: AdminColors.textSecondary),
          ),
          IconButton(
            onPressed: page < pages ? onNext : null,
            icon: const Icon(Icons.chevron_right),
            color: AdminColors.primary,
            disabledColor: AdminColors.textMuted.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

/// Empty state. [message] explains *why* it is empty — a filter that matched
/// nothing reads differently from a collection with no rows at all.
class AdminEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const AdminEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 40.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48.sp, color: AdminColors.border),
            SizedBox(height: 16.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AdminColors.textSecondary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp, color: AdminColors.textMuted),
            ),
            if (action != null) ...[SizedBox(height: 16.h), action!],
          ],
        ),
      ),
    );
  }
}

/// Error state with a retry, for when a load fails outright.
class AdminErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const AdminErrorState({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AdminEmptyState(
      icon: Icons.cloud_off_rounded,
      title: 'Could not load this',
      message: message,
      action: OutlinedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh, size: 16),
        label: const Text('Retry'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AdminColors.primary,
          side: const BorderSide(color: AdminColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
      ),
    );
  }
}

/// Label/value row used in every detail sheet.
class AdminDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? valueWidget;
  final Color? valueColor;

  const AdminDetailRow({
    super.key,
    required this.label,
    this.value = '',
    this.valueWidget,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: AdminColors.textSecondary),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: valueWidget ??
                Text(
                  value.isEmpty ? '—' : value,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AdminColors.textPrimary,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

/// A simple horizontal bar row for report breakdowns — enough to read a
/// distribution at a glance without pulling in a charting dependency.
class AdminBarRow extends StatelessWidget {
  final String label;
  final String value;
  final double fraction;
  final Color color;

  const AdminBarRow({
    super.key,
    required this.label,
    required this.value,
    required this.fraction,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AdminColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              // A NaN or infinite fraction (an all-zero denominator) throws
              // inside the render pass, so clamp before it reaches the widget.
              value: fraction.isFinite ? fraction.clamp(0.0, 1.0) : 0.0,
              minHeight: 6.h,
              backgroundColor: AdminColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sparkline-style bar chart for the dashboard's daily series.
/// Drawn with plain widgets so the console adds no chart dependency.
class AdminMiniBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final Color color;
  final String Function(double) formatValue;

  const AdminMiniBarChart({
    super.key,
    required this.values,
    required this.labels,
    required this.color,
    required this.formatValue,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return SizedBox(
        height: 120.h,
        child: Center(
          child: Text(
            'No data in this period',
            style: TextStyle(fontSize: 12.sp, color: AdminColors.textMuted),
          ),
        ),
      );
    }

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    // An all-zero series would divide by zero and paint NaN-height bars.
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Peak ${formatValue(maxValue)}',
          style: TextStyle(fontSize: 11.sp, color: AdminColors.textMuted),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 110.h,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(values.length, (i) {
              final ratio = values[i] / safeMax;
              return Expanded(
                child: Tooltip(
                  message: '${labels.length > i ? labels[i] : ''}\n'
                      '${formatValue(values[i])}',
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 1.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: (6 + ratio * 96).h,
                          decoration: BoxDecoration(
                            color: values[i] == 0
                                ? AdminColors.divider
                                : color.withValues(alpha: 0.35 + ratio * 0.65),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(3.r),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(labels.isNotEmpty ? labels.first : '',
                style: TextStyle(fontSize: 10.sp, color: AdminColors.textMuted)),
            Text(labels.isNotEmpty ? labels.last : '',
                style: TextStyle(fontSize: 10.sp, color: AdminColors.textMuted)),
          ],
        ),
      ],
    );
  }
}

/// The console's primary button.
class AdminButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? color;
  final bool expand;

  const AdminButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.color,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expand ? double.infinity : null,
      height: 48.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AdminColors.primary,
          disabledBackgroundColor: AdminColors.border,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
        child: isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18.sp, color: Colors.white),
                    SizedBox(width: 8.w),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
