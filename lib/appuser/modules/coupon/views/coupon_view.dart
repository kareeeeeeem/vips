import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../design_system/atoms/app_colors.dart';
import '../controllers/coupon_controller.dart';

class CouponView extends GetView<CouponController> {
  const CouponView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CouponController());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(height: 20.h),
            Expanded(child: _buildCouponsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18.sp,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            'Available Coupons',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponsList() {
    return Obx(() {
      if (controller.isLoading.value && controller.coupons.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }

      if (controller.coupons.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: controller.loadData,
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
          itemCount: controller.coupons.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: _buildCouponCard(controller.coupons[index]),
            );
          },
        ),
      );
    });
  }

  Widget _buildCouponCard(Coupon coupon) {
    final isActive = coupon.status == CouponStatus.active;

    return GestureDetector(
      onTap: () => controller.viewCouponDetails(coupon),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 4.h,
              decoration: BoxDecoration(
                color: isActive ? AppColors.AppPrimaryColor : Colors.grey.shade400,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              coupon.code,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                                letterSpacing: 1.5,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 14.sp,
                                  color: Colors.grey.shade500,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '${coupon.daysLeft}d left',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                if (coupon.minOrderAmount > 0) ...[
                                  SizedBox(width: 12.w),
                                  Text(
                                    'Min ${coupon.minOrderAmount.toStringAsFixed(0)} TND',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          coupon.type == CouponType.percentage
                              ? '-${coupon.discount.toInt()}%'
                              : '-${coupon.discount.toInt()}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextButton('View Details', () {
                          controller.viewCouponDetails(coupon);
                        }),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.copyCouponCode(coupon),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            decoration: BoxDecoration(
                              color: AppColors.AppPrimaryColor,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.copy_rounded, size: 14.sp, color: Colors.white),
                                SizedBox(width: 6.w),
                                Text(
                                  'Copy Code',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_offer_outlined,
              size: 64.sp,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'No coupons available',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Check back later for new offers',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
