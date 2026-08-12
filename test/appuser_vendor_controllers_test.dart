// Unit tests for the pure/testable business logic in several appuser
// GetX controllers: list filtering, computed counts/totals, toggle state,
// and formatting helpers.
//
// Pattern (matches appuser_business_logic_test.dart): controllers are
// constructed directly (never Get.put/onInit) so their network-calling or
// hardware-touching onInit() bodies never run — we drive the reactive
// fields and pure getters/methods directly instead. Fields that are
// initialized inline as class fields (not inside onInit()) are safe to
// read/write directly.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip/appuser/modules/delivery_driver/controllers/delivery_driver_controller.dart';
import 'package:vip/appuser/modules/promotions/controllers/promotions_controller.dart';
import 'package:vip/appuser/modules/report/controllers/report_controller.dart';
import 'package:vip/appuser/modules/shipping/controllers/shipping_controller.dart';
import 'package:vip/appuser/modules/transactions_extract/controllers/transactions_extract_controller.dart';
import 'package:vip/appuser/modules/vendor_home/controllers/vendor_home_controller.dart';
import 'package:vip/appuser/modules/vendor_order/controllers/vendor_order_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ═══════════════════════════════════════════════════════════
  // VendorOrderController — order filtering & counts
  // ═══════════════════════════════════════════════════════════
  group('VendorOrderController', () {
    late VendorOrderController c;

    setUp(() {
      c = VendorOrderController();
      // Replace the built-in mock data with a small, controlled dataset.
      c.allOrders
        ..clear()
        ..addAll([
          {'id': 'A', 'status': 'Pending', 'refundStatus': 'none'},
          {'id': 'B', 'status': 'Confirmed', 'refundStatus': 'none'},
          {'id': 'C', 'status': 'Delivered', 'refundStatus': 'none'},
          {'id': 'D', 'status': 'Cancelled', 'refundStatus': 'approved'},
          {'id': 'E', 'status': 'Delivered', 'refundStatus': 'approved'},
        ]);
    });

    test('getActiveOrdersCount excludes delivered/cancelled/refunded', () {
      expect(c.getActiveOrdersCount(), equals(2)); // A, B
    });

    test('getDoneOrdersCount counts delivered orders not yet refunded', () {
      expect(c.getDoneOrdersCount(), equals(1)); // C
    });

    test('getRefundedOrdersCount counts orders with approved refunds', () {
      expect(c.getRefundedOrdersCount(), equals(2)); // D, E
    });

    test('getFilteredOrders defaults to the Active top filter', () {
      final filtered = c.getFilteredOrders();
      expect(filtered.map((o) => o['id']), equals(['A', 'B']));
    });

    test('getFilteredOrders(Done) returns only delivered/non-refunded', () {
      c.setFilterIndex(1);
      expect(c.getFilteredOrders().map((o) => o['id']), equals(['C']));
    });

    test('getFilteredOrders(Refunded) returns only approved-refund orders', () {
      c.setFilterIndex(2);
      expect(c.getFilteredOrders().map((o) => o['id']), equals(['D', 'E']));
    });

    test('getFilteredOrders narrows further by selected status', () {
      // orderStatuses[1] == 'Confirmed'
      c.setStatusIndex(1);
      expect(c.getFilteredOrders().map((o) => o['id']), equals(['B']));
    });

    test('setFilterIndex resets the status filter back to All', () {
      c.setStatusIndex(3);
      expect(c.selectedStatusIndex, equals(3));
      c.setFilterIndex(2);
      expect(c.selectedFilterIndex, equals(2));
      expect(c.selectedStatusIndex, equals(0));
    });

    test('getCountForStatus counts matching orders, "All" counts everything',
        () {
      expect(c.getCountForStatus('Confirmed'), equals(1));
      expect(c.getCountForStatus('Delivered'), equals(2));
      expect(c.getCountForStatus('All'), equals(5));
    });

    test('getOrderById finds an existing order and returns null otherwise',
        () {
      expect(c.getOrderById('C')!['status'], equals('Delivered'));
      expect(c.getOrderById('missing'), isNull);
    });

    test('getStatusColor maps known statuses case-insensitively', () {
      expect(c.getStatusColor('pending'), equals('0xFFFF9800'));
      expect(c.getStatusColor('PENDING'), equals('0xFFFF9800'));
      expect(c.getStatusColor('delivered'), equals('0xFF009688'));
      expect(c.getStatusColor('unknown'), equals('0xFF9E9E9E'));
    });

    test('selectOrder stores the selected order id', () {
      expect(c.selectedOrderId, isEmpty);
      c.selectOrder('B');
      expect(c.selectedOrderId, equals('B'));
    });

    test('topFilters and orderStatuses expose the expected labels', () {
      expect(c.topFilters, equals(['Active', 'Done', 'Refunded']));
      expect(
        c.orderStatuses,
        equals([
          'Pending',
          'Confirmed',
          'Processing',
          'Ready',
          'Delivered',
          'Cancelled',
        ]),
      );
    });
  });

  // ═══════════════════════════════════════════════════════════
  // VendorHomeController — tabs, toggles & offer filtering
  // ═══════════════════════════════════════════════════════════
  group('VendorHomeController', () {
    late VendorHomeController c;

    setUp(() {
      c = VendorHomeController();
    });

    // The underlying `_recentOrders` list is private and only ever populated
    // by the network call in onInit() (never called here), so absent a live
    // backend these all stay empty — we assert that real default, not
    // fabricated fixture data.
    test('getFilteredOrders returns last running orders by default', () {
      final result = c.getFilteredOrders();
      expect(result, equals(c.getLastRunningOrders()));
      expect(result, isEmpty);
    });

    test('setOrderTab switches to recent running orders', () {
      c.setOrderTab(1);
      expect(c.selectedOrderTab, equals(1));
      expect(c.getFilteredOrders(), equals(c.getRecentRunningOrders()));
      expect(c.getFilteredOrders(), isEmpty);
    });

    test('getRecentOrdersCount reflects the (empty) recent-orders list', () {
      expect(c.getRecentOrdersCount(), equals(0));
    });

    test('toggleStoreStatus flips isStoreActive', () {
      expect(c.isStoreActive, isTrue);
      c.toggleStoreStatus();
      expect(c.isStoreActive, isFalse);
      c.toggleStoreStatus();
      expect(c.isStoreActive, isTrue);
    });

    test('toggleCampaignOnly flips campaignOnly', () {
      expect(c.campaignOnly, isFalse);
      c.toggleCampaignOnly();
      expect(c.campaignOnly, isTrue);
    });

    test('setOrderIndex stores the selected order index', () {
      c.setOrderIndex(2);
      expect(c.selectedOrderIndex, equals(2));
    });

    test('toggleOrderCard expands and collapses by index', () {
      expect(c.expandedOrderIndex.value, isNull);
      c.toggleOrderCard(1);
      expect(c.expandedOrderIndex.value, equals(1));
      c.toggleOrderCard(1);
      expect(c.expandedOrderIndex.value, isNull);
      c.toggleOrderCard(2);
      expect(c.expandedOrderIndex.value, equals(2));
    });

    test('getFilteredOffers(All) returns every offer', () {
      c.offers.addAll([
        {'category': 'discount'},
        {'category': 'voucher'},
      ]);
      c.setOfferTab(0);
      expect(c.getFilteredOffers().length, equals(2));
    });

    test('getFilteredOffers(Discount) filters by category', () {
      c.offers.addAll([
        {'category': 'discount'},
        {'category': 'voucher'},
      ]);
      c.setOfferTab(1);
      final result = c.getFilteredOffers();
      expect(result.length, equals(1));
      expect(result.single['category'], equals('discount'));
    });

    test('getFilteredOffers(Voucher) filters by category', () {
      c.offers.addAll([
        {'category': 'discount'},
        {'category': 'voucher'},
      ]);
      c.setOfferTab(2);
      final result = c.getFilteredOffers();
      expect(result.length, equals(1));
      expect(result.single['category'], equals('voucher'));
    });

    test('offerTabs and orderStatuses expose the expected labels', () {
      expect(c.offerTabs, equals(['All', 'Discount', 'Voucher']));
      expect(
        c.orderStatuses,
        equals(['Pending', 'Confirmed', 'Processing', 'Ready', 'Delivered']),
      );
    });
  });

  // ═══════════════════════════════════════════════════════════
  // DeliveryDriverController — tabs, orders & current order
  // ═══════════════════════════════════════════════════════════
  group('DeliveryDriverController', () {
    late DeliveryDriverController c;

    setUp(() {
      c = DeliveryDriverController();
    });

    // The underlying `_allOrders` list is private and only populated by the
    // network call in loadData() (never invoked here), so absent a live
    // backend these all stay empty — asserting the real default, not
    // fabricated fixture data.
    test('getFilteredOrders(Request) returns the request queue by default',
        () {
      expect(c.getFilteredOrders(), equals(c.getRequestOrders()));
      expect(c.getFilteredOrders(), isEmpty);
    });

    test('setOrderTab switches tabs and collapses any expanded card', () {
      c.toggleOrderCard(3);
      expect(c.expandedOrderIndex.value, equals(3));

      c.setOrderTab(1);
      expect(c.selectedOrderTab.value, equals(1));
      expect(c.expandedOrderIndex.value, isNull);
      expect(c.getFilteredOrders(), equals(c.getActiveHistoryOrders()));
    });

    test('getFilteredOrders(History) returns the completed orders', () {
      c.selectedOrderTab.value = 2;
      expect(c.getFilteredOrders(), equals(c.getHistoryOrders()));
      expect(c.getFilteredOrders(), isEmpty);
    });

    test('getFilteredOrders falls back to an empty list for unknown tabs',
        () {
      c.selectedOrderTab.value = 99;
      expect(c.getFilteredOrders(), isEmpty);
    });

    test('toggleOrderCard expands and collapses by index', () {
      expect(c.expandedOrderIndex.value, isNull);
      c.toggleOrderCard(0);
      expect(c.expandedOrderIndex.value, equals(0));
      c.toggleOrderCard(0);
      expect(c.expandedOrderIndex.value, isNull);
    });

    test('currentOrder / hasActiveOrder default to empty until loadData() populates them from the API',
        () {
      // loadData() is network-only (no local fixture data); without a live
      // backend it fails fast and leaves these at their defaults.
      expect(c.currentOrder.value, isNull);
      expect(c.hasActiveOrder.value, isFalse);
    });

    test('closeNotificationPermissionWarning marks the permission granted',
        () {
      c.isNotificationPermissionGranted.value = false;
      c.closeNotificationPermissionWarning();
      expect(c.isNotificationPermissionGranted.value, isTrue);
    });

    test('closeBatteryOptimizationWarning marks the optimization granted',
        () {
      c.isBatteryOptimizationGranted.value = false;
      c.closeBatteryOptimizationWarning();
      expect(c.isBatteryOptimizationGranted.value, isTrue);
    });

    test('orderTabs exposes the expected labels', () {
      expect(c.orderTabs, equals(['Request', 'Active History', 'History']));
    });

    // Note: toggleOnlineStatus() is intentionally not tested here — it calls
    // the raw (unwrapped) Get.snackbar API, which throws "No Overlay widget
    // found" even under a pumped GetMaterialApp in this GetX version, so it
    // isn't reliably unit-testable without touching production code.
  });

  // ═══════════════════════════════════════════════════════════
  // ReportController — reports by tab, totals & model formatting
  // ═══════════════════════════════════════════════════════════
  group('ReportController', () {
    late ReportController c;

    Report makeReport({
      String id = '1',
      ReportType type = ReportType.all,
      DateTime? date,
      double amount = 10.0,
      ReportStatus status = ReportStatus.completed,
    }) {
      return Report(
        id: id,
        title: 'Report $id',
        type: type,
        date: date ?? DateTime.now(),
        amount: amount,
        status: status,
        description: 'desc',
      );
    }

    setUp(() {
      c = ReportController();
    });

    test('currentReports defaults to allReports (tabIndex 0)', () {
      c.allReports.addAll([makeReport(id: '1'), makeReport(id: '2')]);
      expect(c.currentReports.length, equals(2));
      expect(c.reportCount, equals(2));
    });

    test('totalAmount sums the amounts of the current tab reports', () {
      c.allReports.addAll([
        makeReport(id: '1', amount: 10.0),
        makeReport(id: '2', amount: 5.5),
      ]);
      expect(c.totalAmount, closeTo(15.5, 0.001));
    });

    test('couponReports and packageReports are independent lists', () {
      c.couponReports.add(makeReport(id: 'c1', type: ReportType.coupon));
      c.packageReports.add(makeReport(id: 'p1', type: ReportType.package));
      expect(c.couponReports.length, equals(1));
      expect(c.packageReports.length, equals(1));
      expect(c.allReports, isEmpty);
    });

    test('tabIndex and isLoading default sanely without onInit', () {
      expect(c.tabIndex, equals(0));
      expect(c.isLoading, isFalse);
      expect(c.selectedDateRange, isNull);
    });

    test('Report.formattedDate renders relative labels', () {
      final now = DateTime.now();
      expect(makeReport(date: now).formattedDate, equals('Today'));
      expect(
        makeReport(date: now.subtract(const Duration(days: 1))).formattedDate,
        equals('Yesterday'),
      );
      expect(
        makeReport(date: now.subtract(const Duration(days: 3))).formattedDate,
        equals('3 days ago'),
      );
      expect(
        makeReport(date: DateTime(2020, 1, 15)).formattedDate,
        equals('15/1/2020'),
      );
    });

    test('Report.formattedAmount formats as a 2-decimal currency string', () {
      expect(makeReport(amount: 1234.5).formattedAmount, equals('\$1234.50'));
      expect(makeReport(amount: 0).formattedAmount, equals('\$0.00'));
    });

    test('ReportTypeExtension.displayName maps each type', () {
      expect(ReportType.all.displayName, equals('All Reports'));
      expect(ReportType.coupon.displayName, equals('Coupon Report'));
      expect(ReportType.package.displayName, equals('Package Report'));
    });

    test('ReportStatusExtension.displayName and color map each status', () {
      expect(ReportStatus.completed.displayName, equals('Completed'));
      expect(ReportStatus.pending.displayName, equals('Pending'));
      expect(ReportStatus.failed.displayName, equals('Failed'));
      expect(ReportStatus.completed.color, equals(const Color(0xff4CAF50)));
      expect(ReportStatus.pending.color, equals(const Color(0xffFF9800)));
      expect(ReportStatus.failed.color, equals(const Color(0xffF44336)));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // ShippingController — trip grouping
  // ═══════════════════════════════════════════════════════════
  group('ShippingController', () {
    late ShippingController c;

    setUp(() {
      c = ShippingController();
    });

    test('groupedTrips is empty by default (trips only load from the API)',
        () {
      expect(c.groupedTrips, isEmpty);
    });

    test('groupedTrips reflects custom trip data', () {
      c.trips
        ..clear()
        ..addAll([
          {'id': 1, 'title': 'A', 'date': '1 Jan'},
          {'id': 2, 'title': 'B', 'date': '1 Jan'},
          {'id': 3, 'title': 'C', 'date': '2 Jan'},
        ]);
      final grouped = c.groupedTrips;
      expect(grouped.keys.length, equals(2));
      expect(grouped['1 Jan']!.length, equals(2));
      expect(grouped['2 Jan']!.length, equals(1));
    });

    test('groupedTrips is empty when there are no trips', () {
      c.trips.clear();
      expect(c.groupedTrips, isEmpty);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // TransactionsExtractController — stats & date filters
  // ═══════════════════════════════════════════════════════════
  group('TransactionsExtractController', () {
    late TransactionsExtractController c;

    Transaction makeTx({
      String id = 't1',
      TransactionType type = TransactionType.reward,
      double amount = 10.0,
      DateTime? date,
    }) {
      return Transaction(
        id: id,
        type: type,
        amount: amount,
        title: 'Title',
        time: '10:00',
        date: date ?? DateTime.now(),
        status: TransactionStatus.completed,
      );
    }

    setUp(() {
      c = TransactionsExtractController();
    });

    test('stats default to zero before any calculation', () {
      expect(c.totalRewards.value, equals(0.0));
      expect(c.totalExtract.value, equals(0.0));
      expect(c.netBalance.value, equals(0.0));
    });

    test('calculateStats sums rewards and extracts and derives netBalance',
        () {
      c.transactions.addAll([
        makeTx(id: 'a', type: TransactionType.reward, amount: 100),
        makeTx(id: 'b', type: TransactionType.reward, amount: 50),
        makeTx(id: 'c', type: TransactionType.extract, amount: 30),
      ]);
      c.calculateStats();
      expect(c.totalRewards.value, equals(150.0));
      expect(c.totalExtract.value, equals(30.0));
      expect(c.netBalance.value, equals(120.0));
    });

    test('calculateStats resets stats to zero for an empty transaction list',
        () {
      c.calculateStats();
      expect(c.totalRewards.value, equals(0.0));
      expect(c.totalExtract.value, equals(0.0));
      expect(c.netBalance.value, equals(0.0));
    });

    test('todayTransactions returns only transactions dated today', () {
      final now = DateTime.now();
      c.transactions.addAll([
        makeTx(id: 'today', date: now),
        makeTx(id: 'old', date: now.subtract(const Duration(days: 2))),
      ]);
      expect(c.todayTransactions.length, equals(1));
      expect(c.todayTransactions.single.id, equals('today'));
    });

    test('yesterdayTransactions returns only transactions dated yesterday',
        () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      c.transactions.addAll([
        makeTx(id: 'yesterday', date: yesterday),
        makeTx(id: 'today', date: now),
      ]);
      expect(c.yesterdayTransactions.length, equals(1));
      expect(c.yesterdayTransactions.single.id, equals('yesterday'));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // PromotionsController — tab-based lists & selection toggling
  // ═══════════════════════════════════════════════════════════
  group('PromotionsController', () {
    late PromotionsController c;

    Promotion makePromo(
      String id, {
      PromotionType type = PromotionType.orderOffer,
    }) {
      return Promotion(
        id: id,
        title: 'Title $id',
        brandName: 'Brand',
        validUntil: '2025',
        type: type,
      );
    }

    setUp(() {
      c = PromotionsController();
    });

    test('currentPromotions returns orderOffers when selectedTab is 0', () {
      c.orderOffers.add(makePromo('o1'));
      c.shippingOffers.add(
        makePromo('s1', type: PromotionType.shippingOffer),
      );
      expect(c.currentPromotions.length, equals(1));
      expect(c.currentPromotions.single.id, equals('o1'));
    });

    test('currentPromotions returns shippingOffers when selectedTab is 1',
        () {
      c.orderOffers.add(makePromo('o1'));
      c.shippingOffers.add(
        makePromo('s1', type: PromotionType.shippingOffer),
      );
      c.selectedTab.value = 1;
      expect(c.currentPromotions.single.id, equals('s1'));
    });

    test('togglePromotionSelection tracks ids and flips isSelected in orderOffers',
        () {
      c.orderOffers.add(makePromo('o1'));
      c.togglePromotionSelection('o1');
      expect(c.selectedPromotions, contains('o1'));
      expect(c.orderOffers.first.isSelected, isTrue);

      c.togglePromotionSelection('o1');
      expect(c.selectedPromotions, isNot(contains('o1')));
      expect(c.orderOffers.first.isSelected, isFalse);
    });

    test('togglePromotionSelection also matches promotions in shippingOffers',
        () {
      c.shippingOffers.add(makePromo('s1', type: PromotionType.shippingOffer));
      c.togglePromotionSelection('s1');
      expect(c.selectedPromotions, contains('s1'));
      expect(c.shippingOffers.first.isSelected, isTrue);
    });

    test('applyPromotions is a no-op when nothing is selected', () {
      expect(c.selectedPromotions, isEmpty);
      expect(() => c.applyPromotions(), returnsNormally);
      expect(c.selectedPromotions, isEmpty);
    });
  });
}
