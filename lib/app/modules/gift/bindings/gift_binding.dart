import 'package:get/get.dart';

import '../controllers/gift_controller.dart';

class GiftBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GiftController>(
      () => GiftController(),
    );
  }
}
