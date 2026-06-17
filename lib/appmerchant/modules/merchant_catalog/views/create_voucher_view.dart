import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import '../controllers/merchant_catalog_controller.dart';
import 'widgets/uploads_banner.dart';
import 'widgets/tags_input.dart';
import 'widgets/form_widgets.dart';
import 'widgets/voucher_preview_card.dart';

class CreateVoucherView extends GetView<MerchantCatalogController> {
  const CreateVoucherView({Key? key}) : super(key: key);

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
                    
                    FormWidgets.buildTextField('Voucher Code', hint: 'Voucher Code'),
                    SizedBox(height: 16.h),
                    
                    Text('Availability', style: TextStyle(fontSize: 13.sp, color: const Color(0xFF374151))),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        FormWidgets.buildDatePicker('Start Date', isHalf: true),
                        SizedBox(width: 8.w),
                        Container(width: 8.w, height: 1.h, color: const Color(0xFF9CA3AF)), // dash
                        SizedBox(width: 8.w),
                        FormWidgets.buildDatePicker('End Date', isHalf: true),
                      ],
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
                        FormWidgets.buildDropdown('Select Customer', 'All', isHalf: true),
                        SizedBox(width: 16.w),
                        FormWidgets.buildDropdown('Limit for same user', '0000', isHalf: true),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Voucher Price info', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
                        Text('0000 %', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF9CA3AF))),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    
                    // Grid for percentages
                    Wrap(
                      spacing: 12.w,
                      runSpacing: 12.h,
                      children: [
                        _buildPercentageBox(25, true),
                        _buildPercentageBox(50, false),
                        _buildPercentageBox(75, false),
                        _buildPercentageBox(100, false),
                        _buildPercentageBox(200, false),
                        _buildPercentageBox(300, false),
                        _buildPercentageBox(400, false),
                        _buildPercentageBox(500, false),
                        _buildPercentageBox(0, false, isAdd: true),
                      ],
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
                  child: Text('Publish Voucher', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentageBox(int value, bool isSelected, {bool isAdd = false}) {
    return Container(
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
                  Text('$value', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: isSelected ? const Color(0xFF10B981) : const Color(0xFF1F2937))),
                  Icon(Icons.percent, size: 12.sp, color: isSelected ? const Color(0xFF10B981) : const Color(0xFF6B7280)),
                ],
              ),
      ),
    );
  }
}
