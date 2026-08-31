import 'package:get/get.dart';

import '../controllers/pos_controller.dart';
import '../controllers/pos_customers_controller.dart';
import '../controllers/pos_invoices_controller.dart';

class PosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PosController>(() => PosController());
  }
}

class PosInvoicesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PosInvoicesController>(() => PosInvoicesController());
  }
}


class PosCustomersBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => PosCustomersController());
}
