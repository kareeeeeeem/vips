import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Regular scrollable content (header)
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildUserHeader(),
                  SizedBox(height: 20.h),
                  _buildServicesRow(),
                  SizedBox(height: 24.h),
                  _buildQualificationCard(),
                  SizedBox(height: 24.h),
                  _buildPremiumCard(),
                  SizedBox(height: 24.h),
                ],
              ),
            ),

            // Sticky header with filters
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                child: Obx(
                  () => Container(
                    color: Colors.white,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Date filter et result count
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            children: [
                              Container(
                                width: 35.w,
                                height: 35.h,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.orange,
                                      Colors.orange.withValues(alpha: 0.85),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(6.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withValues(alpha: 0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                      spreadRadius: -2,
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: controller.showSortDialog,
                                  icon: Icon(
                                    Icons.sort_rounded,
                                    color: Colors.white,
                                    size: 28.sp,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                height: 30,
                                width: 1,
                                color: Colors.grey.shade300,
                              ),
                              SizedBox(width: 8.w),
                              _buildOrderStatusChip(
                                'Active',
                                controller.activeOrdersCount,
                              ),
                              SizedBox(width: 8.w),
                              _buildOrderStatusChip(
                                'Done',
                                controller.doneOrdersCount,
                              ),
                              SizedBox(width: 8.w),
                              _buildOrderStatusChip(
                                'Refunded',
                                controller.refundedOrdersCount,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => controller.selectDateRange(),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 14.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        'From: ${controller.formatDate(controller.fromDate.value)}  To: ${controller.formatDate(controller.toDate.value)}',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Spacer(),
                              Text(
                                '${controller.filteredOrders.length} Result Found',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Scrollable orders list
            Obx(() {
              final orders = controller.filteredOrders;

              // Si aucune commande, afficher l'état vide
              if (orders.isEmpty) {
                return SliverToBoxAdapter(child: _buildEmptyState());
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index == orders.length) {
                    return SizedBox(height: 20.h);
                  }
                  final order = orders[index];
                  return _buildOrderItem(order);
                }, childCount: orders.length + 1),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Obx(() {
      final currentRole = controller.selectedRole.value;
      final isBusiness =
          currentRole == 'Business' ||
          currentRole == 'Vendor' ||
          currentRole == 'Agent';
      final primaryColor = controller.primaryColor;

      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Row: Avatar + Last Connection + Settings Icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar on the left
                InkWell(
                  onTap: () => Get.toNamed('/vips-club-history'),
                  child: CircleAvatar(
                    radius: 40.r,
                    backgroundColor: primaryColor.withValues(alpha: 0.1),
                    child: Icon(
                      isBusiness ? Icons.business : Icons.person,
                      size: 38.sp,
                      color: primaryColor,
                    ),
                  ),
                ),

                Expanded(child: SizedBox()),

                // Last Connection
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Last Connection',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Obx(() => Text(
                            controller.lastLogin.value,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey.shade600,
                            ),
                          )),
                        ],
                      ),

                      SizedBox(width: 14.w),

                      // Settings Icon
                      InkWell(
                        onTap: () {
                          Get.toNamed('/settings');
                        },
                        child: Container(
                          child: Icon(
                            Icons.settings_outlined,
                            size: 24.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Full Name - Aligned left
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                controller.userName.value,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Row: Current Package + Alerts + Wallet
            Row(
              children: [
                // Current Package card (plus large)
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: primaryColor, width: 1.5),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.workspace_premium,
                            color: primaryColor,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: InkWell(
                            onTap: () => Get.toNamed('/packages'),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Current Package',
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Obx(() => Text(
                                  controller.packageName.value,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: primaryColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 8.w),

                // Alerts card (carré)
                Expanded(
                  child: GestureDetector(
                    onTap: () => Get.toNamed('/notifications'),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                Icons.notifications_outlined,
                                color: primaryColor,
                                size: 26.sp,
                              ),
                              if (controller.unreadNotificationsCount.value > 0)
                                Positioned(
                                  right: -4,
                                  top: -4,
                                  child: Container(
                                    padding: EdgeInsets.all(4.w),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${controller.unreadNotificationsCount.value}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Alerts',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 8.w),

                // Wallet card (carré)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      controller.navigateToVipsId();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            color: primaryColor,
                            size: 26.sp,
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'VIPsID',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Row: Wallet Points
            Row(
              children: [
                // Wallet Points (plus large avec flèche)
                Expanded(
                  child: InkWell(
                    onTap: () => controller.navigateToWallet(),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Wallet Points',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: primaryColor,
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                // Real balance — this used to claim a fixed
                                // "expiring on 31/12/<year>" date with no
                                // backend field backing it (the account has
                                // no points-expiry concept at all).
                                Obx(
                                  () => Text(
                                    '${controller.totalExpenses.value} points available',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16.sp,
                            color: primaryColor,
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
      );
    });
  }

  Widget _buildServicesRow() {
    return Obx(() {
      final primaryColor = controller.primaryColor;
      final services = controller.servicesList.toList();

      return SizedBox(
        height: 90.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            final badge = index == 0 ? controller.activeOrdersCount
                : (index == 3 ? controller.unreadNotificationsCount.value : 0);

            return Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: _buildServiceIcon(
                service['icon'],
                service['title'],
                badge,
                primaryColor,
                () => Get.toNamed(service['route']),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildServiceIcon(
    IconData icon,
    String label,
    int badge,
    Color primaryColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: Colors.black87, size: 24.sp),
              ),
              if (badge > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$badge',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualificationCard() {
    return Obx(() {
      final primaryColor = controller.primaryColor;
      final completion = controller.profileCompletion.value;

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'In order to be qualified you must:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16.h),

            Row(
              children: [
                // VIP Progress circle
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 50.w,
                      height: 50.h,
                      child: CircularProgressIndicator(
                        value: controller.vipProgress.value,
                        strokeWidth: 4,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          controller.vipPoints.value.toString(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          'VIP',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(width: 16.w),

                Expanded(
                  child: Text(
                    'To reach the minimum VIPs Points eligible to Win Super Bonus',
                    style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            Row(
              children: [
                // Profile Progress
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 50.w,
                      height: 50.h,
                      child: CircularProgressIndicator(
                        value: completion,
                        strokeWidth: 4,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    ),
                    Text(
                      '${(completion * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 16.w),

                Expanded(
                  child: SizedBox(
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: controller.navigateToEditProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Complete your Profile',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPremiumCard() {
    return Obx(() {
      // Both requirements used to show a permanent red X with no way to
      // act on either, regardless of the account's real state — now
      // reflects /auth/me's real isVerified flag and whether a real
      // payment method is on file, and each unmet one is tappable.
      final verified = controller.isVerified.value;
      final hasPayment = controller.hasPaymentMethod.value;

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'In order to be premium you must:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),

            _buildRequirement(
              'Choose Payment Method',
              hasPayment,
              onTap: hasPayment ? null : controller.navigateToPaymentMethods,
            ),
            SizedBox(height: 8.h),
            _buildRequirement(
              'Verify Your Account now',
              verified,
              onTap: verified || controller.isSendingVerification.value ? null : controller.verifyAccountNow,
              isLoading: controller.isSendingVerification.value,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRequirement(String text, bool isCompleted, {VoidCallback? onTap, bool isLoading = false}) {
    final color = isCompleted ? const Color(0xFF22C55E) : Colors.red;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Row(
        children: [
          if (isLoading)
            SizedBox(
              width: 20.sp,
              height: 20.sp,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          else
            Icon(isCompleted ? Icons.check_circle_rounded : Icons.close_rounded, color: color, size: 20.sp),
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onTap != null) ...[
            const Spacer(),
            Icon(Icons.chevron_right, color: color, size: 18.sp),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderStatusChip(String label, int count) {
    return Expanded(
      child: Obx(() {
        final isActive = controller.selectedOrderFilter.value == label;
        return GestureDetector(
          onTap: () => controller.changeOrderFilter(label),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isActive ? Colors.orange : Colors.white,
              borderRadius: BorderRadius.circular(9.r),
              border: Border.all(
                color: isActive ? Colors.orange : Colors.grey.shade300,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : Colors.black87,
                  ),
                ),
                if (count > 0 && label == 'Done') ...[
                  SizedBox(width: 4.w),
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.orange : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Obx(() {
      final primaryColor = controller.primaryColor;
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 40.h),
        padding: EdgeInsets.all(40.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 64.sp,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'No Orders Found',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'You don\'t have any orders in this category.\nTry changing the filter or date range.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                controller.changeOrderFilter('Active');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'View All Orders',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
  // Safe date-part helpers — handle both "2024-01-15" and "10 Mar" formats
  String _dateDay(String date) {
    if (date.isEmpty) return '--';
    // ISO date like "2024-01-15"
    if (date.contains('-')) {
      final parts = date.split('-');
      return parts.length >= 3 ? parts[2].substring(0, 2) : parts.first;
    }
    // Space-separated like "10 Mar"
    final parts = date.split(' ');
    return parts.isNotEmpty ? parts[0] : date;
  }

  String _dateMonth(String date) {
    if (date.isEmpty) return '';
    if (date.contains('-')) {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final parts = date.split('-');
      if (parts.length >= 2) {
        final idx = (int.tryParse(parts[1]) ?? 1) - 1;
        return months.elementAtOrNull(idx) ?? parts[1];
      }
      return '';
    }
    final parts = date.split(' ');
    return parts.length >= 2 ? parts[1] : '';
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    Color getStatusColor(String status) {
      switch (status.toLowerCase()) {
        case 'reserved':
          return const Color(0xFF9C27B0); // Violet
        case 'completed':
          return const Color(0xFF4CAF50); // Vert
        case 'pending':
          return const Color(0xFFFF9800); // Orange
        case 'cancelled':
          return const Color(0xFFF44336); // Rouge
        case 'in store':
          return const Color(0xFFFF9800); // Orange
        default:
          return Colors.grey;
      }
    }

    Color getStatusBgColor(String status) {
      switch (status.toLowerCase()) {
        case 'reserved':
          return const Color(0xFFF3E5F5); // Violet clair
        case 'completed':
          return const Color(0xFFE8F5E9); // Vert clair
        case 'pending':
          return const Color(0xFFFFF3E0); // Orange clair
        case 'cancelled':
          return const Color(0xFFFFEBEE); // Rouge clair
        case 'in store':
          return const Color(0xFFFFF3E0); // Orange clair
        default:
          return Colors.grey.shade100;
      }
    }

    return GestureDetector(
      onTap: () => _showOrderDetailsSheet(order, getStatusColor, getStatusBgColor),
      child: Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ══════════════════════════════════════════════
          // ROW 1: Store Name | Items Count        Price
          // ══════════════════════════════════════════════
          Row(
            children: [
              // Store Name
              Text(
                order['store'],
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 8.w),
              // Separator
              Text(
                '|',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade400),
              ),
              SizedBox(width: 8.w),
              // Items count
              Text(
                '${order['items']} Items',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
              ),
              const Spacer(),
              // Price
              Text(
                'D ${order['amount']}',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4CAF50), // Vert
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // ══════════════════════════════════════════════
          // ROW 2: Date Box + Order Info + Arrow
          // ══════════════════════════════════════════════
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Date Container
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _dateDay(order['date']?.toString() ?? ''),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      _dateMonth(order['date']?.toString() ?? ''),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 12.w),

              // Order Info Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Order ID + Type Badge
                    Row(
                      children: [
                        Text(
                          'Order ID : ${order['id']}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          '|',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        // Type Badge (In Store)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: getStatusBgColor(order['type']),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            order['type'],
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: getStatusColor(order['type']),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8.h),

                    // Date Time + Status Badge
                    Row(
                      children: [
                        Text(
                          '${order['date']} ${order['time']}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          '|',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        // Status Badge (Reserved)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: getStatusBgColor(order['status']),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            order['status'],
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: getStatusColor(order['status']),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
                size: 24.sp,
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  void _showOrderDetailsSheet(
    Map<String, dynamic> order,
    Color Function(String) getStatusColor,
    Color Function(String) getStatusBgColor,
  ) {
    final items = (order['rawItems'] as List? ?? []).whereType<Map>().toList();
    final canCancel = controller.orderIsCancelable(order);

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.75),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order #${order['id']}',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: getStatusBgColor(order['status']),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(order['status'],
                      style: TextStyle(
                          color: getStatusColor(order['status']),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(order['store'], style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp)),
            SizedBox(height: 16.h),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (_, __) => Divider(height: 16.h),
                itemBuilder: (_, i) {
                  final it = items[i];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${it['item_name'] ?? 'Item'}  x${it['quantity'] ?? 1}',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                      Text('${it['price'] ?? 0}', style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  );
                },
              ),
            ),
            Divider(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.sp)),
                Text('${order['amount']}', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.sp)),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                if (canCancel)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        controller.cancelOrder(order);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: const Text('Cancel Order'),
                    ),
                  ),
                if (canCancel) SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      controller.reorder(order);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: const Text('Reorder', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 110.h;
  @override
  double get maxExtent => 110.h;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(height: 110.h, child: child);
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return false;
  }
}
