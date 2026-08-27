import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/business_registration_controller.dart';

class SocialMediaSetupView extends GetView<BusinessRegistrationController> {
  const SocialMediaSetupView({super.key});

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
              'Social Media Setup',
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
                border: Border.all(color: const Color(0xFFFFB800)),
              ),
              child: Text(
                '99%',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFFB800),
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
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSocialMediaField('FACEBOOK', Icons.facebook, Colors.blue, controller.facebookCtrl),
                  SizedBox(height: 24.h),
                  _buildSocialMediaField('INSTAGRAM', Icons.camera_alt_outlined, Colors.pink, controller.instagramCtrl),
                  SizedBox(height: 24.h),
                  _buildSocialMediaField('WEBSITE', Icons.language, Colors.grey, controller.websiteCtrl),
                ],
              ),
            ),
          ),
          // Apply Button
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Apply',
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

  Widget _buildSocialMediaField(String label, IconData icon, Color iconColor, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9CA3AF),
              ),
            ),
            // Each field's header carried a red edit + delete pair with no
            // handler on either. The field below is a plain editable
            // TextFormField, so "edit" meant nothing; clearing it is the only
            // real action, and now it works.
            GestureDetector(
              onTap: ctrl.clear,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Icon(Icons.delete_outline,
                    color: const Color(0xFFEF4444), size: 16.sp),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: 'URL',
            hintStyle: TextStyle(color: const Color(0xFF9CA3AF), fontSize: 14.sp),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            prefixIcon: Icon(icon, color: iconColor),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
}
