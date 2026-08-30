import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/pos_invoices_controller.dart';

/// Till receipt history, with the refund action.
class PosInvoicesView extends GetView<PosInvoicesController> {
  const PosInvoicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'POS Receipts',
      route: AdminRoutes.POS,
      onRefresh: () => controller.load(),
      actions: [
        IconButton(
          tooltip: 'Filter by date',
          onPressed: () => _pickRange(context),
          icon: Obx(() => Icon(Icons.date_range_rounded,
              size: 20.sp,
              color: controller.dateRange.value != null
                  ? AdminColors.primary
                  : AdminColors.textSecondary)),
        ),
      ],
      body: Column(
        children: [
          _buildTotals(),
          _buildFilters(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildTotals() {
    return Obx(() => Padding(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 4.h),
          child: Row(
            children: [
              Expanded(
                child: AdminStatCard(
                  label: 'Takings',
                  value: adminMoney(controller.salesTotal.value),
                  icon: Icons.payments_rounded,
                  color: AdminColors.success,
                  // Refunds are excluded server-side, so this is money kept
                  // rather than money rung up.
                  sublabel: 'Refunds already deducted',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: AdminStatCard(
                  label: 'Refunded',
                  value: adminMoney(controller.refundedTotal.value),
                  icon: Icons.assignment_return_outlined,
                  color: AdminColors.danger,
                ),
              ),
            ],
          ),
        ));
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
              hint: 'Search by receipt number, customer or item',
              onChanged: controller.onSearchChanged,
              onClear: controller.clearSearch,
            );
          }),
          SizedBox(height: 12.h),
          Obx(() => AdminFilterChips(
                options: [
                  const AdminFilterOption('', 'All'),
                  for (final status in PosInvoicesController.statuses)
                    AdminFilterOption(status, adminLabel(status)),
                ],
                selected: controller.statusFilter.value,
                onSelected: controller.setStatusFilter,
              )),
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
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: AdminColors.primary),
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
          title: controller.hasAnyFilter ? 'No matching receipts' : 'No till sales yet',
          message: controller.hasAnyFilter
              ? 'No receipt matches these filters.'
              : 'Sales rung up on the till appear here.',
        );
      }

      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
        children: [
          for (final invoice in controller.items) _buildCard(invoice),
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

  Widget _buildCard(Map<String, dynamic> invoice) {
    final status = adminString(invoice['status'], 'completed');
    final refundable = PosInvoicesController.isRefundable(status);

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () => Get.toNamed(AdminRoutes.POS_INVOICE, arguments: {'invoice': invoice}),
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
                      adminString(invoice['invoiceNumber'], '—'),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: AdminColors.textPrimary,
                      ),
                    ),
                  ),
                  AdminStatusPill(
                    label: adminLabel(status),
                    color: status == 'refunded'
                        ? AdminColors.danger
                        : status == 'cancelled'
                            ? AdminColors.textSecondary
                            : AdminColors.success,
                    compact: true,
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.person_outline_rounded, size: 13.sp, color: AdminColors.textMuted),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      adminString(invoice['customerName'], 'Walk-in'),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.sp, color: AdminColors.textSecondary),
                    ),
                  ),
                  Text(
                    adminRelative(adminDate(invoice['createdAt'])),
                    style: TextStyle(fontSize: 11.sp, color: AdminColors.textMuted),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              const Divider(height: 1, color: AdminColors.divider),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Text(
                    adminMoney(adminDouble(invoice['total'])),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  AdminStatusPill(
                    label: adminLabel(adminString(invoice['paymentMethod'], 'cash')),
                    color: AdminColors.info,
                    compact: true,
                  ),
                  const Spacer(),
                  Obx(() => TextButton.icon(
                        // Only a completed sale can be refunded; disabled
                        // rather than failing after the tap.
                        onPressed: !refundable || controller.isMutating.value
                            ? null
                            : () => _refund(invoice),
                        icon: Icon(Icons.assignment_return_outlined,
                            size: 15.sp,
                            color: refundable ? AdminColors.danger : AdminColors.textMuted),
                        label: Text(
                          refundable ? 'Refund' : adminLabel(status),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: refundable ? AdminColors.danger : AdminColors.textMuted,
                          ),
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refund(Map<String, dynamic> invoice) async {
    final reason = await adminPromptReason(
      title: 'Refund ${adminString(invoice['invoiceNumber'], 'this sale')}',
      message: 'The stock goes back on the shelf and the takings are reversed '
          'on the session that made the sale.',
      hint: 'e.g. Customer changed their mind',
      confirmLabel: 'Refund',
    );
    if (reason != null) {
      await controller.refund(adminString(invoice['_id']), reason);
    }
  }
}
