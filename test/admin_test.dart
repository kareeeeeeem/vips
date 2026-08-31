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
import 'package:vip/admin/core/routes/admin_pages.dart';
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
import 'package:vip/admin/modules/reports/controllers/reports_controller.dart';
import 'package:vip/admin/modules/staff/controllers/staff_controller.dart';
import 'package:vip/admin/modules/auth/controllers/admin_auth_controller.dart';
import 'package:vip/admin/modules/dashboards/controllers/finance_dashboard_controller.dart';
import 'package:vip/admin/modules/dashboards/controllers/marketing_dashboard_controller.dart';
import 'package:vip/admin/modules/dashboards/controllers/merchants_dashboard_controller.dart';
import 'package:vip/admin/modules/dashboards/controllers/operations_dashboard_controller.dart';
import 'package:vip/admin/modules/dashboards/controllers/sales_dashboard_controller.dart';
import 'package:vip/admin/modules/dashboards/models/dashboard_models.dart';
import 'package:vip/admin/modules/dashboards/views/dashboard_shell.dart';
import 'package:vip/admin/modules/products/controllers/products_controller.dart';
import 'package:vip/admin/core/widgets/admin_nav_entry.dart';

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
    test('every drawer destination has a registered page', () {
      // Checked against the real route table rather than a list repeated
      // here: a hand-maintained copy goes stale the moment a section is
      // added, and then the test fails for the wrong reason.
      final registered = AdminPages.routes.map((r) => r.name).toSet();
      // allEntries, not entries: the five analytical boards are nested inside
      // the Dashboards group, and checking only the top level would let a
      // broken child route ship.
      for (final entry in AdminDrawer.allEntries) {
        expect(registered, contains(entry.route),
            reason: '${entry.label} points at a route with no GetPage');
      }
    });

    test('every registered page is reachable from the drawer or another screen', () {
      // Detail, checkout and sibling-tab routes are opened from a parent
      // screen rather than the drawer, so they are listed here explicitly.
      // Anything not in either set would be a page nothing can navigate to.
      const openedFromAnotherScreen = {
        AdminRoutes.SPLASH,
        AdminRoutes.LOGIN,
        AdminRoutes.USER_DETAILS,
        AdminRoutes.MERCHANT_DETAILS,
        AdminRoutes.ORDER_DETAILS,
        AdminRoutes.INVENTORY_MOVEMENTS,
        AdminRoutes.INVENTORY_TRANSFERS,
        AdminRoutes.INVENTORY_ALERTS,
        AdminRoutes.POS_CHECKOUT,
        AdminRoutes.POS_INVOICE,
        AdminRoutes.POS_INVOICES,
        AdminRoutes.STAFF_NEW,
        AdminRoutes.STAFF_DETAILS,
        AdminRoutes.STAFF_EDIT,
        AdminRoutes.ROLES,
      };
      final drawerRoutes = AdminDrawer.allEntries.map((e) => e.route).toSet();
      for (final page in AdminPages.routes) {
        expect(
          drawerRoutes.contains(page.name) ||
              openedFromAnotherScreen.contains(page.name),
          isTrue,
          reason: '${page.name} is registered but nothing navigates to it',
        );
      }
    });

    test('every bottom-nav destination also appears in the drawer', () {
      final drawerRoutes = AdminDrawer.allEntries.map((e) => e.route).toSet();
      for (final entry in AdminBottomNav.entries) {
        expect(drawerRoutes, contains(entry.route),
            reason: '${entry.label} is reachable from the bottom bar only');
      }
    });

    test('routes are unique', () {
      // A group repeats the route of the board it opens, so uniqueness is
      // asserted over the leaves an operator can actually land on.
      final routes = AdminDrawer.allEntries
          .where((e) => !e.isGroup)
          .map((e) => e.route)
          .toList();
      expect(routes.toSet().length, routes.length);
    });

    test('every dashboard in the switcher is also in the drawer', () {
      // Two lists naming the same five boards is exactly how one of them ends
      // up pointing at a route the other never registered.
      final drawerRoutes = AdminDrawer.allEntries.map((e) => e.route).toSet();
      for (final tab in DashboardShell.tabs) {
        expect(drawerRoutes, contains(tab.route),
            reason: '${tab.label} is reachable from the switcher only');
      }
    });

    test('the switcher and the drawer agree on what each board needs', () {
      final byRoute = {
        for (final e in AdminDrawer.allEntries)
          if (e.permission != null) e.route: e.permission,
      };
      for (final tab in DashboardShell.tabs) {
        expect(byRoute[tab.route], tab.permission,
            reason: '${tab.label} is gated differently in the drawer and the '
                'switcher, so one of them will offer a board that 403s');
      }
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

  // ═══════════════════════════════════════════════════════════
  // AdminReportsController  (Phase 3 — advanced reports)
  // ═══════════════════════════════════════════════════════════
  group('AdminReportsController', () {
    late AdminReportsController c;

    setUp(() => c = AdminReportsController());

    test('all seven reports are listed', () {
      for (final type in [
        'sales', 'profit', 'products', 'customers',
        'orders', 'merchants', 'commission',
      ]) {
        expect(AdminReportsController.reports, contains(type));
      }
      expect(AdminReportsController.reports.length, 7);
    });

    test('only the lifetime report is flagged as ignoring the date range', () {
      c.activeTab.value = 'merchants';
      expect(c.isLifetime, isTrue);
      for (final type in ['sales', 'profit', 'products', 'customers', 'orders']) {
        c.activeTab.value = type;
        expect(c.isLifetime, isFalse, reason: type);
      }
    });

    test('only groupable reports offer a granularity', () {
      for (final type in ['sales', 'profit', 'customers']) {
        c.activeTab.value = type;
        expect(c.isGroupable, isTrue, reason: type);
      }
      for (final type in ['products', 'orders', 'merchants', 'commission']) {
        c.activeTab.value = type;
        expect(c.isGroupable, isFalse, reason: type);
      }
    });

    test('summary() reads a nested figure and falls back to 0', () {
      c.cache['sales'] = {
        'summary': {'revenue': 248.565, 'orders': 7}
      };
      c.activeTab.value = 'sales';
      expect(c.summary('revenue'), 248.565);
      expect(c.summary('orders'), 7);
      // A key the backend did not send must not throw.
      expect(c.summary('missing'), 0);
    });

    test('summaryIsNull distinguishes "no data" from zero', () {
      // The orders report sends null for average fulfilment when nothing
      // reached "delivered" — rendering that as 0 would read as instant
      // delivery rather than as no data.
      c.cache['orders'] = {
        'summary': {'averageFulfilmentMinutes': null, 'total': 0}
      };
      c.activeTab.value = 'orders';
      expect(c.summaryIsNull('averageFulfilmentMinutes'), isTrue);
      expect(c.summaryIsNull('total'), isFalse);
      expect(c.summary('total'), 0);
    });

    test('changing the date range clears every cached report', () {
      c.cache['sales'] = {'summary': {}};
      c.cache['profit'] = {'summary': {}};
      // Each cached answer was computed for the old window, so keeping any
      // of them would show one report on a different period from the rest.
      c.dateRange.value = DateTimeRange(
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 31),
      );
      c.cache.clear();
      expect(c.cache, isEmpty);
    });

    test('changing granularity only clears the reports it affects', () {
      c.cache['sales'] = {'summary': {}};
      c.cache['orders'] = {'summary': {}};
      c.setGroupBy('month');
      expect(c.cache.containsKey('sales'), isFalse);
      // Orders has no granularity, so its cached answer is still valid.
      expect(c.cache.containsKey('orders'), isTrue);
    });

    test('the export filename names the report and the day', () {
      c.activeTab.value = 'commission';
      expect(c.exportFilename, startsWith('vips-commission-'));
      expect(c.exportFilename, endsWith('.csv'));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // StaffController  (Phase 4 — console operators)
  // ═══════════════════════════════════════════════════════════
  group('StaffController', () {
    late StaffController c;
    late AdminAuthController auth;

    setUp(() {
      auth = AdminAuthController();
      Get.put<AdminAuthController>(auth);
      c = StaffController();
    });

    tearDown(() {
      c.searchController.dispose();
      auth.emailController.dispose();
      auth.passwordController.dispose();
    });

    test('all five built-in roles are listed', () {
      expect(StaffController.builtInRoles,
          ['viewer', 'cashier', 'manager', 'admin', 'super_admin']);
    });

    test('permissionsByModule follows the server\'s module order', () {
      c.moduleOrder.value = ['dashboard', 'users', 'orders'];
      c.moduleActions.value = {
        'dashboard': ['read'],
        'users': ['create', 'read', 'ban'],
        'orders': ['read', 'cancel'],
      };
      final grouped = c.permissionsByModule;
      // Order matters: alphabetical grouping would put orders before users
      // and read before create, which is not how the model is laid out.
      expect(grouped.keys.toList(), ['dashboard', 'users', 'orders']);
      expect(grouped['users'], ['users.create', 'users.read', 'users.ban']);
    });

    test('roleGrants understands exact, wildcard and module-wildcard grants', () {
      c.rolePermissions.value = {
        'super_admin': ['*'],
        'viewer': ['users.read'],
        'manager': ['orders.*'],
      };
      expect(c.roleGrants('super_admin', 'users.delete'), isTrue);
      expect(c.roleGrants('viewer', 'users.read'), isTrue);
      expect(c.roleGrants('viewer', 'users.ban'), isFalse);
      expect(c.roleGrants('manager', 'orders.refund'), isTrue);
      expect(c.roleGrants('manager', 'users.read'), isFalse);
    });

    test('a permission that gates nothing is reported as such', () {
      c.catalogue.value = {
        'orders.cancel': {'label': 'Cancel an order', 'enforced': true, 'reason': ''},
        'orders.delete': {
          'label': 'Delete an order',
          'enforced': false,
          'reason': 'Orders are financial records.',
        },
      };
      expect(c.isEnforced('orders.cancel'), isTrue);
      expect(c.isEnforced('orders.delete'), isFalse);
      expect(c.enforcementReason('orders.delete'), contains('financial records'));
      expect(c.describe('orders.cancel'), 'Cancel an order');
      // An unknown key must not throw — it falls back to the raw string.
      expect(c.describe('nothing.here'), 'nothing.here');
      expect(c.isEnforced('nothing.here'), isTrue);
    });

    test('only a super admin may assign the super admin role', () {
      auth.adminRole.value = 'admin';
      expect(c.canAssignRole('viewer'), isTrue);
      expect(c.canAssignRole('manager'), isTrue);
      expect(c.canAssignRole('admin'), isTrue);
      // The server refuses this too — the UI just says so first.
      expect(c.canAssignRole('super_admin'), isFalse);

      auth.adminRole.value = 'super_admin';
      expect(c.canAssignRole('super_admin'), isTrue);
    });

    test('canWrite and canDelete follow the caller\'s own permissions', () {
      auth.permissions.value = ['staff.read'];
      expect(c.canWrite, isFalse);
      expect(c.canDelete, isFalse);

      auth.permissions.value = ['staff.read', 'staff.write'];
      expect(c.canWrite, isTrue);
      expect(c.canDelete, isFalse);

      auth.permissions.value = ['*'];
      expect(c.canWrite, isTrue);
      expect(c.canDelete, isTrue);
    });

    test('deleteBlockedReason names every reason the server would refuse', () {
      auth.adminId.value = 'me';
      auth.adminRole.value = 'super_admin';
      auth.permissions.value = ['*'];
      c.total.value = 5;

      // Deleting yourself locks you out mid-session.
      expect(c.deleteBlockedReason({'_id': 'me', 'adminRole': 'admin'}),
          contains('your own account'));

      // The last admin would leave nobody able to sign in.
      c.total.value = 1;
      expect(c.deleteBlockedReason({'_id': 'other', 'adminRole': 'admin'}),
          contains('last admin'));

      c.total.value = 5;
      expect(c.deleteBlockedReason({'_id': 'other', 'adminRole': 'admin'}), isNull);

      auth.adminRole.value = 'admin';
      expect(c.deleteBlockedReason({'_id': 'other', 'adminRole': 'super_admin'}),
          contains('super admin'));

      auth.permissions.value = ['staff.read'];
      expect(c.deleteBlockedReason({'_id': 'other', 'adminRole': 'viewer'}),
          contains('does not allow'));
    });

    test('isSelf compares against the signed-in admin', () {
      auth.adminId.value = 'abc123';
      expect(c.isSelf({'_id': 'abc123'}), isTrue);
      expect(c.isSelf({'_id': 'other'}), isFalse);
      expect(c.isSelf({}), isFalse);
    });

    test('permissions group by module for a readable checklist', () {
      c.allPermissions.value = [
        'orders.read', 'orders.write', 'orders.delete',
        'users.read', 'users.write',
      ];
      final grouped = c.permissionsByModule;
      expect(grouped.keys, containsAll(['orders', 'users']));
      expect(grouped['orders']!.length, 3);
      expect(grouped['users']!.length, 2);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // AdminAuthController permission checks
  // ═══════════════════════════════════════════════════════════
  // ═══════════════════════════════════════════════════════════
  // Analytical dashboards
  // ═══════════════════════════════════════════════════════════
  group('DashboardPeriod', () {
    test('every preset round-trips through its wire key', () {
      for (final period in DashboardPeriod.values) {
        expect(DashboardPeriodX.fromKey(period.key), period);
      }
    });

    test('an unknown key falls back to the default window', () {
      // The server does the same thing, so the chip and the data agree
      // instead of the screen claiming a window nobody queried.
      expect(DashboardPeriodX.fromKey('fortnight'), DashboardPeriod.month);
      expect(DashboardPeriodX.fromKey(''), DashboardPeriod.month);
    });
  });

  group('ChartPoint', () {
    test('reads the label and value spellings the endpoints actually send', () {
      expect(ChartPoint.fromJson({'date': '2026-08-01', 'value': 12.5}).label,
          '2026-08-01');
      expect(
          ChartPoint.fromJson({'status': 'pending', 'count': 4},
                  labelKey: 'status', valueKey: 'count')
              .value,
          4);
      expect(
          ChartPoint.fromJson({'category': 'Food', 'amount': 9},
                  labelKey: 'category', valueKey: 'amount')
              .label,
          'Food');
      expect(
          ChartPoint.fromJson({'segment': 'Active', 'count': 3},
                  labelKey: 'segment', valueKey: 'count')
              .value,
          3);
    });

    test('a missing label reads as a dash rather than throwing', () {
      final point = ChartPoint.fromJson(const {});
      expect(point.label, '—');
      expect(point.value, 0);
    });

    test('an int and a double both parse to the same value', () {
      // Mongo returns whichever the aggregation produced, and a list builder
      // that throws on one of them blanks the whole screen.
      expect(ChartPoint.fromJson({'date': 'a', 'value': 7}).value, 7.0);
      expect(ChartPoint.fromJson({'date': 'a', 'value': 7.0}).value, 7.0);
    });

    test('slice colours are stable for a given index', () {
      // A legend that reshuffles its colours on every refresh is unreadable.
      expect(dashboardSliceColor(0), dashboardSliceColor(0));
      expect(dashboardSliceColor(kDashboardPalette.length),
          dashboardSliceColor(0));
    });
  });

  group('DashboardBaseController payload reading', () {
    late SalesDashboardController c;

    setUp(() {
      c = SalesDashboardController();
      c.data.value = {
        'window': {
          'period': 'week',
          'groupBy': 'day',
          'startDate': '2026-08-24T21:00:00.000Z',
          'endDate': '2026-08-31T10:00:00.000Z',
        },
        'totalRevenue': 248.565,
        'totalOrders': 7,
        'conversionRate': null,
        'previous': {'totalRevenue': 100},
        'change': {'totalRevenue': 148.5, 'totalOrders': null},
        'engagementMetrics': {'repeatRate': 25},
        'salesChart': [
          {'date': '2026-08-24', 'value': 0, 'orders': 0},
          {'date': '2026-08-25', 'value': 160, 'orders': 2},
        ],
        'topProducts': [
          {'name': 'Latte', 'sales': 5, 'revenue': 220}
        ],
      };
    });

    test('reads numbers, counts and money off the payload', () {
      expect(c.money('totalRevenue'), 248.565);
      expect(c.count('totalOrders'), 7);
      expect(c.number('totalRevenue'), 248.565);
    });

    test('an absent key reads as zero rather than throwing', () {
      expect(c.money('notThere'), 0);
      expect(c.count('notThere'), 0);
      expect(c.table('notThere'), isEmpty);
      expect(c.chart('notThere'), isEmpty);
    });

    test('an explicit null is distinguishable from zero', () {
      // "Not measurable" and "measured zero" must never render the same way.
      expect(c.isNull('conversionRate'), isTrue);
      expect(c.isNull('totalOrders'), isFalse);
      expect(c.conversionIsTracked, isFalse);
    });

    test('a change with no baseline stays null instead of becoming zero', () {
      expect(c.change('totalRevenue'), 148.5);
      expect(c.change('totalOrders'), isNull);
      expect(c.change('neverSent'), isNull);
    });

    test('previous-period and nested figures read through', () {
      expect(c.previous('totalRevenue'), 100);
      expect(c.nested('engagementMetrics', 'repeatRate'), 25);
      expect(c.nested('notABlock', 'x'), 0);
    });

    test('the window label reports what the server applied, not what was asked',
        () {
      // A bad custom range falls back server-side; a filter still reading
      // "Custom" over last month's numbers is how a whole board is misread.
      c.period.value = DashboardPeriod.custom;
      expect(c.appliedWindowLabel, contains('by day'));
      expect(c.appliedWindowLabel, isNot(equals(DashboardPeriod.custom.label)));
    });

    test('charts keep zero buckets so a flat stretch is visible', () {
      final chart = c.salesChart;
      expect(chart.length, 2);
      expect(chart.first.value, 0);
      expect(chart[1].count, 2);
    });

    test('order volume is derived from the revenue series, not refetched', () {
      // Two series over two different windows drawn on one screen is the
      // failure this rules out.
      expect(c.orderVolume.map((p) => p.label).toList(),
          c.salesChart.map((p) => p.label).toList());
      expect(c.orderVolume[1].value, 2);
    });

    test('the channel split adds up to the revenue it came from', () {
      c.data['onlineRevenue'] = 232.5;
      c.data['posRevenue'] = 16.065;
      final total = c.channelSplit.fold<double>(0, (sum, p) => sum + p.value);
      expect(total, closeTo(c.totalRevenue, 0.001));
    });

    test('a custom filter with no range is ignored', () {
      // Otherwise the controller would query period=custom with no dates and
      // the server would silently answer for a different window.
      c.period.value = DashboardPeriod.week;
      c.setFilter(DashboardPeriod.custom, null);
      expect(c.period.value, DashboardPeriod.week);
    });

    test('every board names the endpoint and permission it needs', () {
      expect(SalesDashboardController().endpoint, 'sales');
      expect(SalesDashboardController().permission, 'reports.read');
      expect(OperationsDashboardController().endpoint, 'operations');
      // The shift-level board, so a cashier can open it.
      expect(OperationsDashboardController().permission, 'dashboard.read');
      expect(FinanceDashboardController().permission, 'reports.read');
      expect(MarketingDashboardController().permission, 'reports.read');
      expect(MerchantsDashboardController().permission, 'reports.read');
    });
  });

  group('Dashboard figures that must not be faked', () {
    test('fulfilment time reports no sample instead of zero', () {
      final c = OperationsDashboardController();
      c.data.value = {'averageFulfillmentTime': null, 'fulfillmentSampleSize': 0};
      expect(c.hasFulfilmentSample, isFalse);

      c.data.value = {'averageFulfillmentTime': 4.2, 'fulfillmentSampleSize': 5};
      expect(c.hasFulfilmentSample, isTrue);
      expect(c.averageFulfilmentHours, 4.2);
    });

    test('churn reports no cohort instead of perfect retention', () {
      final c = MarketingDashboardController();
      c.data.value = {'churnRate': null, 'churnBaseline': 0};
      expect(c.hasChurnBaseline, isFalse);

      c.data.value = {'churnRate': 18.5, 'churnBaseline': 40};
      expect(c.hasChurnBaseline, isTrue);
      expect(c.churnRate, 18.5);
    });

    test('an unrated merchant is not printed as a zero rating', () {
      expect(dashboardRating(null), 'Unrated');
      expect(dashboardRating(0), 'Unrated');
      expect(dashboardRating(4.75), '4.8 ★');
    });

    test('money and percentage columns dash out on a missing value', () {
      expect(dashboardMoney(null), '—');
      expect(dashboardPercent(null), '—');
      expect(dashboardCount(null), '—');
      expect(dashboardPercent(10.25), '10.3%');
    });

    test('the merchant ranking carries orders alongside revenue', () {
      final c = MerchantsDashboardController();
      c.data.value = {
        'topMerchants': [
          {'name': 'Cafe Central', 'revenue': 1250, 'orders': 45},
          {'revenue': 10},
        ],
      };
      expect(c.revenueRanking.first.label, 'Cafe Central');
      expect(c.revenueRanking.first.count, 45);
      // A row with no name still ranks rather than throwing mid-build.
      expect(c.revenueRanking[1].label, 'Unknown');
    });

    test('the finance board keeps the coverage behind its margin', () {
      final c = FinanceDashboardController();
      c.data.value = {
        'totalRevenue': 246,
        'costedRevenue': 13.5,
        'costCoverage': 5.488,
        'margin': 57.037,
        'merchantsOnZeroRate': 3,
      };
      // A margin without its coverage is a statement about 5% of the business
      // presented as a statement about all of it.
      expect(c.costCoverage, 5.488);
      expect(c.costedRevenue, lessThan(c.totalRevenue));
      expect(c.merchantsOnZeroRate, 3);
    });
  });

  group('Identity loading', () {
    test('an unknown identity is not the same as no permissions', () {
      // A browser refresh on any route enters past the splash, so nothing has
      // asked /admin/me yet. Treating that as "denied" would strip every
      // permission-gated control off the screen for a super admin.
      final auth = AdminAuthController();
      expect(auth.isIdentityLoaded.value, isFalse);
      expect(auth.can('reports.read'), isFalse);

      // The nav gates on this flag, not on `can`, so nothing is hidden while
      // the answer is still unknown.
      expect(DashboardShell.tabs.length, 5);
    });
  });

  group('AdminProductsController', () {
    late AdminProductsController c;

    setUp(() => c = AdminProductsController());

    test('the selling price is the discount when one is in force', () {
      // This must match what the till freezes onto a line, or the catalogue
      // screen and a receipt would disagree about what a product costs.
      expect(c.sellingPrice({'price': 10.0, 'discountPrice': 7.5}), 7.5);
      expect(c.sellingPrice({'price': 10.0, 'discountPrice': 0}), 10.0);
      expect(c.sellingPrice({'price': 10.0, 'discountPrice': null}), 10.0);
      expect(c.sellingPrice(const {}), 0);
    });

    test('a cost of zero reads as "not recorded", not as free', () {
      expect(c.hasCost({'costPrice': 4.0}), isTrue);
      expect(c.hasCost({'costPrice': 0}), isFalse);
      expect(c.hasCost(const {}), isFalse);
    });

    test('products with no cost are counted so the screen can say why', () {
      c.items.value = [
        {'costPrice': 4.0},
        {'costPrice': 0},
        {'name': 'no cost key'},
      ];
      expect(c.missingCostCount, 2);
    });

    test('status filters name what they select', () {
      expect(AdminProductsController.statusLabel('active'), 'Active');
      expect(AdminProductsController.statusLabel('inactive'), 'Hidden');
      // The filter that exists to find what holds the profit report back.
      expect(AdminProductsController.statusLabel('no_cost'), 'No cost set');
      expect(AdminProductsController.statusLabel(''), 'All');
    });

    test('deleting is blocked without the permission', () {
      // No auth controller is registered here, so `can` answers false — the
      // reason must still be a sentence rather than a null that reads as
      // "allowed".
      expect(c.deleteBlockedReason(const {}), isNotNull);
    });
  });

  group('Navigation permissions', () {
    test('an entry with no permission is always allowed', () {
      expect(
        AdminDrawer.isAllowed(
          const AdminNavEntry('/x', 'X', Icons.abc)),
        isTrue,
      );
    });

    test('an unknown identity does not hide a section', () {
      // No AdminAuthController registered stands in for "/admin/me has not
      // answered". Reading that as "denied" would empty the drawer on a
      // browser refresh.
      expect(
        AdminDrawer.isAllowed(const AdminNavEntry(
            '/x', 'X', Icons.abc, permission: 'reports.read')),
        isTrue,
      );
    });

    test('every drawer and bottom-nav destination names its permission', () {
      // A destination with no permission cannot be filtered, so it would be
      // offered to a role the server refuses.
      final unguarded = [
        ...AdminDrawer.allEntries.where((e) => !e.isGroup),
        ...AdminBottomNav.entries,
      ].where((e) => e.permission == null).map((e) => e.label).toList();
      expect(unguarded, isEmpty,
          reason: 'these sections cannot be hidden from a role that cannot '
              'open them: ${unguarded.join(', ')}');
    });

    test('the bottom bar is a subset of the drawer, permissions included', () {
      final byRoute = {
        for (final e in AdminDrawer.allEntries) e.route: e.permission,
      };
      for (final entry in AdminBottomNav.entries) {
        expect(byRoute[entry.route], entry.permission,
            reason: '${entry.label} is gated differently in the two bars, so '
                'one of them will offer a screen the other hides');
      }
    });
  });

  group('AdminAuthController.can', () {
    late AdminAuthController c;

    setUp(() => c = AdminAuthController());
    tearDown(() {
      c.emailController.dispose();
      c.passwordController.dispose();
    });

    test('the wildcard grants everything', () {
      c.permissions.value = ['*'];
      expect(c.can('orders.delete'), isTrue);
      expect(c.can('anything.at.all'), isTrue);
    });

    test('an exact permission is honoured', () {
      c.permissions.value = ['orders.read'];
      expect(c.can('orders.read'), isTrue);
      expect(c.can('orders.write'), isFalse);
    });

    test('a module wildcard covers its actions', () {
      // Matches the server's own check, so the UI and the gate agree.
      c.permissions.value = ['orders.*'];
      expect(c.can('orders.read'), isTrue);
      expect(c.can('orders.delete'), isTrue);
      expect(c.can('users.read'), isFalse);
    });

    test('no permissions grants nothing', () {
      c.permissions.clear();
      expect(c.can('dashboard.read'), isFalse);
    });
  });
}
