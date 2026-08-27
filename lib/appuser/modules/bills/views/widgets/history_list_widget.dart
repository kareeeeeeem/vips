import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vip/appuser/modules/Cart/views/widgets/order_request.dart' hide OrderItem;
import 'package:vip/core/services/api_service.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

import '../../controllers/bills_controller.dart';

class HistoryListWidget extends GetView<BillsController> {
  const HistoryListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Date Range and Results Count
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
                    border: Border.all(color: Colors.grey.shade300),
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
              Obx(() => Text(
                '${controller.orders.length} Result Found',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              )),
            ],
          ),
        ),

        // Orders List
        Expanded(
          child: Obx(() {
            if (controller.orders.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade400),
                      SizedBox(height: 12.h),
                      Text(
                        'No orders yet.',
                        style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12),
              itemCount: controller.orders.length,
              itemBuilder: (context, index) {
                final order = controller.orders[index];
                return _buildOrderCard(order, index);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildOrderCard(OrderItem order, int index) {
    return GestureDetector(
      onTap: () => controller.toggleOrder(index),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Row 1: Order ID + Status Badge + Price
                  Row(
                    children: [
                      // Order ID
                      Text(
                        'Order #',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        order.orderId,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Séparateur vertical
                      Container(
                        width: 1,
                        height: 14.h,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(width: 8.w),
                      // Real order status (Pending/Confirmed/Delivered/Cancelled/...)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(order.type),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          order.type,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Price
                      Text(
                        order.price,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFF6B35),
                        ),
                      ),
                    ],
                  ),

                  // Ligne pointillée
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: _buildDashedLine(),
                  ),

                  // Row 2: Date + Info + Menu
                  Row(
                    children: [
                      // Date Container
                      Container(
                        width: 55.w,
                        height: 55.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFBDBDBD),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              order.day,
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              order.month,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),

                      // Info Column — real item names + real store, not a
                      // fixed "Mobil Card Type" / "VIPs App" label shown
                      // for every single order regardless of what it was.
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    order.cardType,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF4CAF50),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (order.itemCount > 1)
                                  Text(
                                    ' (${order.itemCount} items)',
                                    style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                                  ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.storefront, size: 14.sp, color: const Color(0xFFFF6B35)),
                                SizedBox(width: 4.w),
                                Flexible(
                                  child: Text(
                                    order.store,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFFFF6B35),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Menu Icon
                      GestureDetector(
                        onTap: () => _showOptionsMenu(order),
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          child: Icon(
                            Icons.more_vert,
                            color: Colors.grey.shade600,
                            size: 22.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ══════════════════════════════════════════════
            // EXPANDABLE DETAILS (Fond blanc)
            // ══════════════════════════════════════════════
            Obx(() {
              final isExpanded = controller.expandedOrders[index];
              return AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Container(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDetailRow('Order Number:', order.transId),
                      SizedBox(height: 12.h),
                      _buildDetailRow('Items', '${order.itemCount}'),
                      SizedBox(height: 12.h),
                      _buildDetailRow('Date', order.fullDate),
                      if (order.rating > 0) ...[
                        SizedBox(height: 12.h),
                        _buildDetailRow('Your Rating', '${'★' * order.rating}${'☆' * (5 - order.rating)}',
                            valueColor: Colors.amber.shade700),
                      ],
                      SizedBox(height: 20.h),

                      // View Order Button — opens the real order (fetched
                      // live via GET /order/:id), not '/deal-details' with
                      // just an order id, which that screen can't render.
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.to(() => OrderRequestView(), arguments: {'orderId': order.id});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'View Order',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                crossFadeState:
                    isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              );
            }),
          ],
        ),
      ),
    );
  }

  // order.type is bills_controller.dart's _formatStatusLabel() output
  // ("Picked Up", "Refund Requested", etc.), not the raw enum — this used to
  // only recognize 5 of the real 11 Order.status values (models/Order.js),
  // so confirmed/processing/ready/handover/picked_up/refund_requested all
  // fell through to flat grey regardless of where the order actually was.
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return const Color(0xFF22C55E);
      case 'cancelled':
      case 'canceled':
        return const Color(0xFFEF4444);
      case 'pending':
        return const Color(0xFF3B82F6);
      case 'confirmed':
      case 'processing':
        return const Color(0xFF2196F3);
      case 'ready':
      case 'handover':
      case 'picked up':
        return const Color(0xFF009688);
      case 'refund requested':
      case 'refunded':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF4A4A4A);
    }
  }

  /// Menu d'options — share/download receipt, plus a real "Rate this
  /// order" action (POST /order/:id/review) when it hasn't been rated yet.
  void _showOptionsMenu(OrderItem order) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            if (order.rating == 0 && order.type.toLowerCase() == 'delivered')
              ListTile(
                leading: Icon(Icons.star_outline, color: Colors.amber.shade700),
                title: const Text('Rate this Order'),
                onTap: () {
                  Get.back();
                  _showRateDialog(order);
                },
              ),
            if (order.type.toLowerCase() == 'delivered')
              ListTile(
                leading: const Icon(Icons.assignment_return_outlined, color: Color(0xFFEF4444)),
                title: const Text('Request Refund'),
                onTap: () {
                  Get.back();
                  _showRequestRefundDialog(order);
                },
              ),
            ListTile(
              leading: Icon(Icons.share_outlined, color: Colors.grey.shade700),
              title: const Text('Share Receipt'),
              onTap: () {
                Get.back();
                _shareReceipt(order);
              },
            ),
            ListTile(
              leading: Icon(Icons.download_outlined, color: Colors.grey.shade700),
              title: const Text('Download Receipt'),
              onTap: () {
                Get.back();
                _shareReceipt(order);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRateDialog(OrderItem order) {
    final ratingRx = 5.obs;
    final reviewController = TextEditingController();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Rate Order #${order.orderId}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 16.h),
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => IconButton(
                  onPressed: () => ratingRx.value = i + 1,
                  icon: Icon(
                    i < ratingRx.value ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 28,
                  ),
                )),
              )),
              TextField(
                controller: reviewController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Leave a review (optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final res = await ApiService().post('/order/${order.id}/review', {
                      'rating': ratingRx.value,
                      'review': reviewController.text.trim(),
                    });
                    Get.back();
                    if (res.success) {
                      safeSnackbar('Thank you!', 'Your rating was submitted.', snackPosition: SnackPosition.BOTTOM);
                      Get.find<BillsController>().fetchOrderHistory();
                    } else {
                      safeSnackbar('Error', res.message, snackPosition: SnackPosition.BOTTOM);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B35)),
                  child: const Text('Submit Rating', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRequestRefundDialog(OrderItem order) {
    final reasonController = TextEditingController();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Request Refund — Order #${order.orderId}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 8.h),
              Text('The merchant will review your request and approve or deny it.',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
              SizedBox(height: 16.h),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Reason for refund',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final res = await ApiService().put('/order/${order.id}/request-refund', {
                          'reason': reasonController.text.trim(),
                        });
                        Get.back();
                        if (res.success) {
                          safeSnackbar('Refund Requested', 'The merchant will review your request.', snackPosition: SnackPosition.BOTTOM);
                          Get.find<BillsController>().fetchOrderHistory();
                        } else {
                          safeSnackbar('Error', res.message, snackPosition: SnackPosition.BOTTOM);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                      child: const Text('Submit', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareReceipt(OrderItem order) {
    final receiptText = 'VIPs Receipt\n'
        'Order: #${order.orderId}\n'
        'Status: ${order.type}\n'
        'Store: ${order.store}\n'
        'Date: ${order.fullDate}\n'
        'Items: ${order.itemCount}\n'
        'Total: ${order.price}';
    SharePlus.instance.share(
      ShareParams(text: receiptText, subject: 'VIPs Receipt #${order.orderId}'),
    );
  }

  /// Ligne pointillée
  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashWidth = 5.0;
        final dashSpace = 3.0;
        final dashCount =
            (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return Container(
              width: dashWidth,
              height: 1,
              color: Colors.grey.shade400,
            );
          }),
        );
      },
    );
  }

  /// Ligne de détail
  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
