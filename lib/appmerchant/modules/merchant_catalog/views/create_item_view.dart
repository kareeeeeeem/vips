import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import '../controllers/merchant_catalog_controller.dart';
import 'widgets/uploads_banner.dart';
import 'widgets/shipping_options.dart';
import 'widgets/form_widgets.dart';
import 'widgets/product_preview_card.dart';

class CreateItemView extends GetView<MerchantCatalogController> {
  const CreateItemView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Create Item', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937))),
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
                    
                    FormWidgets.buildTextField('Name*'),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(child: FormWidgets.buildDropdown('Type*', 'Select')),
                        SizedBox(width: 16.w),
                        Expanded(child: FormWidgets.buildTextField('Code*')),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    FormWidgets.buildTextField('Bar Code Symbology*', suffixIcon: const Icon(Icons.qr_code_scanner, color: Color(0xFF10B981))),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        FormWidgets.buildDropdown('Brand*', 'Select', isHalf: true),
                        SizedBox(width: 16.w),
                        FormWidgets.buildDropdown('Categories*', 'Select', isHalf: true),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        FormWidgets.buildDropdown('Product Unit*', 'Select', isHalf: true),
                        SizedBox(width: 16.w),
                        FormWidgets.buildDropdown('Product Code', 'Select', isHalf: true),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(child: FormWidgets.buildTextField('Selling Price*')),
                        SizedBox(width: 16.w),
                        Expanded(child: FormWidgets.buildTextField('Alert Quantity')),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    
                    Text('Product Image*', style: TextStyle(fontSize: 13.sp, color: const Color(0xFF374151))),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => Get.snackbar('Upload', 'File picker will be connected in next step', snackPosition: SnackPosition.BOTTOM),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF3F4F6),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                          ),
                          child: Text('Choose File', style: TextStyle(color: const Color(0xFF6B7280), fontSize: 12.sp)),
                        ),
                        SizedBox(width: 12.w),
                        Text('No File chosen', style: TextStyle(color: const Color(0xFF9CA3AF), fontSize: 12.sp)),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    
                    Row(
                      children: [
                        FormWidgets.buildDropdown('Tax Method', 'Select', isHalf: true),
                        SizedBox(width: 16.w),
                        FormWidgets.buildTextField('VAT', hint: '10', suffixIcon: const Icon(Icons.percent, size: 16, color: Color(0xFF9CA3AF))),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    
                    _buildCheckboxList(controller),
                    
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
                        Text('Publish', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    elevation: 0,
                  ),
                  child: Text('Publish Item', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxList(MerchantCatalogController controller) {
    return Column(
      children: [
        _buildCheckboxRow('Feature Product (Will Be displayed in POS)', controller.isFeatureProduct),
        SizedBox(height: 12.h),
        _buildCheckboxRow('This Product has multi variants', controller.hasMultiVariants),
        SizedBox(height: 12.h),
        _buildCheckboxRow('Add Promotional Price', controller.hasPromotionalPrice),
      ],
    );
  }

  Widget _buildCheckboxRow(String label, RxBool rxBool) {
    return Row(
      children: [
        Obx(() => SizedBox(
          width: 20.w,
          height: 20.w,
          child: Checkbox(
            value: rxBool.value,
            onChanged: (val) => rxBool.value = val!,
            activeColor: const Color(0xFF10B981),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
          ),
        )),
        SizedBox(width: 8.w),
        Expanded(child: Text(label, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF4B5563)))),
      ],
    );
  }
}
