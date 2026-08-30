import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:get/get.dart';
import 'package:vip/core/services/api_service.dart';

import '../../../core/admin_list_controller.dart';
import '../../../services/admin_api_service.dart';

class AdminOrdersController extends AdminListController {
  /// The full `Order.status` enum from `models/Order.js`. Kept here rather
  /// than hand-written per screen — an earlier sweep found several UI
  /// switches covering only the subset one test session happened to produce.
  static const List<String> statuses = [
    'pending', 'confirmed', 'processing', 'ready',
    'handover', 'picked_up', 'delivered',
    'cancelled', 'refund_requested', 'refunded',
  ];

  final RxString statusFilter = ''.obs;
  final RxString paymentFilter = ''.obs;
  final RxString typeFilter = ''.obs;
  final RxString merchantFilter = ''.obs;
  final RxString userFilter = ''.obs;
  final Rxn<DateTimeRange> dateRange = Rxn<DateTimeRange>();

  /// `statusCounts` from the list response, used for the tab badges.
  final RxMap<String, int> statusCounts = <String, int>{}.obs;

  final RxBool isLoadingDetails = false.obs;
  final Rxn<Map<String, dynamic>> details = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    final args = Get.arguments;
    if (args is Map) {
      if (args['status'] is String) statusFilter.value = args['status'] as String;
      if (args['merchantId'] is String) merchantFilter.value = args['merchantId'] as String;
      if (args['userId'] is String) userFilter.value = args['userId'] as String;
    }
    super.onInit();
  }

  @override
  Future<ApiResponse> fetch() => api.orders(
        page: page.value,
        limit: 20,
        search: search.value,
        status: statusFilter.value,
        paymentStatus: paymentFilter.value,
        orderType: typeFilter.value,
        merchantId: merchantFilter.value,
        userId: userFilter.value,
        from: _isoDate(dateRange.value?.start),
        to: _isoDate(dateRange.value?.end),
      );

  @override
  void parse(Map<String, dynamic> data) {
    final counts = data['statusCounts'];
    if (counts is Map) {
      statusCounts.value = counts.map(
        (key, value) => MapEntry(key.toString(), adminInt(value)),
      );
    }
  }

  String? _isoDate(DateTime? date) => date?.toIso8601String().substring(0, 10);

  /// The badge for a status tab. 'cancelled' spans both spellings in the
  /// enum, so its badge has to sum the two or it under-reports.
  int countFor(String status) {
    if (status.isEmpty) {
      return statusCounts.values.fold(0, (sum, value) => sum + value);
    }
    if (status == 'cancelled') {
      return (statusCounts['cancelled'] ?? 0) + (statusCounts['canceled'] ?? 0);
    }
    return statusCounts[status] ?? 0;
  }

  void setStatusFilter(String value) {
    if (statusFilter.value == value) return;
    statusFilter.value = value;
    load(resetPage: true);
  }

  void setPaymentFilter(String value) {
    if (paymentFilter.value == value) return;
    paymentFilter.value = value;
    load(resetPage: true);
  }

  void setTypeFilter(String value) {
    if (typeFilter.value == value) return;
    typeFilter.value = value;
    load(resetPage: true);
  }

  void setDateRange(DateTimeRange? range) {
    dateRange.value = range;
    load(resetPage: true);
  }

  /// Clears the deep-linked merchant/customer scope, so an operator who
  /// arrived from a merchant page can widen back out to every order.
  void clearScope() {
    merchantFilter.value = '';
    userFilter.value = '';
    load(resetPage: true);
  }

  bool get hasScope =>
      merchantFilter.value.isNotEmpty || userFilter.value.isNotEmpty;

  bool get hasAnyFilter =>
      hasScope ||
      search.value.isNotEmpty ||
      statusFilter.value.isNotEmpty ||
      paymentFilter.value.isNotEmpty ||
      typeFilter.value.isNotEmpty ||
      dateRange.value != null;

  Future<void> loadDetails(String id) async {
    isLoadingDetails.value = true;
    details.value = null;
    try {
      final response = await api.orderDetails(id);
      if (response.success && response.data is Map) {
        details.value = Map<String, dynamic>.from(response.data as Map);
      }
    } catch (e) {
      debugPrint('[ADMIN ORDERS] loadDetails failed: $e');
    } finally {
      isLoadingDetails.value = false;
    }
  }

  Future<bool> updateStatus(String id, String status) => mutate(
        () => api.updateOrderStatus(id, status),
        successTitle: 'Order updated',
      );

  Future<bool> cancelOrder(String id, String reason) => mutate(
        () => api.cancelOrder(id, reason),
        successTitle: 'Order cancelled',
        // The backend refuses to cancel an already-cancelled or completed
        // order with a specific 409 message worth showing verbatim.
        failureTitle: 'Cannot cancel',
      );

  /// True for a status the backend will refuse to cancel, so the button can
  /// be disabled rather than failing after the tap.
  bool isTerminal(String status) => const [
        'delivered', 'picked_up', 'cancelled', 'canceled', 'refunded',
      ].contains(status);
}
