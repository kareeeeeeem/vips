import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip/appmerchant/core/api/api_client.dart';
import 'package:vip/appmerchant/core/util/app_constants.dart';
import 'package:vip/appmerchant/core/common/models/response_model.dart';
import 'package:vip/appmerchant/modules/merchant_orders/domain/models/merchant_order_details_model.dart';
import 'package:vip/appmerchant/modules/merchant_orders/domain/models/merchant_order_model.dart';
import 'package:vip/appmerchant/modules/merchant_orders/domain/repositories/merchant_order_repository_interface.dart';

class MerchantOrderRepository implements MerchantOrderRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  MerchantOrderRepository({
    required this.apiClient,
    required this.sharedPreferences,
  });

  @override
  Future<PaginatedMerchantOrderModel?> getOrders(
    int offset,
    String status,
  ) async {
    try {
      PaginatedMerchantOrderModel? orderModel;
      Response response = await apiClient.getData(
        '${AppConstants.allOrdersUri}?status=$status&offset=$offset&limit=10',
      );

      if (response.statusCode == 200) {
        orderModel = PaginatedMerchantOrderModel.fromJson(response.body);
      }
      return orderModel;
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      return null;
    }
  }

  @override
  Future<List<MerchantOrder>?> getCurrentOrders() async {
    try {
      List<MerchantOrder>? orderList;
      Response response = await apiClient.getData(
        AppConstants.currentOrdersUri,
      );

      if (response.statusCode == 200) {
        orderList = [];
        response.body.forEach((order) {
          MerchantOrder orderModel = MerchantOrder.fromJson(order);
          orderList!.add(orderModel);
        });
      }
      return orderList;
    } catch (e) {
      debugPrint('Error fetching current orders: $e');
      return null;
    }
  }

  @override
  Future<PaginatedMerchantOrderModel?> getCompletedOrders(int offset) async {
    try {
      PaginatedMerchantOrderModel? orderModel;
      Response response = await apiClient.getData(
        '${AppConstants.completedOrdersUri}?offset=$offset&limit=10',
      );

      if (response.statusCode == 200) {
        orderModel = PaginatedMerchantOrderModel.fromJson(response.body);
      }
      return orderModel;
    } catch (e) {
      debugPrint('Error fetching completed orders: $e');
      return null;
    }
  }

  @override
  Future<MerchantOrder?> getOrderWithId(int orderId) async {
    try {
      MerchantOrder? orderModel;
      Response response = await apiClient.getData(
        '${AppConstants.orderDetailsUri}$orderId',
      );

      if (response.statusCode == 200) {
        orderModel = MerchantOrder.fromJson(response.body);
      }
      return orderModel;
    } catch (e) {
      debugPrint('Error fetching order details: $e');
      return null;
    }
  }

  @override
  Future<List<MerchantOrderDetailsModel>?> getOrderDetails(int orderId) async {
    try {
      List<MerchantOrderDetailsModel>? orderDetails;
      Response response = await apiClient.getData(
        '${AppConstants.orderDetailsUri}$orderId/items',
      );

      if (response.statusCode == 200) {
        orderDetails = [];
        response.body.forEach((detail) {
          orderDetails!.add(MerchantOrderDetailsModel.fromJson(detail));
        });
      }
      return orderDetails;
    } catch (e) {
      debugPrint('Error fetching order items: $e');
      return null;
    }
  }

  @override
  Future<ResponseModel> updateOrderStatus(
    MerchantOrderStatusUpdateBody updateStatusBody,
  ) async {
    try {
      ResponseModel responseModel;
      Response response = await apiClient.postData(
        AppConstants.updatedOrderStatusUri,
        updateStatusBody.toJson(),
        handleError: false,
      );

      if (response.statusCode == 200) {
        responseModel = ResponseModel(
          true,
          response.body['message'] ?? 'Order status updated successfully',
        );
      } else {
        responseModel = ResponseModel(
          false,
          response.statusText ?? 'Failed to update order status',
        );
      }
      return responseModel;
    } catch (e) {
      debugPrint('Error updating order status: $e');
      return ResponseModel(false, 'Network error occurred');
    }
  }

  @override
  Future<List<String>?> getCancelReasons() async {
    try {
      // Assuming similar endpoint structure to user app
      List<String>? reasons;
      Response response = await apiClient.getData(
        '${AppConstants.orderCancellationUri}?type=store',
      );

      if (response.statusCode == 200) {
        reasons = List<String>.from(response.body['reasons'] ?? []);
      }
      return reasons;
    } catch (e) {
      debugPrint('Error fetching cancel reasons: $e');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> getOrderStats() async {
    try {
      // Create a summary from available orders
      List<MerchantOrder>? allOrders = await getCurrentOrders();
      List<MerchantOrder>? completedOrders = await getCompletedOrders(
        0,
      ).then((paginated) => paginated?.orders ?? []);

      if (allOrders == null) {
        return null;
      }

      double totalRevenue = 0;
      int todayOrders = 0;
      String today = DateTime.now().toString().split(' ')[0];

      for (var order in allOrders) {
        totalRevenue += order.orderAmount ?? 0;
        if (order.createdAt?.contains(today) ?? false) {
          todayOrders++;
        }
      }

      return {
        'totalOrders': allOrders.length,
        'completedOrders': completedOrders?.length ?? 0,
        'pendingOrders':
            allOrders.where((o) => o.orderStatus == 'pending').length,
        'totalRevenue': totalRevenue,
        'todayOrders': todayOrders,
        'averageOrderValue':
            allOrders.isNotEmpty ? totalRevenue / allOrders.length : 0,
      };
    } catch (e) {
      debugPrint('Error calculating order stats: $e');
      return null;
    }
  }

  String _getMerchantToken() {
    return sharedPreferences.getString(AppConstants.token) ?? "";
  }
}
