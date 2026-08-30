import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/admin_toast.dart';
import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/inventory_controller.dart';
import '../widgets/inventory_filter.dart';
import '../widgets/inventory_tabs.dart';

/// Adapted from `merchant_stock/views/stock_list_view.dart`: same summary
/// cards, same row layout with the ± adjusters, same low-stock highlighting
/// — but across every merchant, with the store and warehouse on each row.
///
/// The alerts and ledger now have screens of their own; this one stays the
/// place you look at and correct current levels.
class InventoryOverviewView extends GetView<AdminInventoryController> {
  const InventoryOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Inventory',
      route: AdminRoutes.INVENTORY,
      onRefresh: () async {
        await controller.load();
        await controller.loadAlerts();
      },
      actions: [
        Obx(() => IconButton(
              tooltip: 'Low-stock alerts',
              onPressed: () => Get.toNamed(AdminRoutes.INVENTORY_ALERTS),
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.notifications_none_rounded,
                      size: 21.sp, color: AdminColors.textSecondary),
                  if (controller.alertCount > 0)
                    Positioned(
                      right: -3,
                      top: -3,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: AdminColors.danger,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        constraints: BoxConstraints(minWidth: 15.w),
                        child: Text(
                          '${controller.alertCount}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            )),
      ],
      body: Column(
        children: [
          const InventoryTabs(current: AdminRoutes.INVENTORY),
          _buildSummary(),
          _buildFilters(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Obx(() => Padding(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 4.h),
          child: Row(
            children: [
              Expanded(
                child: AdminStatCard(
                  label: 'Stock value',
                  value: adminMoney(controller.totalValue.value),
                  icon: Icons.savings_outlined,
                  color: AdminColors.success,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: AdminStatCard(
                  label: 'Units on hand',
                  value: adminCount(controller.totalUnits.value),
                  icon: Icons.inventory_2_outlined,
                  color: AdminColors.info,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: AdminStatCard(
                  label: 'Low stock',
                  value: adminCount(controller.alertCount),
                  icon: Icons.warning_amber_rounded,
                  color: AdminColors.danger,
                  onTap: () => Get.toNamed(AdminRoutes.INVENTORY_ALERTS),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildFilters() {
    return Obx(() {
      controller.search.value;
      return InventoryFilter(
        searchController: controller.searchController,
        hint: 'Search by item, category or location',
        onSearchChanged: controller.onSearchChanged,
        onSearchCleared: controller.clearSearch,
        locations: controller.locations,
        selectedLocation: controller.locationFilter.value,
        onLocationSelected: controller.setLocationFilter,
        trailing: Row(
          children: [
            AdminFilterChips(
              options: const [AdminFilterOption('low', 'Low stock only')],
              selected: controller.lowStockOnly.value ? 'low' : '',
              onSelected: (_) => controller.toggleLowStockOnly(),
            ),
            if (controller.merchantFilter.value.isNotEmpty) ...[
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: controller.clearMerchantFilter,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: AdminColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'One merchant',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: AdminColors.primary,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Icon(Icons.close_rounded, size: 14.sp, color: AdminColors.primary),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
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
        final filtered =
            controller.search.value.isNotEmpty || controller.lowStockOnly.value;
        return AdminEmptyState(
          icon: Icons.inventory_2_outlined,
          title: filtered ? 'No matching stock' : 'No stock recorded',
          message: filtered
              ? 'No stock line matches these filters.'
              : 'Stock lines appear here once merchants add them in the '
                  'VIPs Merchant app.',
        );
      }

      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
        children: [
          for (final item in controller.items) _buildStockRow(item),
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

  Widget _buildStockRow(Map<String, dynamic> item) {
    final isLow = adminBool(item['isLowStock']);
    final stock = adminInt(item['currentStock']);

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AdminColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isLow ? AdminColors.danger.withValues(alpha: 0.35) : AdminColors.border,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: (isLow ? AdminColors.danger : AdminColors.info)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                  child: Icon(
                    isLow ? Icons.warning_amber_rounded : Icons.inventory_2_outlined,
                    size: 20.sp,
                    color: isLow ? AdminColors.danger : AdminColors.info,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        adminString(item['name'], 'Unnamed item'),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${adminString(item['category'], 'General')} · '
                        '${adminString(item['merchantName'], 'Unknown store')}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11.sp, color: AdminColors.textMuted),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        '${adminMoney(adminDouble(item['unitPrice']))} per unit · '
                        'alert at ${adminCount(adminInt(item['lowStockThreshold']))}',
                        style: TextStyle(fontSize: 11.sp, color: AdminColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Edit',
                  onPressed: () => _showEditSheet(item),
                  icon: Icon(Icons.edit_outlined, size: 18.sp, color: AdminColors.textMuted),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            const Divider(height: 1, color: AdminColors.divider),
            SizedBox(height: 8.h),
            Obx(() {
              final busy = controller.isMutating.value;
              return Row(
                children: [
                  Text(
                    isLow ? 'Low stock' : 'In stock',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: isLow ? AdminColors.danger : AdminColors.success,
                    ),
                  ),
                  const Spacer(),
                  _adjustButton(
                    Icons.remove_rounded,
                    busy || stock == 0 ? null : () => controller.adjustStock(item, -1),
                  ),
                  SizedBox(width: 14.w),
                  Text(
                    adminCount(stock),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  _adjustButton(
                    Icons.add_rounded,
                    busy ? null : () => controller.adjustStock(item, 1),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _adjustButton(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: 30.w,
        height: 30.w,
        decoration: BoxDecoration(
          color: onTap == null ? AdminColors.divider : AdminColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          icon,
          size: 17.sp,
          color: onTap == null ? AdminColors.textMuted : AdminColors.primary,
        ),
      ),
    );
  }

  // ── Edit sheet ────────────────────────────────────────────

  void _showEditSheet(Map<String, dynamic> item) {
    final id = adminString(item['_id']);
    final nameCtrl = TextEditingController(text: adminString(item['name']));
    final categoryCtrl = TextEditingController(text: adminString(item['category']));
    final stockCtrl =
        TextEditingController(text: '${adminInt(item['currentStock'])}');
    final thresholdCtrl =
        TextEditingController(text: '${adminInt(item['lowStockThreshold'])}');
    final priceCtrl =
        TextEditingController(text: '${adminDouble(item['unitPrice'])}');

    adminSheet(
      title: 'Edit ${adminString(item['name'], 'item')}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            adminString(item['merchantName'], 'Unknown store'),
            style: TextStyle(fontSize: 12.sp, color: AdminColors.textMuted),
          ),
          SizedBox(height: 16.h),
          _field(nameCtrl, 'Item name'),
          SizedBox(height: 12.h),
          _field(categoryCtrl, 'Category'),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(child: _field(stockCtrl, 'Current stock', numeric: true)),
              SizedBox(width: 12.w),
              Expanded(child: _field(thresholdCtrl, 'Low-stock alert at', numeric: true)),
            ],
          ),
          SizedBox(height: 12.h),
          _field(priceCtrl, 'Unit price (D)', numeric: true, decimal: true),
          SizedBox(height: 20.h),
          Obx(() => AdminButton(
                label: 'Save changes',
                icon: Icons.save_outlined,
                isLoading: controller.isMutating.value,
                onPressed: () async {
                  final stock = int.tryParse(stockCtrl.text.trim());
                  final threshold = int.tryParse(thresholdCtrl.text.trim());
                  final price = double.tryParse(priceCtrl.text.trim());

                  // Validate before the request: the backend rejects these
                  // with a 400, and catching it here says which field is
                  // wrong instead of showing a generic server message.
                  if (stock == null || stock < 0) {
                    return adminToast('Check stock',
                        'Current stock must be a whole number of 0 or more.',
                        isError: true);
                  }
                  if (threshold == null || threshold < 0) {
                    return adminToast('Check threshold',
                        'The alert threshold must be 0 or more.',
                        isError: true);
                  }
                  if (price == null || price < 0) {
                    return adminToast('Check price',
                        'The unit price must be 0 or more.',
                        isError: true);
                  }
                  if (nameCtrl.text.trim().isEmpty) {
                    return adminToast('Check name', 'The item needs a name.',
                        isError: true);
                  }

                  final ok = await controller.updateItem(id, {
                    'name': nameCtrl.text.trim(),
                    'category': categoryCtrl.text.trim(),
                    'currentStock': stock,
                    'lowStockThreshold': threshold,
                    'unitPrice': price,
                  });
                  if (ok) Get.back();
                },
              )),
        ],
      ),
    ).whenComplete(() {
      nameCtrl.dispose();
      categoryCtrl.dispose();
      stockCtrl.dispose();
      thresholdCtrl.dispose();
      priceCtrl.dispose();
    });
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool numeric = false,
    bool decimal = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: numeric
          ? TextInputType.numberWithOptions(decimal: decimal)
          : TextInputType.text,
      inputFormatters: numeric
          ? [
              FilteringTextInputFormatter.allow(
                decimal ? RegExp(r'[0-9.]') : RegExp(r'[0-9]'),
              ),
            ]
          : null,
      style: TextStyle(fontSize: 14.sp, color: AdminColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13.sp, color: AdminColors.textSecondary),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AdminColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AdminColors.primary),
        ),
      ),
    );
  }
}
