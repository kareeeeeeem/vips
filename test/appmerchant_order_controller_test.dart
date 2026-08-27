// Unit tests for MerchantOrderController, using a fake
// MerchantOrderServiceInterface implementation instead of the real
// network-backed one — this controller takes its service as a constructor
// parameter (dependency injection), so unlike most controllers in this repo
// we CAN safely call onInit() and exercise the full load/filter/update flow
// without touching the network.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/core/common/models/response_model.dart';
import 'package:vip/appmerchant/modules/merchant_orders/controllers/merchant_order_controller.dart';
import 'package:vip/appmerchant/modules/merchant_orders/domain/models/merchant_order_details_model.dart';
import 'package:vip/appmerchant/modules/merchant_orders/domain/models/merchant_order_model.dart';
import 'package:vip/appmerchant/modules/merchant_orders/domain/services/merchant_order_service_interface.dart';

class FakeMerchantOrderService implements MerchantOrderServiceInterface {
  List<MerchantOrder> ordersToReturn = [];
  Map<String, dynamic>? statsToReturn;
  MerchantOrder? orderWithIdToReturn;
  List<MerchantOrderDetailsModel>? orderDetailsToReturn;
  ResponseModel updateStatusResponse = ResponseModel(true, 'OK');
  bool throwOnGetOrders = false;

  @override
  Future<List<MerchantOrder>?> getCurrentOrders() async => ordersToReturn;

  @override
  Future<PaginatedMerchantOrderModel?> getOrders(
    int offset,
    String status,
  ) async {
    if (throwOnGetOrders) throw Exception('network down');
    return PaginatedMerchantOrderModel(orders: ordersToReturn);
  }

  @override
  Future<PaginatedMerchantOrderModel?> getCompletedOrders(int offset) async =>
      PaginatedMerchantOrderModel(orders: ordersToReturn);

  @override
  Future<MerchantOrder?> getOrderWithId(int orderId) async =>
      orderWithIdToReturn;

  @override
  Future<List<MerchantOrderDetailsModel>?> getOrderDetails(
    int orderId,
  ) async => orderDetailsToReturn;

  @override
  Future<ResponseModel> updateOrderStatus(
    MerchantOrderStatusUpdateBody updateStatusBody,
  ) async => updateStatusResponse;

  @override
  Future<List<String>?> getCancelReasons() async => ['Out of stock', 'Other'];

  @override
  Future<Map<String, dynamic>?> getOrderStats() async => statsToReturn;

  @override
  Map<String, dynamic> calculateOrderTotals(MerchantOrder order) {
    final amount = order.orderAmount ?? 0;
    final tax = order.totalTaxAmount ?? 0;
    return {'grandTotal': amount + tax};
  }
}

