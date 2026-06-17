import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/merchant_order_controller.dart';
import '../domain/models/merchant_order_model.dart';
import '../domain/models/merchant_order_details_model.dart';

class MerchantOrderDetailView extends GetView<MerchantOrderController> {
  const MerchantOrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final int orderId = Get.arguments as int;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getOrderDetails(orderId);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.status.value == MerchantOrderViewStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF10B981)),
          );
        }

        if (controller.status.value == MerchantOrderViewStatus.error) {
          return _buildErrorState();
        }

        final order = controller.currentOrder.value;
        if (order == null) {
          return const Center(child: Text('Order not found'));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(order),
              SizedBox(height: 16.h),
              _buildCustomerCard(order),
              SizedBox(height: 16.h),
              _buildOrderItemsCard(),
              SizedBox(height: 16.h),
              _buildDeliveryCard(order),
              SizedBox(height: 16.h),
              _buildPaymentCard(order),
              SizedBox(height: 24.h),
              _buildActionButtons(order),
              SizedBox(height: 24.h),
            ],
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
        onPressed: () => Get.back(),
      ),
      title: Obx(() {
        final id = controller.currentOrder.value?.id;
        return Text(
          id != null ? 'Order #$id' : 'Order Detail',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111827),
          ),
        );
      }),
      centerTitle: true,
    );
  }

  Widget _buildStatusCard(MerchantOrder order) {
    final statusColor = controller.getOrderStatusColor(order.orderStatus);
    final statusIcon = controller.getOrderStatusIcon(order.orderStatus);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (order.orderStatus ?? 'pending').toUpperCase(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  controller.formatDate(order.createdAt),
                  style: TextStyle(fontSize: 12.sp, color: const Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: order.paymentStatus == 'paid'
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              (order.paymentStatus ?? 'unpaid').toUpperCase(),
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: order.paymentStatus == 'paid' ? Colors.green : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(MerchantOrder order) {
    final customer = order.customer;
    return _card(
      title: 'Customer',
      icon: Icons.person_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.1),
                child: Text(
                  '${customer?.fName?.substring(0, 1) ?? 'U'}${customer?.lName?.substring(0, 1) ?? ''}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${customer?.fName ?? ''} ${customer?.lName ?? 'Guest'}'.trim(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  if (customer?.phone != null)
                    Text(
                      customer!.phone!,
                      style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
                    ),
                  if (customer?.email != null)
                    Text(
                      customer!.email!,
                      style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
                    ),
                ],
              ),
            ],
          ),
          if (order.orderNote != null && order.orderNote!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFF59E0B), size: 16),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      order.orderNote!,
                      style: TextStyle(fontSize: 12.sp, color: const Color(0xFF78350F)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderItemsCard() {
    return _card(
      title: 'Order Items',
      icon: Icons.shopping_bag_outlined,
      child: Obx(() {
        final items = controller.orderDetails;
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Text(
                'No item details available',
                style: TextStyle(fontSize: 13.sp, color: const Color(0xFF9CA3AF)),
              ),
            ),
          );
        }
        return Column(
          children: items.map((item) => _buildItemRow(item)).toList(),
        );
      }),
    );
  }

  Widget _buildItemRow(MerchantOrderDetailsModel item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: item.itemImageFullUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      item.itemImageFullUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.fastfood_outlined, color: Color(0xFF9CA3AF)),
                    ),
                  )
                : const Icon(Icons.fastfood_outlined, color: Color(0xFF9CA3AF)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName ?? 'Item',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                Text(
                  'x${item.quantity ?? 1}',
                  style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          Text(
            '\$${((item.price ?? 0) * (item.quantity ?? 1)).toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(MerchantOrder order) {
    final address = order.deliveryAddress;
    if (address == null) return const SizedBox.shrink();

    return _card(
      title: 'Delivery Address',
      icon: Icons.location_on_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (address.contactPersonName != null)
            _infoRow(Icons.person_outline, address.contactPersonName!),
          if (address.contactPersonNumber != null)
            _infoRow(Icons.phone_outlined, address.contactPersonNumber!),
          if (address.address != null)
            _infoRow(Icons.home_outlined, address.address!),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(MerchantOrder order) {
    final totals = controller.calculateOrderTotals(order);
    return _card(
      title: 'Payment Summary',
      icon: Icons.receipt_outlined,
      child: Column(
        children: [
          _priceRow('Subtotal', totals['subtotal'] ?? 0.0),
          if ((totals['taxAmount'] ?? 0.0) > 0)
            _priceRow('Tax', totals['taxAmount'] ?? 0.0),
          if ((totals['deliveryCharge'] ?? 0.0) > 0)
            _priceRow('Delivery', totals['deliveryCharge'] ?? 0.0),
          if ((totals['discountAmount'] ?? 0.0) > 0)
            _priceRow('Discount', -(totals['discountAmount'] ?? 0.0), isDiscount: true),
          Divider(color: const Color(0xFFE5E7EB), height: 16.h),
          _priceRow('Total', totals['total'] ?? 0.0, isTotal: true),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.payment_outlined, size: 14.sp, color: const Color(0xFF6B7280)),
              SizedBox(width: 6.w),
              Text(
                (order.paymentMethod ?? 'cash').toUpperCase(),
                style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(MerchantOrder order) {
    final status = order.orderStatus?.toLowerCase();
    final nextStatus = _getNextStatus(status);
    if (nextStatus == null) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final success = await controller.updateOrderStatus(order.id!, nextStatus);
              if (success) Get.back();
            },
            icon: Icon(_getNextStatusIcon(nextStatus), size: 18.sp),
            label: Text(
              _getNextStatusLabel(nextStatus),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
          ),
        ),
        if (status == 'pending') ...[
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showCancelDialog(order),
              icon: Icon(Icons.cancel_outlined, size: 18.sp),
              label: Text(
                'Cancel Order',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String? _getNextStatus(String? current) {
    switch (current) {
      case 'pending':
        return 'confirmed';
      case 'confirmed':
        return 'processing';
      case 'processing':
        return 'ready';
      case 'ready':
        return 'delivered';
      default:
        return null;
    }
  }

  String _getNextStatusLabel(String next) {
    switch (next) {
      case 'confirmed':
        return 'Accept Order';
      case 'processing':
        return 'Start Processing';
      case 'ready':
        return 'Mark as Ready';
      case 'delivered':
        return 'Mark as Delivered';
      default:
        return 'Update Status';
    }
  }

  IconData _getNextStatusIcon(String next) {
    switch (next) {
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'processing':
        return Icons.autorenew;
      case 'ready':
        return Icons.fastfood_outlined;
      case 'delivered':
        return Icons.delivery_dining;
      default:
        return Icons.update;
    }
  }

  void _showCancelDialog(MerchantOrder order) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await controller.updateOrderStatus(
                order.id!,
                'canceled',
                reason: 'Merchant canceled',
              );
              if (success) Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _card({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: const Color(0xFF10B981)),
              SizedBox(width: 6.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF374151),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14.sp, color: const Color(0xFF9CA3AF)),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF374151)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, double amount, {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14.sp : 13.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? const Color(0xFF111827) : const Color(0xFF6B7280),
            ),
          ),
          Text(
            '${isDiscount ? '-' : ''}\$${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 14.sp : 13.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount
                  ? Colors.green
                  : isTotal
                      ? const Color(0xFF111827)
                      : const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            'Failed to load order',
            style: TextStyle(fontSize: 16.sp, color: const Color(0xFF6B7280)),
          ),
          SizedBox(height: 12.h),
          ElevatedButton(
            onPressed: () => controller.getOrderDetails(Get.arguments as int),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
