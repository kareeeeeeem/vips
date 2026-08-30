import 'package:get/get.dart';

import '../controllers/orders_controller.dart';

class AdminOrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminOrdersController>(() => AdminOrdersController());
  }
}
