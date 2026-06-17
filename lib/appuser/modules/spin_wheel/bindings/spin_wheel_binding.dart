import 'package:get/get.dart';

import '../controllers/spin_wheel_controller.dart';

class SpinWheelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SpinWheelController>(
      () => SpinWheelController(),
    );
  }
}
