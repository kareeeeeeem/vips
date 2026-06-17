import 'package:get/get.dart';

import '../controllers/main_app_controller.dart';

class MainAppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainAppController>(
      () => MainAppController(),
    );
  }
}
