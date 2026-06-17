import 'package:get/get.dart';

import '../controllers/delivery_order_details_controller.dart';

class DeliveryOrderDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryOrderDetailsController>(
      () => DeliveryOrderDetailsController(),
    );
  }
}
