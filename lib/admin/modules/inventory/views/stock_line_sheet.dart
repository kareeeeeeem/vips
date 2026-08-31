import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/admin_theme.dart';
import '../../../core/widgets/admin_scaffold.dart';
import '../../../core/widgets/admin_widgets.dart';
import '../../../services/admin_api_service.dart';
import '../controllers/inventory_controller.dart';

/// Opens a new stock line.
///
/// A line is one item in one location, so the same item in two store rooms is
/// two lines — that is what makes a transfer between them a real movement
/// with two ledger entries rather than a relabelling.
Future<void> showStockLineSheet({required AdminInventoryController controller}) {
  final name = TextEditingController();
  final category = TextEditingController(text: 'General');
  final location = TextEditingController(text: 'Main');
  final currentStock = TextEditingController();
  final lowStockThreshold = TextEditingController();
  final unitPrice = TextEditingController();

  final merchantId = ''.obs;
  final error = RxnString();
  final isSaving = false.obs;

  controller.loadMerchants();

  double? numberOf(TextEditingController c) {
    final text = c.text.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text.replaceAll(',', '.'));
  }

  Future<void> submit() async {
    if (isSaving.value) return;
    error.value = null;

    if (merchantId.value.isEmpty) {
      error.value = 'Choose the store this stock belongs to.';
      return;
    }
    if (name.text.trim().isEmpty) {
      error.value = 'An item name is required.';
      return;
    }

    isSaving.value = true;
    try {
      final ok = await controller.createItem({
        'merchantId': merchantId.value,
        'name': name.text.trim(),
        'category': category.text.trim().isEmpty ? 'General' : category.text.trim(),
        'location': location.text.trim().isEmpty ? 'Main' : location.text.trim(),
        'currentStock': numberOf(currentStock) ?? 0,
        'lowStockThreshold': numberOf(lowStockThreshold) ?? 0,
        'unitPrice': numberOf(unitPrice) ?? 0,
      });
      if (ok) Get.back();
    } finally {
      isSaving.value = false;
    }
  }

  return adminSheet(
    title: 'Open a stock line',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: Text(
            'The opening quantity is written to the stock ledger, so this line '
            'starts with a movement like any other change.',
            style: TextStyle(
              fontSize: 11.5.sp,
              height: 1.35,
              color: AdminColors.textMuted,
            ),
          ),
        ),
        Obx(() => _merchantPicker(controller, merchantId)),
        SizedBox(height: 14.h),
        _field(name, 'Item name'),
        Row(
          children: [
            Expanded(child: _field(category, 'Category')),
            SizedBox(width: 10.w),
            Expanded(
              child: _field(location, 'Location',
                  helper: 'The store room this line sits in'),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(child: _field(currentStock, 'Opening quantity', numeric: true)),
            SizedBox(width: 10.w),
            Expanded(
              child: _field(lowStockThreshold, 'Alert at', numeric: true,
                  helper: '0 for no alert'),
            ),
          ],
        ),
        _field(unitPrice, 'Unit cost', numeric: true,
            helper: 'What the stock is valued at'),
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
              label: 'Open stock line',
              isLoading: isSaving.value || controller.isMutating.value,
              onPressed: submit,
            )),
      ],
    ),
  );
}

Widget _merchantPicker(AdminInventoryController controller, RxString selected) {
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
      'No active store to open a stock line for.',
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
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
          : null,
      style: TextStyle(fontSize: 13.5.sp),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13.sp),
        helperText: helper,
        helperMaxLines: 2,
        helperStyle: TextStyle(fontSize: 10.5.sp, color: AdminColors.textMuted),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      ),
    ),
  );
}
