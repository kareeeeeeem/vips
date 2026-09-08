import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:vip/main.dart' as app;
import 'package:vip/core/services/api_service.dart';
import 'package:vip/appuser/modules/home/controllers/home_controller.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
  }

  testWidgets('customer signs in and adds a real catalogue product using buttons', (tester) async {
    const base = String.fromEnvironment('API_BASE_URL');
    const fixtureToken = String.fromEnvironment('QA_TOKEN');
    const productId = String.fromEnvironment('QA_PRODUCT_ID');
    expect(Uri.parse(base).host, anyOf('localhost', '127.0.0.1'));
    expect(fixtureToken, isNotEmpty);
    SharedPreferences.setMockInitialValues({});
    app.main();
    await tester.pump(const Duration(seconds: 4));
    await settle(tester);
    await ApiService().setToken(fixtureToken);
    expect((await ApiService().post('/auth/pin', {'pin': '1234'})).success, isTrue);
    expect((await ApiService().post('/cart/clear', {})).success, isTrue);
    await ApiService().clearToken();
    Get.offAllNamed('/login');
    await settle(tester);
    await tester.enterText(find.byType(TextField).at(0), 'customer@vips.test');
    await tester.enterText(find.byType(TextField).at(1), 'UiTest123!');
    FocusManager.instance.primaryFocus?.unfocus();
    await settle(tester);
    await tester.ensureVisible(find.text('Sign In'));
    await tester.tap(find.text('Sign In'));
    await settle(tester);
    expect(Get.currentRoute, '/main-app');
    expect(ApiService().isLoggedIn, isTrue);
    // Reproduce the route replacement that failed in the previous device walk.
    Get.toNamed('/login');
    await settle(tester);
    await tester.ensureVisible(find.text('Continue as Guest'));
    await tester.tap(find.text('Continue as Guest'));
    await settle(tester);
    expect(Get.currentRoute, '/main-app');
    expect(Get.find<HomeController>(), isA<HomeController>());
    expect(tester.takeException(), isNull);
    Get.toNamed('/login');
    await settle(tester);
    await tester.enterText(find.byType(TextField).at(0), 'customer@vips.test');
    await tester.enterText(find.byType(TextField).at(1), 'UiTest123!');
    FocusManager.instance.primaryFocus?.unfocus();
    await settle(tester);
    await tester.ensureVisible(find.text('Sign In'));
    await tester.tap(find.text('Sign In'));
    await settle(tester);
    expect(Get.currentRoute, '/main-app');
    expect(ApiService().isLoggedIn, isTrue);
    for (final label in ['Offers', 'Digital', 'Account', 'Home']) {
      await tester.tap(find.text(label).last);
      await settle(tester);
      expect(tester.takeException(), isNull);
    }
    Get.toNamed('/deal-details', arguments: <String, dynamic>{
      '_id': productId, 'type': 'product', 'name': 'QA Coffee', 'price': 10.0,
      'description': 'Synthetic UI test product',
      'merchantId': const String.fromEnvironment('QA_MERCHANT_ID'),
    });
    await settle(tester);
    await tester.tap(find.text('Add to Cart'));
    await settle(tester);
    final cart = await ApiService().get('/cart');
    expect(cart.success, isTrue);
    final items = (cart.data as List).where((item) => item['itemId'] == productId).toList();
    expect(items, hasLength(1));
    expect(items.single['price'], 10);
    expect(items.single['quantity'], 1);
    expect(Get.currentRoute, '/cart');
    expect(find.text('QA Coffee'), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byIcon(Icons.add).first);
    await tester.tap(find.byIcon(Icons.add).first);
    await settle(tester);
    final increased = await ApiService().get('/cart');
    expect((increased.data as List).single['quantity'], 2);
    await tester.tap(find.byIcon(Icons.remove).first);
    await settle(tester);
    final decreased = await ApiService().get('/cart');
    expect((decreased.data as List).single['quantity'], 1);
    await tester.tap(find.text('Place Order'));
    await settle(tester);
    expect(Get.currentRoute, '/checkout');
    await tester.ensureVisible(find.text('Takeaway'));
    await tester.tap(find.text('Takeaway'));
    await settle(tester);
    final beforeOrders = await ApiService().get('/order/history');
    await tester.tap(find.text('Place Order'));
    await settle(tester);
    final orders = await ApiService().get('/order/history');
    expect(orders.success, isTrue);
    expect((orders.data as List).length, (beforeOrders.data as List).length + 1);
    final created = (orders.data as List).first as Map;
    expect(created['totalAmount'], 10);
    expect(created['orderType'], 'takeaway');
    expect((created['items'] as List).single['productId'], productId);
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(minutes: 8)));
}
