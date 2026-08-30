import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/low_stock_controller.dart';
import '../widgets/inventory_tabs.dart';

/// Everything at or below its own alert threshold, across both the merchant
/// store-room lines and the customer-facing catalogue.
class LowStockAlertsView extends GetView<LowStockController> {
  const LowStockAlertsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Low Stock',
      route: AdminRoutes.INVENTORY,
      onRefresh: controller.load,
      body: Column(
        children: [
          const InventoryTabs(current: AdminRoutes.INVENTORY_ALERTS),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.total == 0) {
                return const AdminLoading();
              }
              if (controller.errorMessage.isNotEmpty && controller.total == 0) {
                return AdminErrorState(
                  message: controller.errorMessage.value,
                  onRetry: controller.load,
                );
              }
              if (controller.total == 0) {
                return AdminEmptyState(
                  icon: Icons.check_circle_outline_rounded,
                  title: 'Everything is above its threshold',
                  message: 'Nothing is at or below its alert level right now.',
                );
              }

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 20.h),
                children: [
                  _buildSummary(),
                  SizedBox(height: 14.h),
                  _buildSourceChips(),
                  SizedBox(height: 6.h),
                  if (controller.showStock && controller.stockAlerts.isNotEmpty) ...[
                    _heading('Store-room stock', controller.stockAlerts.length),
                    for (final alert in controller.stockAlerts)
                      _buildRow(
                        name: adminString(alert['name'], 'Unnamed'),
                        merchant: adminString(alert['merchantName'], 'Unknown store'),
                        detail: adminString(alert['category'], 'General'),
                        current: adminInt(alert['currentStock']),
                        threshold: adminInt(alert['lowStockThreshold']),
                        value: adminDouble(alert['unitPrice']),
                      ),
                    SizedBox(height: 16.h),
                  ],
                  if (controller.showProducts && controller.productAlerts.isNotEmpty) ...[
                    // The catalogue is what customers actually order from, so
                    // a stockout here is the one that loses a sale.
                    _heading('Catalogue products', controller.productAlerts.length),
                    for (final alert in controller.productAlerts)
                      _buildRow(
                        name: adminString(alert['name'], 'Unnamed'),
                        merchant: adminString(alert['merchantName'], 'Unknown store'),
                        detail: adminString(alert['category'], 'Uncategorised'),
                        current: adminInt(alert['stock']),
                        threshold: adminInt(alert['alertQty']),
                        value: adminDouble(alert['price']),
                      ),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Row(
      children: [
        Expanded(
          child: AdminStatCard(
            label: 'Below threshold',
            value: adminCount(controller.total),
            icon: Icons.warning_amber_rounded,
            color: AdminColors.warning,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: AdminStatCard(
            label: 'Out of stock',
            value: adminCount(controller.outOfStockCount),
            icon: Icons.remove_shopping_cart_outlined,
            color: AdminColors.danger,
            sublabel: 'Blocking sales now',
          ),
        ),
      ],
    );
  }

  Widget _buildSourceChips() {
    return AdminFilterChips(
      options: [
        AdminFilterOption('', 'All', count: controller.total),
        AdminFilterOption('stock', 'Store room', count: controller.stockAlerts.length),
        AdminFilterOption('products', 'Catalogue',
            count: controller.productAlerts.length),
      ],
      selected: controller.sourceFilter.value,
      onSelected: controller.setSourceFilter,
    );
  }

  Widget _heading(String label, int count) => Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: AdminColors.textPrimary,
              ),
            ),
            SizedBox(width: 8.w),
            AdminStatusPill(
              label: '$count',
              color: AdminColors.warning,
              compact: true,
            ),
          ],
        ),
      );

  Widget _buildRow({
    required String name,
    required String merchant,
    required String detail,
    required int current,
    required int threshold,
    required double value,
  }) {
    final out = current == 0;
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AdminColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: out
                ? AdminColors.danger.withValues(alpha: 0.4)
                : AdminColors.warning.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: (out ? AdminColors.danger : AdminColors.warning)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11.r),
              ),
              child: Text(
                '$current',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: out ? AdminColors.danger : AdminColors.warning,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '$merchant · $detail',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11.sp, color: AdminColors.textMuted),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Alerts at $threshold · ${adminMoney(value)} per unit',
                    style: TextStyle(fontSize: 11.sp, color: AdminColors.textSecondary),
                  ),
                ],
              ),
            ),
            AdminStatusPill(
              label: out ? 'Out of stock' : 'Low',
              color: out ? AdminColors.danger : AdminColors.warning,
              compact: true,
            ),
          ],
        ),
      ),
    );
  }
}
