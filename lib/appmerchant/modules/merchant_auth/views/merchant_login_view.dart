import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/routes/merchant_routes.dart';
import '../controllers/merchant_auth_controller.dart';

class MerchantLoginView extends StatefulWidget {
  const MerchantLoginView({super.key});

  @override
  State<MerchantLoginView> createState() => _MerchantLoginViewState();
}

class _MerchantLoginViewState extends State<MerchantLoginView> {
  late final MerchantAuthController controller;

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60.h),
              
              // App Logo/Icon
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  size: 40.sp,
                  color: const Color(0xFFF97316),
                ),
              ),
              
              SizedBox(height: 32.h),
              
              Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Sign in to your merchant dashboard to manage your business.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              
              SizedBox(height: 48.h),
              
              Text(
                'Phone Number',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'e.g. +216 12 345 678',
                  hintStyle: TextStyle(color: const Color(0xFF9CA3AF), fontSize: 14.sp),
                  prefixIcon: const Icon(Icons.phone_iphone_rounded, color: Color(0xFF9CA3AF)),
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
                    borderSide: const BorderSide(color: Color(0xFFF97316), width: 1.5),
                  ),
                ),
              ),
              
              SizedBox(height: 40.h),

              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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
                          'Get OTP',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              )),

              SizedBox(height: 28.h),
              _buildSocialDivider(),
              SizedBox(height: 20.h),
              _buildSocialButtons(),

              SizedBox(height: 24.h),

              Center(
                child: GestureDetector(
                  onTap: () => Get.toNamed(MerchantRoutes.SIGNUP),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
                      children: const [
                        TextSpan(text: "Don't have a store yet? "),
                        TextSpan(
                          text: 'Create one',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFF97316),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'By signing in, you agree to our ',
                      style: TextStyle(fontSize: 12.sp, color: const Color(0xFF9CA3AF)),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed(MerchantRoutes.TERMS),
                      child: Text(
                        'Terms & Conditions',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFF97316),
                          decoration: TextDecoration.underline,
                          decorationColor: const Color(0xFFF97316),
                        ),
                      ),
                    ),
                    Text(
                      ' and ',
                      style: TextStyle(fontSize: 12.sp, color: const Color(0xFF9CA3AF)),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed(MerchantRoutes.PRIVACY),
                      child: Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFF97316),
                          decoration: TextDecoration.underline,
                          decorationColor: const Color(0xFFF97316),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: const Color(0xFFE5E7EB))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            'Or continue with',
            style: TextStyle(fontSize: 13.sp, color: const Color(0xFF9CA3AF)),
          ),
        ),
        Expanded(child: Divider(color: const Color(0xFFE5E7EB))),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSocialButton(
            icon: 'assets/icons/Google.svg',
            onTap: isLoading ? null : controller.googleLogin,
          ),
          SizedBox(width: 16.w),
          _buildSocialButton(
            icon: 'assets/icons/Facebook.svg',
            onTap: isLoading ? null : controller.facebookLogin,
          ),
          SizedBox(width: 16.w),
          _buildSocialButton(
            icon: 'assets/icons/apple.svg',
            onTap: isLoading ? null : controller.appleLogin,
          ),
        ],
      );
    });
  }

  Widget _buildSocialButton({required String icon, required VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: IconButton(
        icon: SvgPicture.asset(icon, width: 24.w, height: 24.h),
        onPressed: onTap,
      ),
    );
  }
}

