import 'package:get/get.dart';

import '../controllers/createpin_controller.dart';

class CreatepinBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreatepinController>(
      () => CreatepinController(),
    );
  }
}
