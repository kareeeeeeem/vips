import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../domain/models/merchant_order_details_model.dart';
import '../domain/models/merchant_order_model.dart';
import '../domain/services/merchant_order_service_interface.dart';
import 'package:vip/core/utils/safe_snackbar.dart';

enum MerchantOrderViewStatus { initial, loading, success, error, empty }

class MerchantOrderController extends GetxController {
  final MerchantOrderServiceInterface orderService;

  MerchantOrderController({required this.orderService});

  // State variables
  final status = MerchantOrderViewStatus.initial.obs;
  final orders = <MerchantOrder>[].obs;
  final filteredOrders = <MerchantOrder>[].obs;
  final currentOrder = Rxn<MerchantOrder>();
  final orderDetails = <MerchantOrderDetailsModel>[].obs;
  final selectedTab = 0.obs;
  final searchQuery = ''.obs;
  final isLoadingMore = false.obs;
  final currentOffset = 0.obs;

  // Statistics
  final totalOrders = 0.obs;
  final completedOrders = 0.obs;
  final pendingOrders = 0.obs;
  final totalRevenue = 0.0.obs;
  final todayOrders = 0.obs;

  // Filter options
  /// Mirrors `Order.status`'s real enum (models/Order.js). `handover`,
  /// `picked_up`, `refund_requested` and `refunded` were missing, so orders
  /// in any of those four states had no tab and could not be reached from
  /// this screen at all.
  final statusFilters = [
    'all',
    'pending',
    'confirmed',
    'processing',
    'ready',
    'handover',
    'picked_up',
    'delivered',
    'canceled',
    'refund_requested',
    'refunded',
  ];

  /// Human labels for the tabs — `picked_up` / `refund_requested` read badly
  /// as raw enum values.
  static const statusLabels = {
    'all': 'All',
    'pending': 'Pending',
    'confirmed': 'Confirmed',
    'processing': 'Processing',
    'ready': 'Ready',
    'handover': 'Handover',
    'picked_up': 'Picked Up',
    'delivered': 'Delivered',
    'canceled': 'Cancelled',
    'refund_requested': 'Refund Req.',
    'refunded': 'Refunded',
  };
  final selectedStatusFilter = 'all'.obs;
  final selectedDateRange = Rxn<DateTimeRange>();

  @override
  void onInit() {
    super.onInit();
    loadOrders();
    loadOrderStats();
  }

  // Load orders based on current filter
  Future<void> loadOrders({bool isLoadMore = false}) async {
    if (isLoadMore) {
      isLoadingMore.value = true;
    } else {
      status.value = MerchantOrderViewStatus.loading;
      currentOffset.value = 0;
    }

    try {
      PaginatedMerchantOrderModel? result;
      String statusFilter = selectedStatusFilter.value;

      if (statusFilter == 'all') {
        result = await orderService.getOrders(currentOffset.value, '');
      } else {
        result = await orderService.getOrders(
          currentOffset.value,
          statusFilter,
        );
      }

      if (result?.orders != null && result!.orders!.isNotEmpty) {
        if (isLoadMore) {
          orders.addAll(result.orders!);
        } else {
          orders.value = result.orders!;
        }

        currentOffset.value += 10;
        status.value = MerchantOrderViewStatus.success;
        _applyFilters();
      } else {
        if (isLoadMore) {
          // No more orders to load
          isLoadingMore.value = false;
        } else {
          orders.clear();
          status.value = MerchantOrderViewStatus.empty;
        }
      }
    } catch (e) {
      debugPrint('Error loading orders: $e');
      status.value = MerchantOrderViewStatus.error;
    } finally {
      isLoadingMore.value = false;
    }
  }


  /// Real cancellation reasons from GET /merchant/orders?type=store. The
  /// repository has always been able to fetch these, but nothing called it —
  /// the cancel dialog hardcoded "Merchant canceled" for every cancellation.
  final cancelReasons = <String>[].obs;
  final isLoadingCancelReasons = false.obs;

  Future<void> loadCancelReasons() async {
    if (cancelReasons.isNotEmpty || isLoadingCancelReasons.value) return;
    isLoadingCancelReasons.value = true;
    try {
      final reasons = await orderService.getCancelReasons();
      if (reasons != null && reasons.isNotEmpty) {
        cancelReasons.value = reasons;
      }
    } catch (e) {
      debugPrint('Error loading cancel reasons: $e');
    } finally {
      isLoadingCancelReasons.value = false;
    }
  }

  // Load order statistics
  Future<void> loadOrderStats() async {
    try {
      final stats = await orderService.getOrderStats();
      if (stats != null) {
        totalOrders.value = stats['totalOrders'] ?? 0;
        completedOrders.value = stats['completedOrders'] ?? 0;
        pendingOrders.value = stats['pendingOrders'] ?? 0;
        totalRevenue.value = stats['totalRevenue'] ?? 0.0;
        todayOrders.value = stats['todayOrders'] ?? 0;
      }
    } catch (e) {
      debugPrint('Error loading order stats: $e');
    }
  }

