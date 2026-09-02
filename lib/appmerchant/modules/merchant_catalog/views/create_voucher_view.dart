import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/merchant_catalog_controller.dart';
import 'widgets/uploads_banner.dart';
import 'widgets/tags_input.dart';
import 'widgets/form_widgets.dart';

class CreateVoucherView extends GetView<MerchantCatalogController> {
  const CreateVoucherView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Create Voucher', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937))),
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

                    FormWidgets.buildTextField('Voucher Code', hint: 'e.g. VIP50', controller: controller.voucherCodeCtrl),
                    SizedBox(height: 16.h),

                    // Real Coupon.expiryDate. The old "Start Date — End Date"
                    // pair were two inert boxes and the backend stores no
                    // start date, so one working picker replaces both.
                    Obx(
                      () => FormWidgets.buildDatePicker(
                        'Expires on',
                        value: controller.voucherEndDate.value,
                        firstDate: DateTime.now(),
                        onPicked: (d) => controller.voucherEndDate.value = d,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Leave empty to expire 30 days from today.',
                      style: TextStyle(fontSize: 11.sp, color: const Color(0xFF9CA3AF)),
                    ),
                    SizedBox(height: 16.h),

                    // Real Coupon.maxUsage. The old "Select Customer / Limit
                    // for same user" pair set nothing at all.
                    FormWidgets.buildTextField(
                      'Total redemptions allowed',
                      hint: 'Unlimited',
                      controller: controller.voucherMaxUsageCtrl,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16.h),

                    TagsInput(
                      tags: controller.tags,
                      controller: controller.tagController,
                      onAdd: controller.addTag,
                      onRemove: controller.removeTag,
                    ),
                    SizedBox(height: 16.h),

                    FormWidgets.buildTextField(
                      'Description',
                      hint: 'Shown to customers with the voucher',
                      maxLines: 3,
                      controller: controller.voucherDescriptionCtrl,
                    ),
                    SizedBox(height: 24.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Voucher value', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
                        Obx(() => Text(
                            'D ${controller.voucherValueTnd.value.toStringAsFixed(0)}',
                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)))),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // §4.2's third offer is a voucher worth a stated number of
                    // dinars, not a percentage off. These are the platform's
                    // suggestions; long-press removes one the merchant will
                    // not offer, and Add puts a new one in the list for good.
                    Obx(
                      () => Wrap(
                        spacing: 12.w,
                        runSpacing: 12.h,
                        children: [
                          for (final value in controller.voucherValueOptions)
                            _buildValueBox(
                              value,
                              controller.voucherValueTnd.value == value,
                              onTap: () =>
                                  controller.voucherValueTnd.value = value.toDouble(),
                              onLongPress: () => _confirmHideValue(context, value),
                            ),
                          _buildValueBox(
                            0,
                            false,
                            isAdd: true,
                            onTap: () => _promptCustomValue(context),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Obx(() => Text(
                          controller.voucherValueTnd.value <= 0
                              ? 'Pick what the voucher is worth.'
                              : 'Customers pay '
                                  '${controller.pointsForVoucherValue(controller.voucherValueTnd.value)} points for it. '
                                  'Hold a value to take it off your list.',
                          style: TextStyle(
                              fontSize: 11.sp, color: const Color(0xFF6B7280)),
                        )),

                    SizedBox(height: 32.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Publish', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
                        Obx(() => Switch(
                          value: controller.isPublishedVoucher.value,
                          onChanged: (val) => controller.isPublishedVoucher.value = val,
                          activeThumbColor: const Color(0xFF10B981),
                        )),
                      ],
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(24.w),
              child: SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.createVoucherFromForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    elevation: 0,
                  ),
                  child: Text(
                    controller.isLoading.value ? 'Publishing…' : 'Publish Voucher',
                    style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700),
                  ),
                ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Adds a denomination the platform's suggestions do not cover.
  void _promptCustomValue(BuildContext context) {
    final input = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Add a voucher value'),
        content: TextField(
          controller: input,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            prefixText: 'D ',
            hintText: 'e.g. 75',
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final parsed = int.tryParse(input.text.trim());
              if (parsed == null || parsed <= 0) return;
              controller.setCustomVoucherValue(parsed);
              Get.back<void>();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    ).then((_) => input.dispose());
  }

  /// Takes a denomination off this merchant's list. Confirmed because the
  /// list is theirs and a stray long-press should not silently change it.
  void _confirmHideValue(BuildContext context, int value) {
    Get.dialog(
      AlertDialog(
        title: Text('Remove D $value?'),
        content: const Text(
          'It stops appearing when you create a voucher. You can add it back '
          'at any time.',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Keep it')),
          TextButton(
            onPressed: () {
              controller.hideVoucherValue(value);
              Get.back<void>();
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _buildValueBox(
    int value,
    bool isSelected, {
    bool isAdd = false,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
      width: 60.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFECFDF5) : Colors.white,
        border: Border.all(
          color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
          style: isAdd ? BorderStyle.none : BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(
        child: isAdd
            ? Container(
                width: 60.w,
                height: 40.h,
                decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(8.r)),
                child: Center(child: Text('Add', style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w600))),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('D', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: isSelected ? const Color(0xFF10B981) : const Color(0xFF6B7280))),
                  SizedBox(width: 2.w),
                  Text('$value', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: isSelected ? const Color(0xFF10B981) : const Color(0xFF1F2937))),
                ],
              ),
      ),
      ),
    );
  }
}
