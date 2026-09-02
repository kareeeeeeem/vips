import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import '../controllers/merchant_profile_controller.dart';
import '../models/business_profile_model.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class BusinessSwitcherView extends GetView<MerchantProfileController> {
  const BusinessSwitcherView({super.key});

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
              'Your business profile',
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF10B981)),
                  );
                }
                if (controller.profiles.isEmpty) {
                  return Center(
                    child: Text(
                      'Could not load your business profile.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  color: const Color(0xFF10B981),
                  onRefresh: controller.loadProfiles,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: controller.profiles.length,
                    itemBuilder: (context, index) {
                      final profile = controller.profiles[index];
                      return _buildProfileItem(context, profile);
                    },
                  ),
                );
              }),
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
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),
            Text(profile.type, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
            SizedBox(height: 6.h),
            // Real BusinessRegistration.status, so the merchant can see
            // whether their partnership application is still pending.
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: _statusColor(profile.status).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                profile.statusLabel,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: _statusColor(profile.status),
                ),
              ),
            ),
          ],
        ),
        trailing: profile.isActive
          ? const Icon(Icons.check_circle, color: Color(0xFF10B981))
          : const Icon(Icons.arrow_forward_ios, size: 16),
        // The one business this account owns is always the active one, so
        // there is nothing to switch to; open its store page instead of
        // being an inert row.
        onTap: () {
          if (profile.isActive) {
            Get.toNamed(MerchantRoutes.STORE_PROFILE);
          } else {
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
                // Real server-side check (POST /auth/pin/verify) — this used
                // to compare against a SharedPreferences key nothing ever
                // wrote, so any merchant entering 0000 passed.
                final success = await controller.verifyPin(pin);
                if (success) {
                  Get.back();
                  safeSnackbar('Verified', 'Switched to ${profile.name}',
                      snackPosition: SnackPosition.BOTTOM);
                } else {
                  safeSnackbar(
                    'Error',
                    controller.hasPin.value
                        ? 'Incorrect PIN'
                        : 'No PIN is set for this account yet.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  pinController.clear();
                }
              },
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    ).then((_) {
      pinController.dispose();
    });
  }

  Color _statusColor(String status) => switch (status) {
        'approved' => const Color(0xFF059669),
        'rejected' => const Color(0xFFDC2626),
        'pending' || 'under_review' => const Color(0xFFD97706),
        _ => const Color(0xFF6B7280),
      };

  Widget _buildAddNewButton() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 12.h),
          child: OutlinedButton.icon(
            onPressed: controller.addNewBusiness,
            icon: const Icon(Icons.add),
            label: const Text('Add New Business'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              side: const BorderSide(color: Color(0xFF10B981)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
        ),
        // The other half of switching: a shop owner is also a customer, and
        // their own points, offers and orders live in the VIPs app.
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 20.h),
          child: TextButton.icon(
            onPressed: controller.openCustomerApp,
            icon: Icon(Icons.person_outline, size: 18.sp),
            label: Text('Use VIPs as a customer',
                style: TextStyle(fontSize: 13.5.sp)),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              foregroundColor: const Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }
}
