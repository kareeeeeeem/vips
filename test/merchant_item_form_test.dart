import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vip/appmerchant/modules/merchant_catalog/controllers/merchant_catalog_controller.dart';
import 'package:vip/appmerchant/modules/merchant_catalog/views/create_item_view.dart';

class _FormController extends MerchantCatalogController {
  // Keep this layout fixture independent of network loading in onInit.
  // ignore: must_call_super
  @override
  void onInit() {}
}

void main() {
  testWidgets(
    'editing preserves product terms and typed changes across resize',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      addTearDown(Get.reset);
      final controller = Get.put<MerchantCatalogController>(_FormController());
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder:
              (_, child) => GetMaterialApp(
                home: const Scaffold(),
                getPages: [
                  GetPage(name: '/edit', page: () => const CreateItemView()),
                ],
              ),
        ),
      );
      Get.toNamed(
        '/edit',
        arguments: {
          '_id': 'fixture',
          'name': 'Existing product',
          'price': 25,
          'discountPrice': 20,
          'category': 'Food',
          'taxMethod': 'Inclusive',
          'productType': 'Service',
          'hasVariants': true,
          'isActive': false,
        },
      );
      await tester.pumpAndSettle();
      expect(controller.itemPromoPriceCtrl.text, '20');
      expect(controller.hasPromotionalPrice.value, isTrue);
      expect(controller.selectedTaxMethod.value, 'Inclusive');
      expect(controller.selectedItemType.value, 'Service');
      expect(controller.hasMultiVariants.value, isTrue);
      expect(controller.isPublished.value, isFalse);
      controller.itemNameCtrl.text = 'Changed name';
      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpAndSettle();
      expect(controller.itemNameCtrl.text, 'Changed name');
      expect(tester.takeException(), isNull);
      Get.back();
      await tester.pumpAndSettle();
      Get.toNamed('/edit');
      await tester.pumpAndSettle();
      expect(controller.itemNameCtrl.text, isEmpty);
      expect(controller.itemPromoPriceCtrl.text, isEmpty);
      expect(controller.selectedTaxMethod.value, 'Exclusive');
      expect(controller.selectedItemType.value, 'Product');
      expect(controller.selectedCategory.value, 'Select');
      expect(tester.takeException(), isNull);
    },
  );
}