MerchantOrder makeOrder({
  int id = 1,
  double orderAmount = 10.0,
  String? orderStatus = 'pending',
  String? createdAt,
  String? customerFirstName,
  String? orderNote,
}) {
  return MerchantOrder(
    id: id,
    orderAmount: orderAmount,
    orderStatus: orderStatus,
    createdAt: createdAt,
    orderNote: orderNote,
    customer: customerFirstName != null
        ? MerchantCustomer(fName: customerFirstName)
        : null,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeMerchantOrderService fakeService;
  late MerchantOrderController c;

  setUp(() {
    Get.testMode = true;
    fakeService = FakeMerchantOrderService();
    c = MerchantOrderController(orderService: fakeService);
  });

  tearDown(() {
    Get.reset();
  });

  group('loadOrders', () {
    test('populates orders and sets status to success when data is returned',
        () async {
      fakeService.ordersToReturn = [makeOrder(id: 1), makeOrder(id: 2)];
      await c.loadOrders();
      expect(c.orders.length, equals(2));
      expect(c.status.value, equals(MerchantOrderViewStatus.success));
      expect(c.filteredOrders.length, equals(2));
    });

    test('sets status to empty when no orders are returned', () async {
      fakeService.ordersToReturn = [];
      await c.loadOrders();
      expect(c.orders, isEmpty);
      expect(c.status.value, equals(MerchantOrderViewStatus.empty));
    });

    test('sets status to error when the service throws', () async {
      fakeService.throwOnGetOrders = true;
      await c.loadOrders();
      expect(c.status.value, equals(MerchantOrderViewStatus.error));
    });

    test('isLoadMore appends to the existing orders list', () async {
      fakeService.ordersToReturn = [makeOrder(id: 1)];
      await c.loadOrders();
      fakeService.ordersToReturn = [makeOrder(id: 2)];
      await c.loadOrders(isLoadMore: true);
      expect(c.orders.length, equals(2));
      expect(c.isLoadingMore.value, isFalse);
    });
  });

  group('loadOrderStats', () {
    test('populates the statistics fields from the service response',
        () async {
      fakeService.statsToReturn = {
        'totalOrders': 50,
        'completedOrders': 30,
        'pendingOrders': 5,
        'totalRevenue': 999.5,
        'todayOrders': 3,
      };
      await c.loadOrderStats();
      expect(c.totalOrders.value, equals(50));
      expect(c.completedOrders.value, equals(30));
      expect(c.pendingOrders.value, equals(5));
      expect(c.totalRevenue.value, equals(999.5));
      expect(c.todayOrders.value, equals(3));
    });
  });

  group('getOrderDetails', () {
    test('populates currentOrder and orderDetails on success', () async {
      fakeService.orderWithIdToReturn = makeOrder(id: 7);
      fakeService.orderDetailsToReturn = [];
      await c.getOrderDetails(7);
      expect(c.currentOrder.value?.id, equals(7));
      expect(c.status.value, equals(MerchantOrderViewStatus.success));
    });

    test('sets status to error when the order is not found', () async {
      fakeService.orderWithIdToReturn = null;
      await c.getOrderDetails(999);
      expect(c.status.value, equals(MerchantOrderViewStatus.error));
    });
  });

  group('updateOrderStatus', () {
    test('returns true and reloads orders on success', () async {
      fakeService.ordersToReturn = [makeOrder(id: 1)];
      final result = await c.updateOrderStatus(1, 'confirmed');
      expect(result, isTrue);
      expect(c.orders.length, equals(1));
    });

    test('returns false when the service reports failure', () async {
      fakeService.updateStatusResponse = ResponseModel(false, 'Denied');
      final result = await c.updateOrderStatus(1, 'confirmed');
      expect(result, isFalse);
    });
  });

  group('filtering', () {
    setUp(() async {
      fakeService.ordersToReturn = [
        makeOrder(
          id: 1,
          orderStatus: 'pending',
          customerFirstName: 'Alice',
          createdAt: DateTime(2026, 1, 10).toIso8601String(),
        ),
        makeOrder(
          id: 2,
          orderStatus: 'delivered',
          customerFirstName: 'Bob',
          createdAt: DateTime(2026, 1, 20).toIso8601String(),
        ),
      ];
      await c.loadOrders();
    });

    test('updateStatusFilter narrows filteredOrders by status', () async {
      // updateStatusFilter() fires loadOrders() without awaiting it, so give
      // the pending async chain a chance to settle before asserting.
      c.updateStatusFilter('delivered');
      await Future.delayed(Duration.zero);
      expect(c.filteredOrders.length, equals(1));
      expect(c.filteredOrders.single.orderStatus, equals('delivered'));
    });

    test('updateSearchQuery matches by customer first name', () {
      c.updateSearchQuery('alice');
      expect(c.filteredOrders.length, equals(1));
      expect(c.filteredOrders.single.id, equals(1));
    });

    test('updateSearchQuery matches by order id', () {
      c.updateSearchQuery('2');
      expect(c.filteredOrders.single.id, equals(2));
    });

    test('updateDateRange narrows filteredOrders by createdAt', () {
      c.updateDateRange(
        DateTimeRange(start: DateTime(2026, 1, 15), end: DateTime(2026, 1, 25)),
      );
      expect(c.filteredOrders.single.id, equals(2));
    });

    test('clearFilters resets status/search/date and restores all orders',
        () {
      c.updateSearchQuery('alice');
      expect(c.filteredOrders.length, equals(1));
      c.clearFilters();
      expect(c.selectedStatusFilter.value, equals('all'));
      expect(c.searchQuery.value, isEmpty);
      expect(c.selectedDateRange.value, isNull);
      expect(c.filteredOrders.length, equals(2));
    });
  });

  group('formatting helpers', () {
    test('formatDate renders a valid date and falls back gracefully', () {
      expect(c.formatDate(null), equals('-'));
      expect(c.formatDate('not-a-date'), equals('not-a-date'));
      expect(
        c.formatDate(DateTime(2026, 3, 7, 14, 30).toIso8601String()),
        equals('Mar 07, 2026 14:30'),
      );
    });

    test('getOrderStatusColor maps every known status', () {
      expect(c.getOrderStatusColor('pending'), equals(Colors.orange));
      expect(c.getOrderStatusColor('delivered'), equals(Colors.green));
      expect(c.getOrderStatusColor('canceled'), equals(Colors.red));
      expect(c.getOrderStatusColor('unknown'), equals(Colors.grey));
    });

    test('getOrderStatusIcon maps every known status', () {
      expect(c.getOrderStatusIcon('pending'), equals(Icons.pending));
      expect(c.getOrderStatusIcon('delivered'), equals(Icons.delivery_dining));
      expect(c.getOrderStatusIcon('canceled'), equals(Icons.cancel));
      expect(c.getOrderStatusIcon(null), equals(Icons.help));
    });

    test('calculateOrderTotals delegates to the injected service', () {
      final order = makeOrder(orderAmount: 20, id: 1);
      order.totalTaxAmount = 2;
      final totals = c.calculateOrderTotals(order);
      expect(totals['grandTotal'], equals(22));
    });
  });

  group('statusFilters', () {
    // The list must stay in step with Order.status's enum in
    // models/Order.js — handover / picked_up / refund_requested / refunded
    // were missing, so orders in those states had no tab at all.
    test('covers every status the backend enum can produce', () {
      expect(
        c.statusFilters,
        equals([
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
        ]),
      );
    });

    test('every filter has a human label', () {
      for (final status in c.statusFilters) {
        expect(MerchantOrderController.statusLabels[status], isNotNull,
            reason: 'missing label for "$status"');
      }
    });
  });
}
