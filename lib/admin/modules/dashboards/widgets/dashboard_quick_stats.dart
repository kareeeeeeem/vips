import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/admin_theme.dart';

/// One secondary figure in a [DashboardQuickStats] strip.
class QuickStat {
  final String label;
  final String value;
  final Color? tone;

  /// A short line under the figure explaining what it is measured over.
  /// This is where a caveat lives — the share of revenue a margin covers, the
  /// sample size behind an average — instead of being left off the screen.
  final String? note;

  const QuickStat(this.label, this.value, {this.tone, this.note});
}

/// The supporting figures under a dashboard's headline cards.
///
/// Deliberately plainer than [DashboardStatsCard]: these are the numbers that
/// qualify the headline ones, and giving them equal visual weight would make
/// every dashboard read as twelve equally important metrics.
class DashboardQuickStats extends StatelessWidget {
  final String? title;
  final List<QuickStat> stats;

  const DashboardQuickStats({super.key, required this.stats, this.title});

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 4.h),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AdminColors.textPrimary,
              ),
            ),
            SizedBox(height: 10.h),
          ],
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 700 ? 4 : 2;
              final gap = 12.w;
              final itemWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;

              return Wrap(
                spacing: gap,
                runSpacing: 12.h,
                children: [
                  for (final stat in stats)
                    SizedBox(width: itemWidth, child: _buildStat(stat)),
                ],
              );
            },
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildStat(QuickStat stat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          stat.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 10.5.sp, color: AdminColors.textMuted),
        ),
        SizedBox(height: 3.h),
        Text(
          stat.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: stat.tone ?? AdminColors.textPrimary,
          ),
        ),
        if (stat.note != null) ...[
          SizedBox(height: 2.h),
          Text(
            stat.note!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 9.5.sp, height: 1.3, color: AdminColors.textMuted),
          ),
        ],
      ],
    );
  }
}
