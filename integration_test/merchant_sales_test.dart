import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:vip/main_merchant.dart' as app;
import 'package:vip/core/services/api_service.dart';
import 'package:vip/appmerchant/modules/merchant_catalog/controllers/merchant_catalog_controller.dart';
import 'package:vip/appmerchant/modules/merchant_orders/controllers/merchant_order_controller.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
  }

  testWidgets('merchant signs in, edits product terms and reads real orders', (
    tester,
  ) async {
    const base = String.fromEnvironment('API_BASE_URL');
    expect(Uri.parse(base).host, anyOf('localhost', '127.0.0.1'));
    SharedPreferences.setMockInitialValues({});
    app.main();
    await tester.pump(const Duration(seconds: 4));
    await settle(tester);
    Get.offAllNamed('/merchant-login');
    await settle(tester);
    await tester.enterText(find.byType(TextField).at(0), 'merchant@vips.test');
    await tester.enterText(find.byType(TextField).at(1), 'UiTest123!');
    FocusManager.instance.primaryFocus?.unfocus();
    await settle(tester);
    await tester.ensureVisible(find.text('Sign in'));
    await tester.tap(find.text('Sign in'));
    await settle(tester);
    expect(Get.currentRoute, '/merchant-home');
    expect(ApiService().isLoggedIn, isTrue);

    final api = ApiService();
    final created = await api.post('/merchant/products', {
      'name': 'QA editable product',
      'price': 25,
      'discountPrice': 20,
      'category': 'Food',
      'taxMethod': 'Inclusive',
      'vat': 10,
      'productType': 'Service',
      'description': 'Preserve this description',
    });
    expect(created.success, isTrue);
    final product = Map<String, dynamic>.from(created.data as Map);
    final id = product['_id'].toString();
    addTearDown(() async {
      await api.delete('/merchant/products/$id');
    });
    Get.toNamed('/create-item', arguments: product);
    await settle(tester);
    final catalog = Get.find<MerchantCatalogController>();
    expect(catalog.itemPromoPriceCtrl.text, '20');
    expect(catalog.selectedTaxMethod.value, 'Inclusive');
    expect(catalog.selectedItemType.value, 'Service');
    final nameField = find.byWidgetPredicate(
      (w) => w is TextField && identical(w.controller, catalog.itemNameCtrl),
    );
    await tester.enterText(nameField, 'QA renamed product');
    FocusManager.instance.primaryFocus?.unfocus();
    await settle(tester);
    await tester.tap(find.text('Save Changes'));
    await settle(tester);
    expect(Get.currentRoute, '/merchant-catalog');
    final saved = await api.get('/merchant/products');
    expect(saved.success, isTrue);
    final persisted = (saved.data as List).singleWhere((p) => p['_id'] == id);
    expect(persisted['name'], 'QA renamed product');
    expect(persisted['discountPrice'], 20);
    expect(persisted['taxMethod'], 'Inclusive');
    expect(persisted['productType'], 'Service');
    expect(persisted['description'], 'Preserve this description');

    Get.until((r) => r.settings.name == '/merchant-home' || r.isFirst);
    Get.toNamed('/merchant-orders');
    await settle(tester);
    final orders = Get.find<MerchantOrderController>();
    await orders.loadOrders();
    await settle(tester);
    expect(orders.status.value, MerchantOrderViewStatus.success);
    expect(
      orders.orders,
      isNotEmpty,
      reason: 'The customer checkout fixture must exist',
    );
    expect(orders.orders.first.customer?.id, isNotEmpty);
    expect(tester.takeException(), isNull);
  });
}
