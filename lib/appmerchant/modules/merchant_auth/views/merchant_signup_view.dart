import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import '../controllers/merchant_auth_controller.dart';

/// Merchant account creation — POST /auth/register with role: 'merchant'.
/// The merchant app previously had no sign-up path at all, so a brand-new
/// merchant could reach neither the dashboard nor the partnership flow.
class MerchantSignupView extends StatefulWidget {
  const MerchantSignupView({super.key});

  @override
  State<MerchantSignupView> createState() => _MerchantSignupViewState();
}

class _MerchantSignupViewState extends State<MerchantSignupView> {
  late final MerchantAuthController controller;

  static const _orange = Color(0xFFF97316);

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<MerchantAuthController>()
        ? Get.find<MerchantAuthController>()
        : Get.put(MerchantAuthController());
  }

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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create your store',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Register your business to start rewarding your customers.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 32.h),

              _field(
                label: 'Store Name',
                controller: controller.storeNameController,
                hint: 'e.g. Café des Nattes',
                icon: Icons.storefront_rounded,
              ),
              _field(
                label: 'Owner Name',
                controller: controller.ownerNameController,
                hint: 'Full name',
                icon: Icons.person_outline_rounded,
              ),
              _field(
                label: 'Phone Number',
                controller: controller.signupPhoneController,
                hint: 'e.g. +216 12 345 678',
                icon: Icons.phone_iphone_rounded,
                keyboardType: TextInputType.phone,
                helper: 'You will sign in with this number and a one-time code.',
              ),
              _field(
                label: 'Email',
                controller: controller.emailController,
                hint: 'you@business.com',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              Obx(() => _field(
                    label: 'Password',
                    controller: controller.passwordController,
                    hint: 'At least 6 characters',
                    icon: Icons.lock_outline_rounded,
                    obscure: controller.obscurePassword.value,
                    suffix: IconButton(
                      icon: Icon(
                        controller.obscurePassword.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF9CA3AF),
                        size: 20.sp,
                      ),
                      onPressed: () => controller.obscurePassword.toggle(),
                    ),
                  )),
              _field(
                label: 'Store Address (optional)',
                controller: controller.storeAddressController,
                hint: 'Street, city',
                icon: Icons.location_on_outlined,
              ),

              _label('Business Category'),
              SizedBox(height: 8.h),
              Obx(() {
                final selected = controller.selectedCategory.value;
                return GestureDetector(
                  onTap: _pickCategory,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.category_outlined, color: Color(0xFF9CA3AF), size: 20),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            selected.isEmpty ? 'Choose a category' : selected,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: selected.isEmpty
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF1F2937),
                              fontWeight: selected.isEmpty ? FontWeight.w400 : FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF9CA3AF)),
                      ],
                    ),
                  ),
                );
              }),

              SizedBox(height: 32.h),

              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _orange,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? SizedBox(
                              height: 20.h,
                              width: 20.h,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  )),

              SizedBox(height: 20.h),

              Center(
                child: GestureDetector(
                  onTap: () => Get.toNamed(MerchantRoutes.LOGIN),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
                      children: const [
                        TextSpan(text: 'Already have a store? '),
                        TextSpan(
                          text: 'Sign in',
                          style: TextStyle(fontWeight: FontWeight.w700, color: _orange),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  void _pickCategory() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Business Category',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 16.h),
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: MerchantAuthController.businessCategories.entries.map((e) {
                    return Obx(() {
                      final isSelected = controller.selectedCategory.value == e.key;
                      return GestureDetector(
                        onTap: () {
                          controller.selectedCategory.value = e.key;
                          Get.back();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _orange.withValues(alpha: 0.1)
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: isSelected ? _orange : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.key,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              Text(
                                e.value,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF374151),
        ),
      );

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
    String? helper,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          SizedBox(height: 8.h),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: const Color(0xFF9CA3AF), fontSize: 14.sp),
              prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
              suffixIcon: suffix,
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: _orange, width: 1.5),
              ),
            ),
          ),
          if (helper != null) ...[
            SizedBox(height: 6.h),
            Text(
              helper,
              style: TextStyle(fontSize: 11.sp, color: const Color(0xFF9CA3AF)),
            ),
          ],
        ],
      ),
    );
  }
}
