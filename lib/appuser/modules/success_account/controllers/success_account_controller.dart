import 'package:get/get.dart';
import 'package:vip/appuser/routes/app_pages.dart';

class SuccessAccountController extends GetxController {
  void goToHome() {
    Get.offAllNamed(Routes.MAIN_APP);
  }
}
