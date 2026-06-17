import 'package:vip/appmerchant/modules/merchant_orders/domain/models/merchant_order_details_model.dart';
import 'package:vip/appmerchant/modules/merchant_orders/domain/models/merchant_order_model.dart';
import 'package:vip/appmerchant/core/common/models/response_model.dart';

abstract class MerchantOrderRepositoryInterface {
  /// Get paginated orders list
  Future<PaginatedMerchantOrderModel?> getOrders(int offset, String status);

  /// Get current/new orders
  Future<List<MerchantOrder>?> getCurrentOrders();

  /// Get completed orders
  Future<PaginatedMerchantOrderModel?> getCompletedOrders(int offset);

  /// Get order details by ID
  Future<MerchantOrder?> getOrderWithId(int orderId);

  /// Get order details items
  Future<List<MerchantOrderDetailsModel>?> getOrderDetails(int orderId);

  /// Update order status
  Future<ResponseModel> updateOrderStatus(
    MerchantOrderStatusUpdateBody updateStatusBody,
  );

  /// Get order cancellation reasons
  Future<List<String>?> getCancelReasons();

  /// Get order statistics
  Future<Map<String, dynamic>?> getOrderStats();
}