import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/merchant_ads_controller.dart';

class NewAdvertisementView extends GetView<MerchantAdsController> {
  const NewAdvertisementView({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = ['Auto Promotion', 'Banner', 'Sponsored', 'Flash Sale'];

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
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
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
                  // ── Category Dropdown ───────────────────────
                  _label('Category'),
                  SizedBox(height: 6.h),
                  Obx(() => DropdownButtonFormField<String>(
                    key: ValueKey(controller.selectedCategory.value),
                    initialValue: controller.selectedCategory.value,
                    decoration: _inputDeco(),
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => controller.selectedCategory.value = v!,
                  )),
                  SizedBox(height: 16.h),

                  // ── Ad Image ────────────────────────────────
                  _label('Ad Image (optional)'),
                  SizedBox(height: 6.h),
                  Obx(() {
                    final url = controller.uploadedImageUrl.value;
                    final uploading = controller.isUploadingImage.value;
                    return GestureDetector(
                      onTap: uploading ? null : controller.pickAndUploadAdImage,
                      child: Container(
                        height: 140.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          image: url.isNotEmpty
                              ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
                              : null,
                        ),
                        child: uploading
                            ? const Center(child: CircularProgressIndicator())
                            : url.isEmpty
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo_outlined, size: 28.sp, color: const Color(0xFF9CA3AF)),
                                      SizedBox(height: 6.h),
                                      Text('Tap to add an image', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF9CA3AF))),
                                    ],
                                  )
                                : Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: EdgeInsets.all(6.w),
                                      child: CircleAvatar(
                                        radius: 14,
                                        backgroundColor: Colors.black54,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(Icons.close, size: 16, color: Colors.white),
                                          onPressed: () => controller.uploadedImageUrl.value = '',
                                        ),
                                      ),
                                    ),
                                  ),
                      ),
                    );
                  }),
                  SizedBox(height: 16.h),

                  // ── Title ───────────────────────────────────
                  _label('Title'),
                  SizedBox(height: 6.h),
                  TextFormField(
                    controller: controller.titleController,
                    decoration: _inputDeco(hint: 'Enter ad title'),
                  ),
                  SizedBox(height: 16.h),

                  // ── Description ─────────────────────────────
                  _label('Description'),
                  SizedBox(height: 6.h),
                  TextFormField(
                    controller: controller.descriptionController,
                    maxLines: 4,
                    maxLength: 200,
                    decoration: _inputDeco(hint: 'Describe your ad campaign'),
                  ),
                  SizedBox(height: 16.h),

                  // ── Budget ──────────────────────────────────
                  _label('Budget (D)'),
                  SizedBox(height: 6.h),
                  TextFormField(
                    controller: controller.budgetController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: _inputDeco(hint: '0.00'),
                  ),
                  SizedBox(height: 16.h),

                  // ── Date Range ──────────────────────────────
                  Row(children: [
                    Expanded(child: _buildDateTile('Start Date', isStart: true, context: context)),
                    SizedBox(width: 12.w),
                    Expanded(child: _buildDateTile('End Date', isStart: false, context: context)),
                  ]),
                  SizedBox(height: 24.h),

                  // ── Language Tabs ───────────────────────────
                  _label('Language'),
                  SizedBox(height: 8.h),
                  Obx(() => Row(children: [
                    _buildLangTab('English', !controller.isArabicSelected.value, false),
                    _buildLangTab('Arabic - عربي', controller.isArabicSelected.value, true),
                  ])),
                  SizedBox(height: 24.h),

                  // ── Review/Rating checkboxes ─────────────────
                  _label('Show in Ad'),
                  SizedBox(height: 8.h),
                  Row(children: [
                    Obx(() => _buildCheckbox('Review', controller.showReview.value,
                        (v) => controller.showReview.value = v!)),
                    SizedBox(width: 24.w),
                    Obx(() => _buildCheckbox('Rating', controller.showRating.value,
                        (v) => controller.showRating.value = v!)),
                  ]),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),

          // ── Bottom Buttons ───────────────────────────────
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.resetForm,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      backgroundColor: const Color(0xFFF3F4F6),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text('Reset',
                        style: TextStyle(color: const Color(0xFF6B7280), fontSize: 16.sp, fontWeight: FontWeight.w700)),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  flex: 2,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isCreating.value
                        ? null
                        : () => controller.submitAdForm(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      disabledBackgroundColor: const Color(0xFF10B981).withValues(alpha: 0.5),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      elevation: 0,
                    ),
                    child: controller.isCreating.value
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('Create Ad',
                            style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700)),
                  )),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF374151)));

  InputDecoration _inputDeco({String? hint}) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: const Color(0xFF9CA3AF), fontSize: 14.sp),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Color(0xFF10B981))),
      );

  Widget _buildDateTile(String label, {required bool isStart, required BuildContext context}) {
    return Obx(() {
      final date = isStart ? controller.startDate.value : controller.endDate.value;
      final display = date == null
          ? 'Select'
          : '${date.day}/${date.month}/${date.year}';
      return GestureDetector(
        onTap: () => isStart ? controller.pickStartDate(context) : controller.pickEndDate(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(label),
            SizedBox(height: 6.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(display,
                      style: TextStyle(
                          fontSize: 14.sp,
                          color: date == null ? const Color(0xFF9CA3AF) : const Color(0xFF1F2937))),
                  Icon(Icons.calendar_today_outlined, color: const Color(0xFF10B981), size: 18.sp),
                ],
              ),
            ),
          ],
        ),
      );
    });
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
            child: Text(text,
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? const Color(0xFF10B981) : const Color(0xFF6B7280))),
          ),
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
}
