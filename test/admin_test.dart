// admin_test.dart
//
// Unit tests for the admin console's pure/testable logic: the JSON coercion
// helpers every screen parses through, formatting, status→colour mapping
// against the real Mongoose enums, and the controllers' computed getters and
// filter state.
//
// Pattern (matches test/appmerchant_controllers_test.dart): controllers are
// constructed directly — never Get.put()/onInit() — so their network-calling
// onInit() bodies never run. Only pure getters and reactive state are driven.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vip/admin/core/theme/admin_theme.dart';
import 'package:vip/admin/core/routes/admin_routes.dart';
import 'package:vip/admin/core/widgets/admin_bottom_nav.dart';
import 'package:vip/admin/core/widgets/admin_drawer.dart';
import 'package:vip/admin/core/widgets/admin_widgets.dart';
import 'package:vip/admin/services/admin_api_service.dart';
import 'package:vip/admin/modules/dashboard/controllers/admin_dashboard_controller.dart';
import 'package:vip/admin/modules/orders/controllers/orders_controller.dart';
import 'package:vip/admin/modules/users/controllers/users_controller.dart';
import 'package:vip/admin/modules/merchants/controllers/merchants_controller.dart';
import 'package:vip/admin/modules/inventory/controllers/inventory_movements_controller.dart';
import 'package:vip/admin/modules/inventory/controllers/low_stock_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  // ═══════════════════════════════════════════════════════════
  // JSON coercion helpers
  // ═══════════════════════════════════════════════════════════
  group('JSON coercion', () {
    test('adminInt accepts int, double, numeric string, and falls back', () {
      expect(adminInt(7), 7);
      // Mongo aggregations return a double where the app expects a count —
      // the merchant app crashed on exactly this with a raw `as int` cast.
      expect(adminInt(7.9), 7);
      expect(adminInt('12'), 12);
      expect(adminInt(null), 0);
      expect(adminInt('not a number'), 0);
      expect(adminInt(null, 10), 10);
    });

    test('adminDouble accepts int, double and numeric string', () {
      expect(adminDouble(3), 3.0);
      expect(adminDouble(3.5), 3.5);
      expect(adminDouble('2.25'), 2.25);
      expect(adminDouble(null), 0.0);
      expect(adminDouble('abc'), 0.0);
    });

    test('adminString unwraps a populated ref object to its id', () {
      expect(adminString('hello'), 'hello');
      expect(adminString(null), '');
      expect(adminString(null, 'fallback'), 'fallback');
      expect(adminString({'_id': 'abc123'}), 'abc123');
      expect(adminString({'id': 'xyz'}), 'xyz');
      expect(adminString(42), '42');
    });

    test('adminBool defaults correctly for a missing field', () {
      expect(adminBool(true), isTrue);
      expect(adminBool(false), isFalse);
      // isActive defaults to true on the User model, so an absent field must
      // read as active — reading it as false would show every user as banned.
      expect(adminBool(null, true), isTrue);
      expect(adminBool(null), isFalse);
      expect(adminBool('true'), isTrue);
    });

    test('adminDate returns null rather than throwing on a bad value', () {
      expect(adminDate('2026-08-30T10:00:00.000Z'), isNotNull);
      expect(adminDate(null), isNull);
      expect(adminDate('not a date'), isNull);
      expect(adminDate(12345), isNull);
    });

    test('adminItems survives a missing key, a null and a non-list', () {
      expect(adminItems({'items': [{'a': 1}, {'b': 2}]}).length, 2);
      expect(adminItems({'items': []}), isEmpty);
      expect(adminItems({'items': null}), isEmpty);
      expect(adminItems({'items': 'oops'}), isEmpty);
      expect(adminItems({}), isEmpty);
      expect(adminItems('not a map'), isEmpty);
    });

    test('adminItems skips non-map entries instead of crashing', () {
      // GET /favorites/details returns a null item for a deleted product;
      // the same defensive shape applies to every list here.
      final items = adminItems({
        'items': [
          {'ok': 1},
          null,
          'garbage',
          {'ok': 2},
        ]
      });
      expect(items.length, 2);
    });

    test('adminItems reads a named section', () {
      expect(adminItems({'series': [{'d': 1}]}, 'series').length, 1);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // Formatting
  // ═══════════════════════════════════════════════════════════
  group('Formatting', () {
    test('adminMoney formats dinar with three decimals', () {
      // The platform prices in TND; an earlier audit found six merchant
      // screens printing "$" in a dinar app.
      expect(adminMoney(12.5), 'D 12.500');
      expect(adminMoney(0), 'D 0.000');
      expect(adminMoney(1234.567), 'D 1,234.567');
    });

    test('adminCount groups thousands', () {
      expect(adminCount(0), '0');
      expect(adminCount(1234), '1,234');
    });

    test('adminLabel humanises a backend enum value', () {
      expect(adminLabel('refund_requested'), 'Refund Requested');
      expect(adminLabel('picked_up'), 'Picked Up');
      expect(adminLabel('pending'), 'Pending');
      expect(adminLabel(''), '—');
    });

    test('date labels render an em dash for null', () {
      expect(adminDateLabel(null), '—');
      expect(adminDateTimeLabel(null), '—');
      expect(adminRelative(null), '—');
    });

    test('adminRelative describes recent times', () {
      final now = DateTime.now();
      expect(adminRelative(now.subtract(const Duration(seconds: 5))), 'just now');
      expect(adminRelative(now.subtract(const Duration(minutes: 5))), '5m ago');
      expect(adminRelative(now.subtract(const Duration(hours: 3))), '3h ago');
      expect(adminRelative(now.subtract(const Duration(days: 2))), '2d ago');
    });
  });

  // ═══════════════════════════════════════════════════════════
  // Status → colour, checked against the real Mongoose enums
  // ═══════════════════════════════════════════════════════════
  group('Status colour mapping', () {
    test('every Order.status enum value maps to a non-default colour', () {
      // The full enum from models/Order.js. A value falling through to the
      // muted default is the exact bug that made every delivered order
      // render grey in the consumer app.
      const orderStatuses = [
        'pending', 'confirmed', 'processing', 'ready',
        'handover', 'picked_up', 'delivered',
        'canceled', 'cancelled', 'refund_requested', 'refunded',
      ];
      for (final status in orderStatuses) {
        expect(
          AdminColors.orderStatus(status),
          isNot(AdminColors.textMuted),
          reason: '"$status" falls through to the default colour',
        );
      }
    });

    test('delivered is green and cancelled is red, in both spellings', () {
      expect(AdminColors.orderStatus('delivered'), AdminColors.success);
      expect(AdminColors.orderStatus('cancelled'), AdminColors.danger);
      expect(AdminColors.orderStatus('canceled'), AdminColors.danger);
    });

    test('order status colour is case-insensitive', () {
      expect(AdminColors.orderStatus('DELIVERED'), AdminColors.success);
    });

    test('an unknown status degrades to the muted default', () {
      expect(AdminColors.orderStatus('teleported'), AdminColors.textMuted);
    });

    test('every BusinessRegistration.status value maps to a colour', () {
      for (final status in ['pending', 'under_review', 'approved', 'rejected']) {
        expect(
          AdminColors.approvalStatus(status),
          isNot(AdminColors.textMuted),
          reason: '"$status" falls through to the default colour',
        );
      }
      // 'none' is the console's own value for a merchant that never
      // submitted a registration, and is meant to read as muted.
      expect(AdminColors.approvalStatus('none'), AdminColors.textMuted);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // Navigation wiring
  // ═══════════════════════════════════════════════════════════
  group('Navigation', () {
    test('every drawer destination is a declared route', () {
      const declared = [
        AdminRoutes.DASHBOARD, AdminRoutes.USERS, AdminRoutes.MERCHANTS,
        AdminRoutes.ORDERS, AdminRoutes.INVENTORY, AdminRoutes.REPORTS,
        AdminRoutes.SETTINGS,
      ];
      for (final entry in AdminDrawer.entries) {
        expect(declared, contains(entry.route),
            reason: '${entry.label} points at an undeclared route');
      }
    });

    test('every bottom-nav destination also appears in the drawer', () {
      final drawerRoutes = AdminDrawer.entries.map((e) => e.route).toSet();
      for (final entry in AdminBottomNav.entries) {
        expect(drawerRoutes, contains(entry.route),
            reason: '${entry.label} is reachable from the bottom bar only');
      }
    });

    test('routes are unique', () {
      final routes = AdminDrawer.entries.map((e) => e.route).toList();
      expect(routes.toSet().length, routes.length);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // AdminDashboardController
  // ═══════════════════════════════════════════════════════════
  group('AdminDashboardController', () {
    late AdminDashboardController c;

    setUp(() => c = AdminDashboardController());

    test('stat() returns 0 before any response arrives', () {
      expect(c.stat('users', 'total'), 0);
      expect(c.stat('nothing', 'here'), 0);
    });

    test('stat() reads a nested section once loaded', () {
      c.stats.value = {
        'users': {'total': 191, 'banned': 3},
        'revenue': {'total': 232.5},
      };
      expect(c.stat('users', 'total'), 191);
      expect(c.stat('users', 'banned'), 3);
      expect(c.stat('revenue', 'total'), 232.5);
      // A key the backend did not send must not throw.
      expect(c.stat('users', 'missing'), 0);
      expect(c.stat('orders', 'total'), 0);
    });

    test('stat() ignores a non-numeric value rather than throwing', () {
      c.stats.value = {'users': {'total': 'many'}};
      expect(c.stat('users', 'total'), 0);
    });

    test('chartValues switches with the selected metric', () {
      c.series.value = [
        DashboardPoint(date: '2026-08-01', orders: 2, revenue: 50.0, users: 4, merchants: 1),
        DashboardPoint(date: '2026-08-02', orders: 5, revenue: 90.5, users: 1, merchants: 0),
      ];

      c.setChartMetric('revenue');
      expect(c.chartValues, [50.0, 90.5]);

      c.setChartMetric('orders');
      expect(c.chartValues, [2.0, 5.0]);

      c.setChartMetric('users');
      expect(c.chartValues, [4.0, 1.0]);

      // An unrecognised metric falls back to revenue rather than an empty chart.
      c.setChartMetric('nonsense');
      expect(c.chartValues, [50.0, 90.5]);
    });

    test('DashboardPoint.shortLabel formats the backend date', () {
      final point = DashboardPoint.fromJson(
        {'date': '2026-08-30', 'orders': 1, 'revenue': 2, 'users': 3, 'merchants': 4},
      );
      expect(point.shortLabel, '30 Aug');
      expect(point.orders, 1);
      expect(point.revenue, 2.0);
    });

    test('DashboardPoint.shortLabel falls back to the raw string', () {
      final point = DashboardPoint.fromJson({'date': 'garbage'});
      expect(point.shortLabel, 'garbage');
      expect(point.orders, 0);
    });

    test('chartLabels lines up with chartValues', () {
      c.series.value = [
        DashboardPoint(date: '2026-08-01', orders: 1, revenue: 1, users: 1, merchants: 1),
        DashboardPoint(date: '2026-08-02', orders: 1, revenue: 1, users: 1, merchants: 1),
      ];
      expect(c.chartLabels.length, c.chartValues.length);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // AdminOrdersController
  // ═══════════════════════════════════════════════════════════
  group('AdminOrdersController', () {
    late AdminOrdersController c;

    setUp(() => c = AdminOrdersController());
    tearDown(() => c.searchController.dispose());

    test('the status list covers the real Order.status enum', () {
      // 'canceled' is deliberately absent: the UI offers one "Cancelled"
      // control and the backend filter spans both spellings.
      for (final status in [
        'pending', 'confirmed', 'processing', 'ready',
        'handover', 'picked_up', 'delivered',
        'cancelled', 'refund_requested', 'refunded',
      ]) {
        expect(AdminOrdersController.statuses, contains(status));
      }
    });

    test('countFor sums both cancelled spellings', () {
      c.statusCounts.value = {
        'pending': 16,
        'cancelled': 4,
        'canceled': 3,
        'delivered': 5,
      };
      expect(c.countFor('cancelled'), 7);
      expect(c.countFor('pending'), 16);
      expect(c.countFor('delivered'), 5);
    });

    test('countFor("") totals every status', () {
      c.statusCounts.value = {'pending': 2, 'delivered': 3};
      expect(c.countFor(''), 5);
    });

    test('countFor returns 0 for a status with no rows', () {
      c.statusCounts.value = {'pending': 2};
      expect(c.countFor('refunded'), 0);
    });

    test('isTerminal blocks cancelling an order the backend would refuse', () {
      for (final status in ['delivered', 'picked_up', 'cancelled', 'canceled', 'refunded']) {
        expect(c.isTerminal(status), isTrue, reason: '$status should be terminal');
      }
      for (final status in ['pending', 'confirmed', 'processing', 'ready', 'handover']) {
        expect(c.isTerminal(status), isFalse, reason: '$status should be cancellable');
      }
    });

    test('hasScope and hasAnyFilter track the active filters', () {
      expect(c.hasScope, isFalse);
      expect(c.hasAnyFilter, isFalse);

      c.merchantFilter.value = 'abc123';
      expect(c.hasScope, isTrue);
      expect(c.hasAnyFilter, isTrue);

      c.merchantFilter.value = '';
      expect(c.hasScope, isFalse);
      expect(c.hasAnyFilter, isFalse);

      c.statusFilter.value = 'pending';
      expect(c.hasAnyFilter, isTrue);
      expect(c.hasScope, isFalse);

      c.statusFilter.value = '';
      c.dateRange.value = DateTimeRange(
        start: DateTime(2026, 8, 1),
        end: DateTime(2026, 8, 30),
      );
      expect(c.hasAnyFilter, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // AdminUsersController
  // ═══════════════════════════════════════════════════════════
  group('AdminUsersController', () {
    late AdminUsersController c;

    setUp(() => c = AdminUsersController());
    tearDown(() => c.searchController.dispose());

    test('isBanned treats a missing isActive as active', () {
      // User.isActive defaults to true, so an absent field must not render
      // the account as banned.
      expect(c.isBanned({'isActive': false}), isTrue);
      expect(c.isBanned({'isActive': true}), isFalse);
      expect(c.isBanned({}), isFalse);
      expect(c.isBanned({'isActive': null}), isFalse);
    });

    test('the default role filter is customers', () {
      expect(c.roleFilter.value, 'customer');
      expect(c.statusFilter.value, isEmpty);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // AdminMerchantsController
  // ═══════════════════════════════════════════════════════════
  group('AdminMerchantsController', () {
    late AdminMerchantsController c;

    setUp(() => c = AdminMerchantsController());
    tearDown(() => c.searchController.dispose());

    test('approvalOf reports "none" for a merchant with no registration', () {
      expect(c.approvalOf({'approvalStatus': 'approved'}), 'approved');
      expect(c.approvalOf({'approvalStatus': 'none'}), 'none');
      expect(c.approvalOf({}), 'none');
    });

    test('isPending covers both pre-decision states', () {
      expect(c.isPending({'approvalStatus': 'pending'}), isTrue);
      // under_review is a real enum value that an approval queue checking
      // only 'pending' would silently skip.
      expect(c.isPending({'approvalStatus': 'under_review'}), isTrue);
      expect(c.isPending({'approvalStatus': 'approved'}), isFalse);
      expect(c.isPending({'approvalStatus': 'rejected'}), isFalse);
      expect(c.isPending({}), isFalse);
    });

    test('displayName falls back through store, business, then owner name', () {
      expect(
        c.displayName({'storeName': 'QA Store', 'businessName': 'B', 'fullName': 'C'}),
        'QA Store',
      );
      expect(c.displayName({'businessName': 'Cafe QA', 'fullName': 'C'}), 'Cafe QA');
      expect(c.displayName({'fullName': 'Owner QA'}), 'Owner QA');
      expect(c.displayName({}), 'Unnamed merchant');
      // An empty string is as useless as a missing key and must fall through.
      expect(c.displayName({'storeName': '', 'fullName': 'Owner QA'}), 'Owner QA');
    });
  });

  // ═══════════════════════════════════════════════════════════
  // InventoryMovementsController  (Phase 1 — stock ledger)
  // ═══════════════════════════════════════════════════════════
  group('InventoryMovementsController', () {
    late InventoryMovementsController c;

    setUp(() => c = InventoryMovementsController());
    tearDown(() => c.searchController.dispose());

    test('the type list covers the whole StockMovement enum', () {
      // Mirrors models/StockMovement.js. A missing value here would leave a
      // real movement type with no filter chip and no label.
      for (final type in [
        'initial', 'in', 'out', 'adjustment',
        'transfer_in', 'transfer_out', 'removed',
      ]) {
        expect(InventoryMovementsController.types, contains(type));
      }
      expect(InventoryMovementsController.types.length, 7);
    });

    test('isInbound marks exactly the balance-increasing types', () {
      for (final type in ['in', 'initial', 'transfer_in']) {
        expect(InventoryMovementsController.isInbound(type), isTrue, reason: type);
      }
      for (final type in ['out', 'transfer_out', 'removed', 'adjustment']) {
        expect(InventoryMovementsController.isInbound(type), isFalse, reason: type);
      }
    });

    test('countFor reads the byType badges and totals them', () {
      c.typeCounts.value = {'in': 4, 'out': 3, 'transfer_in': 1, 'transfer_out': 1};
      expect(c.countFor('in'), 4);
      expect(c.countFor('out'), 3);
      expect(c.countFor(''), 9);
      expect(c.countFor('removed'), 0);
    });

    test('parse handles the nested {count, units} shape', () {
      c.parse({
        'byType': {
          'in': {'count': 2, 'units': 30},
          'out': {'count': 1, 'units': 5},
        }
      });
      expect(c.countFor('in'), 2);
      expect(c.countFor('out'), 1);
      expect(c.countFor(''), 3);
    });

    test('scope and filter flags track state', () {
      expect(c.hasScope, isFalse);
      expect(c.hasAnyFilter, isFalse);

      c.stockFilter.value = 'abc';
      expect(c.hasScope, isTrue);
      expect(c.hasAnyFilter, isTrue);

      c.stockFilter.value = '';
      c.typeFilter.value = 'transfer_out';
      expect(c.hasScope, isFalse);
      expect(c.hasAnyFilter, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // LowStockController  (Phase 1 — alerts across both sources)
  // ═══════════════════════════════════════════════════════════
  group('LowStockController', () {
    late LowStockController c;

    setUp(() => c = LowStockController());

    test('total spans store-room stock and catalogue products', () {
      c.stockAlerts.value = [
        {'name': 'A', 'currentStock': 0},
        {'name': 'B', 'currentStock': 3},
      ];
      c.productAlerts.value = [
        {'name': 'C', 'stock': 0},
      ];
      expect(c.total, 3);
    });

    test('outOfStockCount counts only what is actually at zero', () {
      c.stockAlerts.value = [
        {'currentStock': 0},
        {'currentStock': 2},
      ];
      c.productAlerts.value = [
        {'stock': 0},
        {'stock': 5},
      ];
      expect(c.outOfStockCount, 2);
    });

    test('the source filter shows one list or both', () {
      expect(c.showStock, isTrue);
      expect(c.showProducts, isTrue);

      c.setSourceFilter('stock');
      expect(c.showStock, isTrue);
      expect(c.showProducts, isFalse);

      c.setSourceFilter('products');
      expect(c.showStock, isFalse);
      expect(c.showProducts, isTrue);

      c.setSourceFilter('');
      expect(c.showStock, isTrue);
      expect(c.showProducts, isTrue);
    });
  });
}
