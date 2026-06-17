import 'package:get/get.dart';
import 'package:vip/appuser/modules/main_app/views/main_app_view.dart';

class SuccessAccountController extends GetxController {
  //TODO: Implement SuccessAccountController

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  goToHome() {
    Get.off(() => MainAppView());
  }

  void increment() => count.value++;
}
