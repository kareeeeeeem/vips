import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/merchant_order_controller.dart';
import '../../domain/models/merchant_order_model.dart';
import '../../../../routes/merchant_routes.dart';

class OrderCard extends GetView<MerchantOrderController> {
  final MerchantOrder order;

  const OrderCard({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        MerchantRoutes.ORDER_DETAIL,
        arguments: order.id,
      ),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildOrderId(),
                _buildStatusBadge(),
              ],
            ),

            SizedBox(height: 8.h),

            // Customer Info
            _buildCustomerInfo(),

            SizedBox(height: 12.h),

            // Order Items Preview
            _buildOrderItemsPreview(),

            SizedBox(height: 12.h),

            // Order Footer
            _buildOrderFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderId() {
    return Row(
      children: [
        Icon(Icons.shopping_bag_outlined, size: 16.sp, color: const Color(0xFF6B7280)),
        SizedBox(width: 4.w),
        Text(
          'Order #${order.id ?? '-'}',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final statusColor = controller.getOrderStatusColor(order.orderStatus);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            controller.getOrderStatusIcon(order.orderStatus),
            size: 12.sp,
            color: statusColor,
          ),
          SizedBox(width: 4.w),
          Text(
            (order.orderStatus ?? 'pending').toUpperCase(),
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20.sp,
          backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
          child: Text(
            '${order.customer?.fName?.substring(0, 1) ?? 'U'}${order.customer?.lName?.substring(0, 1) ?? ''}',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF10B981),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${order.customer?.fName ?? ''} ${order.customer?.lName ?? 'Guest'}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
              if (order.customer?.phone != null)
                Text(
                  order.customer!.phone!,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
            ],
          ),
        ),
        Icon(Icons.arrow_forward_ios, size: 16.sp, color: const Color(0xFF9CA3AF)),
      ],
    );
  }

  Widget _buildOrderItemsPreview() {
    final itemsCount = order.detailsCount ?? 0;
    final orderTotal = order.orderAmount ?? 0;
    final paymentMethod = order.paymentMethod ?? 'cash';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: const Color(0xFFE5E7EB)),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$itemsCount items',
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF6B7280),
              ),
            ),
            Text(
              '\$${orderTotal.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111827),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                paymentMethod.toUpperCase(),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
            if (order.createdAt != null)
              Text(
                controller.formatDate(order.createdAt),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderFooter() {
    // Show action buttons for pending orders
    if (order.orderStatus == 'pending') {
      return Column(
        children: [
          Divider(color: const Color(0xFFE5E7EB)),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showCancelDialog(),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: Text(
                    'Reject',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _acceptOrder(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                  ),
                  child: Text(
                    'Accept',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  void _showCancelDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.updateOrderStatus(order.id!, 'canceled', reason: 'Merchant canceled');
            },
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _acceptOrder() {
    controller.updateOrderStatus(order.id!, 'confirmed');
  }
}