  // Get order details by ID
  Future<void> getOrderDetails(int orderId) async {
    status.value = MerchantOrderViewStatus.loading;
    try {
      final order = await orderService.getOrderWithId(orderId);
      final details = await orderService.getOrderDetails(orderId);

      if (order != null) {
        currentOrder.value = order;
        orderDetails.value = details ?? [];
        status.value = MerchantOrderViewStatus.success;
      } else {
        status.value = MerchantOrderViewStatus.error;
      }
    } catch (e) {
      debugPrint('Error loading order details: $e');
      status.value = MerchantOrderViewStatus.error;
    }
  }

  // Update order status
  Future<bool> updateOrderStatus(
    int orderId,
    String newStatus, {
    String? reason,
  }) async {
    try {
      final updateBody = MerchantOrderStatusUpdateBody(
        orderId: orderId,
        status: newStatus,
        reason: reason,
      );

      final response = await orderService.updateOrderStatus(updateBody);

      if (response.success) {
        // Refresh the order list and details
        await loadOrders();
        if (currentOrder.value?.id == orderId) {
          await getOrderDetails(orderId);
        }
        return true;
      } else {
        safeSnackbar('Error', response.message);
        return false;
      }
    } catch (e) {
      debugPrint('Error updating order status: $e');
      safeSnackbar('Error', 'Failed to update order status');
      return false;
    }
  }

  // Apply filters to orders
  void _applyFilters() {
    var filtered = orders.toList();

    // Apply status filter. Both spellings of cancelled are on the backend
    // enum, so matching one exactly hid orders stored under the other.
    if (selectedStatusFilter.value != 'all') {
      final wanted = selectedStatusFilter.value.toLowerCase();
      final accepted = (wanted == 'canceled' || wanted == 'cancelled')
          ? {'canceled', 'cancelled'}
          : {wanted};
      filtered = filtered
          .where((order) =>
              accepted.contains(order.orderStatus?.toLowerCase() ?? ''))
          .toList();
    }

    // Apply search query filter
    if (searchQuery.value.isNotEmpty) {
      filtered =
          filtered.where((order) {
            return order.id.toString().contains(searchQuery.value) ||
                order.customer?.fName?.toLowerCase().contains(
                      searchQuery.value.toLowerCase(),
                    ) ==
                    true ||
                order.customer?.lName?.toLowerCase().contains(
                      searchQuery.value.toLowerCase(),
                    ) ==
                    true ||
                order.orderNote?.toLowerCase().contains(
                      searchQuery.value.toLowerCase(),
                    ) ==
                    true;
          }).toList();
    }

    // Apply date range filter
    if (selectedDateRange.value != null) {
      final startDate = selectedDateRange.value!.start;
      final endDate = selectedDateRange.value!.end;

      filtered =
          filtered.where((order) {
            if (order.createdAt == null) return false;
            // tryParse — a malformed timestamp must not throw out of the
            // filter and blank the whole list.
            final orderDate = DateTime.tryParse(order.createdAt!);
            if (orderDate == null) return false;
            return orderDate.isAfter(
                  startDate.subtract(const Duration(days: 1)),
                ) &&
                orderDate.isBefore(endDate.add(const Duration(days: 1)));
          }).toList();
    }

    filteredOrders.value = filtered;
  }

  // Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  // Update status filter
  void updateStatusFilter(String status) {
    selectedStatusFilter.value = status;
    loadOrders();
  }

  // Update date range filter
  void updateDateRange(DateTimeRange? range) {
    selectedDateRange.value = range;
    _applyFilters();
  }

  // Clear all filters
  void clearFilters() {
    selectedStatusFilter.value = 'all';
    searchQuery.value = '';
    selectedDateRange.value = null;
    _applyFilters();
  }

  // Get formatted date
  String formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // Get order status color
  Color getOrderStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'ready':
        return Colors.teal;
      case 'delivered':
        return Colors.green;
      case 'canceled':
      case 'cancelled':
        return Colors.red;
      case 'refund_requested':
        return Colors.deepOrange;
      case 'refunded':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  // Get order status icon
  IconData getOrderStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'confirmed':
        return Icons.check_circle;
      case 'processing':
        return Icons.autorenew;
      case 'ready':
        return Icons.fastfood;
      case 'delivered':
        return Icons.delivery_dining;
      case 'canceled':
      case 'cancelled':
        return Icons.cancel;
      case 'refund_requested':
        return Icons.assignment_return_outlined;
      case 'refunded':
        return Icons.currency_exchange;
      default:
        return Icons.help;
    }
  }

  // Calculate order totals
  Map<String, dynamic> calculateOrderTotals(MerchantOrder order) {
    return orderService.calculateOrderTotals(order);
  }

  // Refresh orders
  Future<void> refreshOrders() async {
    await loadOrders();
    await loadOrderStats();
  }

}
