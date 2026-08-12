import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

import '../../../../design_system/atoms/app_colors.dart';
import '../../controllers/coupon_controller.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

class EditCouponSheet extends StatefulWidget {
  final Coupon coupon;
  final VoidCallback onSuccess;

  const EditCouponSheet({super.key,
    required this.coupon,
    required this.onSuccess,
  });

  @override
  State<EditCouponSheet> createState() => _EditCouponSheetState();
}

class _EditCouponSheetState extends State<EditCouponSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _discountController;
  late TextEditingController _minOrderController;
  late DateTime _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _discountController =
        TextEditingController(text: widget.coupon.discount.toStringAsFixed(0));
    _minOrderController = TextEditingController();
    _selectedDate = widget.coupon.expiryDate;
  }

  @override
  void dispose() {
    _discountController.dispose();
    _minOrderController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isAfter(DateTime.now())
          ? _selectedDate
          : DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.AppPrimaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final body = {
        'discount': double.parse(_discountController.text.trim()),
        'expiryDate': _selectedDate.toIso8601String(),
        if (_minOrderController.text.trim().isNotEmpty)
          'minOrderAmount': double.parse(_minOrderController.text.trim()),
      };

      final response =
          await ApiService().put('/rewards/coupons/${widget.coupon.id}', body);

      if (response.success) {
        Get.back();
        widget.onSuccess();
        safeSnackbar(
          'Updated',
          'Coupon updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          margin: EdgeInsets.all(16.w),
          borderRadius: 12.r,
          icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
        );
      } else {
        safeSnackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: EdgeInsets.all(16.w),
          borderRadius: 12.r,
        );
      }
    } catch (e) {
      safeSnackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: EdgeInsets.all(16.w),
        borderRadius: 12.r,
      );
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
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
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

                  // Title row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Edit Coupon',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18.sp,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Code (read-only)
                  _buildFieldLabel('Coupon Code'),
                  SizedBox(height: 8.h),
                  Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 16.sp,
                          color: Colors.grey.shade500,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          widget.coupon.code,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'Read-only',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Discount
                  _buildFieldLabel('Discount (%)'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _discountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                    ],
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    decoration: _inputDecoration(
                      hint: 'e.g. 10',
                      prefix: Icon(
                        Icons.percent_rounded,
                        size: 16.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Discount is required';
                      final d = double.tryParse(v.trim());
                      if (d == null || d <= 0 || d > 100)
                        return 'Enter a value between 1 and 100';
                      return null;
                    },
                  ),

                  SizedBox(height: 20.h),

                  // Min Order Amount
                  _buildFieldLabel('Min. Order Amount (optional)'),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _minOrderController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                    ],
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                      color: Colors.black87,
                    ),
                    decoration: _inputDecoration(
                      hint: 'e.g. 50.00',
                      prefix: Icon(
                        Icons.shopping_bag_outlined,
                        size: 16.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      final d = double.tryParse(v.trim());
                      if (d == null || d < 0)
                        return 'Enter a valid amount';
                      return null;
                    },
                  ),

                  SizedBox(height: 20.h),

                  // Expiry Date
                  _buildFieldLabel('Expiry Date'),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 14.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 16.sp,
                            color: AppColors.AppPrimaryColor,
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            '${_selectedDate.day.toString().padLeft(2, '0')}/'
                            '${_selectedDate.month.toString().padLeft(2, '0')}/'
                            '${_selectedDate.year}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18.sp,
                            color: Colors.grey.shade500,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // Submit button
                  GestureDetector(
                    onTap: _isLoading ? null : _submit,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isLoading
                              ? [Colors.grey.shade400, Colors.grey.shade300]
                              : [
                                  AppColors.AppPrimaryColor,
                                  AppColors.AppPrimaryColor.withValues(alpha: 0.8),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: _isLoading
                            ? []
                            : [
                                BoxShadow(
                                  color:
                                      AppColors.AppPrimaryColor.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: _isLoading
                          ? Center(
                              child: SizedBox(
                                width: 22.w,
                                height: 22.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                            )
                          : Text(
                              'Save Changes',
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

                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, Widget? prefix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14.sp,
        color: Colors.grey.shade400,
      ),
      prefixIcon: prefix != null
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: prefix,
            )
          : null,
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding:
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.AppPrimaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
    );
  }
}
