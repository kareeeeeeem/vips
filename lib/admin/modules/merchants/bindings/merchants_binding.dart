import 'package:get/get.dart';

import '../controllers/merchants_controller.dart';

class AdminMerchantsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminMerchantsController>(() => AdminMerchantsController());
  }
}
