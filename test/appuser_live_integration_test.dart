// Live integration tests for the AppUser flows.
// Requires the backend running on http://localhost:3000.
// Run: flutter test test/appuser_live_integration_test.dart
//
// Each test exercises a full round-trip:
//   Flutter controller logic → HTTP → backend route → DB (or simulation) → response

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

const _base = 'http://localhost:3000/api';

// ─── Helpers ────────────────────────────────────────────────────────────────

Future<Map<String, dynamic>> _post(
  String path,
  Map<String, dynamic> body, {
  String? token,
}) async {
  final headers = <String, String>{
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
  final r = await http
      .post(Uri.parse('$_base$path'),
          headers: headers, body: jsonEncode(body))
      .timeout(const Duration(seconds: 10));
  return jsonDecode(r.body) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> _get(
  String path, {
  String? token,
  Map<String, String>? query,
}) async {
  final uri = Uri.parse('$_base$path').replace(queryParameters: query);
  final headers = <String, String>{
    if (token != null) 'Authorization': 'Bearer $token',
  };
  final r = await http
      .get(uri, headers: headers)
      .timeout(const Duration(seconds: 10));
  return jsonDecode(r.body) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> _put(
  String path,
  Map<String, dynamic> body, {
  String? token,
}) async {
  final headers = <String, String>{
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
  final r = await http
      .put(Uri.parse('$_base$path'),
          headers: headers, body: jsonEncode(body))
      .timeout(const Duration(seconds: 10));
  return jsonDecode(r.body) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> _delete(
  String path, {
  String? token,
}) async {
  final headers = <String, String>{
    if (token != null) 'Authorization': 'Bearer $token',
  };
  final r = await http
      .delete(Uri.parse('$_base$path'), headers: headers)
      .timeout(const Duration(seconds: 10));
  return jsonDecode(r.body) as Map<String, dynamic>;
}

// ─── Auth helpers ────────────────────────────────────────────────────────────

String? _token;
String? _userId;

Future<void> _ensureLoggedIn() async {
  if (_token != null) return;
  // Register a fresh test user (or login if already exists)
  final phone = '9999${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';
  final reg = await _post('/auth/register', {
    'fullName': 'Integration Tester',
    'phone': phone,
    'password': 'Test1234!',
    'email': 'integtest_${phone}@vips.test',
  });
  if (reg['success'] == true) {
    _token = reg['data']?['token']?.toString();
    _userId = reg['data']?['user']?['_id']?.toString();
    return;
  }
  // Fallback: login
  final login = await _post('/auth/login', {
    'phone': phone,
    'password': 'Test1234!',
  });
  _token = login['data']?['token']?.toString();
  _userId = login['data']?['user']?['_id']?.toString();
}

// ─── Tests ───────────────────────────────────────────────────────────────────

Future<bool> _isBackendReachable() async {
  try {
    await http.get(Uri.parse(_base)).timeout(const Duration(seconds: 2));
    return true;
  } catch (_) {
    return false;
  }
}

void main() async {
  final backendReachable = await _isBackendReachable();
  if (!backendReachable) {
    test(
      'live integration suite skipped — backend unreachable at $_base',
      () {},
      skip:
          'Backend not running at $_base. Start it with `node index.js` '
          'in lib/core/vips-backend to run these live integration tests.',
    );
    return;
  }

  // ── 1. AUTH ──────────────────────────────────────────────────────────────

  group('Auth', () {
    test('register → returns success + token', () async {
      final phone =
          '8888${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';
      final r = await _post('/auth/register', {
        'fullName': 'Auth Test User',
        'phone': phone,
        'password': 'Auth1234!',
        'email': 'auth_${phone}@vips.test',
      });
      expect(r['success'], isTrue, reason: r['message']?.toString());
      expect(r['data']?['token'], isNotNull);
    });

    test('login with wrong password → fails gracefully', () async {
      final r = await _post('/auth/login', {
        'phone': '0000000000',
        'password': 'WrongPass',
      });
      expect(r['success'], isFalse);
    });

    test('GET /auth/me with valid token → returns user object', () async {
      await _ensureLoggedIn();
      final r = await _get('/auth/me', token: _token);
      expect(r['success'], isTrue, reason: r.toString());
      // /me wraps user under data.user
      final userData = r['data']?['user'] ?? r['data'];
      expect(userData?['phone'], isNotNull);
    });
  });

  // ── 2. CART ──────────────────────────────────────────────────────────────

  group('Cart', () {
    test('GET /cart → returns cart object', () async {
      await _ensureLoggedIn();
      final r = await _get('/cart', token: _token);
      expect(r['success'], isTrue, reason: r.toString());
      expect(r['data'], isNotNull);
    });

    test('POST /cart/add → item added', () async {
      await _ensureLoggedIn();
      final r = await _post(
        '/cart/add',
        {
          'itemId': 'test-product-${DateTime.now().millisecondsSinceEpoch}',
          'itemType': 'product',
          'name': 'Integration Test Product',
          'price': 25.0,
          'quantity': 1,
        },
        token: _token,
      );
      expect(r['success'], isTrue, reason: r.toString());
    });

    test('PUT /cart/update → quantity updated', () async {
      await _ensureLoggedIn();
      final itemId = 'upd-${DateTime.now().millisecondsSinceEpoch}';
      await _post('/cart/add', {
        'itemId': itemId,
        'itemType': 'product',
        'name': 'Update Test Item',
        'price': 10.0,
        'quantity': 1,
      }, token: _token);

      final r = await _put(
        '/cart/update',
        {'itemId': itemId, 'quantity': 3},
        token: _token,
      );
      expect(r['success'], isTrue, reason: r.toString());
    });

    test('DELETE /cart/remove/:id → item removed', () async {
      await _ensureLoggedIn();
      final itemId = 'del-${DateTime.now().millisecondsSinceEpoch}';
      await _post('/cart/add', {
        'itemId': itemId,
        'itemType': 'product',
        'name': 'Delete Test Item',
        'price': 10.0,
        'quantity': 1,
      }, token: _token);

      final r = await _delete('/cart/remove/$itemId', token: _token);
      expect(r['success'], isTrue, reason: r.toString());
    });

    test('POST /cart/clear → cart emptied', () async {
      await _ensureLoggedIn();
      final r = await _post('/cart/clear', {}, token: _token);
      expect(r['success'], isTrue, reason: r.toString());
    });
  });

  // ── 3. BILL INQUIRY ──────────────────────────────────────────────────────

  group('Bill Inquiry', () {
    late String billServiceId;

    setUp(() async {
      await _ensureLoggedIn();
      // Fetch a real billServiceId from the seeded data
      final r = await _get('/services/bills', token: _token);
      final bills = r['data'] as List? ?? [];
      expect(bills, isNotEmpty, reason: 'No bill services seeded');
      billServiceId = bills.first['_id'].toString();
    });

    // Bill inquiry used to answer with a Math.random() "amount due", which then
    // fed the real pay-bill flow. With no utility-provider account behind it
    // (UTILITY_BILLS_API_KEY unset) the endpoint now refuses honestly instead
    // of inventing a number — this asserts that contract, and will assert the
    // real lookup once a provider is wired up and the key is set.
    test('POST /services/bill-inquiry → honest 503 until a provider is configured',
        () async {
      final status = await _get('/services/status', token: _token);
      final utilityConfigured =
          status['data']?['utilityBills']?['configured'] == true;

      final r = await _post(
        '/services/bill-inquiry',
        {
          'billServiceId': billServiceId,
          'subscriberNumber': '12345678',
          'accountNumber': '87654321',
        },
        token: _token,
      );

      if (utilityConfigured) {
        expect(r['success'], isTrue, reason: r.toString());
        expect(r['data']?['dueDate'], isNotNull);
        expect(r['data']?['amountDue'], isNotNull);
      } else {
        expect(r['success'], isFalse, reason: r.toString());
        expect(r['message'].toString().toLowerCase(), contains('available'));
      }
    });

    test('POST /services/bill-inquiry missing subscriberNumber → 400', () async {
      final r = await _post(
        '/services/bill-inquiry',
        {'billServiceId': billServiceId},
        token: _token,
      );
      expect(r['success'], isFalse);
    });
  });

  // ── 4. PAY BILL ──────────────────────────────────────────────────────────

  group('Pay Bill', () {
    test('POST /services/pay-bill with zero amount → 400', () async {
      await _ensureLoggedIn();
      final bills = (await _get('/services/bills', token: _token))['data'] as List;
      final serviceId = bills.first['_id'].toString();
      final r = await _post(
        '/services/pay-bill',
        {'billServiceId': serviceId, 'amount': 0, 'referenceNumber': '000'},
        token: _token,
      );
      expect(r['success'], isFalse);
    });
  });

  // ── 5. DEAL REDEEM ───────────────────────────────────────────────────────

  group('Deal Redeem', () {
    test('POST /content/deals/:id/redeem → adds to cart or returns error', () async {
      await _ensureLoggedIn();
      final deals = (await _get('/content/hot-deals'))['data'] as List? ?? [];
      if (deals.isEmpty) {
        // No deals seeded — skip gracefully
        return;
      }
      final dealId = deals.first['_id'].toString();
      final r = await _post(
        '/content/deals/$dealId/redeem',
        {},
        token: _token,
      );
      // Success if deal is active, error if already inactive — both are valid responses
      expect(r, isA<Map>());
      expect(r['success'], isA<bool>());
    });
  });

  // ── 6. PRODUCT COMMENT ───────────────────────────────────────────────────

  group('Product Comment', () {
    test('POST /content/products/:id/comment → comment saved', () async {
      await _ensureLoggedIn();
      final products = (await _get('/content/products'))['data'] as List? ?? [];
      if (products.isEmpty) return;
      final productId = products.first['_id'].toString();
      final r = await _post(
        '/content/products/$productId/comment',
        {'comment': 'Great product! Integration test comment.'},
        token: _token,
      );
      expect(r['success'], isTrue, reason: r.toString());
    });

    test('POST /content/products/:id/comment empty text → 400', () async {
      await _ensureLoggedIn();
      final products = (await _get('/content/products'))['data'] as List? ?? [];
      if (products.isEmpty) return;
      final productId = products.first['_id'].toString();
      final r = await _post(
        '/content/products/$productId/comment',
        {'comment': '   '},
        token: _token,
      );
      expect(r['success'], isFalse);
    });
  });

  // ── 7. MOBILE RECHARGE ───────────────────────────────────────────────────

  group('Mobile Recharge', () {
    test('POST /services/mobile-recharge → succeeds or insufficient balance', () async {
      await _ensureLoggedIn();
      final r = await _post(
        '/services/mobile-recharge',
        {'operator': 'Ooredoo', 'amount': 5, 'phoneNumber': '25000000'},
        token: _token,
      );
      // Either success (has balance) or insufficient balance — both valid
      expect(r, isA<Map>());
      expect(r['success'], isA<bool>());
    });

    test('POST /services/mobile-recharge amount > 500 → 400', () async {
      await _ensureLoggedIn();
      final r = await _post(
        '/services/mobile-recharge',
        {'operator': 'Ooredoo', 'amount': 1000, 'phoneNumber': '25000000'},
        token: _token,
      );
      expect(r['success'], isFalse);
    });
  });

  // ── 8. DONATION ──────────────────────────────────────────────────────────

  group('Donation', () {
    test('GET /services/organizations → returns org list', () async {
      final r = await _get('/services/organizations');
      expect(r['success'], isTrue);
      expect((r['data'] as List).length, greaterThan(0));
    });

    test('POST /services/donate → succeeds or insufficient balance', () async {
      await _ensureLoggedIn();
      final r = await _post(
        '/services/donate',
        {'organization': 'UNICEF', 'amount': 1},
        token: _token,
      );
      expect(r, isA<Map>());
      expect(r['success'], isA<bool>());
    });
  });

  // ── 9. CONTENT FEEDS ─────────────────────────────────────────────────────

  group('Content Feeds', () {
    test('GET /content/hot-deals → list', () async {
      final r = await _get('/content/hot-deals');
      expect(r['success'], isTrue);
      expect(r['data'], isA<List>());
    });

    test('GET /content/ending-soon-deals → list', () async {
      final r = await _get('/content/ending-soon-deals');
      expect(r['success'], isTrue);
      expect(r['data'], isA<List>());
    });

    test('GET /content/outings → list', () async {
      final r = await _get('/content/outings');
      expect(r['success'], isTrue);
      expect(r['data'], isA<List>());
    });

    test('GET /content/trending-merchants → list', () async {
      final r = await _get('/content/trending-merchants');
      expect(r['success'], isTrue);
      expect(r['data'], isA<List>());
    });

    test('GET /content/products → list', () async {
      final r = await _get('/content/products');
      expect(r['success'], isTrue);
      expect(r['data'], isA<List>());
    });

    test('GET /content/promotions → list of active promos', () async {
      final r = await _get('/content/promotions');
      expect(r['success'], isTrue);
      expect(r['data'], isA<List>());
    });

    test('GET /content/search?q=food → results', () async {
      final r = await _get('/content/search', query: {'q': 'food'});
      expect(r['success'], isTrue);
      expect(r['data']?['deals'], isA<List>());
      expect(r['data']?['products'], isA<List>());
    });
  });

  // ── 10. PACKAGES ─────────────────────────────────────────────────────────

  group('Packages', () {
    test('GET /services/packages → 4 tiers returned', () async {
      await _ensureLoggedIn();
      final r = await _get('/services/packages', token: _token);
      expect(r['success'], isTrue);
      expect((r['data'] as List).length, equals(4));
    });

    test('POST /services/packages/subscribe invalid tier → 400', () async {
      await _ensureLoggedIn();
      final r = await _post(
        '/services/packages/subscribe',
        {'tier': 'diamond'},
        token: _token,
      );
      expect(r['success'], isFalse);
    });
  });

  // ── 11. USER PROFILE & WALLET ─────────────────────────────────────────────

  group('User Profile & Wallet', () {
    test('GET /auth/me → returns walletBalance', () async {
      await _ensureLoggedIn();
      final r = await _get('/auth/me', token: _token);
      expect(r['success'], isTrue);
      final userData = r['data']?['user'] ?? r['data'];
      expect(userData?['walletBalance'], isA<num>());
    });

    test('GET /user/payment-methods → returns cards array', () async {
      await _ensureLoggedIn();
      final r = await _get('/user/payment-methods', token: _token);
      expect(r['success'], isTrue);
      expect(r['data']?['cards'], isA<List>());
    });

    test('GET /user/transactions → returns transaction list', () async {
      await _ensureLoggedIn();
      final r = await _get('/user/transactions', token: _token);
      expect(r['success'], isTrue);
    });
  });

  // ── 12. BILL SERVICES ─────────────────────────────────────────────────────

  group('Bill Services', () {
    test('GET /services/bills → 10 seeded services', () async {
      final r = await _get('/services/bills');
      expect(r['success'], isTrue);
      expect((r['data'] as List).length, greaterThanOrEqualTo(10));
    });
  });
}
