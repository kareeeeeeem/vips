import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../design_system/atoms/app_colors.dart';
import '../controllers/report_controller.dart';

class ReportView extends GetView<ReportController> {
  const ReportView({super.key});

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
              SizedBox(height: 24.h),

              // Stats Card
              _buildStatsCard(),
              SizedBox(height: 20.h),

              // Tab Bar
              _buildTabBar(),
              SizedBox(height: 16.h),

              // Tab Content
              Expanded(child: _buildTabContent()),
            ],
          ),
        ),
      ),
    );
  }

  /// Build header
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back button
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            alignment: Alignment.center,
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppColors.appWhite,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.AppBlackColor.withOpacity(0.04),
                  spreadRadius: 0,
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SvgPicture.asset(AppIcons.arrowLeft),
          ),
        ),

        // Title
        Text(
          'Report',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
            fontFamily: 'Poppins',
          ),
        ),

        // Calendar button
        GestureDetector(
          onTap: () => _showDateFilterOptions(),
          child: Container(
            padding: EdgeInsets.all(8.r),
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppColors.appWhite,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.AppBlackColor.withOpacity(0.04),
                  spreadRadius: 0,
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SvgPicture.asset(AppIcons.calendar),
          ),
        ),
      ],
    );
  }

  /// Build stats card
  Widget _buildStatsCard() {
    return Obx(() {
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
        child: Column(
          children: [
            // Date range (if selected)
            if (controller.selectedDateRange != null) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14.r,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '${_formatDate(controller.selectedDateRange!.start)} - ${_formatDate(controller.selectedDateRange!.end)}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    GestureDetector(
                      onTap: () => controller.clearDateFilter(),
                      child: Icon(
                        Icons.close,
                        size: 14.r,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
            ],

            // Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    label: 'Total Reports',
                    value: controller.reportCount.toString(),
                    icon: Icons.description_outlined,
                  ),
                ),
                Container(width: 1, height: 40.h, color: Colors.grey.shade200),
                Expanded(
                  child: _buildStatItem(
                    label: 'Total Amount',
                    value: '\$${controller.totalAmount.toStringAsFixed(2)}',
                    icon: Icons.attach_money,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24.r, color: Colors.grey.shade600),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.AppBlackColor,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// Build tab bar
  Widget _buildTabBar() {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: const Color(0xffF1F1F1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: controller.tabController,
        labelPadding: EdgeInsets.zero,
        indicatorPadding: EdgeInsets.zero,
        indicator: const BoxDecoration(),
        indicatorColor: Colors.transparent,
        labelColor: AppColors.AppPrimaryColor,
        unselectedLabelColor: Colors.grey,
        padding: EdgeInsets.zero,
        overlayColor: const MaterialStatePropertyAll(Colors.transparent),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
          fontSize: 14.sp,
        ),
        labelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        dividerHeight: 0,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Coupon'),
          Tab(text: 'Package'),
        ],
      ),
    );
  }

  /// Build tab content
  Widget _buildTabContent() {
    return Obx(() {
      if (controller.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      return TabBarView(
        controller: controller.tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildReportList(controller.allReports),
          _buildReportList(controller.couponReports),
          _buildReportList(controller.packageReports),
        ],
      );
    });
  }

  /// Build report list
  Widget _buildReportList(List<Report> reports) {
    return Obx(() {
      if (reports.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: () => controller.loadReports(),
        child: ListView.separated(
          padding: EdgeInsets.only(top: 8.h, bottom: 20.h),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: reports.length,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            if (index >= reports.length) {
              return const SizedBox.shrink();
            }
            return _buildReportCard(reports[index]);
          },
        ),
      );
    });
  }

  /// Build report card
  Widget _buildReportCard(Report report) {
    return GestureDetector(
      onTap: () => controller.viewReportDetails(report),
      child: Container(
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
            // Icon
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                report.type.icon,
                color: Colors.grey.shade700,
                size: 24.r,
              ),
            ),
            SizedBox(width: 12.w),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          report.title,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.AppBlackColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          report.status.displayName,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12.r,
                        color: Colors.grey.shade500,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        report.formattedDate,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (report.itemCount != null) ...[
                        SizedBox(width: 12.w),
                        Icon(
                          Icons.folder_outlined,
                          size: 12.r,
                          color: Colors.grey.shade500,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${report.itemCount} items',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  report.formattedAmount,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.AppBlackColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12.r,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 80.r,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            'No reports found',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Reports will appear here',
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

  /// Show date filter options
  void _showDateFilterOptions() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter by Date',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.AppBlackColor,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(
                    Icons.close,
                    size: 24.r,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Quick filters
            _buildQuickFilter('Today', () => _applyQuickFilter(0)),
            Divider(height: 1.h, color: Colors.grey.shade200),
            _buildQuickFilter('Last 7 Days', () => _applyQuickFilter(7)),
            Divider(height: 1.h, color: Colors.grey.shade200),
            _buildQuickFilter('Last 30 Days', () => _applyQuickFilter(30)),
            Divider(height: 1.h, color: Colors.grey.shade200),
            _buildQuickFilter('Custom Range', () {
              Get.back();
              controller.showDatePicker();
            }),
            Divider(height: 1.h, color: Colors.grey.shade200),

            if (controller.selectedDateRange != null) ...[
              _buildQuickFilter('Clear Filter', () {
                Get.back();
                controller.clearDateFilter();
              }, isDestructive: true),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFilter(
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                color:
                    isDestructive
                        ? Colors.red.shade600
                        : AppColors.AppBlackColor,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14.r,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _applyQuickFilter(int days) {
    Get.back();
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days));
    controller.filterByDateRange(DateTimeRange(start: start, end: now));
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
