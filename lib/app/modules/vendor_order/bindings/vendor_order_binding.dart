import 'package:get/get.dart';

import '../controllers/vendor_order_controller.dart';

class VendorOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorOrderController>(
      () => VendorOrderController(),
    );
  }
}
