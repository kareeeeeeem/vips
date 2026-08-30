import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/admin_toast.dart';
import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/pos_controller.dart';

/// The running sale.
///
/// Every figure here is the server's — the panel renders `totals` from the
/// cart response rather than adding anything up itself, so the number the
/// cashier reads out is the number that will be charged.
class PosCartPanel extends StatelessWidget {
  /// Compact stacks under the grid on a phone; the full panel sits beside it.
  final bool compact;
  final VoidCallback onCheckout;

  const PosCartPanel({super.key, required this.compact, required this.onCheckout});

  PosController get controller => Get.find<PosController>();

  @override
  Widget build(BuildContext context) {
    if (compact) return _buildCompact(context);
    return _buildFull(context);
  }

  // ── Phone: a summary bar that opens the full cart ─────────

  Widget _buildCompact(BuildContext context) {
    return Obx(() {
      final count = controller.itemCount;
      return Container(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
        decoration: const BoxDecoration(
          color: AdminColors.surface,
          border: Border(top: BorderSide(color: AdminColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: count == 0 ? null : () => _openCartSheet(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        count == 0 ? 'Cart empty' : '$count item${count == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AdminColors.textSecondary,
                        ),
                      ),
                      Text(
                        adminMoney(controller.total),
                        style: TextStyle(
                          fontSize: 19.sp,
                          fontWeight: FontWeight.w800,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              SizedBox(
                width: 150.w,
                child: AdminButton(
                  label: 'Charge',
                  icon: Icons.point_of_sale_rounded,
                  isLoading: controller.isBusy.value,
                  onPressed: count == 0 ? null : onCheckout,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _openCartSheet(BuildContext context) {
    adminSheet(
      title: 'Current sale',
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ..._lines(context),
              SizedBox(height: 12.h),
              _totals(),
              SizedBox(height: 14.h),
              _actions(context),
            ],
          )),
    );
  }

  // ── Wide: a permanent side panel ──────────────────────────

  Widget _buildFull(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AdminColors.surface,
        border: Border(left: BorderSide(color: AdminColors.border)),
      ),
      child: Obx(() => Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                child: Row(
                  children: [
                    Text(
                      'Current sale',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: AdminColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    if (controller.cartItems.isNotEmpty)
                      TextButton(
                        onPressed: () => _confirmClear(),
                        child: Text('Clear',
                            style: TextStyle(
                                fontSize: 12.sp, color: AdminColors.danger)),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AdminColors.divider),
              Expanded(
                child: controller.cartItems.isEmpty
                    ? AdminEmptyState(
                        icon: Icons.shopping_cart_outlined,
                        title: 'Nothing rung up',
                        message: 'Tap a product to start the sale.',
                      )
                    : ListView(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        children: _lines(context),
                      ),
              ),
              const Divider(height: 1, color: AdminColors.divider),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    _totals(),
                    SizedBox(height: 14.h),
                    _actions(context),
                    SizedBox(height: 10.h),
                    AdminButton(
                      label: 'Charge ${adminMoney(controller.total)}',
                      icon: Icons.point_of_sale_rounded,
                      isLoading: controller.isBusy.value,
                      onPressed: controller.cartItems.isEmpty ? null : onCheckout,
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  // ── Pieces ────────────────────────────────────────────────

  List<Widget> _lines(BuildContext context) {
    return [
      for (final item in controller.cartItems)
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      adminString(item['name'], 'Unnamed'),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AdminColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${adminMoney(adminDouble(item['unitPrice']))} each',
                      style: TextStyle(fontSize: 11.sp, color: AdminColors.textMuted),
                    ),
                  ],
                ),
              ),
              _stepper(item),
              SizedBox(width: 10.w),
              SizedBox(
                width: 74.w,
                child: Text(
                  adminMoney(adminDouble(item['lineTotal'])),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: AdminColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
    ];
  }

  Widget _stepper(Map<String, dynamic> item) {
    final id = adminString(item['_id']);
    final quantity = adminInt(item['quantity']);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _stepButton(
          Icons.remove_rounded,
          controller.isBusy.value
              ? null
              // Zero removes the line, which is what the backend does too.
              : () => controller.setQuantity(id, quantity - 1),
        ),
        SizedBox(width: 10.w),
        Text(
          '$quantity',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: AdminColors.textPrimary,
          ),
        ),
        SizedBox(width: 10.w),
        _stepButton(
          Icons.add_rounded,
          controller.isBusy.value
              ? null
              : () => controller.setQuantity(id, quantity + 1),
        ),
      ],
    );
  }

  Widget _stepButton(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7.r),
      child: Container(
        width: 26.w,
        height: 26.w,
        decoration: BoxDecoration(
          color: onTap == null
              ? AdminColors.divider
              : AdminColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(7.r),
        ),
        child: Icon(icon,
            size: 15.sp,
            color: onTap == null ? AdminColors.textMuted : AdminColors.primary),
      ),
    );
  }

  Widget _totals() {
    final totals = controller.totals;
    num read(String key) => totals[key] is num ? totals[key] as num : 0;

    return Column(
      children: [
        _totalRow('Subtotal', adminMoney(read('subtotal'))),
        if (read('discount') > 0)
          _totalRow('Discount', '− ${adminMoney(read('discount'))}',
              color: AdminColors.success),
        if (read('tax') > 0) _totalRow('Tax', adminMoney(read('tax'))),
        const Divider(height: 18, color: AdminColors.divider),
        Row(
          children: [
            Text(
              'Total',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: AdminColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              adminMoney(read('total')),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AdminColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _totalRow(String label, String value, {Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(fontSize: 12.5.sp, color: AdminColors.textSecondary)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w700,
              color: color ?? AdminColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: controller.cartItems.isEmpty ? null : () => _askDiscount(),
            icon: Icon(Icons.percent_rounded, size: 15.sp, color: AdminColors.primary),
            label: Text('Discount',
                style: TextStyle(fontSize: 12.sp, color: AdminColors.primary)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AdminColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _askCustomer(),
            icon: Icon(Icons.person_add_alt_rounded,
                size: 15.sp, color: AdminColors.primary),
            label: Text(
              controller.customerName.value.isEmpty
                  ? 'Customer'
                  : controller.customerName.value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.sp, color: AdminColors.primary),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AdminColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmClear() async {
    final confirmed = await adminConfirm(
      title: 'Clear the sale?',
      message: 'Every line, the discount and the customer are removed.',
      confirmLabel: 'Clear',
    );
    if (confirmed) await controller.clearCart();
  }

  void _askDiscount() {
    final amountController =
        TextEditingController(text: controller.discount.value.toString());
    final type = controller.discountType.value.obs;

    adminSheet(
      title: 'Discount',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(() => AdminFilterChips(
                options: const [
                  AdminFilterOption('fixed', 'Amount (D)'),
                  AdminFilterOption('percentage', 'Percent (%)'),
                ],
                selected: type.value,
                onSelected: (value) => type.value = value,
              )),
          SizedBox(height: 14.h),
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
            style: TextStyle(fontSize: 15.sp, color: AdminColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Discount',
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
            label: 'Apply',
            onPressed: () async {
              final amount = double.tryParse(amountController.text.trim()) ?? 0;
              if (amount < 0) {
                return adminToast('Check the discount',
                    'A discount cannot be negative.', isError: true);
              }
              if (type.value == 'percentage' && amount > 100) {
                return adminToast('Check the discount',
                    'A percentage discount cannot exceed 100.', isError: true);
              }
              final ok = await controller.applyDiscount(amount, type.value);
              if (ok) Get.back();
            },
          ),
        ],
      ),
    ).whenComplete(amountController.dispose);
  }

  void _askCustomer() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    adminSheet(
      title: 'Attach a customer',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'A walk-in just needs a name — no account is created for them. '
            'Search below to attach an existing VIPs customer instead.',
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.45,
              color: AdminColors.textSecondary,
            ),
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: nameController,
            style: TextStyle(fontSize: 14.sp, color: AdminColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Name',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AdminColors.border),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            style: TextStyle(fontSize: 14.sp, color: AdminColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Phone (optional)',
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
            label: 'Attach',
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                return adminToast('Name required',
                    'Enter a name for the customer.', isError: true);
              }
              final ok = await controller.attachCustomer(
                name: name,
                phone: phoneController.text.trim(),
              );
              if (ok) Get.back();
            },
          ),
        ],
      ),
    ).whenComplete(() {
      nameController.dispose();
      phoneController.dispose();
    });
  }
}
