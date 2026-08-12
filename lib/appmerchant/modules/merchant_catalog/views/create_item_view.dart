import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import '../controllers/merchant_catalog_controller.dart';
import 'widgets/uploads_banner.dart';
import 'widgets/shipping_options.dart';

class CreateItemView extends GetView<MerchantCatalogController> {
  const CreateItemView({super.key});

  /// Pre-populate form when editing an existing item passed via Get.arguments.
  void _initEditMode() {
    final item = Get.arguments as Map<String, dynamic>?;
    if (item == null) return;
    controller.itemNameCtrl.text = item['name']?.toString() ?? '';
    controller.itemCodeCtrl.text = item['code']?.toString() ?? '';
    controller.itemPriceCtrl.text = (item['price'] ?? '').toString();
    controller.itemAlertQtyCtrl.text = (item['alertQty'] ?? '').toString();
    controller.itemVatCtrl.text = (item['vat'] ?? '').toString();
    controller.itemImageUrl.value = item['image']?.toString() ?? '';
    if (item['category'] != null) controller.selectedCategory.value = item['category'].toString();
    controller.isPublished.value = item['isActive'] as bool? ?? true;
    controller.isFeatureProduct.value = item['isFeature'] as bool? ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // Populate form when entering edit mode
    WidgetsBinding.instance.addPostFrameCallback((_) => _initEditMode());

    final editItem = Get.arguments as Map<String, dynamic>?;
    final editId = (editItem?['_id'] ?? editItem?['id'])?.toString();
    final isEditMode = editId != null && editId.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Item' : 'Create Item',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const UploadsBanner(),

                    // Name
                    _label('Name *'),
                    _textField(controller.itemNameCtrl, 'Enter product name'),
                    SizedBox(height: 16.h),

                    // Type + Code
                    Row(
                      children: [
                        Expanded(child: _dropdownObx('Type *', controller.selectedItemType,
                            ['Product', 'Service', 'Digital', 'Bundle'])),
                        SizedBox(width: 16.w),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Code *'),
                            _textField(controller.itemCodeCtrl, 'e.g. SKU-001'),
                          ],
                        )),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Category
                    _label('Category *'),
                    _dropdownObx('Select category', controller.selectedCategory,
                        ['General', 'Food', 'Electronics', 'Fashion', 'Beauty', 'Health', 'Services', 'Other']),
                    SizedBox(height: 16.h),

                    // Price + Alert Qty
                    Row(
                      children: [
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Selling Price *'),
                            _textField(controller.itemPriceCtrl, '0.00',
                                type: TextInputType.numberWithOptions(decimal: true)),
                          ],
                        )),
                        SizedBox(width: 16.w),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Alert Quantity'),
                            _textField(controller.itemAlertQtyCtrl, '5',
                                type: TextInputType.number),
                          ],
                        )),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Product Image
                    _label('Product Image'),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Obx(() => ElevatedButton(
                          onPressed: controller.isUploadingImage.value ? null : controller.pickAndUploadImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF3F4F6),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                          ),
                          child: controller.isUploadingImage.value
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text('Choose File',
                                  style: TextStyle(color: const Color(0xFF6B7280), fontSize: 12.sp)),
                        )),
                        SizedBox(width: 12.w),
                        Obx(() => Text(
                          controller.itemImageUrl.value.isNotEmpty ? 'Image selected' : 'No File chosen',
                          style: TextStyle(color: const Color(0xFF9CA3AF), fontSize: 12.sp),
                        )),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Tax
                    Row(
                      children: [
                        Expanded(child: _dropdownObx('Tax Method', controller.selectedTaxMethod,
                            ['Exclusive', 'Inclusive', 'None'])),
                        SizedBox(width: 16.w),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('VAT %'),
                            _textField(controller.itemVatCtrl, '0',
                                type: TextInputType.number,
                                suffix: const Icon(Icons.percent, size: 16, color: Color(0xFF9CA3AF))),
                          ],
                        )),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // Checkboxes
                    _buildCheckboxRow('Feature Product (Will be displayed in POS)', controller.isFeatureProduct),
                    SizedBox(height: 12.h),
                    _buildCheckboxRow('This Product has multi variants', controller.hasMultiVariants),
                    SizedBox(height: 12.h),
                    _buildCheckboxRow('Add Promotional Price', controller.hasPromotionalPrice),
                    SizedBox(height: 24.h),

                    ShippingOptions(
                      isDelivery: controller.isDelivery,
                      isTakeaway: controller.isTakeaway,
                      isDineIn:   controller.isDineIn,
                      selectedTime: controller.deliveryTime,
                    ),
                    SizedBox(height: 32.h),

                    // Publish toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Publish', style: TextStyle(
                            fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
                        Obx(() => Switch(
                          value: controller.isPublished.value,
                          onChanged: (val) => controller.isPublished.value = val,
                          activeThumbColor: const Color(0xFF10B981),
                        )),
                      ],
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),

            // Publish / Save Button
            Padding(
              padding: EdgeInsets.all(24.w),
              child: SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          if (isEditMode) {
                            final price = double.tryParse(controller.itemPriceCtrl.text.trim()) ?? 0.0;
                            if (controller.itemNameCtrl.text.trim().isEmpty || price <= 0) return;
                            await controller.updateItem(editId, {
                              'name': controller.itemNameCtrl.text.trim(),
                              'category': controller.selectedCategory.value == 'Select'
                                  ? 'General'
                                  : controller.selectedCategory.value,
                              'price': price,
                              'image': controller.itemImageUrl.value,
                              'isFeature': controller.isFeatureProduct.value,
                              'hasVariants': controller.hasMultiVariants.value,
                              'isActive': controller.isPublished.value,
                              'vat': double.tryParse(controller.itemVatCtrl.text.trim()) ?? 0.0,
                              'code': controller.itemCodeCtrl.text.trim(),
                              'taxMethod': controller.selectedTaxMethod.value,
                            });
                          } else {
                            await controller.createItemFromForm();
                          }
                          if (!controller.isLoading.value) {
                            Get.offNamed(MerchantRoutes.CATALOG);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    disabledBackgroundColor: const Color(0xFF10B981).withValues(alpha: 0.6),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(isEditMode ? 'Save Changes' : 'Publish Item',
                          style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700)),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: EdgeInsets.only(bottom: 6.h),
    child: Text(text, style: TextStyle(fontSize: 13.sp, color: const Color(0xFF374151), fontWeight: FontWeight.w500)),
  );

  Widget _textField(TextEditingController ctrl, String hint, {
    TextInputType type = TextInputType.text,
    Widget? suffix,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
        suffixIcon: suffix,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: Color(0xFF10B981))),
      ),
    );
  }

  Widget _dropdownObx(String hint, RxString selected, List<String> options) {
    return Obx(() => DropdownButtonFormField<String>(
      key: ValueKey(selected.value),
      initialValue: options.contains(selected.value) ? selected.value : null,
      hint: Text(hint, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: Color(0xFF10B981))),
      ),
      items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 13)))).toList(),
      onChanged: (v) => selected.value = v!,
    ));
  }

  Widget _buildCheckboxRow(String label, RxBool rxBool) {
    return Obx(() => Row(
      children: [
        SizedBox(
          width: 20.w, height: 20.w,
          child: Checkbox(
            value: rxBool.value,
            onChanged: (val) => rxBool.value = val!,
            activeColor: const Color(0xFF10B981),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(child: Text(label, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF4B5563)))),
      ],
    ));
  }
}
