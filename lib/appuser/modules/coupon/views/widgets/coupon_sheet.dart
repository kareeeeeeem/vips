import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

import '../../../../design_system/atoms/app_colors.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class CreateCouponSheet extends StatefulWidget {
  @override
  State<CreateCouponSheet> createState() => _CreateCouponSheetState();
}

class _CreateCouponSheetState extends State<CreateCouponSheet> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _redeemCoupon() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      safeSnackbar('Error', 'Please enter a coupon code');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await ApiService().post('/rewards/validate-qr', {'code': code});
      Get.back();
      if (response.success && response.data != null) {
        final discount = response.data['discount'] ?? response.data['discountPercentage'] ?? 0;
        safeSnackbar(
          'Coupon Applied!',
          'You get ${discount}% off your next order.',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        safeSnackbar('Invalid Coupon', response.message.isNotEmpty ? response.message : 'Coupon not found or expired');
      }
    } catch (_) {
      safeSnackbar('Error', 'Failed to validate coupon');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24.w,
            right: 24.w,
            top: 24.w,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.w,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Redeem Coupon',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Enter your coupon code to apply a discount.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'e.g. SAVE20',
                  prefixIcon: const Icon(Icons.confirmation_number_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.AppPrimaryColor),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              GestureDetector(
                onTap: _isLoading ? null : _redeemCoupon,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.AppPrimaryColor,
                        AppColors.AppPrimaryColor.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: _isLoading
                      ? Center(child: SizedBox(width: 24.w, height: 24.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                      : Text(
                          'Apply Coupon',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
