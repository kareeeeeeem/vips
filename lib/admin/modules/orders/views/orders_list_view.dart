import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/orders_controller.dart';

/// Every order on the platform in one list — the consumer app shows a
/// customer their own orders and the merchant app shows a store its own;
/// this merges both sides, with the customer *and* the merchant on each row.
class OrdersListView extends GetView<AdminOrdersController> {
  const OrdersListView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Orders',
      route: AdminRoutes.ORDERS,
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
              hint: 'Search by order number, customer or item',
              onChanged: controller.onSearchChanged,
              onClear: controller.clearSearch,
            );
          }),
          SizedBox(height: 12.h),
          Obx(() => AdminFilterChips(
                options: [
                  AdminFilterOption('', 'All', count: controller.countFor('')),
                  for (final status in AdminOrdersController.statuses)
                    AdminFilterOption(
                      status,
                      adminLabel(status),
                      count: controller.countFor(status),
                    ),
                ],
                selected: controller.statusFilter.value,
                onSelected: controller.setStatusFilter,
              )),
          SizedBox(height: 8.h),
          Obx(() => AdminFilterChips(
                options: const [
                  AdminFilterOption('', 'Any payment'),
                  AdminFilterOption('pending', 'Unpaid'),
                  AdminFilterOption('paid', 'Paid'),
                  AdminFilterOption('failed', 'Failed'),
                  AdminFilterOption('refunded', 'Refunded'),
                ],
                selected: controller.paymentFilter.value,
                onSelected: controller.setPaymentFilter,
              )),
          _buildActiveScopeBanner(),
        ],
      ),
    );
  }

  /// Arriving from a merchant or customer page scopes the list to them.
  /// Without this banner that scope would be invisible and the operator
  /// would think the platform only had a handful of orders.
  Widget _buildActiveScopeBanner() {
    return Obx(() {
      final range = controller.dateRange.value;
      final chips = <Widget>[];

      if (controller.hasScope) {
        chips.add(_scopeChip(
          controller.merchantFilter.value.isNotEmpty
              ? 'One merchant only'
              : 'One customer only',
          controller.clearScope,
        ));
      }
      if (range != null) {
        chips.add(_scopeChip(
          '${adminDateLabel(range.start)} – ${adminDateLabel(range.end)}',
          () => controller.setDateRange(null),
        ));
      }
      if (chips.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.only(top: 10.h),
        child: Row(children: [for (final chip in chips) chip]),
      );
    });
  }

  Widget _scopeChip(String label, VoidCallback onClear) {
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
    final existing = controller.dateRange.value;
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1),
      initialDateRange: existing,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AdminColors.primary,
              ),
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
          icon: Icons.receipt_long_outlined,
          title: controller.hasAnyFilter ? 'No matching orders' : 'No orders yet',
          message: controller.hasAnyFilter
              ? 'No order matches these filters. Try a wider status, payment or date range.'
              : 'Orders placed in the VIPs app will appear here.',
        );
      }

      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
        children: [
          for (final order in controller.items) _buildOrderCard(order),
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

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final id = adminString(order['_id']);
    final status = adminString(order['status']);
    final paymentStatus = adminString(order['paymentStatus'], 'pending');

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () => _openDetails(id),
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
                  Expanded(
                    child: Text(
                      'Order #${adminString(order['orderNumber'], '—')}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: AdminColors.textPrimary,
                      ),
                    ),
                  ),
                  AdminStatusPill(
                    label: adminLabel(status),
                    color: AdminColors.orderStatus(status),
                    compact: true,
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              _row(
                Icons.person_outline_rounded,
                adminString(order['customerName'], 'Unknown customer'),
              ),
              SizedBox(height: 5.h),
              _row(
                Icons.storefront_outlined,
                adminString(order['merchantName'], 'No merchant assigned'),
              ),
              SizedBox(height: 10.h),
              const Divider(height: 1, color: AdminColors.divider),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Text(
                    adminMoney(adminDouble(order['totalAmount'])),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  AdminStatusPill(
                    label: adminLabel(paymentStatus),
                    color: paymentStatus == 'paid'
                        ? AdminColors.success
                        : paymentStatus == 'failed'
                            ? AdminColors.danger
                            : paymentStatus == 'refunded'
                                ? AdminColors.textSecondary
                                : AdminColors.warning,
                    compact: true,
                  ),
                  const Spacer(),
                  Text(
                    adminRelative(adminDate(order['createdAt'])),
                    style: TextStyle(fontSize: 11.sp, color: AdminColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: AdminColors.textMuted),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.sp, color: AdminColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Future<void> _openDetails(String id) async {
    await Get.toNamed(AdminRoutes.orderDetails(id));
    await controller.load();
  }
}
