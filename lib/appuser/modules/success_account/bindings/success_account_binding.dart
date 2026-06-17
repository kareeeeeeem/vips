import 'package:get/get.dart';

import '../controllers/success_account_controller.dart';

class SuccessAccountBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SuccessAccountController>(
      () => SuccessAccountController(),
    );
  }
}
