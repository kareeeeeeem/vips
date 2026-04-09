import 'package:get/get.dart';

import '../controllers/pay_bills_controller.dart';

class PayBillsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PayBillsController>(
      () => PayBillsController(),
    );
  }
}
