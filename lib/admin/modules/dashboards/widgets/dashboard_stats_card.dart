import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/admin_theme.dart';

/// A headline figure with its movement against the previous period.
///
/// [change] is a percentage against the equivalent window immediately before
/// this one. It is nullable on purpose: when the baseline window had nothing
/// to compare against, the card says "no baseline" rather than showing a
/// green "+100%" invented out of a first-ever sale.
class DashboardStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final double? change;

  /// Whether a rise is good news. False for fulfilment time and cancellations,
  /// where a bigger number is the worse outcome and must not be green.
  final bool higherIsBetter;

  /// True when the platform genuinely has no value here, as opposed to zero.
  /// Renders the [note] in place of the figure instead of printing "0".
  final bool isUnavailable;

  final String? note;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const DashboardStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.change,
    this.higherIsBetter = true,
    this.isUnavailable = false,
    this.note,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AdminColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AdminColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(7.w),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                  child: Icon(icon, size: 15.sp, color: color),
                ),
                SizedBox(width: 9.w),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AdminColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 11.h),
            Text(
              isUnavailable ? 'Not tracked' : value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isUnavailable ? 15.sp : 19.sp,
                fontWeight: FontWeight.w800,
                color: isUnavailable
                    ? AdminColors.textMuted
                    : AdminColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    if (note != null && (isUnavailable || change == null)) {
      return Text(
        note!,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 10.sp, height: 1.35, color: AdminColors.textMuted),
      );
    }

    if (change == null) {
      // Stated, not hidden: an empty space where a trend belongs reads as a
      // rendering bug, and a "0%" would claim the figure held steady.
      return Text(
        'No baseline to compare with',
        style: TextStyle(fontSize: 10.sp, color: AdminColors.textMuted),
      );
    }

    final rising = change! >= 0;
    final good = rising == higherIsBetter;
    final tone = change == 0
        ? AdminColors.textSecondary
        : (good ? AdminColors.success : AdminColors.danger);

    return Row(
      children: [
        Icon(
          change == 0
              ? Icons.remove_rounded
              : (rising ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded),
          size: 12.sp,
          color: tone,
        ),
        SizedBox(width: 3.w),
        Text(
          '${rising && change != 0 ? '+' : ''}${change!.toStringAsFixed(1)}%',
          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: tone),
        ),
        SizedBox(width: 5.w),
        Expanded(
          child: Text(
            note ?? 'vs previous period',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10.sp, color: AdminColors.textMuted),
          ),
        ),
      ],
    );
  }
}

/// Lays stats cards out in a grid that fits the width it is given.
///
/// The console runs on a phone and on a desktop browser from the same build,
/// so the column count is measured rather than assumed — four fixed columns
/// squeeze a headline figure into an ellipsis on a phone.
class DashboardStatsGrid extends StatelessWidget {
  final List<Widget> cards;

  const DashboardStatsGrid({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1000
            ? 4
            : width >= 700
                ? 3
                : 2;
        final gap = 10.w;
        final cardWidth = (width - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: 10.h,
          children: [
            for (final card in cards) SizedBox(width: cardWidth, child: card),
          ],
        );
      },
    );
  }
}
