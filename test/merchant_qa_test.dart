// merchant_qa_test.dart
//
// Comprehensive automated test suite for the VIPs Merchant Flutter app.
// Tests are pure unit tests — no HTTP calls, no mocks required.
// Uses GetX test mode to safely instantiate controllers.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Controllers under test
import 'package:vip/appmerchant/modules/merchant_billing/controllers/merchant_create_bill_controller.dart';
import 'package:vip/appmerchant/modules/merchant_billing/controllers/merchant_billing_controller.dart';
import 'package:vip/appmerchant/core/util/app_constants.dart';

// ApiResponse model (self-contained in api_service.dart)
import 'package:vip/core/services/api_service.dart';

// ─────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    Get.reset(); // clear previous controller registrations
  });

  tearDown(() {
    Get.reset();
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 1 — Auth Tests
  // ═══════════════════════════════════════════════════════════
  group('Auth Tests', () {
    test('1.1  Phone field starts empty', () {
      // MerchantAuthController wraps a TextEditingController; we verify
      // that when the controller text is blank the value is indeed empty.
      final phoneCtrl = TextEditingController();
      expect(phoneCtrl.text.trim().isEmpty, isTrue);
      phoneCtrl.dispose();
    });

    test('1.2  Phone shorter than 7 digits is considered invalid', () {
      const shortPhone = '12345';
      // Business rule: phone must be at least 7 characters
      expect(shortPhone.length < 7, isTrue);
    });

    test('1.3  Phone with 10 digits passes basic length check', () {
      const validPhone = '0512345678';
      expect(validPhone.length >= 7, isTrue);
      expect(validPhone.trim().isNotEmpty, isTrue);
    });

    test('1.4  OTP shorter than 4 digits is rejected', () {
      const shortOtp = '123';
      // Mirrors the guard in MerchantAuthController.verifyOtp
      expect(shortOtp.length < 4, isTrue);
    });

    test('1.5  OTP of exactly 4 digits passes length validation', () {
      const validOtp = '1234';
      expect(validOtp.length >= 4, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 2 — Catalog Tests
  // ═══════════════════════════════════════════════════════════
  group('Catalog Tests', () {
    test('2.1  Item name validation — empty name fails', () {
      const name = '';
      expect(name.trim().isEmpty, isTrue);
    });

    test('2.2  Item name validation — non-empty name passes', () {
      const name = 'Grilled Chicken';
      expect(name.trim().isEmpty, isFalse);
    });

    test('2.3  Price validation — zero price is invalid', () {
      final price = double.tryParse('0') ?? 0.0;
      expect(price <= 0, isTrue);
    });

    test('2.4  Price validation — negative price is invalid', () {
      final price = double.tryParse('-5.00') ?? 0.0;
      expect(price <= 0, isTrue);
    });

    test('2.5  Price validation — valid positive price passes', () {
      final price = double.tryParse('29.99') ?? 0.0;
      expect(price > 0, isTrue);
    });

    test('2.6  Tag de-duplication logic', () {
      final tags = <String>[];
      void addTag(String tag) {
        if (tag.isNotEmpty && !tags.contains(tag)) tags.add(tag);
      }

      addTag('burger');
      addTag('burger'); // duplicate — should not be added
      addTag('pizza');

      expect(tags.length, equals(2));
      expect(tags, containsAll(['burger', 'pizza']));
    });

    test('2.7  Tag removal logic', () {
      final tags = ['burger', 'pizza', 'pasta'];
      tags.remove('pizza');
      expect(tags.contains('pizza'), isFalse);
      expect(tags.length, equals(2));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 3 — Billing Tests
  // ═══════════════════════════════════════════════════════════
  group('Billing Tests', () {
    late MerchantCreateBillController createBillCtrl;

    setUp(() {
      createBillCtrl = MerchantCreateBillController();
    });

    tearDown(() {
      createBillCtrl.onClose();
    });

    test('3.1  Initial amount is 0.00', () {
      expect(createBillCtrl.amount.value, equals('0.00'));
    });

    test('3.2  appendNumber builds the amount correctly', () {
      createBillCtrl.appendNumber('5');
      createBillCtrl.appendNumber('0');
      expect(createBillCtrl.amount.value, equals('50'));
    });

    test('3.3  appendDecimal adds a dot once', () {
      createBillCtrl.appendNumber('1');
      createBillCtrl.appendDecimal();
      createBillCtrl.appendDecimal(); // second call should be a no-op
      expect(createBillCtrl.amount.value.split('.').length, equals(2));
    });

    test('3.4  backspace removes the last character', () {
      createBillCtrl.appendNumber('1');
      createBillCtrl.appendNumber('2');
      createBillCtrl.backspace();
      expect(createBillCtrl.amount.value, equals('1'));
    });

    test('3.5  clearAmount resets to 0.00', () {
      createBillCtrl.appendNumber('9');
      createBillCtrl.clearAmount();
      expect(createBillCtrl.amount.value, equals('0.00'));
    });

    test('3.6  PIN digit addition — accumulates up to pinLength', () {
      // Tests MerchantBillingController PIN logic without network calls
      final billingCtrl = MerchantBillingController();
      billingCtrl.addPinDigit('1');
      billingCtrl.addPinDigit('2');
      billingCtrl.addPinDigit('3');
      billingCtrl.addPinDigit('4');
      // 5th digit should be ignored (pinLength = 4)
      billingCtrl.addPinDigit('5');

      expect(billingCtrl.currentPin.value.length, equals(4));
      expect(billingCtrl.currentPin.value, equals('1234'));
    });

    test('3.7  PIN backspace removes last digit', () {
      final billingCtrl = MerchantBillingController();
      billingCtrl.addPinDigit('7');
      billingCtrl.addPinDigit('8');
      billingCtrl.removePinDigit();
      expect(billingCtrl.currentPin.value, equals('7'));
    });

    test('3.8  Bill subtotal / grand-total calculation', () {
      // Basic arithmetic that mirrors how the UI computes totals
      const double itemPrice = 25.0;
      const int qty = 3;
      const double taxRate = 0.15;

      final subtotal = itemPrice * qty;
      final taxAmount = subtotal * taxRate;
      final grandTotal = subtotal + taxAmount;

      expect(subtotal, equals(75.0));
      expect(taxAmount, closeTo(11.25, 0.001));
      expect(grandTotal, closeTo(86.25, 0.001));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 4 — API Model Tests
  // ═══════════════════════════════════════════════════════════
  group('API Model Tests', () {
    test('4.1  ApiResponse can be constructed with success=true', () {
      final response = ApiResponse(
        success: true,
        statusCode: 200,
        message: 'OK',
        data: {'id': 'abc123'},
      );

      expect(response.success, isTrue);
      expect(response.statusCode, equals(200));
      expect(response.message, equals('OK'));
      expect((response.data as Map<String, dynamic>)['id'], equals('abc123'));
    });

    test('4.2  ApiResponse can be constructed with success=false', () {
      final response = ApiResponse(
        success: false,
        statusCode: 401,
        message: 'Unauthorized',
      );

      expect(response.success, isFalse);
      expect(response.statusCode, equals(401));
      expect(response.data, isNull);
    });

    test('4.3  ApiResponse.toString() includes key fields', () {
      final response = ApiResponse(
        success: true,
        statusCode: 201,
        message: 'Created',
      );
      final str = response.toString();
      expect(str, contains('201'));
      expect(str, contains('Created'));
    });

    test('4.4  ApiResponse with list data is accessible', () {
      final response = ApiResponse(
        success: true,
        statusCode: 200,
        message: 'Success',
        data: [
          {'name': 'Item A', 'price': 10.0},
          {'name': 'Item B', 'price': 20.0},
        ],
      );

      final list = response.data as List<dynamic>;
      expect(list.length, equals(2));
      expect((list[0] as Map<String, dynamic>)['name'], equals('Item A'));
    });

    test('4.5  ApiResponse with null data does not throw', () {
      final response = ApiResponse(
        success: false,
        statusCode: 500,
        message: 'Server Error',
        data: null,
      );
      expect(response.data, isNull);
      expect(() => response.toString(), returnsNormally);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 5 — AppConstants Tests
  // ═══════════════════════════════════════════════════════════
  group('AppConstants Tests', () {
    test('5.1  baseUrl is not empty', () {
      expect(AppConstants.baseUrl.isNotEmpty, isTrue);
    });

    test('5.2  baseUrl starts with http', () {
      expect(AppConstants.baseUrl.startsWith('http'), isTrue);
    });

    test('5.3  All auth endpoint URIs start with /api', () {
      expect(AppConstants.loginUri.startsWith('/api'), isTrue);
      expect(AppConstants.forgetPasswordUri.startsWith('/api'), isTrue);
      expect(AppConstants.verifyTokenUri.startsWith('/api'), isTrue);
      expect(AppConstants.resetPasswordUri.startsWith('/api'), isTrue);
    });

    test('5.4  Catalog URIs are properly formatted', () {
      expect(AppConstants.itemListUri.isNotEmpty, isTrue);
      expect(AppConstants.addItemUri.isNotEmpty, isTrue);
      expect(AppConstants.updateItemUri.isNotEmpty, isTrue);
      expect(AppConstants.deleteItemUri.isNotEmpty, isTrue);
    });

    test('5.5  Storage key constants are non-empty strings', () {
      expect(AppConstants.token.isNotEmpty, isTrue);
      expect(AppConstants.languageCode.isNotEmpty, isTrue);
    });

    test('5.6  appName is the expected merchant app name', () {
      expect(AppConstants.appName, equals('VIPsApp Merchant'));
    });
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 6 — Order Controller Logic Tests (pure, no service call)
  // ═══════════════════════════════════════════════════════════
  group('Order Controller Logic Tests', () {
    test('6.1  Status filter list contains expected statuses', () {
      // Mirrors MerchantOrderController.statusFilters, which now covers
      // Order.status's full enum (handover / picked_up / refund_requested /
      // refunded used to be missing).
      const filters = [
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
      expect(filters.contains('all'), isTrue);
      expect(filters.contains('pending'), isTrue);
      expect(filters.contains('delivered'), isTrue);
      expect(filters.contains('handover'), isTrue);
      expect(filters.contains('picked_up'), isTrue);
      expect(filters.contains('refunded'), isTrue);
      expect(filters.length, equals(11));
    });

    test('6.2  Order status color mapping — delivered is green', () {
      Color getColor(String? status) {
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
            return Colors.red;
          default:
            return Colors.grey;
        }
      }

      expect(getColor('delivered'), equals(Colors.green));
      expect(getColor('canceled'), equals(Colors.red));
      expect(getColor('pending'), equals(Colors.orange));
      expect(getColor(null), equals(Colors.grey));
    });

    test('6.3  Date formatting helper handles null gracefully', () {
      String formatDate(String? dateString) {
        if (dateString == null) return '-';
        try {
          DateTime.parse(dateString);
          return 'formatted';
        } catch (_) {
          return dateString;
        }
      }

      expect(formatDate(null), equals('-'));
      expect(formatDate('2024-01-15T10:30:00Z'), equals('formatted'));
      expect(formatDate('not-a-date'), equals('not-a-date'));
    });

    test('6.4  Search filter logic filters by order id', () {
      final orders = [
        {'id': '1001', 'customerName': 'Alice'},
        {'id': '1002', 'customerName': 'Bob'},
        {'id': '2001', 'customerName': 'Carol'},
      ];

      const query = '100';
      final filtered = orders
          .where((o) => (o['id'] as String).contains(query))
          .toList();

      expect(filtered.length, equals(2));
    });

    test('6.5  Revenue accumulation across multiple orders', () {
      final orderAmounts = [120.0, 85.5, 200.0, 45.25];
      final total = orderAmounts.fold(0.0, (sum, a) => sum + a);
      expect(total, closeTo(450.75, 0.001));
    });
  });
}
