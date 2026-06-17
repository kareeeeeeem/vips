import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../design_system/atoms/app_colors.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(NotificationsController());
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: FadeTransition(
          opacity: controller.fadeAnimation,
          child: SlideTransition(
            position: controller.slideAnimation,
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                _buildFilterSection(),
                _buildNotificationsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.h,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: const Color(0xFF6B7280),
            size: 20.sp,
          ),
          onPressed: controller.goBack,
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.AppPrimaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: IconButton(
            icon: Icon(
              Icons.mark_email_read_rounded,
              color: AppColors.AppPrimaryColor,
              size: 20.sp,
            ),
            onPressed: controller.markAllAsRead,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        //titlePadding: EdgeInsets.only(left: 50.w, bottom: 16.h),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937),
                fontFamily: 'SF Pro Display',
              ),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Row(
          children: [
            Obx(
              () => _buildFilterChip(
                'All',
                controller.selectedFilter.value == 'All',
              ),
            ),
            SizedBox(width: 8.w),
            Obx(
              () => _buildFilterChip(
                'Unread',
                controller.selectedFilter.value == 'Unread',
              ),
            ),
            SizedBox(width: 8.w),
            Obx(
              () => _buildFilterChip(
                'Promotions',
                controller.selectedFilter.value == 'Promotions',
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: controller.openFilterOptions,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: AppColors.AppPrimaryColor,
                  size: 16.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => controller.setFilter(label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.AppPrimaryColor : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color:
                isSelected
                    ? AppColors.AppPrimaryColor
                    : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
            fontFamily: 'SF Pro Display',
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 50.h),
              child: CircularProgressIndicator(
                color: AppColors.AppPrimaryColor,
              ),
            ),
          ),
        );
      }

      final filteredNotifications = controller.filteredNotifications;

      if (filteredNotifications.isEmpty) {
        return SliverToBoxAdapter(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 100.h),
                Icon(
                  Icons.notifications_off_outlined,
                  size: 64.sp,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16.h),
                Text(
                  'No notifications',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                    fontFamily: 'SF Pro Display',
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'You\'re all caught up!',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[400],
                    fontFamily: 'SF Pro Text',
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index >= filteredNotifications.length) return null;
            final notification = filteredNotifications[index];

            return AnimatedBuilder(
              animation: controller.animationController,
              builder: (context, child) {
                final animationDelay = index * 0.1;
                final slideAnimation = Tween<Offset>(
                  begin: const Offset(0.3, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: controller.animationController,
                    curve: Interval(
                      animationDelay,
                      (animationDelay + 0.3).clamp(0.0, 1.0),
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                );

                final fadeAnimation = Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(
                  CurvedAnimation(
                    parent: controller.animationController,
                    curve: Interval(
                      animationDelay,
                      (animationDelay + 0.3).clamp(0.0, 1.0),
                      curve: Curves.easeOut,
                    ),
                  ),
                );

                return SlideTransition(
                  position: slideAnimation,
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: _buildNotificationCard(notification, index),
                  ),
                );
              },
            );
          }, childCount: filteredNotifications.length),
        ),
      );
    });
  }

  Widget _buildNotificationCard(NotificationItem notification, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color:
              notification.isRead
                  ? const Color(0xFFE8ECF4)
                  : AppColors.AppPrimaryColor.withOpacity(0.2),
          width: notification.isRead ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () => controller.handleNotificationTap(notification),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNotificationIcon(notification),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1F2937),
                                    fontFamily: 'SF Pro Display',
                                  ),
                                ),
                              ),
                              if (!notification.isRead)
                                Container(
                                  width: 8.w,
                                  height: 8.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.AppPrimaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            notification.message,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6B7280),
                              fontFamily: 'SF Pro Text',
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: controller
                            .getTypeColor(notification.type)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        controller.getTypeLabel(notification.type),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: controller.getTypeColor(notification.type),
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.access_time_rounded,
                      color: const Color(0xFF9CA3AF),
                      size: 12.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      notification.time,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF9CA3AF),
                        fontFamily: 'SF Pro Text',
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap:
                          () =>
                              controller.showNotificationOptions(notification),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: AppColors.AppPrimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'Options',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.AppPrimaryColor,
                            fontFamily: 'SF Pro Display',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationItem notification) {
    if (notification.image != null) {
      return Container(
        width: 48.w,
        height: 48.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE8ECF4)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.asset(notification.image!, fit: BoxFit.cover),
        ),
      );
    }

    return Container(
      width: 48.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: controller.getTypeColor(notification.type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(
        controller.getTypeIcon(notification.type),
        color: controller.getTypeColor(notification.type),
        size: 24.sp,
      ),
    );
  }
}
