import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/admin_toast.dart';
import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/wallets_controller.dart';

class AdminWalletsView extends GetView<AdminWalletsController> {
  const AdminWalletsView({super.key});

  @override
  Widget build(BuildContext context) => AdminScaffold(
    title: 'Wallets & points',
    route: AdminRoutes.WALLETS,
    onRefresh: controller.load,
    body: Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
          child: Column(
            children: [
              AdminSearchField(
                controller: controller.searchController,
                hint: 'Search name, phone, email or ID',
                onChanged: controller.onSearchChanged,
                onClear: controller.clearSearch,
              ),
              SizedBox(height: 8.h),
              Obx(
                () => AdminFilterChips(
                  options: const [
                    AdminFilterOption('', 'All accounts'),
                    AdminFilterOption('customer', 'Customers'),
                    AdminFilterOption('merchant', 'Merchants'),
                  ],
                  selected: controller.role.value,
                  onSelected: controller.setRole,
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
        icon: Icons.account_balance_wallet_outlined,
        title: 'No wallets found',
        message: 'Customer and merchant balances appear here.',
      );
    }
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        AdminCard(
          title: 'Totals in this filter',
          child: Row(
            children: [
              Expanded(
                child: AdminDetailRow(
                  label: 'Cash',
                  value: adminMoney(controller.totals['walletBalance']),
                ),
              ),
              Expanded(
                child: AdminDetailRow(
                  label: 'Points',
                  value: adminCount(
                    adminInt(controller.totals['walletPoints']),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        for (final account in controller.items) _card(account),
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

  Widget _card(Map<String, dynamic> account) => AdminCard(
    title: adminString(account['storeName'] ?? account['fullName'], 'Unnamed'),
    subtitle:
        '${adminLabel(adminString(account['role']))} • ID ${adminString(account['userId'], '—')}',
    trailing:
        controller.canAdjust
            ? IconButton(
              tooltip: 'Record an adjustment',
              onPressed: () => _adjustSheet(account),
              icon: const Icon(Icons.tune_rounded),
            )
            : null,
    child: Row(
      children: [
        Expanded(
          child: AdminDetailRow(
            label: 'Cash wallet',
            value: adminMoney(account['walletBalance']),
          ),
        ),
        Expanded(
          child: AdminDetailRow(
            label: 'Loyalty points',
            value: adminCount(adminInt(account['walletPoints'])),
          ),
        ),
      ],
    ),
  );

  void _adjustSheet(Map<String, dynamic> account) {
    final amount = TextEditingController();
    final reason = TextEditingController();
    final unit = 'points'.obs;
    final direction = 'credit'.obs;
    adminSheet(
      title: 'Wallet adjustment',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Every adjustment is permanent, appears in the ledger, and records your admin account.',
          ),
          SizedBox(height: 14.h),
          Obx(
            () => DropdownButtonFormField<String>(
              initialValue: unit.value,
              items: const [
                DropdownMenuItem(
                  value: 'points',
                  child: Text('Loyalty points'),
                ),
                DropdownMenuItem(
                  value: 'wallet',
                  child: Text('Cash wallet (TND)'),
                ),
              ],
              onChanged: (v) => unit.value = v ?? 'points',
            ),
          ),
          Obx(
            () => DropdownButtonFormField<String>(
              initialValue: direction.value,
              items: const [
                DropdownMenuItem(value: 'credit', child: Text('Add')),
                DropdownMenuItem(value: 'debit', child: Text('Deduct')),
              ],
              onChanged: (v) => direction.value = v ?? 'credit',
            ),
          ),
          TextField(
            controller: amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount'),
          ),
          TextField(
            controller: reason,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Reason (required)'),
          ),
          SizedBox(height: 16.h),
          AdminButton(
            label: 'Record adjustment',
            icon: Icons.save_outlined,
            onPressed: () async {
              final parsed = num.tryParse(amount.text.trim());
              if (parsed == null ||
                  parsed <= 0 ||
                  reason.text.trim().length < 5) {
                return adminToast(
                  'Check the adjustment',
                  'Enter a positive amount and a clear reason.',
                  isError: true,
                );
              }
              final delta = direction.value == 'debit' ? -parsed : parsed;
              final ok = await controller.adjust(
                adminString(account['_id']),
                unit.value,
                delta,
                reason.text.trim(),
              );
              if (ok) Get.back<void>();
            },
          ),
        ],
      ),
    );
  }
}
