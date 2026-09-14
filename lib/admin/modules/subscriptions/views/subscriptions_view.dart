import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/routes/admin_routes.dart';
import '../../../core/admin_toast.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/subscriptions_controller.dart';

class SubscriptionsView extends GetView<AdminSubscriptionsController> {
  const SubscriptionsView({super.key});

  @override
  Widget build(BuildContext context) => AdminScaffold(
    title: 'Subscriptions',
    route: AdminRoutes.SUBSCRIPTIONS,
    onRefresh: controller.load,
    body: Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
          child: Column(
            children: [
              AdminSearchField(
                controller: controller.searchController,
                hint: 'Search name, phone, email or store',
                onChanged: controller.onSearchChanged,
                onClear: controller.clearSearch,
              ),
              SizedBox(height: 8.h),
              Obx(
                () => AdminFilterChips(
                  options: const [
                    AdminFilterOption('customer', 'Customers'),
                    AdminFilterOption('merchant', 'Merchants'),
                  ],
                  selected: controller.audience.value,
                  onSelected: controller.setAudience,
                ),
              ),
              Obx(
                () =>
                    controller.audience.value == 'customer'
                        ? AdminFilterChips(
                          options: const [
                            AdminFilterOption('', 'Any payment'),
                            AdminFilterOption(
                              'pending_payment',
                              'Pending payment',
                            ),
                            AdminFilterOption('paid', 'Paid'),
                            AdminFilterOption('rejected', 'Rejected'),
                          ],
                          selected: controller.paymentStatus.value,
                          onSelected: controller.setPaymentStatus,
                        )
                        : const SizedBox.shrink(),
              ),
              Obx(
                () => AdminFilterChips(
                  options: const [
                    AdminFilterOption('', 'All'),
                    AdminFilterOption('active', 'Active'),
                    AdminFilterOption('inactive', 'Inactive'),
                  ],
                  selected: controller.status.value,
                  onSelected: controller.setStatus,
                ),
              ),
            ],
          ),
        ),
        Expanded(child: Obx(_content)),
      ],
    ),
  );

  Widget _content() {
    if (controller.isLoading.value && controller.items.isEmpty) {
      return const AdminLoading();
    }
    if (controller.errorMessage.isNotEmpty && controller.items.isEmpty) {
      return AdminErrorState(
        message: controller.errorMessage.value,
        onRetry: controller.load,
      );
    }
    if (controller.items.isEmpty) {
      return const AdminEmptyState(
        icon: Icons.workspace_premium_outlined,
        title: 'No subscriptions found',
        message: 'Purchased customer and merchant subscriptions appear here.',
      );
    }
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        for (final item in controller.items) _card(item),
        AdminPaginator(
          page: controller.page.value,
          pages: controller.pages.value,
          total: controller.total.value,
          onPrevious: controller.previousPage,
          onNext: controller.nextPage,
        ),
      ],
    );
  }

  Widget _card(Map<String, dynamic> item) {
    final active = adminBool(item['isActive'], true);
    final tier = adminString(item['tier'] ?? item['planCode'], 'basic');
    final end = adminDate(item['endDate']);
    final amount = adminDouble(item['amountPaid'] ?? item['price']);
    final paymentStatus = adminString(item['paymentStatus'], 'paid');
    final pendingPayment =
        controller.audience.value == 'customer' &&
        paymentStatus == 'pending_payment';
    final statusLabel =
        pendingPayment
            ? 'Payment pending'
            : paymentStatus == 'rejected'
            ? 'Rejected'
            : active
            ? 'Active'
            : 'Inactive';
    final statusColor =
        pendingPayment
            ? AdminColors.warning
            : paymentStatus == 'rejected'
            ? AdminColors.danger
            : active
            ? AdminColors.success
            : AdminColors.danger;
    return AdminCard(
      title: adminString(item['ownerName'], 'Deleted account'),
      subtitle: '${adminLabel(tier)} • ${adminMoney(amount)}',
      trailing: AdminStatusPill(label: statusLabel, color: statusColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            end == null ? 'No expiry' : 'Ends ${adminDateLabel(end)}',
            style: TextStyle(
              fontSize: 11.5.sp,
              color: AdminColors.textSecondary,
            ),
          ),
          if (controller.audience.value == 'customer') ...[
            SizedBox(height: 5.h),
            Text(
              _paymentDescription(item),
              style: TextStyle(
                fontSize: 11.5.sp,
                color: AdminColors.textSecondary,
              ),
            ),
            if (adminString(item['reviewReason']).isNotEmpty)
              Text('Review note: ${adminString(item['reviewReason'])}'),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (pendingPayment && controller.canReviewPayment) ...[
                TextButton(
                  onPressed: () => _reject(item),
                  child: const Text('Reject'),
                ),
                FilledButton(
                  onPressed:
                      () => controller.reviewPayment(
                        adminString(item['_id']),
                        'approve',
                      ),
                  child: const Text('Approve payment'),
                ),
              ] else if (!pendingPayment && paymentStatus != 'rejected')
                IconButton(
                  tooltip:
                      controller.canUpdate
                          ? (active
                              ? 'Suspend subscription'
                              : 'Restore subscription')
                          : 'Permission required',
                  onPressed:
                      controller.canUpdate
                          ? () => controller.setActive(
                            adminString(item['_id']),
                            !active,
                          )
                          : null,
                  icon: Icon(
                    active
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _paymentDescription(Map<String, dynamic> item) {
    final method = adminString(item['paymentMethod'], 'wallet');
    if (method == 'bank_transfer') {
      return 'Bank transfer • Reference: ${adminString(item['bankReference'], 'Not supplied')}';
    }
    if (method == 'partner_cash') {
      return 'Partner cash • Store: ${adminString(item['partnerStore'], 'Not supplied')}';
    }
    return 'Wallet payment';
  }

  void _reject(Map<String, dynamic> item) {
    final reason = TextEditingController();
    adminSheet(
      title: 'Reject subscription payment',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: reason,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Reason'),
          ),
          SizedBox(height: 16.h),
          AdminButton(
            label: 'Reject payment',
            icon: Icons.block_outlined,
            onPressed: () async {
              if (reason.text.trim().length < 3) {
                return adminToast(
                  'Reason required',
                  'Enter a clear rejection reason.',
                  isError: true,
                );
              }
              final ok = await controller.reviewPayment(
                adminString(item['_id']),
                'reject',
                reason: reason.text.trim(),
              );
              if (ok) Get.back<void>();
            },
          ),
        ],
      ),
    );
  }
}
