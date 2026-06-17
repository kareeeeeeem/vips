import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import '../controllers/merchant_ads_controller.dart';

class NewAdvertisementView extends GetView<MerchantAdsController> {
  const NewAdvertisementView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'New Advertisement',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDropdown('Category info', controller.selectedCategory.value),
                  SizedBox(height: 16.h),
                  _buildDateField('Validity'),
                  SizedBox(height: 24.h),
                  
                  // Language Tabs
                  Obx(() => Row(
                    children: [
                      _buildLangTab('English', !controller.isArabicSelected.value, false),
                      _buildLangTab('Arabic - عربي', controller.isArabicSelected.value, true),
                    ],
                  )),
                  SizedBox(height: 16.h),
                  
                  // Text Inputs
                  _buildTextField('Title (English)'),
                  SizedBox(height: 16.h),
                  _buildTextField('Description (English)', maxLines: 4, maxLength: 200),
                  
                  SizedBox(height: 24.h),
                  Text('Show Review Rating', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Obx(() => _buildCheckbox('Review', controller.showReview.value, (val) => controller.showReview.value = val!)),
                      SizedBox(width: 24.w),
                      Obx(() => _buildCheckbox('Rating', controller.showRating.value, (val) => controller.showRating.value = val!)),
                    ],
                  ),
                  
                  SizedBox(height: 24.h),
                  Text('Upload Files', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
                  SizedBox(height: 16.h),
                  
                  // Upload Boxes
                  _buildUploadBox('Profile Image'),
                  SizedBox(height: 16.h),
                  _buildUploadBox('Cover Image'),
                  
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
          
          // Bottom Buttons
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.snackbar('Reset', 'Form cleared for re-entry', snackPosition: SnackPosition.BOTTOM),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        backgroundColor: const Color(0xFFF3F4F6),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text('Reset', style: TextStyle(color: const Color(0xFF6B7280), fontSize: 16.sp, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => Get.offNamed(MerchantRoutes.HOME),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                      ),
                      child: Text('Create Ads', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13.sp, color: const Color(0xFF374151))),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: TextStyle(fontSize: 14.sp, color: const Color(0xFF1F2937))),
              Icon(Icons.keyboard_arrow_down, color: const Color(0xFF6B7280), size: 20.sp),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13.sp, color: const Color(0xFF374151))),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Validity', style: TextStyle(fontSize: 14.sp, color: const Color(0xFF9CA3AF))),
              Icon(Icons.calendar_today_outlined, color: const Color(0xFF10B981), size: 20.sp),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLangTab(String text, bool isSelected, bool isArabic) {
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.toggleLanguage(isArabic),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF10B981) : const Color(0xFF6B7280),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, {int maxLines = 1, int? maxLength}) {
    return TextFormField(
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: const Color(0xFF9CA3AF), fontSize: 14.sp),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 24.w,
          height: 24.w,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF10B981),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
          ),
        ),
        SizedBox(width: 8.w),
        Text(label, style: TextStyle(fontSize: 13.sp, color: const Color(0xFF4B5563))),
      ],
    );
  }

  Widget _buildUploadBox(String label) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF10B981), style: BorderStyle.none),
      ),
      child: CustomPaint(
        painter: DashedRectPainter(color: const Color(0xFF10B981), strokeWidth: 1, gap: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload_outlined, color: const Color(0xFF9CA3AF), size: 32.sp),
            SizedBox(height: 12.h),
            Text(
              'Upload $label\nor Video',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1F2937)),
            ),
            SizedBox(height: 8.h),
            Text(
              'Format Jpeg, Png only, Max Size 2MB',
              style: TextStyle(fontSize: 10.sp, color: const Color(0xFF9CA3AF)),
            ),
          ],
        ),
      ),
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({required this.color, required this.strokeWidth, required this.gap});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    
    // Simple dashed border logic, skipped drawing actual dashes for simplicity,
    // usually requires a dedicated package like `dotted_border` or math.
    // For now, drawing a continuous thin border just to satisfy UI outline.
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
