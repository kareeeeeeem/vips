import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import '../controllers/merchant_catalog_controller.dart';
import 'widgets/uploads_banner.dart';
import 'widgets/tags_input.dart';
import 'widgets/shipping_options.dart';
import 'widgets/form_widgets.dart';
import 'widgets/product_preview_card.dart';

class CreateCouponView extends GetView<MerchantCatalogController> {
  const CreateCouponView({Key? key}) : super(key: key);

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
                      hint: 'Coupon Code',
                      maxLines: 3,
                    ),
                    SizedBox(height: 16.h),

                    Text(
                      'Availability',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF374151),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        FormWidgets.buildDatePicker('Start Date', isHalf: true),
                        SizedBox(width: 8.w),
                        Container(
                          width: 8.w,
                          height: 1.h,
                          color: const Color(0xFF9CA3AF),
                        ),
                        SizedBox(width: 8.w),
                        FormWidgets.buildDatePicker('End Date', isHalf: true),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    FormWidgets.buildDropdown(
                      'Custom Shape / Theme',
                      'Select Theme',
                    ),
                    SizedBox(height: 16.h),

                    TagsInput(
                      tags: controller.tags,
                      controller: controller.tagController,
                      onAdd: controller.addTag,
                      onRemove: controller.removeTag,
                    ),
                    SizedBox(height: 16.h),

                    Row(
                      children: [
                        FormWidgets.buildDropdown(
                          'Select Customer',
                          'All',
                          isHalf: true,
                        ),
                        SizedBox(width: 16.w),
                        FormWidgets.buildDropdown(
                          'Limit for same user',
                          '0000',
                          isHalf: true,
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    Row(
                      children: [
                        FormWidgets.buildDropdown(
                          'Discount info',
                          'Percent',
                          isHalf: true,
                        ),
                        SizedBox(width: 16.w),
                        FormWidgets.buildDropdown(
                          'Max Discount',
                          '0000',
                          isHalf: true,
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    _buildUploadBox('add photo', Icons.photo_outlined),
                    SizedBox(height: 16.h),

                    FormWidgets.buildTextField(
                      'Products Contents',
                      hint: 'Item Name',
                      maxLines: 3,
                    ),
                    SizedBox(height: 16.h),
                    FormWidgets.buildTextField('Item Price', maxLines: 3),
                    SizedBox(height: 16.h),
                    FormWidgets.buildDropdown('Category', 'Select'),
                    SizedBox(height: 24.h),

                    _buildUploadBox(
                      'add thumbnail Photo',
                      Icons.add_photo_alternate_outlined,
                    ),
                    SizedBox(height: 16.h),
                    FormWidgets.buildTextField(
                      'Description',
                      hint: 'Automatic description',
                      maxLines: 3,
                    ),
                    SizedBox(height: 24.h),

                    ShippingOptions(
                      isDelivery: controller.isDelivery,
                      isTakeaway: controller.isTakeaway,
                      isDineIn: controller.isDineIn,
                      selectedTime: controller.deliveryTime,
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
                        Switch(
                          value: true,
                          onChanged: (val) {},
                          activeColor: const Color(0xFF10B981),
                        ),
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
                child: ElevatedButton(
                  onPressed: () => Get.offNamed(MerchantRoutes.CATALOG),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Publish Coupon',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
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

  Widget _buildUploadBox(String label, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13.sp, color: const Color(0xFF374151)),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFF10B981),
              width: 1,
              style: BorderStyle.solid,
            ), // Should be dashed, keeping simple
          ),
          child: Center(
            child: Icon(icon, color: const Color(0xFF10B981), size: 28.sp),
          ),
        ),
      ],
    );
  }
}
