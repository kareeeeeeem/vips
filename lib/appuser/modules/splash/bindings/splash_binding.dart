import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Get.put (not lazyPut): SplashView never reads `controller`, so a lazy
    // registration is never resolved and onInit()/startTimer() never runs,
    // leaving the app stuck on the splash screen forever.
    Get.put<SplashController>(SplashController());
  }
}
