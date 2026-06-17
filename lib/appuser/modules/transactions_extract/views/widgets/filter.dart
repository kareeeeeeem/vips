import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../design_system/atoms/app_colors.dart';
import '../../controllers/transactions_extract_controller.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionsExtractController>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 20.h),
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
                  SizedBox(height: 24.h),

                  // Title avec icon
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.AppPrimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.filter_list_rounded,
                          color: AppColors.AppPrimaryColor,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filter Transactions',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Choose what to display',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Divider
            Divider(height: 1, color: Colors.grey.shade200),

            // Filter options
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaction Type',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  Obx(
                    () => Column(
                      children: [
                        _buildFilterOption(
                          title: 'All Transactions',
                          subtitle: 'Show all activity',
                          icon: Icons.list_rounded,
                          selected: controller.selectedFilter.value == 'All',
                          onTap: () {
                            controller.selectedFilter.value = 'All';
                          },
                        ),
                        SizedBox(height: 12.h),
                        _buildFilterOption(
                          title: 'Rewards Only',
                          subtitle: 'Incoming transactions',
                          icon: Icons.south_west_rounded,
                          iconColor: AppColors.AppPrimaryColor,
                          iconBg: Color(0xFFFFE8DD),
                          selected:
                              controller.selectedFilter.value == 'Rewards',
                          onTap: () {
                            controller.selectedFilter.value = 'Rewards';
                          },
                        ),
                        SizedBox(height: 12.h),
                        _buildFilterOption(
                          title: 'Extracts Only',
                          subtitle: 'Outgoing transactions',
                          icon: Icons.north_east_rounded,
                          iconColor: Colors.grey.shade700,
                          iconBg: Color(0xFFF0F0F0),
                          selected:
                              controller.selectedFilter.value == 'Extracts',
                          onTap: () {
                            controller.selectedFilter.value = 'Extracts';
                          },
                        ),
                        SizedBox(height: 12.h),
                        _buildFilterOption(
                          title: 'Pending',
                          subtitle: 'Processing transactions',
                          icon: Icons.pending_rounded,
                          iconColor: Colors.orange,
                          iconBg: Colors.orange.shade50,
                          selected:
                              controller.selectedFilter.value == 'Pending',
                          onTap: () {
                            controller.selectedFilter.value = 'Pending';
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            controller.selectedFilter.value = 'All';
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Text(
                              'Reset',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            controller.loadTransactions();
                            Get.back();
                            Get.snackbar(
                              'Filter Applied',
                              'Showing ${controller.selectedFilter.value.toLowerCase()} transactions',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppColors
                                  .AppPrimaryColor.withOpacity(0.9),
                              colorText: Colors.white,
                              duration: Duration(seconds: 2),
                              margin: EdgeInsets.all(16.w),
                              borderRadius: 12.r,
                              icon: Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.AppPrimaryColor,
                                  AppColors.AppPrimaryColor.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.AppPrimaryColor.withOpacity(
                                    0.3,
                                  ),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Apply Filter',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 18.sp,
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

  Widget _buildFilterOption({
    required String title,
    required String subtitle,
    required IconData icon,
    Color? iconColor,
    Color? iconBg,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color:
              selected
                  ? AppColors.AppPrimaryColor.withOpacity(0.08)
                  : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: selected ? AppColors.AppPrimaryColor : Colors.grey.shade200,
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color:
                    selected
                        ? AppColors.AppPrimaryColor.withOpacity(0.15)
                        : (iconBg ?? Colors.white),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color:
                    selected
                        ? AppColors.AppPrimaryColor
                        : (iconColor ?? Colors.grey.shade700),
                size: 22.sp,
              ),
            ),

            SizedBox(width: 16.w),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          selected ? AppColors.AppPrimaryColor : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Checkbox
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    selected ? AppColors.AppPrimaryColor : Colors.transparent,
                border: Border.all(
                  color:
                      selected
                          ? AppColors.AppPrimaryColor
                          : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child:
                  selected
                      ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                      : null,
            ),
          ],
        ),
      ),
    );
  }
}
