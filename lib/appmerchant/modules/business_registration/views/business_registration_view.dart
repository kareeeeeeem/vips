import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import '../controllers/business_registration_controller.dart';
import 'widgets/expandable_section.dart';
import 'widgets/job_title_sheet.dart';
import 'widgets/category_sheet.dart';
import 'widgets/time_schedule_widget.dart';

class BusinessRegistrationView extends GetView<BusinessRegistrationController> {
  const BusinessRegistrationView({Key? key}) : super(key: key);

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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Business Registration',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF10B981)),
              ),
              child: Text(
                '31%',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF10B981),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGeneralInfoSection(context),
                  SizedBox(height: 24.h),
                  _buildAdditionalInfoSection(context),
                  _buildTimeInfoSection(context),
                  _buildLocationSection(context),
                  _buildSocialMediaSection(context),
                  _buildUploadIdentitySection(context),
                  
                  SizedBox(height: 24.h),
                  _buildLoyaltyTypeSection(),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
          // Save Button
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Save',
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
    );
  }

  Widget _buildGeneralInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'General Info',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E40AF),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Here you can setup your basic information',
          style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
        ),
        SizedBox(height: 16.h),

        // Image Picker Area
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildImageUploadBox('Logo/Profile'),
            _buildImageUploadBox('Cover'),
          ],
        ),
        SizedBox(height: 8.h),
        Center(
          child: Text(
            'JPG, JPEG, PNG Less Than 2MB (Ratio 1:1)',
            style: TextStyle(fontSize: 10.sp, color: const Color(0xFF9CA3AF)),
          ),
        ),
        SizedBox(height: 24.h),

        _buildTextField('Full name', 'Auto Full name Latina'),
        SizedBox(height: 16.h),
        _buildTextField('Full name', 'Auto Full name عربي', isArabic: true),
        SizedBox(height: 16.h),
        
        // Job Title Dropdown
        Text('Job Title', style: TextStyle(fontSize: 13.sp, color: const Color(0xFF374151))),
        SizedBox(height: 6.h),
        GestureDetector(
          onTap: () {
            Get.bottomSheet(const JobTitleSheet());
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                  controller.jobTitle.value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: controller.jobTitle.value == 'Choose' ? const Color(0xFF9CA3AF) : const Color(0xFF1F2937),
                  ),
                )),
                Icon(Icons.keyboard_arrow_down, color: const Color(0xFF6B7280), size: 20.sp),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.h),

        _buildTextField('Email address', 'Email address'),
        SizedBox(height: 16.h),

        // Phone Number
        Text('Phone number', style: TextStyle(fontSize: 13.sp, color: const Color(0xFF374151))),
        SizedBox(height: 6.h),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2.r),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEF4444), Colors.white, Color(0xFF111827)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Obx(() => Text(controller.countryCode.value, style: TextStyle(fontSize: 14.sp))),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '0123456789',
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
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection(BuildContext context) {
    return Obx(() => ExpandableSection(
      title: 'Additional Info',
      initialExpanded: controller.isAdditionalInfoExpanded.value,
      onExpansionChanged: (_) => controller.toggleSection('Additional Info'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildTextField('Store name', 'Latina')),
              SizedBox(width: 12.w),
              Expanded(child: _buildTextField('Store name', 'عربي', isArabic: true)),
            ],
          ),
          SizedBox(height: 16.h),
          _buildTextField('Business type', 'Choose'), // Simplified for now
          SizedBox(height: 16.h),
          
          // Category Selection
          Text('Category', style: TextStyle(fontSize: 13.sp, color: const Color(0xFF374151))),
          SizedBox(height: 6.h),
          GestureDetector(
            onTap: () {
              Get.bottomSheet(const CategorySheet());
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text(
                    controller.category.value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: controller.category.value == 'Choose' ? const Color(0xFF9CA3AF) : const Color(0xFF1F2937),
                    ),
                  )),
                  Icon(Icons.keyboard_arrow_down, color: const Color(0xFF6B7280), size: 20.sp),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildTimeInfoSection(BuildContext context) {
    return Obx(() => ExpandableSection(
      title: 'Time Info',
      initialExpanded: controller.isTimeInfoExpanded.value,
      onExpansionChanged: (_) => controller.toggleSection('Time Info'),
      content: const TimeScheduleWidget(),
    ));
  }

  Widget _buildLocationSection(BuildContext context) {
    return Obx(() => ExpandableSection(
      title: 'Location',
      initialExpanded: controller.isLocationExpanded.value,
      onExpansionChanged: (_) => controller.toggleSection('Location'),
      content: Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Get.toNamed(MerchantRoutes.ADDRESS_DETAILS),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              side: const BorderSide(color: Color(0xFF10B981)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            child: Text(
              'Add Location',
              style: TextStyle(color: const Color(0xFF10B981), fontSize: 14.sp),
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildSocialMediaSection(BuildContext context) {
    return Obx(() => ExpandableSection(
      title: 'Social Media',
      initialExpanded: controller.isSocialMediaExpanded.value,
      onExpansionChanged: (_) => controller.toggleSection('Social Media'),
      content: Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Get.toNamed(MerchantRoutes.SOCIAL_MEDIA_SETUP),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              side: const BorderSide(color: Color(0xFF10B981)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            child: Text(
              'Add Social Media',
              style: TextStyle(color: const Color(0xFF10B981), fontSize: 14.sp),
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildUploadIdentitySection(BuildContext context) {
    return Obx(() => ExpandableSection(
      title: 'Upload Identity',
      initialExpanded: controller.isIdentityExpanded.value,
      onExpansionChanged: (_) => controller.toggleSection('Upload Identity'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Enter TIN *', ''),
          SizedBox(height: 16.h),
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
                Text('Not set yet', style: TextStyle(color: const Color(0xFF9CA3AF), fontSize: 14.sp)),
                Icon(Icons.calendar_today_outlined, color: const Color(0xFF6B7280), size: 20.sp),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Text('License Document', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF374151))),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE5E7EB), style: BorderStyle.solid),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_upload_outlined, color: const Color(0xFF9CA3AF), size: 24.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select a file', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                      Text('JPG, PNG or PDF. File size no more than 2MB', style: TextStyle(fontSize: 10.sp, color: const Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB800),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text('Select', style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildLoyaltyTypeSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Loyalty type',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF374151)),
          ),
          Obx(() => Row(
            children: [
              Text('Privet', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
              SizedBox(width: 8.w),
              Switch(
                value: !controller.isPrivetLoyalty.value, // True means Everywhere in this UI logic based on design
                onChanged: (val) => controller.isPrivetLoyalty.value = !val,
                activeColor: const Color(0xFF10B981),
              ),
              SizedBox(width: 8.w),
              Text('Everywhere', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF10B981))),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {bool isArabic = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: TextStyle(fontSize: 13.sp, color: const Color(0xFF374151))),
          SizedBox(height: 6.h),
        ],
        TextFormField(
          textAlign: isArabic ? TextAlign.right : TextAlign.left,
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
        ),
      ],
    );
  }

  Widget _buildImageUploadBox(String type) {
    return Container(
      width: 70.w,
      height: 70.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.image_outlined, color: const Color(0xFFD1D5DB), size: 32.sp),
          Positioned(
            right: -5,
            top: -5,
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_a_photo, color: Colors.white, size: 10.sp),
            ),
          ),
        ],
      ),
    );
  }
}
