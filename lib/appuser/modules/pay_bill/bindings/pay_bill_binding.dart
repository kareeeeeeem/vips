import 'package:get/get.dart';

import '../controllers/pay_bill_controller.dart';

class PayBillBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => PayBillController());
}
