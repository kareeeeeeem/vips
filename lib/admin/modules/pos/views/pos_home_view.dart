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
import '../controllers/pos_controller.dart';
import '../widgets/pos_cart_panel.dart';
import '../widgets/pos_product_card.dart';

/// The till. Product grid on one side, the running cart on the other.
///
/// Nothing is priced here — every figure shown comes from the server's cart
/// response, so what the cashier reads out and what the customer is charged
/// are the same number by construction.
class PosHomeView extends GetView<PosController> {
  const PosHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Point of Sale',
      route: AdminRoutes.POS,
      onRefresh: controller.load,
      actions: [
        IconButton(
          tooltip: 'Receipt history',
          onPressed: () => Get.toNamed(AdminRoutes.POS_INVOICES),
          icon: Icon(Icons.receipt_long_outlined,
              size: 20.sp, color: AdminColors.textSecondary),
        ),
        Obx(() => controller.hasSession
            ? IconButton(
                tooltip: 'Close the till',
                onPressed: () => _closeTill(context),
                icon: Icon(Icons.point_of_sale_outlined,
                    size: 20.sp, color: AdminColors.danger),
              )
            : const SizedBox.shrink()),
      ],
      body: Obx(() {
        if (controller.isLoading.value && !controller.hasSession) {
          return const AdminLoading();
        }
        if (!controller.hasSession) return _buildOpenTill(context);
        return _buildTill(context);
      }),
    );
  }

  // ── No open session ───────────────────────────────────────

  Widget _buildOpenTill(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
      children: [
        AdminCard(
          title: 'Open a till',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pick the store you are selling from. The till uses that '
                "merchant's catalogue and moves its stock, so only active "
                'merchants are listed.',
                style: TextStyle(
                  fontSize: 12.5.sp,
                  height: 1.45,
                  color: AdminColors.textSecondary,
                ),
              ),
              SizedBox(height: 16.h),
              if (controller.merchants.isEmpty)
                Text(
                  'No active merchants to sell from.',
                  style: TextStyle(fontSize: 12.sp, color: AdminColors.textMuted),
                )
              else
                for (final merchant in controller.merchants.take(30))
                  _merchantRow(context, merchant),
            ],
          ),
        ),
      ],
    );
  }

  Widget _merchantRow(BuildContext context, Map<String, dynamic> merchant) {
    final name = adminString(
      merchant['storeName'],
      adminString(merchant['fullName'], 'Unnamed'),
    );
    return InkWell(
      onTap: () => _askOpeningFloat(context, adminString(merchant['_id']), name),
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 11.h, horizontal: 4.w),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AdminColors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.storefront_outlined,
                  size: 18.sp, color: AdminColors.purple),
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
                  Text(
                    adminString(merchant['storeCategory'], 'Uncategorised'),
                    style: TextStyle(fontSize: 11.sp, color: AdminColors.textMuted),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18.sp, color: AdminColors.textMuted),
          ],
        ),
      ),
    );
  }

  void _askOpeningFloat(BuildContext context, String merchantId, String name) {
    final floatController = TextEditingController(text: '0');
    adminSheet(
      title: 'Open till — $name',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'The opening float is the cash already in the drawer. It is what '
            'the closing count is measured against, so an accurate figure '
            'here is what makes the end-of-day difference meaningful.',
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.45,
              color: AdminColors.textSecondary,
            ),
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: floatController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
            style: TextStyle(fontSize: 15.sp, color: AdminColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Opening float (D)',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AdminColors.border),
              ),
            ),
          ),
          SizedBox(height: 18.h),
          Obx(() => AdminButton(
                label: 'Open till',
                icon: Icons.lock_open_rounded,
                isLoading: controller.isBusy.value,
                onPressed: () async {
                  final value = double.tryParse(floatController.text.trim()) ?? 0;
                  if (value < 0) {
                    return adminToast('Check the float',
                        'The opening float cannot be negative.', isError: true);
                  }
                  final ok = await controller.startSession(merchantId, value);
                  if (ok) Get.back();
                },
              )),
        ],
      ),
    ).whenComplete(floatController.dispose);
  }

  // ── Open session ──────────────────────────────────────────

  Widget _buildTill(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // On a wide screen the grid and the cart sit side by side, the way a
        // real till is laid out. On a phone the cart drops to a bottom sheet
        // so the grid keeps the full width.
        final wide = constraints.maxWidth > 900;
        final grid = Column(
          children: [
            _buildSessionBar(),
            _buildProductSearch(),
            Expanded(child: _buildProductGrid()),
          ],
        );

        if (!wide) {
          return Column(
            children: [
              Expanded(child: grid),
              PosCartPanel(compact: true, onCheckout: () => _checkout(context)),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 3, child: grid),
            SizedBox(
              width: 380.w,
              child: PosCartPanel(compact: false, onCheckout: () => _checkout(context)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSessionBar() {
    return Obx(() => Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
          decoration: BoxDecoration(
            color: AdminColors.primary.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AdminColors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.storefront_rounded, size: 16.sp, color: AdminColors.primary),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Selling from ${controller.merchantName.value.isEmpty ? 'this store' : controller.merchantName.value}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AdminColors.primary,
                  ),
                ),
              ),
              AdminStatusPill(
                label: 'Float ${adminMoney(adminDouble(controller.session.value?['openingFloat']))}',
                color: AdminColors.primary,
                compact: true,
              ),
            ],
          ),
        ));
  }

  Widget _buildProductSearch() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      child: Obx(() {
        controller.productQuery.value;
        return AdminSearchField(
          controller: controller.productSearchController,
          hint: 'Search the catalogue by name, code or category',
          onChanged: controller.onProductSearch,
          onClear: () {
            controller.productSearchController.clear();
            controller.productQuery.value = '';
          },
        );
      }),
    );
  }

  Widget _buildProductGrid() {
    return Obx(() {
      final items = controller.visibleProducts;
      if (controller.products.isEmpty) {
        return AdminEmptyState(
          icon: Icons.inventory_2_outlined,
          title: 'No products to sell',
          message: 'This merchant has nothing in its catalogue yet.',
        );
      }
      if (items.isEmpty) {
        return AdminEmptyState(
          icon: Icons.search_off_rounded,
          title: 'No matching products',
          message: 'Nothing matches "${controller.productQuery.value}".',
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          final columns = (constraints.maxWidth / 200).floor().clamp(2, 6);
          return GridView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 1.15,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final product = items[index];
              return PosProductCard(
                product: product,
                price: controller.sellingPrice(product),
                stock: controller.stockOf(product),
                onTap: () => controller.addProduct(adminString(product['_id'])),
              );
            },
          );
        },
      );
    });
  }

  // ── Checkout ──────────────────────────────────────────────

  Future<void> _checkout(BuildContext context) async {
    if (controller.cartItems.isEmpty) {
      adminToast('Nothing to charge', 'The cart is empty.', isError: true);
      return;
    }
    final invoice = await Get.toNamed(AdminRoutes.POS_CHECKOUT);
    if (invoice is Map) {
      Get.toNamed(AdminRoutes.POS_INVOICE,
          arguments: {'invoice': Map<String, dynamic>.from(invoice)});
    }
  }

  Future<void> _closeTill(BuildContext context) async {
    final countController = TextEditingController();
    await adminSheet(
      title: 'Close the till',
      child: Obx(() {
        final session = controller.session.value ?? {};
        final expected = adminDouble(session['openingFloat']) +
            adminDouble(session['totalSales']) -
            adminDouble(session['totalRefunds']);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminDetailRow(
              label: 'Opening float',
              value: adminMoney(adminDouble(session['openingFloat'])),
            ),
            AdminDetailRow(
              label: 'Sales',
              value: adminMoney(adminDouble(session['totalSales'])),
            ),
            AdminDetailRow(
              label: 'Refunds',
              value: '− ${adminMoney(adminDouble(session['totalRefunds']))}',
            ),
            const Divider(height: 24, color: AdminColors.divider),
            // Deliberately shown: the cashier counts first, and the
            // difference is only meaningful because the count is entered
            // rather than derived.
            AdminDetailRow(
              label: 'Till should hold',
              value: adminMoney(expected),
              valueColor: AdminColors.primary,
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: countController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              style: TextStyle(fontSize: 15.sp, color: AdminColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Counted cash (D)',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AdminColors.border),
                ),
              ),
            ),
            SizedBox(height: 18.h),
            AdminButton(
              label: 'Close till',
              icon: Icons.lock_outline_rounded,
              color: AdminColors.danger,
              isLoading: controller.isBusy.value,
              onPressed: () async {
                final counted = double.tryParse(countController.text.trim());
                if (counted == null || counted < 0) {
                  return adminToast('Check the count',
                      'Enter the cash counted in the drawer.', isError: true);
                }
                final result = await controller.endSession(counted);
                if (result != null) {
                  Get.back();
                  _showReconciliation(result);
                }
              },
            ),
          ],
        );
      }),
    );
    countController.dispose();
  }

  void _showReconciliation(Map<String, dynamic> result) {
    final difference = adminDouble(result['difference']);
    final over = difference > 0;
    final balanced = difference == 0;

    adminSheet(
      title: 'Till closed',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: (balanced
                      ? AdminColors.success
                      : over
                          ? AdminColors.info
                          : AdminColors.danger)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Text(
                  balanced
                      ? 'Balanced'
                      : over
                          ? 'Over by ${adminMoney(difference.abs())}'
                          : 'Short by ${adminMoney(difference.abs())}',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: balanced
                        ? AdminColors.success
                        : over
                            ? AdminColors.info
                            : AdminColors.danger,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Expected ${adminMoney(adminDouble(result['expectedCash']))}',
                  style: TextStyle(fontSize: 12.sp, color: AdminColors.textSecondary),
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          AdminButton(
            label: 'Done',
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }
}
