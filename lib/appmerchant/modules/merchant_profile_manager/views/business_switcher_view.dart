import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../controllers/merchant_profile_controller.dart';
import '../models/business_profile_model.dart';

class BusinessSwitcherView extends GetView<MerchantProfileController> {
  const BusinessSwitcherView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Switch Business',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF1F2937)),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select your business profile',
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: controller.profiles.length,
                itemBuilder: (context, index) {
                  final profile = controller.profiles[index];
                  return _buildProfileItem(context, profile);
                },
              )),
            ),
            _buildAddNewButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context, BusinessProfile profile) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: profile.isActive ? Border.all(color: const Color(0xFF10B981), width: 2) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.w),
        leading: CircleAvatar(
          radius: 25.r,
          backgroundColor: const Color(0xFFF3F4F6),
          child: Text(profile.name[0], style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
        ),
        title: Text(profile.name, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        subtitle: Text(profile.type, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
        trailing: profile.isActive 
          ? const Icon(Icons.check_circle, color: Color(0xFF10B981))
          : const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          if (!profile.isActive) {
            _showPinPrompt(context, profile);
          }
        },
      ),
    );
  }

  void _showPinPrompt(BuildContext context, BusinessProfile profile) {
    final pinController = TextEditingController();
    
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter PIN for ${profile.name}',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              'Only authorized personnel can switch to this profile',
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6B7280)),
            ),
            SizedBox(height: 24.h),
            Pinput(
              length: 4,
              controller: pinController,
              obscureText: true,
              defaultPinTheme: PinTheme(
                width: 56.w,
                height: 56.h,
                textStyle: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onCompleted: (pin) async {
                final success = await controller.verifyPin(profile, pin);
                if (!success) {
                  Get.snackbar('Error', 'Incorrect PIN', backgroundColor: Colors.red.withOpacity(0.1));
                  pinController.clear();
                }
              },
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNewButton() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 20.h),
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Add New Business'),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          side: const BorderSide(color: Color(0xFF10B981)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
      ),
    );
  }
}
