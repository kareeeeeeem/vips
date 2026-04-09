import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../design_system/atoms/app_colors.dart';
import '../controllers/teams_controller.dart';

class TeamsView extends GetView<TeamsController> {
  const TeamsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            children: [
              // Header
              _buildHeader(),
              SizedBox(height: 23.h),

              // Admin info card
              _buildAdminInfoCard(),
              SizedBox(height: 20.h),

              // Tab bar
              _buildTabBar(),
              SizedBox(height: 16.h),

              // Tab content - this takes remaining space
              Expanded(child: _buildTabContent()),
            ],
          ),
        ),
      ),
    );
  }

  /// Build header with back button, title, and settings
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back button
        _buildIconButton(icon: AppIcons.arrowLeft, onTap: () => Get.back()),

        // Title
        Text(
          'Admin',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
            fontFamily: 'Poppins',
            color: AppColors.AppBlackColor,
          ),
        ),

        // Settings button
        _buildIconButton(
          icon: AppIcons.Settings,
          onTap: () => controller.showSettingsSheet(),
        ),
      ],
    );
  }

  /// Build icon button with shadow
  Widget _buildIconButton({required String icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: 44.w,
        height: 44.h,
        decoration: BoxDecoration(
          color: AppColors.appWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.AppBlackColor.withOpacity(0.06),
              spreadRadius: 0,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SvgPicture.asset(
          icon,
          width: 20.w,
          height: 20.h,
          color: AppColors.AppBlackColor,
        ),
      ),
    );
  }

  /// Build admin info card
  Widget _buildAdminInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.r),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.appWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.AppBlackColor.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side - Employee info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Employee Name',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.AppBlackColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffFFE5D9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            AppIcons.admin,
                            width: 14.w,
                            height: 14.h,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Admin',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.AppPrimaryColor,
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

          // Right side - Actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Add button
              GestureDetector(
                onTap: () => controller.showCreateAdminSheet(),
                child: Container(
                  width: 44.w,
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: AppColors.AppPrimaryColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.AppPrimaryColor.withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: AppColors.appWhite,
                    size: 24.r,
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // Operation button
              GestureDetector(
                onTap: () {
                  // Show operations for current admin
                  // controller.showOperationsSheet(employee);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffFFEDE5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Operation',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.AppPrimaryColor,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12.r,
                        color: AppColors.AppPrimaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build tab bar
  Widget _buildTabBar() {
    return Obx(() {
      return Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: AppColors.appWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.AppBlackColor.withOpacity(0.04),
              spreadRadius: 0,
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TabBar(
          indicator: const BoxDecoration(),
          indicatorColor: Colors.transparent,
          controller: controller.tabController,
          labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
          overlayColor: const MaterialStatePropertyAll(Colors.transparent),
          labelColor: AppColors.appWhite,
          unselectedLabelColor: AppColors.AppBlackColor.withOpacity(0.6),
          dividerHeight: 0,
          tabs: [
            _buildTab('All', 0),
            _buildTab('Active', 1),
            _buildTab('Pending', 2),
            _buildTab('Removed', 3),
          ],
        ),
      );
    });
  }

  /// Build individual tab
  Widget _buildTab(String label, int index) {
    return Obx(() {
      final isSelected = controller.tabIndex == index;
      return Tab(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          height: 36.h,
          decoration: BoxDecoration(
            gradient:
                isSelected
                    ? LinearGradient(
                      colors: [
                        AppColors.AppPrimaryColor,
                        AppColors.AppPrimaryColor.withOpacity(0.8),
                      ],
                    )
                    : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            maxLines: 1,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
    });
  }

  /// Build tab content
  Widget _buildTabContent() {
    return Obx(() {
      if (controller.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.filteredEmployees.isEmpty) {
        return _buildEmptyState();
      }

      return TabBarView(
        controller: controller.tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildEmployeeList(),
          _buildEmployeeList(),
          _buildEmployeeList(),
          _buildEmployeeList(),
        ],
      );
    });
  }

  /// Build employee list
  /// FIX: Wrap in Obx to react to list changes and prevent RangeError
  Widget _buildEmployeeList() {
    return Obx(() {
      // Create a local copy to ensure consistent data during build
      final employees = controller.filteredEmployees.toList();

      // If empty, show empty state in the TabBarView context
      if (employees.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: () => controller.loadEmployees(),
        child: ListView.separated(
          padding: EdgeInsets.only(top: 8.h, bottom: 20.h),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: employees.length,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            // Safety check to prevent RangeError
            if (index >= employees.length) {
              return const SizedBox.shrink();
            }
            final employee = employees[index];
            return _buildEmployeeCard(employee);
          },
        ),
      );
    });
  }

  /// Build employee card
  Widget _buildEmployeeCard(Employee employee) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.appWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.AppBlackColor.withOpacity(0.06),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.AppPrimaryColor,
                  AppColors.AppPrimaryColor.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                employee.name.isNotEmpty
                    ? employee.name.substring(0, 1).toUpperCase()
                    : '?',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.appWhite,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Employee info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.AppBlackColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      employee.role,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.AppBlackColor.withOpacity(0.6),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: employee.status.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        employee.status.displayName,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: employee.status.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // More button
          GestureDetector(
            onTap: () => controller.showOperationsSheet(employee),
            child: Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: const Color(0xffF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.more_vert,
                size: 20.r,
                color: AppColors.AppBlackColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80.r, color: Colors.grey.shade300),
          SizedBox(height: 16.h),
          Text(
            'No employees found',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add your first employee to get started',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
