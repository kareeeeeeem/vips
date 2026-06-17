import 'package:get/get.dart';

import '../controllers/bills_controller.dart';

class BillsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BillsController>(
      () => BillsController(),
    );
  }
}
