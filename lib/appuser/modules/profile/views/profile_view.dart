import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vip/appuser/modules/packages/views/packages_view.dart';
import 'package:vip/appuser/modules/settings/views/settings_view.dart';

import '../../gift/views/gift_view.dart';
import '../../vips_club_history/views/vips_club_history_view.dart';
import '../controllers/profile_controller.dart';
import 'widgets/account_switcher_widget.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileController());
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
                                      Colors.orange.withOpacity(0.85),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(6.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                      spreadRadius: -2,
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: () {},
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
                  onTap: () => Get.to(() => const VipsClubHistoryView()),
                  child: CircleAvatar(
                    radius: 40.r,
                    backgroundColor: primaryColor.withOpacity(0.1),
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
                          Text(
                            'today 4:10 PM',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(width: 14.w),

                      // Settings Icon
                      InkWell(
                        onTap: () {
                          Get.to(() => SettingsView());
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
                isBusiness ? 'Business Name' : controller.userName.value,
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
                            color: primaryColor.withOpacity(0.1),
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
                            onTap: () => Get.to(() => PackagesView()),
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
                                Text(
                                  'Platinum',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: primaryColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
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
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
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
                                  '1',
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
                        color: primaryColor.withOpacity(0.1),
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

            // Row: Wallet Points + Switch to
            Row(
              children: [
                // Wallet Points (plus large avec flèche)
                Expanded(
                  flex: 2,
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
                                Row(
                                  children: [
                                    Text(
                                      'expiring on 31/12/2025',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Icon(
                                      Icons.info_outline,
                                      size: 12.sp,
                                      color: Colors.grey.shade400,
                                    ),
                                  ],
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

                SizedBox(width: 10.w),

                // Switch to button
                GestureDetector(
                  onTap: controller.showRoleSwitcher,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 21.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Switch',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            height: 1.6,
                            fontSize: 11.sp,
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'to',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            height: 1.6,
                            fontSize: 11.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Section spécifique selon le rôle
            if (currentRole == 'Vendor') ...[
              SizedBox(height: 12.h),
              _buildVendorStatsSection(primaryColor),
            ] else if (currentRole == 'Agent') ...[
              SizedBox(height: 16.h),
              _buildAgentSection(primaryColor),
            ] else if (isBusiness) ...[
              SizedBox(height: 16.h),
              _buildBusinessSection(primaryColor),
            ],

            // ─── Account Switcher ─────────────────────────────────────
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: () => showAccountSwitcher(Get.context!),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icons stack (like Meta)
                    SizedBox(
                      width: 56.w,
                      height: 36.h,
                      child: Stack(
                        children: [
                          // Merchant icon
                          Positioned(
                            right: 0,
                            child: Container(
                              width: 32.w,
                              height: 32.w,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF0F172A),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.storefront_rounded,
                                color: Colors.white,
                                size: 16.sp,
                              ),
                            ),
                          ),
                          // Customer icon (on top)
                          Positioned(
                            left: 0,
                            child: Container(
                              width: 32.w,
                              height: 32.w,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFF97316), Color(0xFFEAB308)],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF0F172A),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 16.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Switch Account',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Customer  •  Merchant',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.white.withOpacity(0.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'Switch',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildVendorStatsSection(Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Store Analytics',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'This month',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Icon(Icons.trending_up_rounded, color: primaryColor, size: 22.sp),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('45', 'Products', primaryColor),
              _buildStatColumn('234', 'Sales', primaryColor),
              _buildStatColumnWithSuffix(
                '12.5K',
                'Revenue',
                'TND',
                primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgentSection(Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Deliveries',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
              Icon(
                Icons.delivery_dining_rounded,
                color: primaryColor,
                size: 22.sp,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('24', 'Total', primaryColor),
              _buildStatColumn('18', 'Completed', primaryColor),
              _buildStatColumn('6', 'Pending', primaryColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessSection(Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Network',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
              Icon(Icons.business_rounded, color: primaryColor, size: 20.sp),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('5', 'Stores', primaryColor),
              _buildStatColumn('12', 'Drivers', primaryColor),
              _buildStatColumn('234', 'Customers', primaryColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, Color primaryColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: primaryColor,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumnWithSuffix(
    String value,
    String label,
    String suffix,
    Color primaryColor,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
            SizedBox(width: 4.w),
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                suffix,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: primaryColor.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
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
            final badge = index == 0 ? 2 : (index == 3 ? 1 : 0);

            return Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: _buildServiceIcon(
                service['icon'],
                service['title'],
                badge,
                primaryColor,
                () {
                  final route = service['route'];
                  if (route == '/gift') {
                    Get.to(() => GiftView());
                  } else {
                    Get.toNamed(route);
                  }
                },
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
              color: Colors.black.withOpacity(0.05),
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
                        value: 0.25,
                        strokeWidth: 4,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '250',
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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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

          _buildRequirement('Choose Payment Method', false),
          SizedBox(height: 8.h),
          _buildRequirement('Verify Your Account now', false),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, bool isCompleted) {
    return Row(
      children: [
        Icon(Icons.close_rounded, color: Colors.red, size: 20.sp),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
              color: Colors.black.withOpacity(0.05),
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
                color: primaryColor.withOpacity(0.1),
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

  // VARIANTE 1 : Layout Vertical avec date en haut
  Widget _buildOrderItemVariant1(Map<String, dynamic> order) {
    Color getStatusColor(String colorName) {
      switch (colorName) {
        case 'blue':
          return Colors.blue;
        case 'purple':
          return Colors.purple;
        case 'green':
          return Colors.green;
        case 'orange':
          return Colors.orange;
        default:
          return Colors.grey;
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête : Date et Montant
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16.sp,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '${order['date']}  ${order['time']}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                'D ${order['amount']}',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Nom du magasin
          Text(
            order['store'],
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),

          SizedBox(height: 6.h),

          // Order ID et Items
          Text(
            'Order ID : ${order['id']}  |  ${order['items']} Items',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
          ),

          SizedBox(height: 10.h),

          // Bas : Type, Status et Flèche
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      order['type'],
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusColor(
                        order['statusColor'],
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      order['status'],
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: getStatusColor(order['statusColor']),
                      ),
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // VARIANTE 2 : Layout avec badge date à droite
  Widget _buildOrderItemVariant2(Map<String, dynamic> order) {
    Color getStatusColor(String colorName) {
      switch (colorName) {
        case 'blue':
          return Colors.blue;
        case 'purple':
          return Colors.purple;
        case 'green':
          return Colors.green;
        case 'orange':
          return Colors.orange;
        default:
          return Colors.grey;
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom magasin et montant
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        order['store'],
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'D ${order['amount']}',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 6.h),

                // Order ID
                Text(
                  'Order ID : ${order['id']}  |  ${order['items']} Items',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),

                SizedBox(height: 8.h),

                // Type et statut
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        order['type'],
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: getStatusColor(
                          order['statusColor'],
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        order['status'],
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: getStatusColor(order['statusColor']),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 6.h),

                // Heure
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${order['date']}  ${order['time']}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 12.w),

          // Badge date à droite
          Column(
            children: [
              Container(
                width: 52.w,
                height: 52.h,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.orange.shade200, width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      order['date'].split(' ')[0],
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      order['date'].split(' ')[1],
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // VARIANTE 3 : Layout compact en 2 lignes
  Widget _buildOrderItemVariant3(Map<String, dynamic> order) {
    Color getStatusColor(String colorName) {
      switch (colorName) {
        case 'blue':
          return Colors.blue;
        case 'purple':
          return Colors.purple;
        case 'green':
          return Colors.green;
        case 'orange':
          return Colors.orange;
        default:
          return Colors.grey;
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Ligne 1 : Infos principales
          Row(
            children: [
              // Badge date compact
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  order['date'].split(' ')[0] +
                      ' ' +
                      order['date'].split(' ')[1],
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),

              SizedBox(width: 10.w),

              Expanded(
                child: Text(
                  order['store'],
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),

              Text(
                'D ${order['amount']}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange,
                ),
              ),

              SizedBox(width: 8.w),

              Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: Colors.grey.shade400,
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // Ligne 2 : Détails
          Row(
            children: [
              Text(
                'ID: ${order['id']}',
                style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
              ),

              SizedBox(width: 12.w),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  order['type'],
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: getStatusColor(order['statusColor']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  order['status'],
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: getStatusColor(order['statusColor']),
                  ),
                ),
              ),

              Spacer(),

              Icon(Icons.access_time, size: 11.sp, color: Colors.grey.shade500),
              SizedBox(width: 3.w),
              Text(
                order['time'],
                style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
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

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                      order['date'].split(' ')[0], // "10"
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      order['date'].split(' ')[1], // "Mar"
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
