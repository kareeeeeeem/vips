import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/delivery_driver_controller.dart';

class DeliveryDriverView extends StatelessWidget {
  const DeliveryDriverView({super.key});

  static const Color driverYellow = Color(0xFFFFC107);
  static const Color driverYellowDark = Color(0xFFFFB300);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DeliveryDriverController>(
      init: DeliveryDriverController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: _buildAppBar(context, controller),
          body: RefreshIndicator(
            onRefresh: () => controller.loadData(),
            child: _buildBody(context, controller),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    DeliveryDriverController controller,
  ) {
    return AppBar(
      backgroundColor: driverYellow,
      leading: Padding(
        padding: EdgeInsets.all(8.w),
        child: Icon(Icons.delivery_dining, size: 28.sp, color: Colors.white),
      ),
      titleSpacing: 0,
      elevation: 0,
      title: Text(
        'Delivery Driver',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: Obx(
            () => Stack(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  size: 26.sp,
                  color: Colors.white,
                ),
                if (controller.hasNotification.value)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      height: 10.w,
                      width: 10.w,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(width: 2, color: driverYellow),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          onPressed: () {
            Get.snackbar('Notifications', 'You have new notifications');
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, DeliveryDriverController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: driverYellow),
        );
      }

      return CustomScrollView(
        slivers: [
          // Permission warnings
          if (GetPlatform.isAndroid)
            SliverToBoxAdapter(
              child: Column(
                children: [
                  if (!controller.isNotificationPermissionGranted.value)
                    _buildPermissionWarning(
                      context: context,
                      controller: controller,
                      isBatteryPermission: false,
                      onTap: controller.requestNotificationPermission,
                      closeOnTap: controller.closeNotificationPermissionWarning,
                    ),
                  if (!controller.isBatteryOptimizationGranted.value)
                    _buildPermissionWarning(
                      context: context,
                      controller: controller,
                      isBatteryPermission: true,
                      onTap: controller.requestBatteryOptimization,
                      closeOnTap: controller.closeBatteryOptimizationWarning,
                    ),
                ],
              ),
            ),

          // Main content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Online/Offline toggle
                  _buildOnlineToggle(context, controller),
                  SizedBox(height: 16.h),

                  // Earnings section
                  _buildEarningsSection(context, controller),
                  SizedBox(height: 16.h),

                  // Current active order (if exists)
                  if (controller.hasActiveOrder.value)
                    _buildCurrentOrderCard(context, controller),
                  if (controller.hasActiveOrder.value) SizedBox(height: 20.h),

                  // Orders section with tabs
                  _buildOrdersSection(context, controller),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildOnlineToggle(
    BuildContext context,
    DeliveryDriverController controller,
  ) {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              controller.isOnline.value
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: controller.isOnline.value ? Colors.green : Colors.grey,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                controller.isOnline.value
                    ? 'You are Online'
                    : 'You are Offline',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Transform.scale(
              scale: 0.85,
              child: CupertinoSwitch(
                value: controller.isOnline.value,
                activeColor: Colors.green,
                onChanged: (bool value) {
                  controller.toggleOnlineStatus();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsSection(
    BuildContext context,
    DeliveryDriverController controller,
  ) {
    return Obx(
      () => Row(
        children: [
          // Today card
          Expanded(
            flex: 5,
            child: Container(
              height: 180.h,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [driverYellow, driverYellowDark],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 50.sp,
                    color: Colors.white,
                  ),
                  Spacer(),
                  Text(
                    'Today',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '\$${controller.todayEarning.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Right column
          Expanded(
            flex: 5,
            child: Column(
              children: [
                // This Week card
                Container(
                  height: 84.h,
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    color: driverYellow.withOpacity(0.85),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'This Week',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '\$${controller.weekEarning.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // Cash in hand card
                Stack(
                  children: [
                    Container(
                      height: 84.h,
                      width: double.infinity,
                      padding: EdgeInsets.only(
                        left: 12.w,
                        top: 10.h,
                        right: 36.w,
                        bottom: 10.h,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '\$${controller.cashInHand.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: driverYellow,
                            ),
                            maxLines: 1,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Cash In Hand',
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    // Vertical Adjust button
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 34.w,
                          decoration: BoxDecoration(
                            color: driverYellow,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(16.r),
                              bottomRight: Radius.circular(16.r),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: driverYellow.withOpacity(0.3),
                                blurRadius: 6,
                                offset: Offset(-2, 0),
                              ),
                            ],
                          ),
                          child: Center(
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: Text(
                                'Adjust Now',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
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
    );
  }

  Widget _buildCurrentOrderCard(
    BuildContext context,
    DeliveryDriverController controller,
  ) {
    return Obx(() {
      final order = controller.currentOrder.value;
      if (order == null) return SizedBox.shrink();

      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [driverYellow.withOpacity(0.2), Colors.orange.shade50],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: driverYellow, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: driverYellow,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.motorcycle, size: 16.sp, color: Colors.white),
                      SizedBox(width: 6.w),
                      Text(
                        'ACTIVE ORDER',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Text(
                  order['orderId'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Store info
            Row(
              children: [
                Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.store,
                    color: Colors.orange.shade700,
                    size: 28.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['storeName'],
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        order['storeAddress'],
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: controller.callStore,
                  icon: Icon(Icons.phone, color: driverYellow),
                ),
              ],
            ),

            SizedBox(height: 12.h),
            Divider(color: Colors.grey.shade300),
            SizedBox(height: 12.h),

            // Customer info
            Row(
              children: [
                Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.blue.shade700,
                    size: 28.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['customerName'],
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        order['customerAddress'],
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: controller.callCustomer,
                  icon: Icon(Icons.phone, color: Colors.green),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.startNavigation,
                    icon: Icon(Icons.navigation, size: 18.sp),
                    label: Text(
                      'Navigate',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.completeDelivery,
                    icon: Icon(Icons.check_circle, size: 18.sp),
                    label: Text(
                      'Complete',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
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

  Widget _buildOrdersSection(
    BuildContext context,
    DeliveryDriverController controller,
  ) {
    return Obx(
      () => Column(
        children: [
          // Tabs
          Row(
            children: List.generate(controller.orderTabs.length, (index) {
              bool isSelected = controller.selectedOrderTab.value == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.setOrderTab(index),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? driverYellow : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      controller.orderTabs[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? driverYellow : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 16.h),

          // Orders list
          ...controller.getFilteredOrders().asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> order = entry.value;
            return _buildOrderCard(context, controller, order, index);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    DeliveryDriverController controller,
    Map<String, dynamic> order,
    int index,
  ) {
    return Obx(() {
      bool isExpanded = controller.expandedOrderIndex.value == index;

      return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isExpanded ? driverYellow : Colors.grey.shade200,
            width: isExpanded ? 2 : 1,
          ),
          boxShadow:
              isExpanded
                  ? [
                    BoxShadow(
                      color: driverYellow.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ]
                  : [],
        ),
        child: Column(
          children: [
            // Header
            InkWell(
              onTap: () => controller.toggleOrderCard(index),
              borderRadius: BorderRadius.circular(16.r),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Order ID: ',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          order['orderId'],
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              order['status'],
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            _getStatusText(order['status']),
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: _getStatusColor(order['status']),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Store info
                    Row(
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.store,
                            color: Colors.orange.shade700,
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order['storeName'],
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${order['itemsCount']} items • ${order['distance']}',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: driverYellow,
                          size: 24.sp,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Expanded content
            if (isExpanded)
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                child: Column(
                  children: [
                    Divider(color: Colors.grey.shade200),
                    SizedBox(height: 12.h),

                    // Customer info
                    Row(
                      children: [
                        Icon(Icons.person, size: 20.sp, color: Colors.blue),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order['customerName'],
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                order['customerAddress'],
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12.h),

                    // Payment info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery Fee',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              '\$${order['deliveryFee'].toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              '\$${order['totalAmount'].toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Action buttons
                    if (order['status'] == 'pending')
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.red.shade300,
                                  width: 1.5,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(
                                'Decline',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () => controller.acceptOrder(order),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: driverYellow,
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Accept Order',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => controller.viewOrderDetails(order),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: driverYellow,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'picking_up':
        return Colors.blue;
      case 'delivering':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'New Request';
      case 'picking_up':
        return 'Picking Up';
      case 'delivering':
        return 'Delivering';
      case 'delivered':
        return 'Delivered';
      default:
        return status;
    }
  }

  Widget _buildPermissionWarning({
    required BuildContext context,
    required DeliveryDriverController controller,
    required bool isBatteryPermission,
    required Function() onTap,
    required Function() closeOnTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: driverYellow.withOpacity(0.9)),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  if (isBatteryPermission)
                    Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: Icon(
                        Icons.warning_rounded,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            isBatteryPermission
                                ? 'For better performance, allow notification to run in background'
                                : 'Notification is disabled, please allow notification',
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.arrow_circle_right_rounded,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20.w),
                ],
              ),
            ),
            Positioned(
              top: 5.h,
              right: 5.w,
              child: InkWell(
                onTap: closeOnTap,
                child: Icon(Icons.clear, color: Colors.white, size: 18.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
