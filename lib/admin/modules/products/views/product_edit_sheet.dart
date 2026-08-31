import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/products_controller.dart';

/// Add or edit one product.
///
/// [product] null means "add". Editing sends only the fields that actually
/// changed: the backend applies what it is given, so posting the whole form
/// would rewrite a field nobody touched — and would silently clear a discount
/// somebody else set while this sheet was open.
Future<void> showProductEditSheet({
  required AdminProductsController controller,
  Map<String, dynamic>? product,
}) {
  final isEdit = product != null;

  final name = TextEditingController(text: adminString(product?['name']));
  final category = TextEditingController(text: adminString(product?['category']));
  final code = TextEditingController(text: adminString(product?['code']));
  final price = TextEditingController(
      text: product == null ? '' : adminDouble(product['price']).toString());
  final costPrice = TextEditingController(
      text: product == null ? '' : adminDouble(product['costPrice']).toString());
  final discountPrice = TextEditingController(
      text: (product == null || adminDouble(product['discountPrice']) <= 0)
          ? ''
          : adminDouble(product['discountPrice']).toString());
  final stock = TextEditingController(
      text: product == null ? '' : adminInt(product['stock']).toString());
  final alertQty = TextEditingController(
      text: product == null ? '' : adminInt(product['alertQty']).toString());

  final merchantId = RxString(adminString(product?['merchantId']));
  final error = RxnString();
  final isSaving = false.obs;

  double? numberOf(TextEditingController c) {
    final text = c.text.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text.replaceAll(',', '.'));
  }

  Future<void> submit() async {
    if (isSaving.value) return;
    error.value = null;

    final listPrice = numberOf(price);
    final discount = numberOf(discountPrice);

    if (name.text.trim().isEmpty) {
      error.value = 'A product name is required.';
      return;
    }
    if (category.text.trim().isEmpty) {
      error.value = 'A category is required.';
      return;
    }
    if (listPrice == null || listPrice < 0) {
      error.value = 'Enter a price of 0 or more.';
      return;
    }
    // Caught here as well as server-side: the till would charge a "discount"
    // above the list price as the selling price.
    if (discount != null && discount > listPrice) {
      error.value = 'The discount price cannot exceed the list price.';
      return;
    }
    if (!isEdit && merchantId.value.isEmpty) {
      error.value = 'Choose the store this product belongs to.';
      return;
    }

    isSaving.value = true;
    try {
      bool ok;
      if (isEdit) {
        // Only what changed.
        final changes = <String, dynamic>{};
        void diff(String key, dynamic current, dynamic next) {
          if (current != next) changes[key] = next;
        }

        diff('name', adminString(product['name']), name.text.trim());
        diff('category', adminString(product['category']), category.text.trim());
        diff('code', adminString(product['code']), code.text.trim());
        diff('price', adminDouble(product['price']), listPrice);
        diff('costPrice', adminDouble(product['costPrice']), numberOf(costPrice) ?? 0);
        diff('stock', adminInt(product['stock']), (numberOf(stock) ?? 0).round());
        diff('alertQty', adminInt(product['alertQty']), (numberOf(alertQty) ?? 0).round());

        // Clearing the field removes the discount, which needs an explicit
        // null rather than an omitted key.
        final currentDiscount = adminDouble(product['discountPrice']);
        final nextDiscount = discount ?? 0;
        if (currentDiscount != nextDiscount) {
          changes['discountPrice'] = nextDiscount > 0 ? nextDiscount : null;
        }

        if (changes.isEmpty) {
          error.value = 'Nothing has changed.';
          isSaving.value = false;
          return;
        }
        ok = await controller.updateProduct(adminString(product['_id']), changes);
      } else {
        ok = await controller.createProduct({
          'merchantId': merchantId.value,
          'name': name.text.trim(),
          'category': category.text.trim(),
          'code': code.text.trim(),
          'price': listPrice,
          'costPrice': numberOf(costPrice) ?? 0,
          'stock': (numberOf(stock) ?? 0).round(),
          'alertQty': (numberOf(alertQty) ?? 0).round(),
        });
      }
      if (ok) Get.back();
    } finally {
      isSaving.value = false;
    }
  }

  return adminSheet(
    title: isEdit ? adminString(product['name'], 'Edit product') : 'Add a product',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isEdit) ...[
          Obx(() => _merchantPicker(controller, merchantId)),
          SizedBox(height: 14.h),
        ] else
          Padding(
            padding: EdgeInsets.only(bottom: 14.h),
            child: Text(
              // Deliberately not editable: moving a product to another store
              // would carry its whole sales history across with it.
              'Sold by ${adminString(product['merchantName'], 'Unknown store')}. '
              'A product cannot be moved between stores.',
              style: TextStyle(
                fontSize: 11.5.sp,
                height: 1.35,
                color: AdminColors.textMuted,
              ),
            ),
          ),
        _field(name, 'Product name'),
        _field(category, 'Category'),
        _field(code, 'Code or barcode (optional)'),
        Row(
          children: [
            Expanded(child: _field(price, 'List price', numeric: true)),
            SizedBox(width: 10.w),
            Expanded(
              child: _field(discountPrice, 'Discount price', numeric: true,
                  helper: 'Leave empty for none'),
            ),
          ],
        ),
        _field(costPrice, 'Cost price', numeric: true,
            helper: 'What you pay for it. Profit and margin are only computed '
                'over products with this set.'),
        Row(
          children: [
            Expanded(child: _field(stock, 'Stock on hand', numeric: true)),
            SizedBox(width: 10.w),
            Expanded(
              child: _field(alertQty, 'Low-stock alert at', numeric: true,
                  helper: '0 for no alert'),
            ),
          ],
        ),
        Obx(() {
          if (error.value == null) return const SizedBox.shrink();
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Text(
              error.value!,
              style: TextStyle(fontSize: 12.sp, color: AdminColors.danger),
            ),
          );
        }),
        SizedBox(height: 4.h),
        Obx(() => AdminButton(
              label: isEdit ? 'Save changes' : 'Add product',
              isLoading: isSaving.value || controller.isMutating.value,
              onPressed: submit,
            )),
      ],
    ),
  );
}

