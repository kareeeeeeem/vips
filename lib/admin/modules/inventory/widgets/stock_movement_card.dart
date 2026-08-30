import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/inventory_movements_controller.dart';

/// One row of the stock ledger.
///
/// Shows the running balance either side of the change, not just the delta —
/// a movement of "40" means nothing without knowing it took the line from 120
/// to 80.
class StockMovementCard extends StatelessWidget {
  final Map<String, dynamic> movement;

  const StockMovementCard({super.key, required this.movement});

  @override
  Widget build(BuildContext context) {
    final type = adminString(movement['type']);
    final inbound = InventoryMovementsController.isInbound(type);
    final removed = type == 'removed';

    final color = removed
        ? AdminColors.textSecondary
        : inbound
            ? AdminColors.success
            : AdminColors.danger;

    final reference = adminString(movement['reference']);

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AdminColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AdminColors.border),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 38.w,
                  height: 38.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    removed
                        ? Icons.delete_outline_rounded
                        : inbound
                            ? Icons.south_west_rounded
                            : Icons.north_east_rounded,
                    size: 18.sp,
                    color: color,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        adminString(movement['itemName'], 'Unnamed item'),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${adminString(movement['merchantName'], 'Unknown store')} · '
                        '${adminString(movement['location'], 'Main')}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11.sp, color: AdminColors.textMuted),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${inbound ? '+' : '−'}${adminCount(adminInt(movement['quantity']))}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    AdminStatusPill(
                      label: adminLabel(type),
                      color: color,
                      compact: true,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10.h),
            const Divider(height: 1, color: AdminColors.divider),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.timeline_rounded, size: 13.sp, color: AdminColors.textMuted),
                SizedBox(width: 6.w),
                Text(
                  '${adminCount(adminInt(movement['balanceBefore']))} → '
                  '${adminCount(adminInt(movement['balanceAfter']))}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AdminColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  adminRelative(adminDate(movement['createdAt'])),
                  style: TextStyle(fontSize: 11.sp, color: AdminColors.textMuted),
                ),
              ],
            ),
            if (adminString(movement['reason']).isNotEmpty ||
                reference.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      adminString(movement['reason'], '—'),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5.sp, color: AdminColors.textSecondary),
                    ),
                  ),
                  // Both halves of a transfer carry the same reference, so
                  // this is how the pair is recognisable in the ledger.
                  if (reference.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AdminColors.divider,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        reference,
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w600,
                          color: AdminColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(Icons.person_outline_rounded, size: 12.sp, color: AdminColors.textMuted),
                SizedBox(width: 5.w),
                Text(
                  '${adminString(movement['performedByName'], 'System')}'
                  '${adminString(movement['performedByRole']).isEmpty ? '' : ' · ${adminLabel(adminString(movement['performedByRole']))}'}',
                  style: TextStyle(fontSize: 10.5.sp, color: AdminColors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
