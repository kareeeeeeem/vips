import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/routes/admin_routes.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/products_controller.dart';
import 'product_edit_sheet.dart';

/// The product catalogue across every merchant.
class ProductsListView extends GetView<AdminProductsController> {
  const ProductsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Products',
      route: AdminRoutes.PRODUCTS,
      onRefresh: () => controller.load(),
      actions: [
        Obx(() {
          // Disabled rather than failing after the tap — the server refuses
          // it either way, and a control that only ever errors is worse than
          // one that says why it is off.
          final allowed = controller.canCreate;
          return IconButton(
            tooltip: allowed
                ? 'Add a product'
                : 'Adding needs the products.create permission',
            onPressed: allowed ? () => _openAddSheet(context) : null,
            icon: Icon(Icons.add_box_outlined,
                size: 20.sp,
                color: allowed ? AdminColors.primary : AdminColors.border),
          );
        }),
      ],
      body: Column(
        children: [
          _buildFilters(),
          Expanded(child: _buildList(context)),
        ],
      ),
    );
  }

  // ── Filters ───────────────────────────────────────────────

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
              hint: 'Search by name, code or category',
              onChanged: controller.onSearchChanged,
              onClear: controller.clearSearch,
            );
          }),
          SizedBox(height: 12.h),
          Obx(() => AdminFilterChips(
                options: [
                  const AdminFilterOption('', 'All'),
                  for (final status in AdminProductsController.statuses)
                    AdminFilterOption(
                        status, AdminProductsController.statusLabel(status)),
                ],
                selected: controller.statusFilter.value,
                onSelected: controller.setStatus,
              )),
          Obx(() {
            if (controller.categories.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: AdminFilterChips(
                options: [
                  const AdminFilterOption('', 'Every category'),
                  for (final category in controller.categories)
                    AdminFilterOption(category, category),
                ],
                selected: controller.categoryFilter.value,
                onSelected: controller.setCategory,
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── List ──────────────────────────────────────────────────

  Widget _buildList(BuildContext context) {
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
        final filtered = controller.search.value.isNotEmpty ||
            controller.statusFilter.value.isNotEmpty ||
            controller.categoryFilter.value.isNotEmpty;
        return AdminEmptyState(
          icon: Icons.inventory_outlined,
          title: filtered ? 'No matching products' : 'No products yet',
          message: filtered
              ? 'No product matches these filters.'
              : 'Products added here appear in the customer app and on the till.',
        );
      }

      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
        children: [
          _buildCostBanner(),
          for (final product in controller.items) _buildCard(context, product),
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

  /// Names the connection between this screen and the profit report, which is
  /// otherwise invisible: a margin can only be computed over products whose
  /// cost is recorded here.
  Widget _buildCostBanner() {
    final missing = controller.missingCostCount;
    if (missing == 0) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AdminColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AdminColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 15.sp, color: AdminColors.warning),
          SizedBox(width: 9.w),
          Expanded(
            child: Text(
              '$missing product${missing == 1 ? '' : 's'} on this page '
              '${missing == 1 ? 'has' : 'have'} no cost price. Profit and margin '
              'are only computed over products that do.',
              style: TextStyle(
                fontSize: 11.5.sp,
                height: 1.35,
                color: AdminColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, Map<String, dynamic> product) {
    final name = adminString(product['name'], 'Unnamed');
    final active = adminBool(product['isActive'], true);
    final price = adminDouble(product['price']);
    final selling = controller.sellingPrice(product);
    final discounted = selling < price;
    final stock = adminInt(product['stock']);
    final alertQty = adminInt(product['alertQty']);
    final lowStock = alertQty > 0 && stock <= alertQty;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () => _openEditSheet(context, product),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AdminColors.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: active
                  ? AdminColors.border
                  : AdminColors.danger.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        SizedBox(height: 3.h),
                        Text(
                          adminString(product['merchantName'], 'Unknown store'),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11.5.sp, color: AdminColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        adminMoney(selling),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                      // The list price is struck through only when a discount
                      // is really in force, so the two prices cannot be read
                      // as one arbitrary pair.
                      if (discounted)
                        Text(
                          adminMoney(price),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AdminColors.textMuted,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6.w,
                      runSpacing: 4.h,
                      children: [
                        AdminStatusPill(
                          label: active ? 'Live' : 'Hidden',
                          color: active ? AdminColors.success : AdminColors.danger,
                          compact: true,
                        ),
                        AdminStatusPill(
                          label: adminString(product['category'], 'Uncategorised'),
                          color: AdminColors.info,
                          compact: true,
                        ),
                        AdminStatusPill(
                          label: '$stock in stock',
                          color: lowStock ? AdminColors.warning : AdminColors.textSecondary,
                          compact: true,
                        ),
                        if (!controller.hasCost(product))
                          const AdminStatusPill(
                            label: 'No cost set',
                            color: AdminColors.warning,
                            compact: true,
                          ),
                      ],
                    ),
                  ),
                  Obx(() => IconButton(
                        tooltip: 'Actions',
                        visualDensity: VisualDensity.compact,
                        onPressed: controller.isMutating.value
                            ? null
                            : () => _showActions(context, product),
                        icon: Icon(Icons.more_vert_rounded,
                            size: 20.sp, color: AdminColors.textMuted),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────

  void _showActions(BuildContext context, Map<String, dynamic> product) {
    final id = adminString(product['_id']);
    final name = adminString(product['name'], 'this product');
    final active = adminBool(product['isActive'], true);
    final deleteBlocked = controller.deleteBlockedReason(product);

    adminSheet(
      title: name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _tile(
            icon: Icons.edit_outlined,
            label: controller.canUpdate
                ? 'Edit price, cost and stock'
                : 'Editing needs the products.update permission',
            color: AdminColors.primary,
            onTap: controller.canUpdate
                ? () {
                    Get.back();
                    _openEditSheet(context, product);
                  }
                : null,
          ),
          _tile(
            icon: active ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            label: active
                ? 'Hide from customers and the till'
                : 'Make visible again',
            color: active ? AdminColors.warning : AdminColors.success,
            onTap: !controller.canUpdate
                ? null
                : () async {
                    Get.back();
                    await controller.setActive(id, !active);
                  },
          ),
          _tile(
            icon: Icons.delete_outline_rounded,
            label: deleteBlocked ?? 'Delete this product',
            color: AdminColors.danger,
            onTap: deleteBlocked != null
                ? null
                : () async {
                    Get.back();
                    final confirmed = await adminConfirm(
                      title: 'Delete $name?',
                      // The server refuses outright if it has ever sold, and
                      // says so — this only warns about the reversible case.
                      message: 'This cannot be undone. A product that has '
                          'already sold cannot be deleted at all; hide it '
                          'instead so past orders stay readable.',
                      confirmLabel: 'Delete',
                    );
                    if (confirmed) await controller.deleteProduct(id);
                  },
          ),
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 13.h, horizontal: 4.w),
          child: Row(
            children: [
              Icon(icon, size: 20.sp, color: color),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEditSheet(BuildContext context, Map<String, dynamic> product) {
    if (!controller.canUpdate) return;
    showProductEditSheet(controller: controller, product: product);
  }

  void _openAddSheet(BuildContext context) {
    controller.loadMerchants();
    showProductEditSheet(controller: controller, product: null);
  }
}
