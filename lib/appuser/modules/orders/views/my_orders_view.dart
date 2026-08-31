import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vip/appuser/design_system/atoms/app_colors.dart';

import '../controllers/order_tracking_controller.dart';
import '../controllers/orders_controller.dart';

/// The customer's own orders.
///
/// The app knew these endpoints existed — they were in its constants file —
/// but nothing listed them, so an order disappeared the moment it was placed.
class MyOrdersView extends GetView<OrdersController> {
  const MyOrdersView({super.key});

  static const Color _muted = Color(0xFF9CA3AF);
  static const Color _line = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 20.sp, color: Colors.black87),
          onPressed: Get.back,
        ),
        title: Text('My orders',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800)),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.isNotEmpty && controller.orders.isEmpty) {
          return _buildMessage(controller.errorMessage.value, retry: true);
        }
        if (controller.orders.isEmpty) {
          return _buildMessage('You have not placed an order yet.');
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          color: AppColors.AppPrimaryColor,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
            itemCount: controller.orders.length,
            itemBuilder: (context, i) => _buildCard(controller.orders[i]),
          ),
        );
      }),
    );
  }

  Widget _buildMessage(String text, {bool retry = false}) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 0.22.sh),
        Icon(Icons.receipt_long_outlined, size: 40.sp, color: _line),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, height: 1.4, color: _muted)),
        ),
        if (retry) ...[
          SizedBox(height: 14.h),
          Center(
            child: ElevatedButton(
              onPressed: controller.load,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.AppPrimaryColor),
              child: const Text('Try again'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCard(Map<String, dynamic> order) {
    final id = '${order['_id'] ?? ''}';
    final number = '${order['orderNumber'] ?? ''}';
    final status = '${order['status'] ?? 'pending'}';
    final total = order['totalAmount'];
    final placed = DateTime.tryParse('${order['createdAt'] ?? ''}');
    final items = order['items'];
    final count = items is List ? items.length : 0;
    final colour = _statusColour(status);

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: id.isEmpty
            ? null
            // A literal path, like the rest of this app: app_routes.dart is a
            // `part of` app_pages.dart and cannot be imported from a view.
            : () => Get.toNamed('/order-tracking', arguments: {'orderId': id}),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: _line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Order #$number',
                        style: TextStyle(
                            fontSize: 13.5.sp, fontWeight: FontWeight.w800)),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: colour.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      OrderTrackingController.label(status),
                      style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: colour),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                '$count item${count == 1 ? '' : 's'}'
                '${total is num ? ' · D ${total.toStringAsFixed(3)}' : ''}',
                style: TextStyle(fontSize: 11.5.sp, color: Colors.black54),
              ),
              if (placed != null) ...[
                SizedBox(height: 3.h),
                Text(DateFormat('d MMM yyyy, HH:mm').format(placed.toLocal()),
                    style: TextStyle(fontSize: 10.5.sp, color: _muted)),
              ],
              SizedBox(height: 10.h),
              Row(
                children: [
                  Icon(Icons.timeline_rounded,
                      size: 14.sp, color: AppColors.AppPrimaryColor),
                  SizedBox(width: 5.w),
                  Text('Track this order',
                      style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.AppPrimaryColor)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColour(String status) => switch (status) {
        'delivered' || 'picked_up' => const Color(0xFF10B981),
        'canceled' || 'cancelled' => const Color(0xFFDC2626),
        'refunded' || 'refund_requested' => const Color(0xFFD97706),
        'pending' => const Color(0xFFD97706),
        _ => AppColors.AppPrimaryColor,
      };
}
