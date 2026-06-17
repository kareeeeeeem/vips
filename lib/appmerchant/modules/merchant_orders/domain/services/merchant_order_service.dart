import 'package:vip/appmerchant/modules/merchant_orders/domain/models/merchant_order_details_model.dart';
import 'package:vip/appmerchant/modules/merchant_orders/domain/models/merchant_order_model.dart';
import 'package:vip/appmerchant/modules/merchant_orders/domain/repositories/merchant_order_repository_interface.dart';
import 'package:vip/appmerchant/modules/merchant_orders/domain/services/merchant_order_service_interface.dart';
import 'package:vip/appmerchant/core/common/models/response_model.dart';

class MerchantOrderService implements MerchantOrderServiceInterface {
  final MerchantOrderRepositoryInterface orderRepositoryInterface;

  MerchantOrderService({required this.orderRepositoryInterface});

  @override
  Future<List<MerchantOrder>?> getCurrentOrders() async {
    return await orderRepositoryInterface.getCurrentOrders();
  }

  @override
  Future<PaginatedMerchantOrderModel?> getOrders(
    int offset,
    String status,
  ) async {
    return await orderRepositoryInterface.getOrders(offset, status);
  }

  @override
  Future<PaginatedMerchantOrderModel?> getCompletedOrders(int offset) async {
    return await orderRepositoryInterface.getCompletedOrders(offset);
  }

  @override
  Future<MerchantOrder?> getOrderWithId(int orderId) async {
    return await orderRepositoryInterface.getOrderWithId(orderId);
  }

  @override
  Future<List<MerchantOrderDetailsModel>?> getOrderDetails(int orderId) async {
    return await orderRepositoryInterface.getOrderDetails(orderId);
  }

  @override
  Future<ResponseModel> updateOrderStatus(
    MerchantOrderStatusUpdateBody updateStatusBody,
  ) async {
    return await orderRepositoryInterface.updateOrderStatus(updateStatusBody);
  }

  @override
  Future<List<String>?> getCancelReasons() async {
    return await orderRepositoryInterface.getCancelReasons();
  }

  @override
  Future<Map<String, dynamic>?> getOrderStats() async {
    return await orderRepositoryInterface.getOrderStats();
  }

  @override
  Map<String, dynamic> calculateOrderTotals(MerchantOrder order) {
    double subtotal = 0;
    double taxAmount = 0;
    double discountAmount = 0;
    double deliveryCharge = order.deliveryCharge ?? 0;
    double total = 0;

    // Calculate from order details if available
    if (order.orderDetails != null) {
      for (var detail in order.orderDetails!) {
        subtotal += (detail.price ?? 0) * (detail.quantity ?? 1);
        taxAmount += detail.taxAmount ?? 0;
        discountAmount += detail.discountOnItem ?? 0;
      }
    } else {
      // Use order-level amounts
      subtotal = order.orderAmount ?? 0;
      taxAmount = order.totalTaxAmount ?? 0;
      discountAmount = order.couponDiscountAmount ?? 0;
    }

    total = subtotal + taxAmount + deliveryCharge - discountAmount;

    return {
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'deliveryCharge': deliveryCharge,
      'total': total,
      'currency': 'USD', // Assuming USD, can be configurable
    };
  }
}
