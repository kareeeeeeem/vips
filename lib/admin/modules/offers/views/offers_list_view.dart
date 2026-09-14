import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/offers_controller.dart';

class OffersListView extends GetView<AdminOffersController> {
  const OffersListView({super.key});

  @override
  Widget build(BuildContext context) => AdminScaffold(
    title: 'Coupons & vouchers',
    route: AdminRoutes.OFFERS,
    onRefresh: controller.load,
    body: Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
          child: Column(
            children: [
              AdminSearchField(
                controller: controller.searchController,
                hint: 'Search code, description or tag',
                onChanged: controller.onSearchChanged,
                onClear: controller.clearSearch,
              ),
              SizedBox(height: 8.h),
              Obx(
                () => AdminFilterChips(
                  options: const [
                    AdminFilterOption('', 'All types'),
                    AdminFilterOption('voucher', 'Vouchers'),
                    AdminFilterOption('percentage', 'Percent'),
                    AdminFilterOption('fixed', 'Fixed'),
                    AdminFilterOption('shipping', 'Shipping'),
                  ],
                  selected: controller.typeFilter.value,
                  onSelected: controller.setType,
                ),
              ),
              Obx(
                () => AdminFilterChips(
                  options: const [
                    AdminFilterOption('', 'Any status'),
                    AdminFilterOption('active', 'Active'),
                    AdminFilterOption('inactive', 'Suspended'),
                  ],
                  selected: controller.statusFilter.value,
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
        icon: Icons.local_offer_outlined,
        title: 'No offers found',
        message: 'Coupons and vouchers published by merchants appear here.',
      );
    }
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        for (final offer in controller.items) _card(offer),
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

  Widget _card(Map<String, dynamic> offer) {
    final id = adminString(offer['_id']);
    final active = adminBool(offer['isActive'], true);
    final used = adminInt(offer['usageCount'] ?? offer['usedCount']);
    final type = adminString(offer['type'], 'percentage');
    final discount = adminDouble(offer['discount']);
    final value =
        type == 'voucher' || offer['discountUnit'] == 'tnd'
            ? adminMoney(discount)
            : type == 'shipping'
            ? 'Free shipping'
            : type == 'fixed'
            ? adminMoney(discount)
            : '${discount.toStringAsFixed(discount % 1 == 0 ? 0 : 1)}%';
    return AdminCard(
      title: adminString(offer['code'], 'No code'),
      subtitle: '${adminString(offer['merchantName'], 'Platform')} • $value',
      trailing: AdminStatusPill(
        label: active ? 'Active' : 'Suspended',
        color: active ? AdminColors.success : AdminColors.danger,
      ),
      child: Row(
        children: [
          Expanded(child: Text('$used redemption${used == 1 ? '' : 's'}')),
          IconButton(
            tooltip:
                controller.canUpdate
                    ? (active ? 'Suspend' : 'Activate')
                    : 'Permission required',
            onPressed:
                controller.canUpdate
                    ? () => controller.setActive(id, !active)
                    : null,
            icon: Icon(
              active ? Icons.pause_circle_outline : Icons.play_circle_outline,
            ),
          ),
          IconButton(
            tooltip: used > 0 ? 'Used offers cannot be deleted' : 'Delete',
            onPressed:
                controller.canDelete && used == 0
                    ? () async {
                      final ok = await adminConfirm(
                        title: 'Delete this offer?',
                        message: 'This removes the unused offer permanently.',
                        confirmLabel: 'Delete',
                      );
                      if (ok) await controller.remove(id);
                    }
                    : null,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}
