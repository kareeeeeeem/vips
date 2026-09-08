import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:vip/main_merchant.dart' as app;
import 'package:vip/core/services/api_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
  }

  testWidgets('merchant creates a QR bill and records its cash settlement', (tester) async {
    const base = String.fromEnvironment('API_BASE_URL');
    const token = String.fromEnvironment('QA_TOKEN');
    expect(Uri.parse(base).host, anyOf('localhost', '127.0.0.1'));
    expect(token, isNotEmpty);
    SharedPreferences.setMockInitialValues({'auth_token': token, 'token': token});
    app.main();
    await tester.pump(const Duration(seconds: 4));
    await settle(tester);
    Get.offAllNamed('/merchant-home');
    await settle(tester);
    Get.toNamed('/merchant-create-bill');
    await settle(tester);
    for (final digit in ['1', '2', '.', '5']) {
      await tester.tap(find.text(digit));
      await tester.pump();
    }
    await tester.tap(find.text('Generate QR Code'));
    await settle(tester);
    expect(Get.currentRoute, '/bill-scan-me');
    final args = Map<String, dynamic>.from(Get.arguments as Map);
    expect(args['payCode'], isNotEmpty);
    final billId = args['billId'] as String;
    expect(billId, isNotEmpty);
    final pending = await ApiService().get('/merchant/billing/$billId');
    expect(pending.success, isTrue);
    expect(pending.data['grandTotal'], 12.5);
    expect(pending.data['paymentStatus'], 'pending');
    expect(pending.data['paidAmount'], 0);
    expect(tester.takeException(), isNull);

    // This records a synthetic cash payment; it calls no payment provider.
    await tester.ensureVisible(find.text('Mark as Paid'));
    await tester.tap(find.text('Mark as Paid'));
    await settle(tester);
    final paid = await ApiService().get('/merchant/billing/$billId');
    expect(paid.success, isTrue);
    expect(paid.data['paymentStatus'], 'paid');
    expect(paid.data['paidAmount'], 12.5);
    expect(Get.currentRoute, '/merchant-create-bill');
    expect(tester.takeException(), isNull);
  });
}
