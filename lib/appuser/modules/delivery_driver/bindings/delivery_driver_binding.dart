import 'package:get/get.dart';

import '../controllers/delivery_driver_controller.dart';

class DeliveryDriverBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryDriverController>(
      () => DeliveryDriverController(),
    );
  }
}
