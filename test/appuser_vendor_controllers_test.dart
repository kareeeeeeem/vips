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
import 'package:vip/appuser/modules/promotions/controllers/promotions_controller.dart';
import 'package:vip/appuser/modules/report/controllers/report_controller.dart';
import 'package:vip/appuser/modules/shipping/controllers/shipping_controller.dart';
import 'package:vip/appuser/modules/transactions_extract/controllers/transactions_extract_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
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

    test('Report.formattedAmount formats as a 3-decimal TND currency string', () {
      expect(makeReport(amount: 1234.5).formattedAmount, equals('D 1234.500'));
      expect(makeReport(amount: 0).formattedAmount, equals('D 0.000'));
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
        code: 'CODE$id',
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
