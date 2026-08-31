import 'package:get/get.dart';

import '../controllers/products_controller.dart';

class AdminProductsBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => AdminProductsController());
}
