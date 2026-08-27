import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/merchant_catalog_controller.dart';
import 'widgets/uploads_banner.dart';
import 'widgets/tags_input.dart';
import 'widgets/form_widgets.dart';

class CreateCouponView extends GetView<MerchantCatalogController> {
  const CreateCouponView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Create Coupon',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
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

                    FormWidgets.buildTextField(
                      'Coupon Code',
                      hint: 'e.g. SUMMER25',
                      controller: controller.couponCodeCtrl,
                    ),
                    SizedBox(height: 16.h),

                    // Coupon.type is a real enum on the backend
                    // (percentage / fixed / shipping / voucher). It used to be
                    // a decorative "Discount info: Percent" box, so every
                    // coupon was created as a percentage regardless.
                    Obx(
                      () => FormWidgets.buildDropdown(
                        'Discount type',
                        MerchantCatalogController
                            .couponTypeLabels[controller.couponType.value]!,
                        items: MerchantCatalogController.couponTypes
                            .map((t) =>
                                MerchantCatalogController.couponTypeLabels[t]!)
                            .toList(),
                        onChanged: (label) {
                          final code = MerchantCatalogController
                              .couponTypeLabels.entries
                              .firstWhere((e) => e.value == label)
                              .key;
                          controller.couponType.value = code;
                        },
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // The discount value had NO input at all — the controller
                    // held a hardcoded 25, so every coupon in the system was
                    // 25% off.
                    Obx(() {
                      if (controller.couponType.value == 'shipping') {
                        return Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            'Free-shipping coupons waive the delivery fee, so they '
                            'do not take a discount value.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF059669),
                            ),
                          ),
                        );
                      }
                      return FormWidgets.buildTextField(
                        controller.couponType.value == 'fixed'
                            ? 'Discount amount (D)'
                            : 'Discount percentage (%)',
                        hint: controller.couponType.value == 'fixed' ? '10' : '25',
                        controller: controller.couponDiscountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      );
                    }),
                    SizedBox(height: 16.h),

                    // Real Coupon.expiryDate. The old "Start Date — End Date"
                    // pair was two inert boxes; the backend has no start date
                    // at all, only an expiry, so one real picker replaces them.
                    Obx(
                      () => FormWidgets.buildDatePicker(
                        'Expires on',
                        value: controller.couponEndDate.value,
                        firstDate: DateTime.now(),
                        onPicked: (d) => controller.couponEndDate.value = d,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Leave empty to expire 30 days from today.',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: FormWidgets.buildTextField(
                            'Min order (D)',
                            hint: 'None',
                            controller: controller.couponMinOrderCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: FormWidgets.buildTextField(
                            'Max discount (D)',
                            hint: 'No cap',
                            controller: controller.couponMaxDiscountCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Real Coupon.maxUsage — the old "Limit for same user"
                    // box showed a fixed '0000' and set nothing.
                    FormWidgets.buildTextField(
                      'Total redemptions allowed',
                      hint: 'Unlimited',
                      controller: controller.couponMaxUsageCtrl,
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
                      hint: 'Shown to customers with the coupon',
                      maxLines: 3,
                      controller: controller.couponDescriptionCtrl,
                    ),

                    SizedBox(height: 32.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Publish',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF374151),
                          ),
                        ),
                        Obx(() => Switch(
                          value: controller.isPublishedCoupon.value,
                          onChanged: (val) => controller.isPublishedCoupon.value = val,
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
                      : controller.createCouponFromForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    controller.isLoading.value ? 'Publishing…' : 'Publish Coupon',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
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
}
