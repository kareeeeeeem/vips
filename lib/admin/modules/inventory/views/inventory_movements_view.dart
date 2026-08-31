import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../controllers/inventory_movements_controller.dart';
import '../widgets/inventory_tabs.dart';
import '../widgets/stock_movement_card.dart';

/// The stock ledger: every recorded change to every stock line, from the
/// merchant app as well as the console.
class InventoryMovementsView extends GetView<InventoryMovementsController> {
  const InventoryMovementsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      // Adjustments is this ledger with the type filter already applied, not
      // a second screen — one list, so the two can never disagree.
      title: controller.adjustmentsOnly.value ? 'Adjustments' : 'Stock Movements',
      route: controller.adjustmentsOnly.value
          ? AdminRoutes.INVENTORY_ADJUSTMENTS
          : AdminRoutes.INVENTORY_MOVEMENTS,
      onRefresh: () => controller.load(),
      actions: [
        IconButton(
          tooltip: 'Filter by date',
          onPressed: () => _pickDateRange(context),
          icon: Obx(() => Icon(
                Icons.date_range_rounded,
                size: 20.sp,
                color: controller.dateRange.value != null
                    ? AdminColors.primary
                    : AdminColors.textSecondary,
              )),
        ),
      ],
      body: Column(
        children: [
          const InventoryTabs(current: AdminRoutes.INVENTORY_MOVEMENTS),
          _buildFilters(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: AdminColors.background,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      child: Column(
        children: [
          Obx(() {
            controller.search.value;
            return AdminSearchField(
              controller: controller.searchController,
              hint: 'Search by item, category or reason',
              onChanged: controller.onSearchChanged,
              onClear: controller.clearSearch,
            );
          }),
          SizedBox(height: 12.h),
          Obx(() => AdminFilterChips(
                options: [
                  AdminFilterOption('', 'All', count: controller.countFor('')),
                  for (final type in InventoryMovementsController.types)
                    AdminFilterOption(
                      type,
                      adminLabel(type),
                      count: controller.countFor(type),
                    ),
                ],
                selected: controller.typeFilter.value,
                onSelected: controller.setTypeFilter,
              )),
          _buildScopeBanner(),
        ],
      ),
    );
  }

  /// Arriving from one stock line or merchant scopes the ledger. Without a
  /// visible marker the operator would read a handful of rows as the whole
  /// history of the platform.
  Widget _buildScopeBanner() {
    return Obx(() {
      final range = controller.dateRange.value;
      final chips = <Widget>[];

      if (controller.hasScope) {
        chips.add(_chip(
          controller.stockFilter.value.isNotEmpty
              ? 'One stock line only'
              : 'One merchant only',
          controller.clearScope,
        ));
      }
      if (range != null) {
        chips.add(_chip(
          '${adminDateLabel(range.start)} – ${adminDateLabel(range.end)}',
          () => controller.setDateRange(null),
        ));
      }
      if (chips.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.only(top: 10.h),
        child: Row(children: chips),
      );
    });
  }

  Widget _chip(String label, VoidCallback onClear) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: AdminColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AdminColors.primary,
              ),
            ),
            SizedBox(width: 6.w),
            GestureDetector(
              onTap: onClear,
              child: Icon(Icons.close_rounded, size: 14.sp, color: AdminColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange(BuildContext context) async {
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

  Widget _buildList() {
    return Obx(() {
      if (controller.isLoading.value && controller.items.isEmpty) {
        return const AdminLoading();
      }
      if (controller.errorMessage.isNotEmpty && controller.items.isEmpty) {
        return AdminErrorState(
          message: controller.errorMessage.value,
          onRetry: () => controller.load(),
        );
      }
      if (controller.items.isEmpty) {
        return AdminEmptyState(
          icon: Icons.swap_vert_rounded,
          title: controller.hasAnyFilter ? 'No matching movements' : 'No movements yet',
          message: controller.hasAnyFilter
              ? 'No stock movement matches these filters. Try a wider type or date range.'
              : 'Every stock change — from the merchant app or this console — '
                  'is recorded here as it happens.',
        );
      }

      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
        children: [
          for (final movement in controller.items)
            StockMovementCard(movement: movement),
          AdminPaginator(
            page: controller.page.value,
            pages: controller.pages.value,
            total: controller.total.value,
            onPrevious: controller.previousPage,
            onNext: controller.nextPage,
          ),
        ],
      );
    });
  }
}
