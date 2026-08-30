import 'package:get/get.dart';

import '../controllers/pos_controller.dart';
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
