import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/admin_theme.dart';
import '../models/dashboard_models.dart';

/// A ranked or recent-activity table.
///
/// The whole table scrolls horizontally inside its own card so a wide row
/// never forces the page itself sideways — the console is used at phone width
/// as well as on a desktop browser.
class DashboardTable extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<DashboardColumn> columns;
  final List<Map<String, dynamic>> rows;
  final String emptyMessage;
  final int maxRows;
  final void Function(Map<String, dynamic> row)? onRowTap;
  final Widget? trailing;

  const DashboardTable({
    super.key,
    required this.title,
    required this.columns,
    required this.rows,
    this.subtitle,
    this.emptyMessage = 'Nothing to show for this period',
    this.maxRows = 10,
    this.onRowTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final visible = rows.take(maxRows).toList();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 10.h),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w700,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          subtitle!,
                          style:
                              TextStyle(fontSize: 11.sp, color: AdminColors.textMuted),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
                // Said plainly, so a top-10 is never mistaken for the whole list.
                if (rows.length > maxRows)
                  Text(
                    'Top $maxRows of ${rows.length}',
                    style: TextStyle(fontSize: 10.5.sp, color: AdminColors.textMuted),
                  ),
              ],
            ),
          ),
          if (visible.isEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 6.h, 14.w, 22.h),
              child: Text(
                emptyMessage,
                style: TextStyle(fontSize: 12.sp, color: AdminColors.textMuted),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                // 90dp of breathing room per column; below that the table
                // scrolls rather than squeezing a merchant name to one letter.
                final minWidth = columns.length * 90.w;
                final width =
                    minWidth > constraints.maxWidth ? minWidth : constraints.maxWidth;

                final table = SizedBox(
                  width: width,
                  child: Column(
                    children: [
                      _buildHeaderRow(),
                      for (var i = 0; i < visible.length; i++)
                        _buildRow(visible[i], i.isOdd),
                    ],
                  ),
                );

                return minWidth > constraints.maxWidth
                    ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal, child: table)
                    : table;
              },
            ),
          SizedBox(height: 6.h),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AdminColors.divider),
          bottom: BorderSide(color: AdminColors.divider),
        ),
      ),
      child: Row(
        children: [
          for (final column in columns)
            Expanded(
              flex: column.flex,
              child: Text(
                column.label,
                textAlign: column.numeric ? TextAlign.right : TextAlign.left,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: AdminColors.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(Map<String, dynamic> row, bool striped) {
    final content = Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      color: striped ? AdminColors.background : Colors.transparent,
      child: Row(
        children: [
          for (final column in columns)
            Expanded(
              flex: column.flex,
              child: Text(
                column.render(row[column.key]),
                textAlign: column.numeric ? TextAlign.right : TextAlign.left,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: column.numeric ? FontWeight.w700 : FontWeight.w500,
                  fontFeatures:
                      column.numeric ? const [FontFeature.tabularFigures()] : null,
                  color: column.numeric
                      ? AdminColors.textPrimary
                      : AdminColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );

    return onRowTap == null
        ? content
        : InkWell(onTap: () => onRowTap!(row), child: content);
  }
}
