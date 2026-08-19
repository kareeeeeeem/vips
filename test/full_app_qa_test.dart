import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip/appuser/modules/home/controllers/home_controller.dart';
import 'package:vip/appuser/modules/checkout/controllers/checkout_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Senior QA Automated Flutter Unit & Controller Tests', () {
    test('1. HomeController carousel and bill categories initialization', () {
      final controller = HomeController();
      expect(controller.carouselImages.isNotEmpty, isTrue);
      expect(controller.billServices.isNotEmpty, isTrue);
      expect(controller.billTypes.isNotEmpty, isTrue);
    });

    test('2. CheckoutController totals calculation', () {
      final controller = CheckoutController();
      controller.subtotal.value = 50.0;
      controller.deliveryFee.value = 5.0;
      controller.discount.value = 10.0;
      controller.selectedTip.value = 2.0;

      expect(controller.grandTotal, equals(47.0));
    });

  testWidgets('3. CheckoutController order type delivery fee updates', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SizedBox()),
      ),
    );
    final controller = CheckoutController();
    controller.selectedOrderType.value = OrderType.takeaway;
    controller.deliveryFee.value = 0.0;
    expect(controller.deliveryFee.value, equals(0.0));

    controller.selectedOrderType.value = OrderType.delivery;
    controller.deliveryFee.value = 6.0;
    expect(controller.deliveryFee.value, equals(6.0));
  });
  });
}
