import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../design_system/atoms/app_colors.dart';
import '../../controllers/coupon_controller.dart';

class CouponDetailsSheet extends StatelessWidget {
  final Coupon coupon;

  const CouponDetailsSheet({Key? key, required this.coupon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isActive = coupon.status == CouponStatus.active;
    final isExpired = coupon.status == CouponStatus.expired;

    return Container(
      height: Get.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    width: 48.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Coupon card preview
                  Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                            isExpired
                                ? [Colors.red.shade400, Colors.red.shade300]
                                : (isActive
                                    ? [
                                      AppColors.AppPrimaryColor,
                                      AppColors.AppPrimaryColor.withOpacity(
                                        0.7,
                                      ),
                                    ]
                                    : [
                                      Colors.grey.shade400,
                                      Colors.grey.shade300,
                                    ]),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: (isExpired
                                  ? Colors.red
                                  : (isActive
                                      ? AppColors.AppPrimaryColor
                                      : Colors.grey))
                              .withOpacity(0.3),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'COUPON CODE',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.8),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  coupon.code,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.local_offer_rounded,
                                color: Colors.white,
                                size: 32.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DISCOUNT',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.8),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  coupon.type == CouponType.percentage
                                      ? '${coupon.discount.toInt()}% OFF'
                                      : '${coupon.discount.toInt()} TND OFF',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isExpired
                                        ? Icons.close_rounded
                                        : (isActive
                                            ? Icons.check_circle_rounded
                                            : Icons.pause_circle_rounded),
                                    size: 16.sp,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    isExpired
                                        ? 'Expired'
                                        : (isActive ? 'Active' : 'Inactive'),
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: Colors.grey.shade200),

            // Details
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coupon Details',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Usage stats
                    _buildInfoCard(
                      icon: Icons.analytics_rounded,
                      title: 'Usage Statistics',
                      children: [
                        _buildStatRow(
                          'Total Uses',
                          '${coupon.usageCount}',
                          Colors.blue,
                        ),
                        SizedBox(height: 12.h),
                        _buildStatRow(
                          'Max Usage',
                          '${coupon.maxUsage}',
                          Colors.purple,
                        ),
                        SizedBox(height: 12.h),
                        _buildStatRow(
                          'Remaining',
                          '${coupon.maxUsage - coupon.usageCount}',
                          Colors.green,
                        ),
                        SizedBox(height: 16.h),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progress',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  '${coupon.usagePercentage.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.AppPrimaryColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: LinearProgressIndicator(
                                value: coupon.usagePercentage / 100,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.AppPrimaryColor,
                                ),
                                minHeight: 10.h,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Validity info
                    _buildInfoCard(
                      icon: Icons.calendar_today_rounded,
                      title: 'Validity Period',
                      children: [
                        _buildDetailRow(
                          'Expiry Date',
                          '${coupon.expiryDate.day}/${coupon.expiryDate.month}/${coupon.expiryDate.year}',
                        ),
                        SizedBox(height: 12.h),
                        _buildDetailRow(
                          'Days Remaining',
                          isExpired ? 'Expired' : '${coupon.daysLeft} days',
                          valueColor: isExpired ? Colors.red : Colors.green,
                        ),
                        SizedBox(height: 12.h),
                        _buildDetailRow(
                          'Status',
                          isExpired
                              ? 'Expired'
                              : (isActive ? 'Active' : 'Inactive'),
                          valueColor:
                              isExpired
                                  ? Colors.red
                                  : (isActive ? Colors.green : Colors.orange),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Discount info
                    _buildInfoCard(
                      icon: Icons.discount_rounded,
                      title: 'Discount Information',
                      children: [
                        _buildDetailRow(
                          'Type',
                          coupon.type == CouponType.percentage
                              ? 'Percentage'
                              : 'Fixed Amount',
                        ),
                        SizedBox(height: 12.h),
                        _buildDetailRow(
                          'Value',
                          coupon.type == CouponType.percentage
                              ? '${coupon.discount.toInt()}%'
                              : '${coupon.discount.toInt()} TND',
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),

            // Actions
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.AppPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  size: 20.sp,
                  color: AppColors.AppPrimaryColor,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8.w,
              height: 8.h,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.sp,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13.sp,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
