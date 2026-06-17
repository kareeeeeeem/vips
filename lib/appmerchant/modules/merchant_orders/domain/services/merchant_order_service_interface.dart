import 'package:vip/appmerchant/modules/merchant_orders/domain/models/merchant_order_details_model.dart';
import 'package:vip/appmerchant/modules/merchant_orders/domain/models/merchant_order_model.dart';
import 'package:vip/appmerchant/core/common/models/response_model.dart';

abstract class MerchantOrderServiceInterface {
  /// Get current/new orders for merchant
  Future<List<MerchantOrder>?> getCurrentOrders();

  /// Get paginated orders with status filter
  Future<PaginatedMerchantOrderModel?> getOrders(int offset, String status);

  /// Get completed orders
  Future<PaginatedMerchantOrderModel?> getCompletedOrders(int offset);

  /// Get specific order by ID
  Future<MerchantOrder?> getOrderWithId(int orderId);

  /// Get order details/items
  Future<List<MerchantOrderDetailsModel>?> getOrderDetails(int orderId);

  /// Update order status (accept, confirm, process, ready, deliver, cancel)
  Future<ResponseModel> updateOrderStatus(
    MerchantOrderStatusUpdateBody updateStatusBody,
  );

  /// Get cancellation reasons for orders
  Future<List<String>?> getCancelReasons();

  /// Get order statistics for dashboard
  Future<Map<String, dynamic>?> getOrderStats();

  /// Calculate order totals and summaries
  Map<String, dynamic> calculateOrderTotals(MerchantOrder order);
}