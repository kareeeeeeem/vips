import 'package:get/get.dart';

import '../controllers/credit_controller.dart';

class CreditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreditController>(
      () => CreditController(),
    );
  }
}
