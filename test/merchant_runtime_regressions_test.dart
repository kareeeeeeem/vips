import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/modules/merchant_orders/domain/models/merchant_order_model.dart';
import 'package:vip/appmerchant/modules/merchant_dues/controllers/merchant_dues_controller.dart';
import 'package:vip/appmerchant/modules/merchant_dues/views/due_list_view.dart';
import 'package:vip/appmerchant/modules/merchant_gift_back/controllers/merchant_gift_back_controller.dart';
import 'package:vip/appmerchant/modules/merchant_gift_back/views/gift_back_form_view.dart';
import 'package:vip/appmerchant/modules/merchant_orders/controllers/merchant_order_controller.dart';
import 'package:vip/appmerchant/modules/merchant_orders/domain/services/merchant_order_service_interface.dart';
import 'package:vip/appmerchant/modules/merchant_orders/views/merchant_orders_view.dart';

class _OrderService extends Fake implements MerchantOrderServiceInterface {}

class _OrderController extends MerchantOrderController {
  _OrderController() : super(orderService: _OrderService());
  // No network loading is needed to exercise the filter sheet.
  // ignore: must_call_super
  @override
  void onInit() {}
}

class _DuesController extends MerchantDuesController {
  // Keep this layout fixture independent of network loading in onInit.
  // ignore: must_call_super
  @override
  void onInit() {}
}

class _GiftBackController extends MerchantGiftBackController {
  // Keep this layout fixture independent of network loading in onInit.
  // ignore: must_call_super
  @override
  void onInit() {}
}

void main() {
  testWidgets('all order filters fit and the clear button remains reachable', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    addTearDown(Get.reset);
    final orders = Get.put<MerchantOrderController>(_OrderController());
    orders.selectedStatusFilter.value = 'refunded';
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, child) => const GetMaterialApp(home: MerchantOrdersView()),
    ));
    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(FilterChip), findsNWidgets(orders.statusFilters.length));
    await tester.ensureVisible(find.text('Clear All Filters'));
    await tester.tap(find.text('Clear All Filters'));
    await tester.pumpAndSettle();
    expect(orders.selectedStatusFilter.value, 'all');
    expect(find.text('Filter Orders'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('gift back terms fit a narrow phone and consent is tappable', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    addTearDown(Get.reset);
    final gift = Get.put<MerchantGiftBackController>(_GiftBackController());
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, child) => const GetMaterialApp(home: GiftBackFormView()),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    expect(gift.customerConsented.value, isTrue);
    expect(tester.takeException(), isNull);
  });

  test('merchant order accepts the backend MongoDB customer identifier', () {
    const customerId = '64e3b7aedd89c520f0912a34';
    final order = MerchantOrder.fromJson({
      'id': 1001,
      'order_amount': 10,
      'customer': {'id': customerId, 'f_name': 'QA', 'l_name': 'Customer'},
    });
    expect(order.id, 1001);
    expect(order.customer?.id, customerId);
    expect(order.customer?.toJson()['id'], customerId);
  });

  testWidgets('dues summary renders and updates both balances', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    addTearDown(Get.reset);
    final dues = Get.put<MerchantDuesController>(_DuesController());
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, child) => const GetMaterialApp(home: DueListView()),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    dues.totalReceivable.value = 125;
    dues.totalPayable.value = 75;
    await tester.pump();
    expect(find.text('D 125.00'), findsOneWidget);
    expect(find.text('D 75.00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