Widget _merchantPicker(AdminProductsController controller, RxString selected) {
  if (controller.isLoadingMerchants.value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          SizedBox(
            width: 14.w,
            height: 14.w,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10.w),
          Text('Loading stores…',
              style: TextStyle(fontSize: 12.sp, color: AdminColors.textMuted)),
        ],
      ),
    );
  }
  if (controller.merchants.isEmpty) {
    return Text(
      'No active store to add a product to.',
      style: TextStyle(fontSize: 12.sp, color: AdminColors.danger),
    );
  }

  return DropdownButtonFormField<String>(
    initialValue: selected.value.isEmpty ? null : selected.value,
    isExpanded: true,
    decoration: InputDecoration(
      labelText: 'Store',
      labelStyle: TextStyle(fontSize: 13.sp),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
    ),
    items: [
      for (final merchant in controller.merchants)
        DropdownMenuItem(
          value: adminString(merchant['_id']),
          child: Text(
            adminString(merchant['storeName'],
                adminString(merchant['fullName'], 'Unnamed store')),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13.sp),
          ),
        ),
    ],
    onChanged: (value) => selected.value = value ?? '',
  );
}

Widget _field(
  TextEditingController controller,
  String label, {
  bool numeric = false,
  String? helper,
}) {
  return Padding(
    padding: EdgeInsets.only(bottom: 12.h),
    child: TextField(
      controller: controller,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      inputFormatters: numeric
          // Only digits and one separator reach the parser, so a stray letter
          // cannot turn a price into null and clear it on save.
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
          : null,
      style: TextStyle(fontSize: 13.5.sp),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13.sp),
        helperText: helper,
        helperMaxLines: 3,
        helperStyle: TextStyle(fontSize: 10.5.sp, color: AdminColors.textMuted),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      ),
    ),
  );
}
