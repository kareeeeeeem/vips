// Unit tests for MerchantOrderService (the data-layer implementation
// actually wired up in merchant_order_binding.dart), using a fake
// MerchantOrderRepositoryInterface so no network call is ever made — the
// service takes its repository as a constructor parameter (DI), which makes
// its delegation and calculation logic directly unit-testable.

import 'package:flutter_test/flutter_test.dart';
import 'package:vip/appmerchant/core/common/models/response_model.dart';
import 'package:vip/appmerchant/modules/merchant_orders/data/services/merchant_order_service.dart';
import 'package:vip/appmerchant/modules/merchant_orders/domain/models/merchant_order_details_model.dart';
import 'package:vip/appmerchant/modules/merchant_orders/domain/models/merchant_order_model.dart';
import 'package:vip/appmerchant/modules/merchant_orders/domain/repositories/merchant_order_repository_interface.dart';

class FakeMerchantOrderRepository implements MerchantOrderRepositoryInterface {
  List<MerchantOrder>? currentOrders;
  PaginatedMerchantOrderModel? paginatedOrders;
  PaginatedMerchantOrderModel? completedOrders;
  MerchantOrder? orderWithId;
  List<MerchantOrderDetailsModel>? orderDetails;
  ResponseModel updateStatusResponse = ResponseModel(true, 'OK');
  List<String>? cancelReasons;
  Map<String, dynamic>? orderStats;

  int? lastGetOrdersOffset;
  String? lastGetOrdersStatus;

  @override
  Future<List<MerchantOrder>?> getCurrentOrders() async => currentOrders;

  @override
  Future<PaginatedMerchantOrderModel?> getOrders(
    int offset,
    String status,
  ) async {
    lastGetOrdersOffset = offset;
    lastGetOrdersStatus = status;
    return paginatedOrders;
  }

  @override
  Future<PaginatedMerchantOrderModel?> getCompletedOrders(int offset) async =>
      completedOrders;

  @override
  Future<MerchantOrder?> getOrderWithId(int orderId) async => orderWithId;

  @override
  Future<List<MerchantOrderDetailsModel>?> getOrderDetails(
    int orderId,
  ) async => orderDetails;

  @override
  Future<ResponseModel> updateOrderStatus(
    MerchantOrderStatusUpdateBody updateStatusBody,
  ) async => updateStatusResponse;

  @override
  Future<List<String>?> getCancelReasons() async => cancelReasons;

  @override
  Future<Map<String, dynamic>?> getOrderStats() async => orderStats;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeMerchantOrderRepository fakeRepo;
  late MerchantOrderService service;

  setUp(() {
    fakeRepo = FakeMerchantOrderRepository();
    service = MerchantOrderService(orderRepositoryInterface: fakeRepo);
  });

  group('delegation to the repository', () {
    test('getCurrentOrders returns whatever the repository returns',
        () async {
      fakeRepo.currentOrders = [MerchantOrder(id: 1)];
      final result = await service.getCurrentOrders();
      expect(result!.single.id, equals(1));
    });

    test('getOrders forwards offset and status to the repository', () async {
      fakeRepo.paginatedOrders = PaginatedMerchantOrderModel(totalSize: 5);
      final result = await service.getOrders(2, 'pending');
      expect(fakeRepo.lastGetOrdersOffset, equals(2));
      expect(fakeRepo.lastGetOrdersStatus, equals('pending'));
      expect(result!.totalSize, equals(5));
    });

    test('getCompletedOrders returns the repository result', () async {
      fakeRepo.completedOrders = PaginatedMerchantOrderModel(totalSize: 9);
      final result = await service.getCompletedOrders(1);
      expect(result!.totalSize, equals(9));
    });

    test('getOrderWithId returns the repository result', () async {
      fakeRepo.orderWithId = MerchantOrder(id: 42);
      final result = await service.getOrderWithId(42);
      expect(result!.id, equals(42));
    });

    test('getOrderDetails returns the repository result', () async {
      fakeRepo.orderDetails = [MerchantOrderDetailsModel(id: 1)];
      final result = await service.getOrderDetails(1);
      expect(result!.single.id, equals(1));
    });

    test('updateOrderStatus returns the repository response', () async {
      fakeRepo.updateStatusResponse = ResponseModel(false, 'Rejected');
      final result = await service.updateOrderStatus(
        MerchantOrderStatusUpdateBody(orderId: 1, status: 'confirmed'),
      );
      expect(result.success, isFalse);
      expect(result.message, equals('Rejected'));
    });

    test('getCancelReasons returns the repository result', () async {
      fakeRepo.cancelReasons = ['Out of stock'];
      final result = await service.getCancelReasons();
      expect(result, equals(['Out of stock']));
    });

    test('getOrderStats returns the repository result', () async {
      fakeRepo.orderStats = {'totalOrders': 10};
      final result = await service.getOrderStats();
      expect(result!['totalOrders'], equals(10));
    });
  });

  group('calculateOrderTotals', () {
    test('sums from orderDetails when present, ignoring order-level amounts',
        () {
      final order = MerchantOrder(
        orderAmount: 999, // should be ignored since orderDetails is present
        deliveryCharge: 5,
        orderDetails: [
          MerchantOrderDetailsModel(
            price: 10,
            quantity: 2,
            taxAmount: 1.5,
            discountOnItem: 1,
          ),
          MerchantOrderDetailsModel(
            price: 5,
            quantity: 1,
            taxAmount: 0.5,
            discountOnItem: 0,
          ),
        ],
      );

      final totals = service.calculateOrderTotals(order);

      // subtotal = 10*2 + 5*1 = 25; tax = 1.5+0.5 = 2; discount = 1+0 = 1
      expect(totals['subtotal'], equals(25.0));
      expect(totals['taxAmount'], equals(2.0));
      expect(totals['discountAmount'], equals(1.0));
      expect(totals['deliveryCharge'], equals(5.0));
      // total = subtotal + tax + delivery - discount = 25 + 2 + 5 - 1 = 31
      expect(totals['total'], equals(31.0));
      expect(totals['currency'], equals('USD'));
    });

    test('falls back to order-level amounts when orderDetails is null', () {
      final order = MerchantOrder(
        orderAmount: 40,
        totalTaxAmount: 4,
        couponDiscountAmount: 5,
        deliveryCharge: 3,
      );

      final totals = service.calculateOrderTotals(order);

      expect(totals['subtotal'], equals(40.0));
      expect(totals['taxAmount'], equals(4.0));
      expect(totals['discountAmount'], equals(5.0));
      expect(totals['deliveryCharge'], equals(3.0));
      // total = 40 + 4 + 3 - 5 = 42
      expect(totals['total'], equals(42.0));
    });

    test('treats missing numeric fields as zero', () {
      final order = MerchantOrder();
      final totals = service.calculateOrderTotals(order);
      expect(totals['subtotal'], equals(0.0));
      expect(totals['taxAmount'], equals(0.0));
      expect(totals['discountAmount'], equals(0.0));
      expect(totals['deliveryCharge'], equals(0.0));
      expect(totals['total'], equals(0.0));
    });

    test('quantity defaults to 1 when a line item has none', () {
      final order = MerchantOrder(
        orderDetails: [MerchantOrderDetailsModel(price: 7)],
      );
      final totals = service.calculateOrderTotals(order);
      expect(totals['subtotal'], equals(7.0));
    });
  });
}
